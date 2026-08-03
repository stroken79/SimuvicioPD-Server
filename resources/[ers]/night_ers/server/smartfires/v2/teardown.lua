-- ============================================================================
--  SFV2.Teardown — single cleanup path for a callout's fires and smokes.
-- ============================================================================
--  Replaces the three overlapping paths the old bridge had (`SANITIZE`,
--  `STOP_GONE_FX`, `SPAWN_CLEANUP`). After Phase 1 SmartFires patches:
--      - `StopFire(id)` is idempotent and broadcasts `fire:cl:stopBySource`.
--      - `fire:cl:stopBySource` clears every visual whose `incidentId` or
--        `sourceIncidentId` is in the passed list.
--
--  So teardown is just: stop every registered spawn id, then broadcast one
--  `fire:cl:stopBySource` covering everything (defence-in-depth in case the
--  patched server emit gets missed).
-- ============================================================================

if not IsDuplicityVersion() then return end

SFV2 = SFV2 or {}

local SF_RES = 'SmartFires'

local function log(step, detail)
    if not (SFV2 and SFV2.IsDebug and SFV2.IsDebug()) then return end
    print('[ERS-SF] ' .. step .. (detail and (' | ' .. detail) or ''))
end

local function collectIdSet(callout)
    local set = {}
    if not callout then return set end
    for _, id in ipairs(callout.sfAllSpawnIds or {}) do
        if id ~= nil then set[tostring(id)] = true end
    end
    for _, id in ipairs(callout.fireList or {}) do
        if id ~= nil then set[tostring(id)] = true end
    end
    -- Also include live host ids from the latest scope (spread).
    local scope = SFV2.GetCalloutScope(callout)
    if scope then
        for _, hostId in ipairs(scope.hostIds) do
            set[tostring(hostId)] = true
        end
    end
    return set
end

--- Public: stop every fire belonging to this callout. Idempotent.
function SFV2.Teardown(callout, cancelSrc)
    if not callout then return false end
    if GetResourceState(SF_RES) ~= 'started' then return false end

    local ids = collectIdSet(callout)
    local list = {}
    for id in pairs(ids) do list[#list + 1] = id end

    -- Snapshot vehicle fires currently in callout scope BEFORE we invalidate.
    -- Ambient mode = we don't own these, but the user opted into force-stop
    -- on cancel; we filter to `scope.vehicleFires` (scene-radius gated) to
    -- minimise collateral. A vehicle fire that another player's callout also
    -- has in scope will still be force-stopped here.
    local vehList = {}
    if SFV2 and SFV2.GetCalloutScope then
        local scope = SFV2.GetCalloutScope(callout)
        if scope and scope.vehicleFires then
            for _, vrow in ipairs(scope.vehicleFires) do
                if vrow.vehNet then
                    vehList[#vehList + 1] = vrow.vehNet
                end
            end
        end
    end

    -- Stop on the server (this also broadcasts fire:cl:stopBySource per patch).
    for i = 1, #list do
        pcall(function() exports[SF_RES]:StopFire(list[i]) end)
        SFV2.ForgetSpawnId(list[i])
    end

    -- Force-extinguish vehicle fires that were inside scope. SmartFires fires
    -- its own client-side teardown (`fire:cl:stopVehicleFire`) from
    -- `StopVehicleIncident`, so no defensive broadcast is needed here.
    for i = 1, #vehList do
        pcall(function() exports[SF_RES]:StopVehicleIncident(vehList[i]) end)
    end

    -- Defence-in-depth: one extra broadcast in case a server emit was missed.
    if #list > 0 then
        TriggerClientEvent('fire:cl:stopBySource', -1, list, true)
    end

    log('TEARDOWN', string.format('callout=%s ids=%d veh=%d src=%s',
        tostring(callout.calloutId), #list, #vehList, tostring(cancelSrc)))

    -- Reset callout fire/smoke registries.
    callout.fireList = {}
    callout.sfAllSpawnIds = {}
    callout.sfSpawnCoordsById = {}
    SFV2.InvalidateScope(callout)
    SFV2.ResetHud(callout)

    -- Smokes: stop each registered id. `callout.smokeList` is a mixed bag:
    --   • Callouts that use the public `ERS_AddCalloutSmoke` bridge helper
    --     append the raw id (string for V2, e.g. `"s12"`).
    --   • The internal `SFV2.SpawnSmoke` path appends `{ smokeId = id }` tables.
    -- We have to accept both shapes here, otherwise raw-id entries silently
    -- escape teardown and the smoke keeps burning past callout cancel.
    if type(callout.smokeList) == 'table' then
        for i = 1, #callout.smokeList do
            local entry = callout.smokeList[i]
            local sid
            if type(entry) == 'table' then
                sid = entry.smokeId or entry.id
            else
                sid = entry
            end
            if sid ~= nil then
                pcall(function() exports[SF_RES]:StopSmoke(sid) end)
            end
        end
        callout.smokeList = {}
    end

    return true
end

--- Stop one spawn id and remove it from the callout registry. Used by NPC
--- backup when a spawn is fully extinguished mid-callout.
function SFV2.StopSpawn(callout, incidentId)
    if not callout or incidentId == nil then return end
    local key = tostring(incidentId)
    pcall(function() exports[SF_RES]:StopFire(key) end)
    -- Drop from fireList; keep sfAllSpawnIds (append-only by design).
    if type(callout.fireList) == 'table' then
        for i = #callout.fireList, 1, -1 do
            if callout.fireList[i] ~= nil and tostring(callout.fireList[i]) == key then
                table.remove(callout.fireList, i)
            end
        end
    end
    SFV2.ForgetSpawnId(key)
    SFV2.InvalidateScope(callout)
end
