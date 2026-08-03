-- ============================================================================
--  SFV2 server events + AttachCallout / Poll orchestration.
-- ============================================================================
--  Two new net events define the entire client/server contract:
--
--    EventPrefix .. ':sfv2_calloutScope'  (server -> client)
--      payload: full ActiveCalloutsList (clients mirror it for HUD/NPC counts).
--
--    EventPrefix .. ':sfv2_purgeRequest'  (client -> server)
--      payload: array of spawn ids the client cannot account for.
--
--  Old events (`sfPurgeSpawnVisuals`, `sfNativeFireSweep`, `sfRequestSpawnCleanup`,
--  `sfRequestGoneFxSweep`) are no longer emitted by the v2 path. The bridge
--  keeps stubs for the duration of the migration so any straggler caller is a
--  no-op rather than an error.
-- ============================================================================

if not IsDuplicityVersion() then return end

SFV2 = SFV2 or {}

local SF_RES = 'SmartFires'

local function log(step, detail)
    if not (SFV2 and SFV2.IsDebug and SFV2.IsDebug()) then return end
    print('[ERS-SF] ' .. step .. (detail and (' | ' .. detail) or ''))
end

-- ---------------------------------------------------------------------------
--  AttachCallout / Poll
-- ---------------------------------------------------------------------------

--- Called once when a callout's fire/smoke entity lists are inserted into
--- `ActiveCalloutsList`. Syncs the spawn registry from `callout.fireList`,
--- resets HUD tracking, broadcasts the initial scope.
function SFV2.AttachCallout(callout)
    if not callout then return end
    callout.sfAllSpawnIds = callout.sfAllSpawnIds or {}
    callout.sfSpawnCoordsById = callout.sfSpawnCoordsById or {}
    -- Make sure every CreateFire id from the plugin is registered.
    for _, id in ipairs(callout.fireList or {}) do
        if id ~= nil then
            local coords = SFV2.GetSpawnCoords(id)
            SFV2.RegisterSpawnId(callout, id, coords)
        end
    end
    SFV2.ResetHud(callout)
    SFV2.AdvanceScopeTick()
    SFV2.InvalidateScope(callout)
    SFV2.GetHudCounts(callout)  -- prime baseline
    log('ATTACH', string.format('callout=%s spawns=%d',
        tostring(callout.calloutId),
        callout.sfAllSpawnIds and #callout.sfAllSpawnIds or 0))
end

--- Called by the server poll loop (5s). Refreshes scope, picks up new spread
--- hosts, updates HUD counts. Returns the scope so callers can decide whether
--- to push the callout list to clients.
function SFV2.Poll(callout)
    if not callout then return nil end
    SFV2.AdvanceScopeTick()
    SFV2.InvalidateScope(callout)
    local addedHosts = SFV2.AppendSpreadHostsToCallout(callout)
    -- Self-heal `callout.smokeList`: prune entries SmartFires no longer knows
    -- about. Smoke can be killed outside the ERS `:stopSmoke` event path —
    -- admin `/stopsmoke`, source-fire auto-clear, or (if anyone toggles off
    -- `suppressDuringNightErsCallout`) the SmartFires investigate prompt —
    -- and without this prune the HUD shows a phantom `Clear the area of smoke`
    -- task forever and NPC backup keeps logging `NPC smoke skip | already gone`.
    -- `ERS_SmartFires_V2PruneGoneSmokeSlots` normalises both id shapes itself.
    local prunedSmokes = 0
    if type(callout.smokeList) == 'table'
        and type(ERS_SmartFires_V2PruneGoneSmokeSlots) == 'function'
    then
        prunedSmokes = ERS_SmartFires_V2PruneGoneSmokeSlots(callout.smokeList) or 0
    end
    local scope = SFV2.GetCalloutScope(callout)
    SFV2.GetHudCounts(callout)
    -- Track scope size between polls; broadcast only when it changes. Treat a
    -- smoke prune as a scope change so the client mirror of `smokeList` (which
    -- the HUD numerator reads as `#smokeList`) updates on the same broadcast.
    local liveN = scope and #scope.liveNodes or 0
    local prev = callout._sfPrevLive
    callout._sfPrevLive = liveN
    callout._sfScopeChanged = (prev ~= liveN) or (addedHosts > 0) or (prunedSmokes > 0)
    return scope
end

--- True when the last `SFV2.Poll` saw the scope change. Server.lua uses this
--- to decide whether to TriggerClientEvent the callout list.
function SFV2.ScopeChanged(callout)
    return callout and callout._sfScopeChanged == true
end

-- ---------------------------------------------------------------------------
--  Net events
-- ---------------------------------------------------------------------------

local function findCalloutByFireIds(ids)
    if type(ids) ~= 'table' or not ActiveCalloutsList then return nil end
    local set = {}
    for _, id in ipairs(ids) do
        if id ~= nil then set[tostring(id)] = true end
    end
    for _, callout in ipairs(ActiveCalloutsList) do
        for _, id in ipairs(callout.sfAllSpawnIds or {}) do
            if id ~= nil and set[tostring(id)] then return callout end
        end
        for _, id in ipairs(callout.fireList or {}) do
            if id ~= nil and set[tostring(id)] then return callout end
        end
    end
    return nil
end

--- Client says "I see these ids burning that I cannot account for." Re-emit
--- the scope so they re-sync, and broadcast a defensive purge for those ids.
RegisterNetEvent(Config.EventPrefix .. ':sfv2_purgeRequest')
AddEventHandler(Config.EventPrefix .. ':sfv2_purgeRequest', function(spawnIds)
    if not UsingSmartFiresV2 then return end
    if type(spawnIds) ~= 'table' or #spawnIds < 1 then return end
    local callout = findCalloutByFireIds(spawnIds)
    if not callout then return end
    -- One belt-and-braces broadcast — `fire:cl:stopBySource` is idempotent.
    TriggerClientEvent('fire:cl:stopBySource', -1, spawnIds, true)
    SFV2.AdvanceScopeTick()
    SFV2.InvalidateScope(callout)
    TriggerClientEvent(Config.EventPrefix .. ':sfv2_calloutScope', -1, ActiveCalloutsList)
    log('PURGE_REQUEST', string.format('callout=%s ids=%d',
        tostring(callout.calloutId), #spawnIds))
end)
