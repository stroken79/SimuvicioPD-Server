-- ============================================================================
--  Smart Fires v2 (London Studios — incident lifecycle release) bridge
-- ============================================================================
--  The bulk of ERS's Smart Fires integration. Active when the convar
--  `SmartFiresV2` is truthy AND the `SmartFires` resource is running
--  (see `server.lua` `ERS_ApplySmartFiresIntegrationFlagsFromConvars`).
--
--  Layout overview:
--    - State + helpers ............... incident seed counts, spawn-coord
--                                       registry, row classifiers, gap pacer
--    - HUD machinery ................. baseline lock, count, refresh
--    - Scope / discovery ............. enumerate, sync, append spread hosts,
--                                       fire-row map normalizer
--    - Spawn / sanitize / teardown ... CreateFire validate, sanitize fireList,
--                                       broadcast cleanup, near sweep
--    - NPC node tasks ................ build per-node task, remove flame node,
--                                       complete-node lifecycle
--    - Net events .................... sfNpcApplyFireDamageAtCoords,
--                                       sfRequestSpawnCleanup, sfRequestGoneFxSweep
--    - V2 dispatcher entry points .... ERS_SmartFires_V2_CreateFireAtCoords,
--                                       _StopFire, etc. — called from the
--                                       top-level bridge.
--
--  Sibling V2 modules under `server/smartfires/v2/`:
--    scope.lua, hud.lua, spawn.lua, npc.lua, teardown.lua, events.lua —
--    the SFV2.* contract (see `shared/smartfires_v2_contract.lua`).
--
--  The top-level `server/smartfires/bridge.lua` dispatches version-agnostic
--  calls (`ERS_SmartFires_CreateFireAtCoords`, `_StopFire`, etc.) into the
--  `ERS_SmartFires_V2_*` entry points exported below; v1 and Lite live in
--  their own bridge files.
--
--  Do NOT add v1 or Lite logic here. Add it under `server/smartfires/v1/`
--  or `server/smartfires/lite/` instead.
-- ============================================================================

local SF_RES = 'SmartFires'

-- ============================================================================
--  V2 state + low-level helpers
-- ============================================================================

local sfIncidentSeedCounts = {}
local sfSpawnCoordsByIncident = {}
local sfLastV2CreateMs = 0
-- Inter-spawn throttle. The real client-side rate protection lives in
-- SmartFires (cl_outdoors.lua seed queue + per-master Wait); this gap only
-- needs to be enough for GetIncidentStatus polling to settle.
local V2_CREATE_MIN_GAP_MS = 600
local V2_CREATE_VALIDATE_TIMEOUT_MS = 800
local V2_CREATE_VALIDATE_STEP_MS = 50
local V2_HUD_LOCK_MIN_WAIT_MS = 8000
local V2_HUD_LOCK_MAX_WAIT_MS = 28000
local V2_HUD_LOCK_STABLE_POLLS = 2

--- Default radius (m) for v2 spread discovery at a callout.
function ERS_SmartFires_V2DefaultSceneRadius()
    return 200.0
end

--- Wider radius (m) for callout cancel — wildfire spread can exceed HUD discovery range.
function ERS_SmartFires_V2TeardownSweepRadius()
    return 750.0
end

local function v2BuildCalloutIdSet(fireList)
    local set = {}
    if type(fireList) ~= 'table' then
        return set
    end
    for _, id in ipairs(fireList) do
        if id ~= nil then
            set[tostring(id)] = true
        end
    end
    return set
end

local function v2RowHostKey(row)
    if not row then
        return nil
    end
    if row.incidentId ~= nil then
        return tostring(row.incidentId)
    end
    if row.sourceIncidentId ~= nil then
        return tostring(row.sourceIncidentId)
    end
    if row.originalId ~= nil then
        return tostring(row.originalId)
    end
    return nil
end

local function v2RowIsLive(row)
    return row and row.coords and row.active ~= false
end

--- SmartFires v2 `GetAllFires` row still seeding particles (not a HUD/NPC target).
local function v2RowIsPendingSeed(row)
    if not row or row.active == false then
        return false
    end
    if row.pendingSeed == true then
        return true
    end
    if row.live == false and (row.id == 0 or row.id == nil) then
        return true
    end
    return false
end

--- Real flame node from `GetAllFires` (`row.live` when present; else not `id == 0` placeholder).
local function v2RowIsRealFlameNode(row)
    if not v2RowIsLive(row) or v2RowIsPendingSeed(row) then
        return false
    end
    if row.live == true then
        return true
    end
    if row.live == false then
        return false
    end
    local nodeId = row.id
    return nodeId ~= nil and nodeId ~= 0
end

local function v2RowMatchesStoredId(row, want)
    if not row or not want then
        return false
    end
    if row.sourceIncidentId and tostring(row.sourceIncidentId) == want then
        return true
    end
    if row.incidentId and tostring(row.incidentId) == want then
        if row.sourceIncidentId and tostring(row.sourceIncidentId) ~= want then
            return false
        end
        return true
    end
    if row.originalId and tostring(row.originalId) == want then
        return true
    end
    return false
end

--- True when the running SmartFires resource exposes V2 incident lifecycle (not only the convar).
function ERS_SmartFires_UsesV2IncidentApi()
    if UsingSmartFiresV2 then
        return GetResourceState(SF_RES) == 'started'
    end
    if GetResourceState(SF_RES) ~= 'started' then
        return false
    end
    local ok, probe = pcall(function()
        return exports[SF_RES]:GetIncidentStatus('__ers_probe__')
    end)
    return ok and type(probe) == 'table' and probe.state ~= nil
end

--- v2 incident id string for StopFire / GetIncidentStatus (store CreateFire return value as-is).
local function normalizeV2IncidentId(id)
    if id == nil then
        return nil
    end
    if type(id) == 'string' then
        return id
    end
    return tostring(id)
end

--- Smart Fires v2: `GetIncidentStatus` — states `active`, `merged`, `gone`, `invalid` (London docs).
function ERS_SmartFires_GetIncidentStatus(incidentId)
    if not UsingSmartFiresV2 or GetResourceState(SF_RES) ~= 'started' then
        return nil
    end
    local inc = normalizeV2IncidentId(incidentId)
    if not inc or inc == '' then
        return { state = 'invalid', id = inc }
    end
    local ok, status = pcall(function()
        return exports[SF_RES]:GetIncidentStatus(inc)
    end)
    if not ok or type(status) ~= 'table' then
        if UsingSmartFiresV2 then
            ERS_SmartFires_Log('STATUS error', 'id=' .. tostring(inc) .. ' err=' .. tostring(status))
        end
        return nil
    end
    return status
end

--- v2 merge: resolve the live master incident id (`merged` rows point at `mergedInto`).
function ERS_SmartFires_V2ResolveMasterIncidentId(incidentId)
    if not UsingSmartFiresV2 then
        return normalizeV2IncidentId(incidentId)
    end
    local inc = normalizeV2IncidentId(incidentId)
    if not inc then
        return nil
    end
    local status = ERS_SmartFires_GetIncidentStatus(inc)
    if status and status.state == 'merged' and status.mergedInto then
        return normalizeV2IncidentId(status.mergedInto)
    end
    if status and status.id then
        return normalizeV2IncidentId(status.id)
    end
    return inc
end

--- One-line incident snapshot for logs (stored id + optional merge host).
function ERS_SmartFires_DebugIncidentSnapshot(incidentId)
    if not UsingSmartFiresV2 then
        return "v2=off id=" .. tostring(incidentId) .. " stillActive=" .. tostring(ERS_SmartFires_IsFireStillActive(incidentId))
    end
    local inc = normalizeV2IncidentId(incidentId)
    local status = ERS_SmartFires_GetIncidentStatus(inc)
    local state = status and status.state or "nil"
    local mergedInto = status and status.mergedInto
    local hostState = "n/a"
    if mergedInto then
        local hostStatus = ERS_SmartFires_GetIncidentStatus(mergedInto)
        hostState = hostStatus and hostStatus.state or "nil"
    end
    local parts = {
        "id=" .. tostring(inc),
        "state=" .. tostring(state),
        "stillActive=" .. tostring(ERS_SmartFires_IsFireStillActive(incidentId)),
    }
    if mergedInto then
        parts[#parts + 1] = "mergedInto=" .. tostring(mergedInto)
        parts[#parts + 1] = "hostState=" .. tostring(hostState)
    end
    return table.concat(parts, " ")
end

function ERS_SmartFires_DebugIncident(label, incidentId)
    ERS_SmartFires_Log(tostring(label), ERS_SmartFires_DebugIncidentSnapshot(incidentId))
end

-- ============================================================================
--  Row enumeration + map normalizers
-- ============================================================================

--- Normalize `GetAllFires()` snapshot to an array (handles map-shaped exports).
function ERS_SmartFires_V2EnumerateFireRows()
    local ok, fires = pcall(function()
        return exports[SF_RES]:GetAllFires()
    end)
    if not ok or type(fires) ~= 'table' then
        return {}
    end
    if fires[1] ~= nil then
        return fires
    end
    local arr = {}
    for _, row in pairs(fires) do
        arr[#arr + 1] = row
    end
    return arr
end

function ERS_SmartFires_V2EnumerateSmokeRows()
    local ok, smokes = pcall(function()
        return exports[SF_RES]:GetAllSmokes()
    end)
    if not ok or type(smokes) ~= 'table' then
        return {}
    end
    if smokes[1] ~= nil then
        return smokes
    end
    local arr = {}
    for _, row in pairs(smokes) do
        arr[#arr + 1] = row
    end
    return arr
end

--- v2 `StopFire` / `StopSmoke` expect the string incident id from `CreateFire` / `CreateSmoke` (e.g. `"o12"`).
--- Per London docs, `GetAllFires` rows also expose numeric `id` as a *node index* — never use that as `StopFire`'s argument.
local function resolveFireRowIncidentId(row)
    if not row then
        return nil
    end
    local cid = row.incidentId or row.originalId
    if cid ~= nil then
        return cid
    end
    if UsingSmartFiresV2 then
        return nil
    end
    return row.id
end

--- V2 `GetAllFires` rows → incident-id-keyed map. Both `sourceIncidentId` and
--- the post-merge `incidentId` are indexed so legacy callers that store the
--- original CreateFire id keep finding the row even after a merge.
function ERS_SmartFires_V2_GetFiresIncidentMap()
    if GetResourceState(SF_RES) ~= 'started' then return {} end
    local ok, fires = pcall(function()
        return exports[SF_RES]:GetAllFires()
    end)
    if not ok then
        ERS_SmartFires_Log('GET_ALL_FIRES error', tostring(fires))
        return {}
    end
    if type(fires) ~= 'table' then
        ERS_SmartFires_Log('GET_ALL_FIRES error', 'unexpected type ' .. type(fires))
        return {}
    end
    local out = {}
    if fires[1] ~= nil then
        for _, row in ipairs(fires) do
            if row and row.coords then
                if row.sourceIncidentId ~= nil then
                    out[tostring(row.sourceIncidentId)] = row
                end
                local cid = resolveFireRowIncidentId(row)
                if cid ~= nil then
                    out[tostring(cid)] = row
                end
            end
        end
        return out
    end
    return fires
end

function ERS_SmartFires_V2_GetSmokesIncidentMap()
    if GetResourceState(SF_RES) ~= 'started' then return {} end
    local ok, smokes = pcall(function()
        return exports[SF_RES]:GetAllSmokes()
    end)
    if not ok then
        ERS_SmartFires_Log('GET_ALL_SMOKES error', tostring(smokes))
        return {}
    end
    if type(smokes) ~= 'table' then
        ERS_SmartFires_Log('GET_ALL_SMOKES error', 'unexpected type ' .. type(smokes))
        return {}
    end
    local out = {}
    if smokes[1] ~= nil then
        for _, row in ipairs(smokes) do
            if row and row.coords then
                local cid = row.incidentId or row.originalId
                if cid ~= nil then
                    out[cid] = row
                end
            end
        end
        return out
    end
    return smokes
end

-- ============================================================================
--  Spawn registry / seed-count bookkeeping
-- ============================================================================

function ERS_SmartFires_V2StoreIncidentSeedCount(incidentId, count)
    if incidentId == nil then
        return
    end
    sfIncidentSeedCounts[tostring(incidentId)] = tonumber(count) or 0
end

function ERS_SmartFires_V2GetIncidentSeedCount(incidentId)
    if incidentId == nil then
        return nil
    end
    return sfIncidentSeedCounts[tostring(incidentId)]
end

function ERS_SmartFires_V2ExpectedSeedNodesForCallout(callout)
    if not callout then
        return 0
    end
    local total = 0
    for _, id in ipairs(callout.sfAllSpawnIds or {}) do
        local n = ERS_SmartFires_V2GetIncidentSeedCount(id)
        if n and n > 0 then
            total = total + n
        end
    end
    if total > 0 then
        return total
    end
    return tonumber(callout.sfExpectedSeedNodes) or 0
end

--- Append-only registry of every `CreateFire` id for a callout (never pruned; used on cancel).
function ERS_SmartFires_RegisterCalloutSpawnId(callout, incidentId)
    if not callout or incidentId == nil then
        return
    end
    callout.sfAllSpawnIds = callout.sfAllSpawnIds or {}
    local key = tostring(incidentId)
    for _, id in ipairs(callout.sfAllSpawnIds) do
        if id ~= nil and tostring(id) == key then
            return
        end
    end
    callout.sfAllSpawnIds[#callout.sfAllSpawnIds + 1] = incidentId
end

function ERS_SmartFires_SyncSpawnRegistryFromFireList(callout, fireList)
    if not callout then
        return
    end
    callout.sfSpawnCoordsById = callout.sfSpawnCoordsById or {}
    local expected = 0
    for _, id in ipairs(fireList or {}) do
        ERS_SmartFires_RegisterCalloutSpawnId(callout, id)
        local key = tostring(id)
        local c = sfSpawnCoordsByIncident[key]
        if c then
            callout.sfSpawnCoordsById[key] = { x = c.x, y = c.y, z = c.z }
        end
        local seedN = ERS_SmartFires_V2GetIncidentSeedCount(id)
        if seedN and seedN > 0 then
            expected = expected + seedN
        end
    end
    if expected > 0 then
        callout.sfExpectedSeedNodes = expected
    end
end

-- ============================================================================
--  Stable node keys (incident + nth)
-- ============================================================================

--- Stable key for one SmartFires flame node (`incidentId` + server `nth`).
function ERS_SmartFires_V2NodeKey(incidentId, nth)
    if incidentId == nil or nth == nil then
        return nil
    end
    return tostring(incidentId) .. ':' .. tostring(nth)
end

function ERS_SmartFires_V2ParseNodeKey(nodeKey)
    if nodeKey == nil then
        return nil, nil
    end
    local s = tostring(nodeKey)
    -- `veh:<vehNet>` is the ambient vehicle-fire task key — not a flame-node
    -- key. Refuse here so callers (e.g. `:stopFire`) don't misinterpret a
    -- vehicle-fire id as `inc=veh, nth=<number>`.
    if s:sub(1, 4) == 'veh:' then
        return nil, nil
    end
    local inc, nthStr = s:match('^(.+):(%d+)$')
    if not inc or not nthStr then
        return nil, nil
    end
    return inc, tonumber(nthStr)
end

-- ============================================================================
--  Scene scope: per-callout enumeration / discovery / spread
-- ============================================================================

--- Register spread / scene fires on `fireList` + `sfAllSpawnIds` so HUD, NPC, and teardown match SmartFires.
function ERS_SmartFires_V2SyncCalloutSceneFireTracking(callout)
    if not callout or not UsingSmartFiresV2 then
        return
    end
    local coords = callout.calloutData and callout.calloutData.Coordinates
    local center = coords and ERS_SmartFires_CoordsToVector(coords)
    if not center then
        return
    end
    if type(callout.fireList) == 'table' then
        ERS_SmartFires_V2AppendSpreadHostsToCallout(
            callout.fireList,
            coords,
            nil,
            callout.calloutId,
            callout
        )
    end
    local radiusM = ERS_SmartFires_V2HudSceneRadius(callout, center)
    local fireList = callout.fireList
    for _, row in ipairs(ERS_SmartFires_V2EnumerateFireRows()) do
        if v2RowIsRealFlameNode(row) and row.coords then
            local fc = ERS_SmartFires_CoordsToVector(row.coords)
            if fc and #(center - fc) <= radiusM then
                local host = v2RowHostKey(row)
                if host then
                    ERS_SmartFires_RegisterCalloutSpawnId(callout, host)
                    if fireList then
                        local key = tostring(host)
                        local found = false
                        for _, id in ipairs(fireList) do
                            if id ~= nil and tostring(id) == key then
                                found = true
                                break
                            end
                        end
                        if not found then
                            fireList[#fireList + 1] = host
                            ERS_SmartFires_Log(
                                'SCENE_TRACK host',
                                'callout=' .. tostring(callout.calloutId) .. ' host=' .. key
                            )
                        end
                    end
                end
            end
        end
    end
end

--- All live SmartFires flame nodes in the callout scene (spawn + wind spread; server `GetAllFires` truth).
function ERS_SmartFires_V2EnumerateCalloutFireNodes(callout)
    if not callout or not UsingSmartFiresV2 then
        return {}
    end
    local coords = callout.calloutData and callout.calloutData.Coordinates
    local center = coords and ERS_SmartFires_CoordsToVector(coords)
    if not center then
        return {}
    end
    ERS_SmartFires_V2SyncCalloutSceneFireTracking(callout)
    local radiusM = ERS_SmartFires_V2HudSceneRadius(callout, center)
    local nodes = {}
    for _, row in ipairs(ERS_SmartFires_V2EnumerateFireRows()) do
        if v2RowIsRealFlameNode(row) and row.coords then
            local fc = ERS_SmartFires_CoordsToVector(row.coords)
            if fc and #(center - fc) <= radiusM then
                nodes[#nodes + 1] = row
            end
        end
    end
    return nodes
end

function ERS_SmartFires_V2CountCalloutFireNodes(callout)
    local seen = {}
    local count = 0
    for _, row in ipairs(ERS_SmartFires_V2EnumerateCalloutFireNodes(callout)) do
        local key = ERS_SmartFires_V2NodeKey(row.incidentId, row.id)
        if key and not seen[key] then
            seen[key] = true
            count = count + 1
        end
    end
    return count
end

--- HUD remaining: live scene nodes + incidents still seeding (matches SmartFires sync truth).
function ERS_SmartFires_V2CountCalloutHudRemaining(callout)
    if not callout then
        return 0
    end
    local nodes = ERS_SmartFires_V2CountCalloutFireNodes(callout)
    local pending = ERS_SmartFires_V2CountCalloutPendingSeedTickets(callout)
    return math.max(nodes, pending)
end

--- Active incidents in `fireList` still waiting for SmartFires to seed flame nodes.
function ERS_SmartFires_V2IncidentHasPendingSeed(storedId)
    if storedId == nil then
        return false
    end
    local status = ERS_SmartFires_GetIncidentStatus(storedId)
    if not status or status.state ~= 'active' then
        return false
    end
    local want = tostring(storedId)
    for _, row in ipairs(ERS_SmartFires_V2EnumerateFireRows()) do
        if v2RowIsPendingSeed(row) and v2RowMatchesStoredId(row, want) then
            return true
        end
    end
    return false
end

function ERS_SmartFires_V2CountCalloutPendingSeedTickets(callout)
    if not callout or not UsingSmartFiresV2 then
        return 0
    end
    local n = 0
    for _, id in ipairs(callout.fireList or {}) do
        if ERS_SmartFires_V2IncidentHasPendingSeed(id) then
            n = n + 1
        end
    end
    return n
end

function ERS_SmartFires_V2BuildNpcNodeTask(row)
    if not row or not v2RowIsRealFlameNode(row) then
        return nil
    end
    local inc = row.incidentId
    local nth = row.id
    if inc == nil or nth == nil then
        return nil
    end
    local storedId = row.sourceIncidentId or inc
    return {
        nodeKey = ERS_SmartFires_V2NodeKey(inc, nth),
        fireId = storedId,
        incidentId = inc,
        nodeNth = nth,
        fireData = row,
    }
end

--- v2 HUD: live entries in `fireList`. Spawns that get absorbed into a host
--- by SmartFires' native merge still show up here under their original
--- CreateFire id; the canonical-id resolution in the HUD path dedupes them
--- before counting tasks, so a merged spawn never double-counts.
function ERS_SmartFires_V2CountLiveFireListSlots(callout)
    if not callout or not UsingSmartFiresV2 then
        return 0
    end
    local count = 0
    for _, id in ipairs(callout.fireList or {}) do
        if id ~= nil and ERS_SmartFires_V2HasLiveContribution(id) then
            count = count + 1
        end
    end
    return count
end

--- HUD / spawn-site discovery: wide enough for forest-fire position sets (not only 200 m bubble).
function ERS_SmartFires_V2HudSceneRadius(callout, sceneCenter)
    local radiusM = ERS_SmartFires_V2DefaultSceneRadius()
    local center = sceneCenter and ERS_SmartFires_CoordsToVector(sceneCenter)
    if not center or not callout then
        return radiusM
    end
    local spawnSet = {}
    for _, id in ipairs(callout.sfAllSpawnIds or callout.fireList or {}) do
        if id ~= nil then
            spawnSet[tostring(id)] = true
        end
    end
    for _, row in ipairs(ERS_SmartFires_V2EnumerateFireRows()) do
        if row.coords and (v2RowIsRealFlameNode(row) or v2RowIsPendingSeed(row)) then
            local fc = ERS_SmartFires_CoordsToVector(row.coords)
            if fc then
                local d = #(center - fc)
                if d > radiusM then
                    radiusM = d
                end
            end
        end
    end
    if callout.sfSpawnCoordsById then
        for _, c in pairs(callout.sfSpawnCoordsById) do
            local fc = ERS_SmartFires_CoordsToVector(c)
            if fc then
                local d = #(center - fc)
                if d > radiusM then
                    radiusM = d
                end
            end
        end
    end
    for _, id in ipairs(callout.sfAllSpawnIds or {}) do
        local fc = sfSpawnCoordsByIncident[tostring(id)]
        if fc then
            local d = #(center - fc)
            if d > radiusM then
                radiusM = d
            end
        end
    end
    return radiusM + 80.0
end

--- Host incident ids near scene not yet listed on the callout (spread / predatory).
function ERS_SmartFires_V2DiscoverSpreadHostIds(fireList, sceneCenter, radiusM)
    local discovered = {}
    if not UsingSmartFiresV2 or type(fireList) ~= 'table' or #fireList < 1 then
        return discovered
    end
    local center = ERS_SmartFires_CoordsToVector(sceneCenter)
    if not center then
        return discovered
    end
    radiusM = tonumber(radiusM) or ERS_SmartFires_V2DefaultSceneRadius()

    local known = {}
    for _, id in ipairs(fireList) do
        if id ~= nil then
            known[tostring(id)] = true
        end
    end

    local seen = {}
    for _, row in ipairs(ERS_SmartFires_V2EnumerateFireRows()) do
        if v2RowIsLive(row) then
            local fc = ERS_SmartFires_CoordsToVector(row.coords)
            local host = v2RowHostKey(row)
            if fc and host and #(center - fc) <= radiusM and not known[host] and not seen[host] then
                seen[host] = true
                discovered[#discovered + 1] = host
            end
        end
    end
    return discovered
end

--- Append spread host ids to `fireList`; returns number added.
function ERS_SmartFires_V2AppendSpreadHostsToCallout(fireList, sceneCenter, radiusM, traceId, callout)
    if not UsingSmartFiresV2 or type(fireList) ~= 'table' then
        return 0
    end
    local newHosts = ERS_SmartFires_V2DiscoverSpreadHostIds(fireList, sceneCenter, radiusM)
    local added = 0
    for _, hostId in ipairs(newHosts) do
        local key = tostring(hostId)
        local found = false
        for _, id in ipairs(fireList) do
            if id ~= nil and tostring(id) == key then
                found = true
                break
            end
        end
        if not found then
            fireList[#fireList + 1] = hostId
            added = added + 1
            if callout then
                ERS_SmartFires_RegisterCalloutSpawnId(callout, hostId)
            end
            ERS_SmartFires_Log(
                'SPREAD_ADD',
                (traceId and ('callout=' .. tostring(traceId) .. ' ') or '')
                .. 'host=' .. key
            )
        end
    end
    if callout and added > 0 and callout.sfFireHudBaselineLocked then
        local now = ERS_SmartFires_V2CountCalloutFireNodes(callout)
        if now > (callout.sfFireHudBaseline or 0) then
            callout.sfFireHudBaseline = now
        end
    end
    return added
end

function ERS_SmartFires_V2PruneGoneSmokeSlots(smokeList)
    if not smokeList or not UsingSmartFiresV2 then
        return 0
    end
    local removed = 0
    for i = #smokeList, 1, -1 do
        local entry = smokeList[i]
        -- `callout.smokeList` is a mixed bag (see SFV2.Teardown for the why):
        -- raw ids from the public `ERS_AddCalloutSmoke` helper and
        -- `{ smokeId = id }` tables from the internal `SFV2.SpawnSmoke` path.
        -- `ShouldKeepCalloutSmokeSlot` does `tostring(id)` and matches against
        -- SmartFires' incident map; passing it a table makes every lookup miss
        -- and we'd wrongly prune live smokes. Normalise to the raw id first.
        local id = entry
        if type(entry) == 'table' then
            id = entry.smokeId or entry.id
        end
        if id == nil or not ERS_SmartFires_ShouldKeepCalloutSmokeSlot(id) then
            table.remove(smokeList, i)
            removed = removed + 1
        end
    end
    if removed > 0 then
        ERS_SmartFires_Log('PRUNE smokeList', 'removed=' .. tostring(removed) .. ' remaining=' .. tostring(#smokeList))
    end
    return removed
end

--- Smoke incidents near scene not in `smokeList`.
function ERS_SmartFires_V2DiscoverSpreadSmokeIds(smokeList, sceneCenter, radiusM)
    local discovered = {}
    if not UsingSmartFiresV2 or type(smokeList) ~= 'table' then
        return discovered
    end
    local center = ERS_SmartFires_CoordsToVector(sceneCenter)
    if not center then
        return discovered
    end
    radiusM = tonumber(radiusM) or ERS_SmartFires_V2DefaultSceneRadius()
    local known = {}
    for _, id in ipairs(smokeList) do
        if id ~= nil then
            known[tostring(id)] = true
        end
    end
    for smokeId, row in pairs(ERS_SmartFires_GetSmokesIncidentMap()) do
        if row and row.coords then
            local key = tostring(smokeId)
            local inc = row.incidentId or row.originalId
            if inc ~= nil then
                key = tostring(inc)
            end
            if not known[key] then
                local pos = ERS_SmartFires_CoordsToVector(row.coords)
                if pos and #(center - pos) <= radiusM then
                    known[key] = true
                    discovered[#discovered + 1] = inc or smokeId
                end
            end
        end
    end
    return discovered
end

function ERS_SmartFires_V2AppendSpreadSmokesToCallout(smokeList, sceneCenter, radiusM, traceId)
    if not UsingSmartFiresV2 or type(smokeList) ~= 'table' then
        return 0
    end
    local newIds = ERS_SmartFires_V2DiscoverSpreadSmokeIds(smokeList, sceneCenter, radiusM)
    local added = 0
    for _, smokeId in ipairs(newIds) do
        local key = tostring(smokeId)
        local found = false
        for _, id in ipairs(smokeList) do
            if id ~= nil and tostring(id) == key then
                found = true
                break
            end
        end
        if not found then
            smokeList[#smokeList + 1] = smokeId
            added = added + 1
            ERS_SmartFires_Log(
                'SPREAD_ADD smoke',
                (traceId and ('callout=' .. tostring(traceId) .. ' ') or '') .. 'id=' .. key
            )
        end
    end
    return added
end

-- ============================================================================
--  HUD lock / refresh
-- ============================================================================

--- Clear HUD peak/lock state when a callout (re)attaches entity lists.
function ERS_SmartFires_V2ResetCalloutHudTracking(callout)
    if not callout then
        return
    end
    callout.sfFireHudBaselineLocked = false
    callout.sfFireHudBaseline = nil
    callout.sfFireHudCurrent = nil
    callout.sfHudNodePeak = 0
    callout.sfHudNodeStablePolls = 0
    callout.sfHudAttachAt = GetGameTimer()
end

--- Lock HUD denominator after seeding stabilizes (peak live nodes, not first snapshot).
function ERS_SmartFires_V2TryLockCalloutHudBaseline(callout)
    if not callout or not UsingSmartFiresV2 or callout.sfFireHudBaselineLocked then
        return callout and callout.sfFireHudBaseline or 0
    end
    local nodes = ERS_SmartFires_V2CountCalloutHudRemaining(callout)
    local pending = ERS_SmartFires_V2CountCalloutPendingSeedTickets(callout)
    callout.sfFirePendingSeedTickets = pending
    if nodes < 1 and pending < 1 then
        return 0
    end
    if nodes < 1 then
        return 0
    end

    local peak = math.max(callout.sfHudNodePeak or 0, nodes)
    callout.sfHudNodePeak = peak
    if nodes >= peak then
        callout.sfHudNodeStablePolls = (callout.sfHudNodeStablePolls or 0) + 1
    else
        callout.sfHudNodeStablePolls = 0
    end

    local attachAt = callout.sfHudAttachAt or GetGameTimer()
    local elapsed = GetGameTimer() - attachAt
    local expected = ERS_SmartFires_V2ExpectedSeedNodesForCallout(callout)
    local spawnN = callout.sfAllSpawnIds and #callout.sfAllSpawnIds or 0
    local minNodes = 1
    if expected > 0 and spawnN > 0 then
        minNodes = math.max(spawnN, math.floor(expected * 0.35))
    elseif spawnN > 0 then
        minNodes = spawnN
    end

    local stableEnough = (callout.sfHudNodeStablePolls or 0) >= V2_HUD_LOCK_STABLE_POLLS
    local minWaitMet = elapsed >= V2_HUD_LOCK_MIN_WAIT_MS
    local timedOut = elapsed >= V2_HUD_LOCK_MAX_WAIT_MS
    local seededEnough = nodes >= minNodes
    local halfExpected = expected > 0 and nodes >= math.max(minNodes, math.floor(expected * 0.55)) or false

    if timedOut or (minWaitMet and stableEnough and seededEnough) or (stableEnough and halfExpected) then
        callout.sfFireHudBaseline = math.max(peak, spawnN > 0 and spawnN or peak)
        callout.sfFireHudBaselineLocked = true
        ERS_SmartFires_Log(
            'HUD_COUNT lock',
            'callout=' .. tostring(callout.calloutId)
            .. ' nodes=' .. tostring(nodes)
            .. ' peak=' .. tostring(peak)
            .. ' baseline=' .. tostring(peak)
            .. ' expected=' .. tostring(expected)
            .. ' elapsedMs=' .. tostring(elapsed)
        )
        return peak
    end

    return 0
end

--- Update server-side HUD on active callout (v2): remaining = live SF nodes in callout scene (`GetAllFires`).
function ERS_SmartFires_V2RefreshCalloutHud(callout)
    if not callout or not UsingSmartFiresV2 then
        return 0, 0
    end
    local ok, current, baseline = pcall(function()
        ERS_SmartFires_V2BroadcastStopForGoneSpawnIds(callout)
        local remaining = ERS_SmartFires_V2CountCalloutHudRemaining(callout)
        callout.sfFirePendingSeedTickets = ERS_SmartFires_V2CountCalloutPendingSeedTickets(callout)
        ERS_SmartFires_V2TryLockCalloutHudBaseline(callout)
        local listN = callout.fireList and #callout.fireList or 0
        local base
        if callout.sfFireHudBaselineLocked then
            base = callout.sfFireHudBaseline or remaining
            if remaining > base then
                callout.sfFireHudBaseline = remaining
                base = remaining
            end
        else
            local peak = math.max(callout.sfHudNodePeak or 0, remaining)
            callout.sfHudNodePeak = peak
            base = math.max(peak, remaining, 1)
        end
        callout.sfFireHudCurrent = remaining
        ERS_SmartFires_Log(
            'HUD_COUNT',
            'callout=' .. tostring(callout.calloutId)
            .. ' nodesRemaining=' .. tostring(remaining)
            .. ' baseline=' .. tostring(base)
            .. (callout.sfFireHudBaselineLocked and '' or ' (unlocked)')
            .. ' fireList=' .. tostring(listN)
        )
        return remaining, base
    end)
    if not ok then
        ERS_SmartFires_Log('HUD refresh ERROR', tostring(current))
        local fallback = callout.sfFireHudCurrent
        if fallback == nil then
            fallback = callout.fireList and #callout.fireList or 0
        end
        local base = callout.sfFireHudBaseline
        if base == nil or base < 1 then
            base = callout.sfAllSpawnIds and #callout.sfAllSpawnIds or fallback
        end
        callout.sfFireHudCurrent = fallback
        callout.sfFireHudBaseline = base
        return fallback, base
    end
    return current, baseline
end

--- v2 HUD / poll: live `fireList` slots (spread adds ids via append before HUD refresh).
function ERS_SmartFires_V2CountOutstandingFireTargets(fireList, sceneCenter, radiusM, callout)
    if not fireList and not callout then
        return 0
    end
    if not UsingSmartFiresV2 then
        return fireList and #fireList or 0
    end
    local hudCallout = callout or { fireList = fireList, sfAllSpawnIds = fireList }
    if not hudCallout.fireList and fireList then
        hudCallout.fireList = fireList
    end
    return ERS_SmartFires_V2CountLiveFireListSlots(hudCallout)
end

-- ============================================================================
--  Cluster / slot semantics
-- ============================================================================

--- v2: live flame node on server snapshot for this stored CreateFire id (not bare `active` registry row).
function ERS_SmartFires_V2HasLiveContribution(storedId)
    if not UsingSmartFiresV2 or storedId == nil then
        return false
    end
    local want = tostring(storedId)
    for _, row in ipairs(ERS_SmartFires_V2EnumerateFireRows()) do
        if v2RowIsRealFlameNode(row) and v2RowMatchesStoredId(row, want) then
            return true
        end
    end
    local status = ERS_SmartFires_GetIncidentStatus(storedId)
    if status and status.state == 'merged' and status.mergedInto then
        local hostWant = tostring(status.mergedInto)
        for _, row in ipairs(ERS_SmartFires_V2EnumerateFireRows()) do
            if v2RowIsRealFlameNode(row) and row.sourceIncidentId and tostring(row.sourceIncidentId) == want then
                return true
            end
            if v2RowIsRealFlameNode(row) and row.incidentId and tostring(row.incidentId) == hostWant
                and row.sourceIncidentId and tostring(row.sourceIncidentId) == want then
                return true
            end
        end
    end
    return false
end

--- Incident id for NPC/HUD. Resolves the canonical host id when SmartFires
--- has merged this spawn into a neighbour, otherwise returns the stored id.
function ERS_SmartFires_V2ClusterHostKey(storedId, _fireList)
    if storedId == nil then
        return nil
    end
    local status = ERS_SmartFires_GetIncidentStatus(storedId)
    if status and status.state == 'merged' and status.mergedInto then
        return tostring(status.mergedInto)
    end
    return tostring(storedId)
end

--- Safe to drop a callout slot when the incident is gone or has no live flame nodes.
function ERS_SmartFires_V2ShouldRemoveCalloutFireSlot(storedId, _fireList)
    if storedId == nil then
        return false
    end
    local status = ERS_SmartFires_GetIncidentStatus(storedId)
    if not status or not status.state then
        return false
    end
    if status.state == 'invalid' or status.state == 'gone' then
        return true
    end
    if status.state == 'merged' then
        return not ERS_SmartFires_V2HasLiveContribution(storedId)
    end
    -- Do not drop `active` slots here — client may still be seeding nodes; use `gone`/`merged` or NPC StopFire.
    if status.state == 'active' then
        return false
    end
    return false
end

--- v2 NPC task done when the slot may be removed from `fireList`.
function ERS_SmartFires_V2IsSlotTaskComplete(storedId, fireList)
    return ERS_SmartFires_V2ShouldRemoveCalloutFireSlot(storedId, fireList)
end

function ERS_SmartFires_V2IncidentHasLiveNodes(incidentId)
    local inc = normalizeV2IncidentId(incidentId)
    if not inc then
        return false
    end
    for _, row in ipairs(ERS_SmartFires_V2EnumerateFireRows()) do
        if v2RowIsRealFlameNode(row) and row.incidentId and tostring(row.incidentId) == inc then
            return true
        end
    end
    return false
end

function ERS_SmartFires_V2NodeStillLive(incidentId, nodeNth)
    local inc = normalizeV2IncidentId(incidentId)
    local nth = tonumber(nodeNth)
    if not inc or not nth then
        return false
    end
    for _, row in ipairs(ERS_SmartFires_V2EnumerateFireRows()) do
        if v2RowIsRealFlameNode(row)
            and row.incidentId
            and tostring(row.incidentId) == inc
            and tonumber(row.id) == nth then
            return true
        end
    end
    return false
end

local function v2NodeCoords(incidentId, nodeNth)
    local inc = normalizeV2IncidentId(incidentId)
    local nth = tonumber(nodeNth)
    if not inc or not nth then
        return nil
    end
    for _, row in ipairs(ERS_SmartFires_V2EnumerateFireRows()) do
        if row.incidentId
            and tostring(row.incidentId) == inc
            and tonumber(row.id) == nth
            and row.coords then
            return row.coords
        end
    end
    return nil
end

--- DEPRECATED — left for legacy callers; new code should read `SFV2.GetCalloutScope`.
function ERS_SmartFires_V2IsIncidentListedInWorld(incidentId)
    if not UsingSmartFiresV2 or not incidentId then
        return false
    end
    local want = tostring(incidentId)
    for _, row in pairs(ERS_SmartFires_GetFiresIncidentMap()) do
        if row then
            if row.incidentId and tostring(row.incidentId) == want then
                return true
            end
            if row.sourceIncidentId and tostring(row.sourceIncidentId) == want then
                return true
            end
            if row.originalId and tostring(row.originalId) == want then
                return true
            end
        end
    end
    return false
end

-- ============================================================================
--  Coord formatting + counting helpers (debug)
-- ============================================================================

local function SF_IdsSummary(ids)
    if not ids or #ids == 0 then
        return 'count=0'
    end
    local parts = {}
    local limit = math.min(#ids, 16)
    for i = 1, limit do
        parts[#parts + 1] = tostring(ids[i])
    end
    local tail = ''
    if #ids > limit then
        tail = ',+' .. tostring(#ids - limit) .. ' more'
    end
    return 'count=' .. tostring(#ids) .. ' [' .. table.concat(parts, ',') .. tail .. ']'
end

local function SF_FormatCoords(c)
    local v = ERS_SmartFires_CoordsToVector(c)
    if not v then
        return 'invalid'
    end
    return string.format('%.1f,%.1f,%.1f', v.x, v.y, v.z)
end

local function SF_CountLiveFireNodesNear(center, radiusM)
    if not center then
        return 0
    end
    radiusM = tonumber(radiusM) or ERS_SmartFires_V2TeardownSweepRadius()
    local n = 0
    for _, row in ipairs(ERS_SmartFires_V2EnumerateFireRows()) do
        if v2RowIsRealFlameNode(row) then
            local fc = ERS_SmartFires_CoordsToVector(row.coords)
            if fc and #(center - fc) <= radiusM then
                n = n + 1
            end
        end
    end
    return n
end

local function SF_CountLiveSmokeNodesNear(center, radiusM)
    if not center then
        return 0
    end
    radiusM = tonumber(radiusM) or ERS_SmartFires_V2TeardownSweepRadius()
    local n = 0
    for _, row in ipairs(ERS_SmartFires_V2EnumerateSmokeRows()) do
        if row and row.coords and row.active ~= false then
            local fc = ERS_SmartFires_CoordsToVector(row.coords)
            if fc and #(center - fc) <= radiusM then
                n = n + 1
            end
        end
    end
    return n
end

-- ============================================================================
--  Spawn-site visual cleanup + native sweep
-- ============================================================================

--- Map legacy ERS "size" roughly to SmartFires v2 master node count (defaults doc: 5).
local function radiusToFireNodeCount(radius)
    local r = tonumber(radius) or 10.0
    local n = math.floor(r / 3.0) + 3
    if n < 4 then n = 4 end
    if n > 8 then n = 8 end
    return n
end

--- Collect distinct spawn-site coords for GTA native fire cleanup (ghost FX without incidentMeta).
function ERS_SmartFires_CollectSpawnSiteCoordsForSweep(callout)
    local sites = {}
    local seen = {}
    local function addCoord(c)
        local v = ERS_SmartFires_CoordsToVector(c)
        if not v then
            return
        end
        local key = string.format('%.1f,%.1f,%.1f', v.x, v.y, v.z)
        if seen[key] then
            return
        end
        seen[key] = true
        sites[#sites + 1] = { x = v.x, y = v.y, z = v.z }
    end
    if callout and type(callout.sfSpawnCoordsById) == 'table' then
        for _, c in pairs(callout.sfSpawnCoordsById) do
            addCoord(c)
        end
    end
    if callout then
        for _, id in ipairs(callout.sfAllSpawnIds or callout.fireList or {}) do
            if id ~= nil then
                addCoord(sfSpawnCoordsByIncident[tostring(id)])
            end
        end
    end
    return sites
end

--- All clients: native + SmartFires visual cleanup at callout spawn sites.
function ERS_SmartFires_BroadcastSpawnSiteCleanup(callout, spawnIds, reason)
    if not UsingSmartFiresV2 then
        return 0
    end
    local sites = ERS_SmartFires_CollectSpawnSiteCoordsForSweep(callout)
    local ids = {}
    local seen = {}
    local function addId(id)
        if id == nil then
            return
        end
        local key = tostring(id)
        if seen[key] then
            return
        end
        seen[key] = true
        ids[#ids + 1] = id
    end
    if type(spawnIds) == 'table' then
        for _, id in ipairs(spawnIds) do
            addId(id)
        end
    end
    if callout then
        for _, id in ipairs(callout.sfAllSpawnIds or callout.fireList or {}) do
            addId(id)
        end
    end
    if #sites < 1 and #ids < 1 then
        return 0
    end
    ERS_SmartFires_Log(
        'SPAWN_CLEANUP',
        'reason=' .. tostring(reason) .. ' sites=' .. tostring(#sites) .. ' ids=' .. tostring(#ids)
    )
    TriggerClientEvent(Config.EventPrefix .. ':sfPurgeSpawnVisuals', -1, ids, sites)
    if #sites > 0 then
        TriggerClientEvent(Config.EventPrefix .. ':sfNativeFireSweep', -1, sites)
    end
    return #sites
end

--- Back-compat alias (native-only callers).
function ERS_SmartFires_BroadcastNativeFireSweepAtSites(sites, reason)
    if type(sites) ~= 'table' or #sites < 1 then
        return 0
    end
    TriggerClientEvent(Config.EventPrefix .. ':sfNativeFireSweep', -1, sites)
    return #sites
end

--- Stop client FX for spawn incidents SmartFires already marked `gone` (do not drop `fireList` slots).
--- Each gone id is broadcast exactly once per callout via `callout.sfStopBroadcastedIds`;
--- subsequent polls skip ids that have already had their cleanup broadcast.
function ERS_SmartFires_V2BroadcastStopForGoneSpawnIds(callout)
    if not UsingSmartFiresV2 then
        return 0
    end
    if callout then
        callout.sfStopBroadcastedIds = callout.sfStopBroadcastedIds or {}
    end
    local stopped = 0
    local seen = {}
    local function tryStop(id)
        if id == nil then
            return
        end
        local key = tostring(id)
        if seen[key] then
            return
        end
        seen[key] = true
        if callout and callout.sfStopBroadcastedIds[key] then
            return
        end
        local status = ERS_SmartFires_GetIncidentStatus(id)
        if status and (status.state == 'gone' or status.state == 'invalid') then
            ERS_SmartFires_BroadcastClientStopIncident(id)
            if callout then
                ERS_SmartFires_BroadcastSpawnSiteCleanup(callout, { id }, 'stop_gone_' .. key)
                callout.sfStopBroadcastedIds[key] = true
            else
                local spawnC = sfSpawnCoordsByIncident[key]
                if spawnC then
                    TriggerClientEvent(
                        Config.EventPrefix .. ':sfPurgeSpawnVisuals',
                        -1,
                        { id },
                        { { x = spawnC.x, y = spawnC.y, z = spawnC.z } }
                    )
                end
            end
            stopped = stopped + 1
            ERS_SmartFires_Log('STOP_GONE_FX', 'id=' .. key)
        end
    end
    if callout then
        for _, id in ipairs(callout.sfAllSpawnIds or callout.fireList or {}) do
            tryStop(id)
        end
    end
    return stopped
end

--- Drop nil / gone ids from a callout `fireList` before registry sync (stops ghost spawn slots).
function ERS_SmartFires_V2SanitizeFireList(fireList, callout)
    if not UsingSmartFiresV2 or type(fireList) ~= 'table' then
        return 0
    end
    local removed = 0
    for i = #fireList, 1, -1 do
        local id = fireList[i]
        if id == nil then
            table.remove(fireList, i)
            removed = removed + 1
        else
            local status = ERS_SmartFires_GetIncidentStatus(id)
            if status and (status.state == 'gone' or status.state == 'invalid') then
                local key = tostring(id)
                ERS_SmartFires_BroadcastClientStopIncident(id)
                if callout then
                    ERS_SmartFires_BroadcastSpawnSiteCleanup(callout, { id }, 'sanitize_' .. key)
                end
                sfSpawnCoordsByIncident[key] = nil
                sfIncidentSeedCounts[key] = nil
                table.remove(fireList, i)
                removed = removed + 1
                ERS_SmartFires_Log('SANITIZE fireList', 'removed=' .. tostring(id) .. ' state=' .. tostring(status.state))
            end
        end
    end
    if callout then
        callout.fireList = fireList
    end
    return removed
end

local function ERS_SmartFires_V2InvalidateFailedSpawn(incidentId, reason, spawnCoords)
    if incidentId == nil then
        return
    end
    local key = tostring(incidentId)
    local c = spawnCoords and ERS_SmartFires_CoordsToVector(spawnCoords) or sfSpawnCoordsByIncident[key]
    ERS_SmartFires_BroadcastClientStopIncident(incidentId)
    if c then
        TriggerClientEvent(
            Config.EventPrefix .. ':sfPurgeSpawnVisuals',
            -1,
            { incidentId },
            { { x = c.x, y = c.y, z = c.z } }
        )
        ERS_SmartFires_BroadcastNativeFireSweepAtSites(
            { { x = c.x, y = c.y, z = c.z } },
            'create_fail_' .. key
        )
    end
    sfSpawnCoordsByIncident[key] = nil
    sfIncidentSeedCounts[key] = nil
    ERS_SmartFires_Log('CREATE_FAIL', 'id=' .. key .. ' reason=' .. tostring(reason))
end

local function ERS_SmartFires_V2IncidentAcceptable(incidentId)
    if incidentId == nil then
        return false
    end
    local status = ERS_SmartFires_GetIncidentStatus(incidentId)
    if status and (status.state == 'gone' or status.state == 'invalid') then
        return false
    end
    if status and (status.state == 'active' or status.state == 'merged') then
        return true
    end
    return ERS_SmartFires_V2HasLiveContribution(incidentId)
end

local function ERS_SmartFires_V2WaitForValidIncident(incidentId)
    if incidentId == nil then
        return false, 'nil_id'
    end
    local deadline = GetGameTimer() + V2_CREATE_VALIDATE_TIMEOUT_MS
    while GetGameTimer() < deadline do
        if ERS_SmartFires_V2IncidentAcceptable(incidentId) then
            return true, 'ok'
        end
        local status = ERS_SmartFires_GetIncidentStatus(incidentId)
        if status and (status.state == 'gone' or status.state == 'invalid') then
            return false, status.state
        end
        Citizen.Wait(V2_CREATE_VALIDATE_STEP_MS)
    end
    if ERS_SmartFires_V2IncidentAcceptable(incidentId) then
        return true, 'ok_late'
    end
    local status = ERS_SmartFires_GetIncidentStatus(incidentId)
    if status and (status.state == 'gone' or status.state == 'invalid') then
        return false, status.state
    end
    return false, 'timeout'
end

--- Client cleanup when server incident is already gone but FX may remain (noclip / prune desync).
function ERS_SmartFires_BroadcastClientStopIncident(incidentId)
    if incidentId == nil or GetResourceState(SF_RES) ~= 'started' then
        return
    end
    local id = normalizeV2IncidentId(incidentId)
    if not id or id == '' then
        return
    end
    TriggerClientEvent('fire:cl:stopIncident', -1, id)
end

-- ============================================================================
--  Teardown — collect ids, stop hosts, near-coord sweep, multi-pass cleanup
-- ============================================================================

--- Cancel teardown: `fireList` + spawn registry + spread hosts + scene-linked blazes.
function ERS_SmartFires_CollectTeardownFireIds(fireList, sceneCenter, radiusM, allSpawnIds)
    local ids = {}
    local seen = {}
    local function add(id)
        if id == nil then
            return
        end
        local key = tostring(id)
        if seen[key] then
            return
        end
        seen[key] = true
        ids[#ids + 1] = id
    end

    if type(fireList) == 'table' then
        for _, id in ipairs(fireList) do
            add(id)
        end
    end

    if type(allSpawnIds) == 'table' then
        for _, id in ipairs(allSpawnIds) do
            add(id)
        end
    end

    if not ERS_SmartFires_UsesV2IncidentApi() then
        return ids
    end

    local center = ERS_SmartFires_CoordsToVector(sceneCenter)
    radiusM = tonumber(radiusM) or ERS_SmartFires_V2TeardownSweepRadius()
    if not center then
        return ids
    end

    for _, hostId in ipairs(ERS_SmartFires_V2DiscoverSpreadHostIds(fireList or {}, center, radiusM)) do
        add(hostId)
    end

    local calloutSet = v2BuildCalloutIdSet(ids)
    for _, row in ipairs(ERS_SmartFires_V2EnumerateFireRows()) do
        local fc = row.coords and ERS_SmartFires_CoordsToVector(row.coords)
        local src = row.sourceIncidentId and tostring(row.sourceIncidentId)
        local host = v2RowHostKey(row)
        local linked = src and calloutSet[src]
        local inScene = fc and #(center - fc) <= radiusM
        if linked or inScene then
            if host then
                add(host)
            end
            if row.incidentId then
                add(row.incidentId)
            end
            if row.sourceIncidentId then
                add(row.sourceIncidentId)
            end
        end
    end

    return ids
end

--- Cancel teardown: listed smokes + spread smokes near scene.
function ERS_SmartFires_CollectTeardownSmokeIds(smokeList, sceneCenter, radiusM)
    local ids = {}
    local seen = {}
    local function add(id)
        if id == nil then
            return
        end
        local key = tostring(id)
        if seen[key] then
            return
        end
        seen[key] = true
        ids[#ids + 1] = id
    end

    if type(smokeList) == 'table' then
        for _, id in ipairs(smokeList) do
            add(id)
        end
    end

    if not ERS_SmartFires_UsesV2IncidentApi() then
        return ids
    end

    local center = ERS_SmartFires_CoordsToVector(sceneCenter)
    radiusM = tonumber(radiusM) or ERS_SmartFires_V2TeardownSweepRadius()
    if not center then
        return ids
    end

    for _, smokeId in ipairs(ERS_SmartFires_V2DiscoverSpreadSmokeIds(smokeList or {}, center, radiusM)) do
        add(smokeId)
    end

    local known = v2BuildCalloutIdSet(ids)
    for _, row in ipairs(ERS_SmartFires_V2EnumerateSmokeRows()) do
        local fc = row.coords and ERS_SmartFires_CoordsToVector(row.coords)
        local inc = row.incidentId and tostring(row.incidentId)
        if fc and inc and #(center - fc) <= radiusM and not known[inc] then
            add(row.incidentId)
        end
    end

    return ids
end

--- Cancel: stop every distinct host referenced by the spawn registry (after prune may have dropped ids).
function ERS_SmartFires_StopAllRegisteredSpawnHosts(callout)
    if not callout or type(callout.sfAllSpawnIds) ~= 'table' or #callout.sfAllSpawnIds < 1 then
        return
    end
    if GetResourceState(SF_RES) ~= 'started' then
        return
    end
    ERS_SmartFires_Log('STOP_SPAWN begin', 'spawnIds=' .. tostring(#callout.sfAllSpawnIds))
    local seen = {}
    for _, id in ipairs(callout.sfAllSpawnIds) do
        if id ~= nil then
            local key = tostring(id)
            if not seen[key] then
                seen[key] = true
                local stopId = ERS_SmartFires_V2ResolveMasterIncidentId(id) or id
                ERS_SmartFires_StopFire(stopId)
                ERS_SmartFires_BroadcastClientStopIncident(stopId)
            end
        end
    end
    ERS_SmartFires_Log('STOP_SPAWN end', 'spawnIds=' .. tostring(#callout.sfAllSpawnIds))
end

--- Cancel fallback: stop every fire host with nodes near coords (uses full `GetAllFires` rows, not deduped map).
---@return number stopsAttempted, number nodesRemainingNearCenter
function ERS_SmartFires_StopFiresNearCoords(coords, radiusM)
    if GetResourceState(SF_RES) ~= 'started' or not coords then
        ERS_SmartFires_Log('NEAR skip', 'sf=' .. tostring(GetResourceState(SF_RES)) .. ' coords=' .. tostring(coords ~= nil))
        return 0, 0
    end
    local center = ERS_SmartFires_CoordsToVector(coords)
    if not center then
        ERS_SmartFires_Log('NEAR skip', 'center=invalid raw=' .. tostring(type(coords)))
        return 0, 0
    end
    radiusM = tonumber(radiusM) or ERS_SmartFires_V2TeardownSweepRadius()
    local nodesBefore = SF_CountLiveFireNodesNear(center, radiusM)
    ERS_SmartFires_Log('NEAR begin', 'center=' .. SF_FormatCoords(center) .. ' radius=' .. tostring(radiusM) .. ' nodesBefore=' .. tostring(nodesBefore))

    local stopped = {}
    local stopCount = 0
    local function tryStopHost(hostId, reason)
        if hostId == nil then
            return
        end
        local master = ERS_SmartFires_UsesV2IncidentApi() and (ERS_SmartFires_V2ResolveMasterIncidentId(hostId) or hostId) or hostId
        local key = tostring(master)
        if stopped[key] then
            return
        end
        stopped[key] = true
        local ok = ERS_SmartFires_StopFire(master)
        stopCount = stopCount + 1
        ERS_SmartFires_Log('NEAR stop', 'reason=' .. tostring(reason) .. ' host=' .. key .. ' ok=' .. tostring(ok))
    end

    for _, row in ipairs(ERS_SmartFires_V2EnumerateFireRows()) do
        if row and row.coords then
            local fc = ERS_SmartFires_CoordsToVector(row.coords)
            if fc and #(center - fc) <= radiusM then
                local host = v2RowHostKey(row)
                if host then
                    tryStopHost(host, 'rowHost')
                end
            end
        end
    end

    local nodesAfter = SF_CountLiveFireNodesNear(center, radiusM)
    ERS_SmartFires_Log('NEAR end', 'stops=' .. tostring(stopCount) .. ' nodesAfter=' .. tostring(nodesAfter))
    return stopCount, nodesAfter
end

---@return number stopsAttempted, number smokesRemainingNearCenter
function ERS_SmartFires_StopSmokesNearCoords(coords, radiusM)
    if GetResourceState(SF_RES) ~= 'started' or not coords then
        return 0, 0
    end
    local center = ERS_SmartFires_CoordsToVector(coords)
    if not center then
        return 0, 0
    end
    radiusM = tonumber(radiusM) or ERS_SmartFires_V2TeardownSweepRadius()
    local stopped = {}
    local stopCount = 0
    for _, row in ipairs(ERS_SmartFires_V2EnumerateSmokeRows()) do
        if row and row.coords and row.incidentId then
            local fc = ERS_SmartFires_CoordsToVector(row.coords)
            if fc and #(center - fc) <= radiusM then
                local key = tostring(row.incidentId)
                if not stopped[key] then
                    stopped[key] = true
                    ERS_SmartFires_StopSmoke(row.incidentId)
                    stopCount = stopCount + 1
                end
            end
        end
    end
    return stopCount, SF_CountLiveSmokeNodesNear(center, radiusM)
end

local function teardownResolveCenterAndRadius(callout, cancelSrc, fireList)
    local center = callout and callout.calloutData and ERS_SmartFires_CoordsToVector(callout.calloutData.Coordinates)
    local centerSource = 'callout.Coordinates'
    if not center and cancelSrc then
        local ped = GetPlayerPed(cancelSrc)
        if ped and ped ~= 0 then
            center = GetEntityCoords(ped)
            centerSource = 'cancelSrc ped'
        end
    end
    local radiusM = ERS_SmartFires_V2TeardownSweepRadius()
    if center and ERS_SmartFires_UsesV2IncidentApi() then
        local maxDist = 0.0
        for _, row in ipairs(ERS_SmartFires_V2EnumerateFireRows()) do
            local fc = row.coords and ERS_SmartFires_CoordsToVector(row.coords)
            if fc then
                local d = #(center - fc)
                if d > maxDist then
                    maxDist = d
                end
            end
        end
        if maxDist > radiusM - 80.0 then
            radiusM = maxDist + 120.0
        end
    end
    return center, centerSource, radiusM
end

--- Callout cancel / resource stop: expanded id list, host-only stops, scene sweep, smokes.
function ERS_SmartFires_TeardownCalloutFires(fireList, callout, cancelSrc)
    local center, centerSource, sweepRadius = teardownResolveCenterAndRadius(callout, cancelSrc, fireList)
    local snapshot = {}
    if ERS_SmartFires_UsesV2IncidentApi() and center then
        snapshot = ERS_SmartFires_CollectTeardownFireIds(fireList, center, sweepRadius, callout and callout.sfAllSpawnIds)
    elseif type(fireList) == 'table' then
        for _, id in ipairs(fireList) do
            if id ~= nil then
                snapshot[#snapshot + 1] = id
            end
        end
    end

    local calloutId = callout and callout.calloutId or '?'
    local hostId = callout and callout.hostId or '?'
    local spawnCount = callout and callout.sfAllSpawnIds and #callout.sfAllSpawnIds or 0
    ERS_SmartFires_Log(
        'TEARDOWN begin',
        'callout=' .. tostring(calloutId)
        .. ' host=' .. tostring(hostId)
        .. ' cancelSrc=' .. tostring(cancelSrc)
        .. ' v2=' .. tostring(UsingSmartFiresV2)
        .. ' sf=' .. tostring(GetResourceState(SF_RES))
        .. ' sweepR=' .. tostring(sweepRadius)
        .. ' spawnRegistry=' .. tostring(spawnCount)
        .. ' ' .. SF_IdsSummary(snapshot)
    )

    if GetResourceState(SF_RES) ~= 'started' then
        if ERS_SmartFires_HasAnyFireResourceStarted() then
            ERS_SmartFires_StopAllCalloutFires(snapshot)
        else
            ERS_SmartFires_Log('TEARDOWN skip STOP_ALL', 'no SmartFires resource')
        end
        ERS_SmartFires_Log('TEARDOWN end', 'SmartFires not started — no near sweep')
        return
    end

    if center then
        ERS_SmartFires_StopFiresNearCoords(center, sweepRadius)
        Wait(150)
    end

    if ERS_SmartFires_HasAnyFireResourceStarted() then
        ERS_SmartFires_StopAllCalloutFires(snapshot)
    else
        ERS_SmartFires_Log('TEARDOWN skip STOP_ALL', 'no SmartFires resource')
    end

    if callout then
        ERS_SmartFires_StopAllRegisteredSpawnHosts(callout)
        Wait(150)
    end

    if center then
        local _, remaining1 = ERS_SmartFires_StopFiresNearCoords(center, sweepRadius)
        Wait(250)
        local _, remaining2 = ERS_SmartFires_StopFiresNearCoords(center, sweepRadius)

        if ERS_SmartFires_UsesV2IncidentApi() and remaining2 > 0 then
            ERS_SmartFires_Log('RELAY_DAMAGE', 'nodes=' .. tostring(remaining2) .. ' multi-player relay')
            local relayed = {}
            local function relayTo(pid)
                pid = tonumber(pid)
                if pid and pid > 0 and not relayed[pid] then
                    relayed[pid] = true
                    for pulse = 1, 3 do
                        ERS_SmartFires_V2RelaySuppressionViaHostClient(pid, center, 5000.0, 80.0)
                        Wait(150)
                    end
                end
            end
            relayTo(cancelSrc)
            relayTo(hostId)
            if callout and callout.playersList then
                for _, pid in pairs(callout.playersList) do
                    relayTo(pid)
                end
            end
            ERS_SmartFires_StopFiresNearCoords(center, sweepRadius)
            Wait(200)
            ERS_SmartFires_StopFiresNearCoords(center, sweepRadius)
            remaining2 = SF_CountLiveFireNodesNear(center, sweepRadius)
        end

        if callout and remaining2 > 0 then
            ERS_SmartFires_StopAllRegisteredSpawnHosts(callout)
            Wait(150)
            ERS_SmartFires_StopFiresNearCoords(center, sweepRadius)
            remaining2 = SF_CountLiveFireNodesNear(center, sweepRadius)
        end

        if ERS_SmartFires_UsesV2IncidentApi() and callout and type(callout.smokeList) == 'table' then
            local smokeIds = ERS_SmartFires_CollectTeardownSmokeIds(callout.smokeList, center, sweepRadius)
            ERS_SmartFires_StopAllCalloutSmokes(smokeIds)
            Wait(150)
            ERS_SmartFires_StopSmokesNearCoords(center, sweepRadius)
        end

        local nativeSites = ERS_SmartFires_BroadcastSpawnSiteCleanup(callout, snapshot, 'teardown')
        ERS_SmartFires_Log(
            'TEARDOWN end',
            'center=' .. SF_FormatCoords(center) .. ' from=' .. centerSource
            .. ' radius=' .. tostring(sweepRadius)
            .. ' nodesAfterPass1=' .. tostring(remaining1)
            .. ' nodesAfterPass2=' .. tostring(remaining2)
            .. ' nativeSweepSites=' .. tostring(nativeSites)
            .. (remaining2 > 0 and ' ^1FIRES MAY REMAIN^7' or ' ^2clear^7')
        )
    else
        if callout then
            ERS_SmartFires_BroadcastSpawnSiteCleanup(callout, nil, 'teardown_no_center')
        end
        ERS_SmartFires_Log('TEARDOWN end', '^1no center^7 — near sweep skipped (spread fires may remain)')
    end
end

-- ============================================================================
--  NPC node tasks
-- ============================================================================

function ERS_SmartFires_FindFireRowForStoredId(map, storedId)
    if not map or storedId == nil then
        return nil
    end
    local want = tostring(storedId)
    if map[storedId] then
        return map[storedId]
    end
    if map[want] then
        return map[want]
    end
    for _, row in pairs(map) do
        if row then
            if row.sourceIncidentId and tostring(row.sourceIncidentId) == want then
                return row
            end
            if row.originalId and tostring(row.originalId) == want then
                return row
            end
            if row.incidentId and tostring(row.incidentId) == want then
                return row
            end
        end
    end
    return nil
end

--- Build NPC tasks from callout flame nodes (v2). `callout` required for node discovery.
--- Also appends synthetic tasks for any ambient SmartFires vehicle fire in
--- scope (`scope.vehicleFires`) so NPC backup fights wrecked-vehicle blazes
--- alongside outdoor/indoor nodes — same task list, one assignment per ped.
function ERS_SmartFires_BuildNpcFireTasksFromCalloutIds(calloutFireIds, fallbackCoords, callout)
    local tasks = {}
    if UsingSmartFiresV2 and callout then
        for _, row in ipairs(ERS_SmartFires_V2EnumerateCalloutFireNodes(callout)) do
            local task = ERS_SmartFires_V2BuildNpcNodeTask(row)
            if task then
                tasks[#tasks + 1] = task
            end
        end
        local scope = SFV2 and SFV2.GetCalloutScope and SFV2.GetCalloutScope(callout) or nil
        if scope and scope.vehicleFires and SFV2.BuildVehicleFireTask then
            for _, vrow in ipairs(scope.vehicleFires) do
                local vtask = SFV2.BuildVehicleFireTask(vrow)
                if vtask then tasks[#tasks + 1] = vtask end
            end
        end
        if #tasks > 0 then
            ERS_SmartFires_Log('NPC tasks nodes', 'count=' .. tostring(#tasks))
            return tasks
        end
    end
    if type(calloutFireIds) ~= 'table' then
        return tasks
    end
    local map = ERS_SmartFires_GetFiresIncidentMap()
    local fallback = ERS_SmartFires_CoordsToVector(fallbackCoords)

    for _, id in ipairs(calloutFireIds) do
        if id ~= nil then
            local row = ERS_SmartFires_FindFireRowForStoredId(map, id)
            if row and row.coords and v2RowIsRealFlameNode(row) then
                local task = ERS_SmartFires_V2BuildNpcNodeTask(row)
                if task then
                    tasks[#tasks + 1] = task
                end
            elseif row and row.coords then
                tasks[#tasks + 1] = { fireId = id, fireData = row }
            elseif fallback then
                tasks[#tasks + 1] = {
                    fireId = id,
                    fireData = { coords = { x = fallback.x, y = fallback.y, z = fallback.z } },
                }
            end
        end
    end
    return tasks
end

--- Remove one flame node via callout host (SmartFires `fire:sv:removeFire`).
function ERS_SmartFires_RemoveFireNode(hostSrc, incidentId, nodeNth)
    if not UsingSmartFiresV2 or not hostSrc or incidentId == nil or nodeNth == nil then
        return false
    end
    local inc = normalizeV2IncidentId(incidentId)
    local nth = tonumber(nodeNth)
    if not inc or not nth then
        return false
    end
    TriggerClientEvent(Config.EventPrefix .. ':sfRelayRemoveFireNode', hostSrc, inc, nth)
    return true
end

--- NPC finished one node: remove it; drop `fireList` slot only when the whole incident is out.
function ERS_SmartFires_CompleteNpcFireNodeTask(incidentId, nodeNth, hostSrc, fireList, storedId)
    if not UsingSmartFiresV2 then
        return false
    end
    local inc = normalizeV2IncidentId(incidentId)
    local nth = tonumber(nodeNth)
    if not inc or not nth then
        return false
    end
    ERS_SmartFires_Log(
        'NPC complete node',
        'inc=' .. tostring(inc) .. ' nth=' .. tostring(nth) .. ' stored=' .. tostring(storedId)
    )
    if ERS_SmartFires_V2NodeStillLive(inc, nth) then
        local nodeCoords = v2NodeCoords(inc, nth)
        local hits = 0
        if nodeCoords then
            hits = ERS_SmartFires_ApplyFireDamageAtCoords(nodeCoords, 6.0, 120.0, {})
            ERS_SmartFires_Log('NPC complete damage', 'inc=' .. tostring(inc) .. ' nth=' .. tostring(nth) .. ' hits=' .. tostring(hits))
            Wait(200)
        end
        if ERS_SmartFires_V2NodeStillLive(inc, nth) then
            if hits < 1 then
                ERS_SmartFires_RemoveFireNode(hostSrc, inc, nth)
            else
                ERS_SmartFires_ApplyFireDamageAtCoords(nodeCoords, 8.0, 80.0, {})
            end
            Wait(350)
        end
    end
    local nodeDone = not ERS_SmartFires_V2NodeStillLive(inc, nth)
    if not nodeDone then
        ERS_SmartFires_Log('NPC complete node fail', 'inc=' .. tostring(inc) .. ' nth=' .. tostring(nth))
        return false
    end
    if storedId and fireList and not ERS_SmartFires_V2IncidentHasLiveNodes(inc) then
        local want = tostring(storedId)
        for i = #fireList, 1, -1 do
            if fireList[i] ~= nil and tostring(fireList[i]) == want then
                table.remove(fireList, i)
                ERS_SmartFires_Log('NPC complete incident slot', 'removed=' .. want)
                break
            end
        end
        if not ERS_SmartFires_V2IncidentHasLiveNodes(inc) then
            ERS_SmartFires_StopFire(storedId)
        end
    end
    return true
end

--- v2 NPC completion: whole-incident StopFire (legacy) or single-node removal when `nodeNth` set.
---@return boolean complete True when the stored id may be removed from `fireList`.
function ERS_SmartFires_CompleteNpcFireTask(storedId, coords, hostSrc, fireList, nodeNth, incidentId)
    if not UsingSmartFiresV2 then
        return false
    end
    if nodeNth ~= nil and incidentId ~= nil then
        return ERS_SmartFires_CompleteNpcFireNodeTask(incidentId, nodeNth, hostSrc, fireList, storedId)
    end
    local stopId = storedId
    ERS_SmartFires_Log('NPC complete begin', ERS_SmartFires_DebugIncidentSnapshot(stopId))

    if ERS_SmartFires_V2IsSlotTaskComplete(stopId, fireList) then
        ERS_SmartFires_Log('NPC complete skip', 'id=' .. tostring(stopId) .. ' already complete')
        return true
    end

    Wait(400)
    if ERS_SmartFires_V2IsSlotTaskComplete(stopId, fireList) then
        ERS_SmartFires_Log('NPC complete skip', 'id=' .. tostring(stopId) .. ' complete after wait')
        return true
    end

    local stopOk = ERS_SmartFires_StopFire(stopId)
    Wait(200)

    local done = ERS_SmartFires_V2IsSlotTaskComplete(stopId, fireList)
    ERS_SmartFires_Log(
        'NPC complete end',
        'id=' .. tostring(stopId) .. ' done=' .. tostring(done) .. ' stopOk=' .. tostring(stopOk) .. ' | ' .. ERS_SmartFires_DebugIncidentSnapshot(stopId)
    )
    return done or (stopOk == true and not ERS_SmartFires_V2HasLiveContribution(stopId))
end

-- ============================================================================
--  V2 dispatcher entry points (called from top-level bridge)
-- ============================================================================

--- V2 CreateFire entry. The top-level `ERS_SmartFires_CreateFireAtCoords`
--- dispatches here when `UsingSmartFiresV2`. Handles the inter-spawn gap, the
--- two-attempt retry, the per-incident seed-count book-keeping, and stores
--- the spawn coords for later teardown / native-sweep work.
function ERS_SmartFires_V2_CreateFireAtCoords(coords, radius, fireType, opts)
    fireType = fireType or 'normal'
    local interiorId = type(opts) == 'table' and tonumber(opts.interiorId) or 0
    local function waitCreateGap()
        local now = GetGameTimer()
        if sfLastV2CreateMs > 0 then
            local gapMs = V2_CREATE_MIN_GAP_MS - (now - sfLastV2CreateMs)
            if gapMs > 0 then
                Citizen.Wait(gapMs)
            end
        end
    end
    waitCreateGap()
    local x, y, z = coords.x, coords.y, coords.z
    local rad = tonumber(radius) or 10.0
    local count = radiusToFireNodeCount(radius)
    local incidentId = ERS_SmartFires_V2_AttemptCreateFireAtCoords(x, y, z, fireType, rad, count, interiorId)
    if incidentId == nil then
        waitCreateGap()
        incidentId = ERS_SmartFires_V2_AttemptCreateFireAtCoords(x, y, z, fireType, rad, count, interiorId)
        if incidentId ~= nil then
            ERS_SmartFires_Log('CREATE_RETRY ok', 'id=' .. tostring(incidentId))
        end
    end
    return incidentId
end

--- Single CreateFire attempt with validation; called by the V2 entry point
--- above (twice if the first try returns nil).
function ERS_SmartFires_V2_AttemptCreateFireAtCoords(x, y, z, fireType, rad, count, interiorId)
    local interior = tonumber(interiorId) or 0
    -- ERS forwards the callout to MDT/CAD on arrival; suppress SmartFires external bridges per spawn.
    local incidentId = exports[SF_RES]:CreateFire(x, y, z, fireType, rad, count, interior, true)
    sfLastV2CreateMs = GetGameTimer()
    if incidentId == nil then
        ERS_SmartFires_Log(
            'CREATE_FAIL',
            'reason=nil_id at=' .. string.format('%.0f,%.0f,%.0f', x, y, z)
        )
        return nil
    end
    local valid, reason = ERS_SmartFires_V2WaitForValidIncident(incidentId)
    if not valid then
        ERS_SmartFires_V2InvalidateFailedSpawn(incidentId, reason, vector3(x, y, z))
        return nil
    end
    ERS_SmartFires_V2StoreIncidentSeedCount(incidentId, count)
    sfSpawnCoordsByIncident[tostring(incidentId)] = vector3(x, y, z)
    ERS_SmartFires_Log(
        'CREATE_FIRE',
        'id=' .. tostring(incidentId)
        .. ' at=' .. string.format('%.0f,%.0f,%.0f', x, y, z)
        .. ' nodes=' .. tostring(count)
        .. ' interior=' .. tostring(interior)
    )
    return incidentId
end

function ERS_SmartFires_V2_CreateSmokeAtCoords(coords, radius, smokeType)
    smokeType = smokeType or 'normal'
    local x, y, z = coords.x, coords.y, coords.z
    local rad = tonumber(radius) or 10.0
    return exports[SF_RES]:CreateSmoke(x, y, z, smokeType, rad, true)
end

function ERS_SmartFires_V2_StopFire(id)
    if id == nil then
        ERS_SmartFires_Log('STOP_FIRE skip', 'id=nil')
        return false
    end
    local inc = normalizeV2IncidentId(id)
    local before = ERS_SmartFires_DebugIncidentSnapshot(inc)
    local exportOk, exportResult = pcall(function()
        return exports[SF_RES]:StopFire(inc)
    end)
    if not exportOk then
        ERS_SmartFires_Log('STOP_FIRE error', 'id=' .. tostring(inc) .. ' export threw: ' .. tostring(exportResult))
        return false
    end
    if exportResult == true then
        ERS_SmartFires_Log('STOP_FIRE ok', 'id=' .. tostring(inc) .. ' export=true | after=' .. ERS_SmartFires_DebugIncidentSnapshot(inc))
        return true
    end
    local status = ERS_SmartFires_GetIncidentStatus(inc)
    local state = status and status.state or 'nil'
    if status and (status.state == 'gone' or status.state == 'invalid') then
        ERS_SmartFires_Log('STOP_FIRE ok', 'id=' .. tostring(inc) .. ' export=false state=' .. state .. ' (treated gone) | before=' .. before)
        return true
    end
    ERS_SmartFires_Log(
        'STOP_FIRE fail',
        'id=' .. tostring(inc)
        .. ' export=false state=' .. state
        .. (status and status.mergedInto and (' mergedInto=' .. tostring(status.mergedInto)) or '')
        .. ' | before=' .. before
    )
    return false
end

function ERS_SmartFires_V2_StopSmoke(id)
    if id == nil then return false end
    local inc = type(id) == 'string' and id or tostring(id)
    local exportOk, exportResult = pcall(function()
        return exports[SF_RES]:StopSmoke(inc)
    end)
    if not exportOk then
        ERS_SmartFires_Log('STOP_SMOKE error', 'id=' .. tostring(inc) .. ' export threw: ' .. tostring(exportResult))
        return false
    end
    return exportResult == true
end

function ERS_SmartFires_V2_IsFireStillActive(id)
    if id == nil then return false end
    return ERS_SmartFires_ShouldKeepCalloutFireSlot(id)
end

function ERS_SmartFires_V2_IsSmokeStillActive(id)
    if id == nil then return false end
    return ERS_SmartFires_ShouldKeepCalloutSmokeSlot(id)
end

--- Server-side suppression at coords (SmartFires v2 `ApplyFireDamageAtCoords` export).
function ERS_SmartFires_ApplyFireDamageAtCoords(coords, radius, amount, opts)
    if not UsingSmartFiresV2 or GetResourceState(SF_RES) ~= 'started' then
        return 0
    end
    local c = ERS_SmartFires_CoordsToVector(coords)
    radius = tonumber(radius)
    amount = tonumber(amount)
    if not c or not radius or radius <= 0 or not amount or amount <= 0 then
        return 0
    end
    local ok, hits = pcall(function()
        return exports[SF_RES]:ApplyFireDamageAtCoords(c.x, c.y, c.z, radius, amount, opts or {})
    end)
    if not ok then
        ERS_SmartFires_Log('APPLY_DAMAGE error', tostring(hits))
        return 0
    end
    return tonumber(hits) or 0
end

--- v2 fallback: when `StopFire` failed but `GetIncidentStatus` says the fire is still `active`/`merged`.
--- London documents `fire:sv:damageFireAtCoords` as **client → server**; relay through the callout host.
function ERS_SmartFires_V2RelaySuppressionViaHostClient(hostSrc, coords, damageAmount, radius)
    if not UsingSmartFiresV2 or not hostSrc or not coords then
        return
    end
    if GetResourceState(SF_RES) ~= 'started' then
        return
    end
    local x, y, z = tonumber(coords.x), tonumber(coords.y), tonumber(coords.z)
    if not x or not y or not z then
        return
    end
    damageAmount = damageAmount or 2500.0
    radius = radius or 45.0
    ERS_SmartFires_Log(
        'RELAY_DAMAGE',
        'src=' .. tostring(hostSrc) .. ' at=' .. x .. ',' .. y .. ',' .. z .. ' dmg=' .. tostring(damageAmount) .. ' r=' .. tostring(radius)
    )
    TriggerClientEvent(Config.EventPrefix..':relaySmartFiresDamageAtCoords', hostSrc, x, y, z, damageAmount, radius)
end

-- ============================================================================
--  Net events (NPC + cleanup relays)
-- ============================================================================

--- NPC hose spray: apply SmartFires v2 damage on server (client `fire:sv:damageFireAtCoords` is player-oriented).
--- `damageVehicles` (optional bool) lets the call also tick down nearby
--- SmartFires vehicle fires; the client passes it when the active task is a
--- `veh:<vehNet>` entry so NPCs can extinguish wrecked-vehicle blazes.
RegisterNetEvent(Config.EventPrefix .. ':sfNpcApplyFireDamageAtCoords')
AddEventHandler(Config.EventPrefix .. ':sfNpcApplyFireDamageAtCoords', function(x, y, z, radius, amount, damageVehicles)
    if not UsingSmartFiresV2 then
        return
    end
    if type(x) ~= 'number' or type(y) ~= 'number' or type(z) ~= 'number' then
        return
    end
    local opts = {}
    if damageVehicles == true then opts.damageVehicles = true end
    ERS_SmartFires_ApplyFireDamageAtCoords(vector3(x, y, z), radius, amount, opts)
end)

--- NPC backup finished its full spray cycle on a SmartFires vehicle fire.
--- SmartFires' built-in extinguish trigger (cl_entity tickExtinguish) only
--- fires when `strength <= 0` AND `waterDps > 0` on the *owner* client, but
--- the owner has `waterDps == 0` when an NPC on another client is doing the
--- spraying — so the broadcast damage chain drains strength to zero and then
--- the fire just sits there forever. ERS therefore force-extinguishes
--- server-side as soon as the NPC reports it spent its full spray cycle on
--- the vehicle. This is distinct from the `:stopFire veh:<net>` give-up path
--- (which we deliberately no-op so we don't yank a wreck out from under a
--- player who could still finish it themselves).
RegisterNetEvent(Config.EventPrefix .. ':sfNpcVehicleFireSprayComplete')
AddEventHandler(Config.EventPrefix .. ':sfNpcVehicleFireSprayComplete', function(vehNet)
    if not UsingSmartFiresV2 then return end
    local nid = tonumber(vehNet)
    if not nid or nid <= 0 then return end
    if GetResourceState('SmartFires') ~= 'started' then return end

    local src = source
    pcall(function() exports['SmartFires']:StopVehicleIncident(nid) end)
    ERS_SmartFires_Log(
        'NPC vehFire sprayComplete',
        'src=' .. tostring(src) .. ' vehNet=' .. tostring(nid)
    )

    for _, callout in ipairs(ActiveCalloutsList) do
        if tonumber(callout.hostId) == tonumber(src) then
            if SFV2 and SFV2.InvalidateScope then SFV2.InvalidateScope(callout) end
            ERS_TriggerCalloutUserInterfaceForHost(callout.hostId)
            break
        end
    end
end)

--- Coords-based variant of the spray-complete handler. Used by the NPC
--- native-fire fallback path when there's no `vehNet` task entry — i.e. the
--- only thing burning at the scene is a SmartFires *custom* vehicle fire on a
--- wrecked vehicle, which is invisible to `ERS_MergeV2SpreadFiresIntoNpcTaskList`
--- because vehicle fires live in `activeVehicleFires`, not the
--- `incidents` / `GetAllFires` table the merge consults.
---
--- Detection on the client is unreliable: SmartFires renders the wreck fire as
--- scripted PTFX, so `IsEntityOnFire(veh)` returns false. Instead, the client
--- sends the spray coords and a small radius, and we look up matches against
--- the authoritative `GetActiveVehicleFires({ center, radius })` server export
--- (sv_exports.lua:391) which reads `ServerManager.activeVehicleFires` directly.
--- Each match is force-extinguished via `StopVehicleIncident`, identical to the
--- single-vehNet handler above.
RegisterNetEvent(Config.EventPrefix .. ':sfNpcVehicleFireSprayCompleteAtCoords')
AddEventHandler(Config.EventPrefix .. ':sfNpcVehicleFireSprayCompleteAtCoords', function(x, y, z, radius)
    if not UsingSmartFiresV2 then return end
    if GetResourceState('SmartFires') ~= 'started' then return end
    local cx, cy, cz = tonumber(x), tonumber(y), tonumber(z)
    local r = tonumber(radius)
    if not cx or not cy or not cz or not r or r <= 0 then
        ERS_SmartFires_Log(
            'NPC vehFire sprayComplete coords',
            'src=' .. tostring(source) .. ' bad payload'
                .. ' x=' .. tostring(x) .. ' y=' .. tostring(y) .. ' z=' .. tostring(z)
                .. ' r=' .. tostring(radius)
        )
        return
    end

    local src = source

    local ok, rows = pcall(function()
        return exports['SmartFires']:GetActiveVehicleFires({
            center = vector3(cx, cy, cz),
            radius = r,
        })
    end)
    if not ok or type(rows) ~= 'table' then
        ERS_SmartFires_Log(
            'NPC vehFire sprayComplete coords',
            'src=' .. tostring(src) .. ' GetActiveVehicleFires failed err=' .. tostring(rows)
        )
        return
    end

    -- Pick the SINGLE closest wreck fire instead of stopping every match. A
    -- spray cycle represents one firefighter aimed at one fire — extinguishing
    -- every wreck inside the search radius collapses tight pileups into a
    -- single instant kill (e.g. r=10m at a 5-car wreck = `rows=5 stopped=5/5`
    -- on the very first spray). The other wrecks still in the radius will be
    -- handled on the next iteration of the native-fire-fight thread (each ped
    -- re-runs `GetClosestFirePos` after every cycle), so each wreck still
    -- needs its own ~15s spray.
    local closestRow, closestDistSq
    for _, row in ipairs(rows) do
        local nid = row and tonumber(row.vehNet)
        local rc = row and row.coords
        local rx = rc and tonumber(rc.x)
        local ry = rc and tonumber(rc.y)
        local rz = rc and tonumber(rc.z)
        if nid and nid > 0 and rx and ry and rz then
            local dx, dy, dz = rx - cx, ry - cy, rz - cz
            local d2 = dx * dx + dy * dy + dz * dz
            if not closestDistSq or d2 < closestDistSq then
                closestRow = row
                closestDistSq = d2
            end
        end
    end

    local stopped, attempts = 0, 0
    local stopErrors = {}
    if closestRow then
        local nid = tonumber(closestRow.vehNet)
        if nid and nid > 0 then
            attempts = 1
            local stoppedOk, err = pcall(function()
                exports['SmartFires']:StopVehicleIncident(nid)
            end)
            if stoppedOk then
                stopped = 1
            else
                stopErrors[#stopErrors + 1] = tostring(nid) .. ':' .. tostring(err)
            end
        end
    end

    if #stopErrors > 0 then
        ERS_SmartFires_Log(
            'NPC vehFire sprayComplete coords',
            'src=' .. tostring(src) .. ' StopVehicleIncident errors=' .. table.concat(stopErrors, ',')
        )
    end

    local closestDistStr = closestDistSq and string.format('%.1f', math.sqrt(closestDistSq)) or '-'
    local closestNid = closestRow and tostring(closestRow.vehNet) or '-'
    ERS_SmartFires_Log(
        'NPC vehFire sprayComplete coords',
        'src=' .. tostring(src)
            .. ' at=' .. string.format('%.1f,%.1f,%.1f', cx, cy, cz)
            .. ' r=' .. tostring(r)
            .. ' candidates=' .. tostring(#rows)
            .. ' closest=' .. closestNid .. '@' .. closestDistStr .. 'm'
            .. ' stopped=' .. tostring(stopped)
            .. '/' .. tostring(attempts)
    )

    -- Diagnostic: if we got no rows, dump every active vehicle fire on the
    -- server with its distance from the spray point so we can tell whether
    -- the table is empty (timing / state issue) or our radius is just too
    -- tight (coords mismatch — common on big trucks where the wreck centre
    -- is several metres from the visible flame plume).
    if #rows == 0 then
        local diagOk, allRows = pcall(function()
            return exports['SmartFires']:GetActiveVehicleFires({})
        end)
        if diagOk and type(allRows) == 'table' then
            if #allRows == 0 then
                ERS_SmartFires_Log(
                    'NPC vehFire sprayComplete coords diag',
                    'src=' .. tostring(src) .. ' activeVehicleFires is empty (no wreck fires server-side)'
                )
            else
                local parts = {}
                for i, row in ipairs(allRows) do
                    if i > 8 then
                        parts[#parts + 1] = '... (' .. tostring(#allRows - 8) .. ' more)'
                        break
                    end
                    local rc = row and row.coords
                    local rx = rc and tonumber(rc.x)
                    local ry = rc and tonumber(rc.y)
                    local rz = rc and tonumber(rc.z)
                    local distStr = '?'
                    if rx and ry and rz then
                        local dx, dy, dz = rx - cx, ry - cy, rz - cz
                        local d = math.sqrt(dx * dx + dy * dy + dz * dz)
                        distStr = string.format('%.1f', d)
                    end
                    parts[#parts + 1] =
                        'vehNet=' .. tostring(row and row.vehNet)
                        .. ' dist=' .. distStr
                end
                ERS_SmartFires_Log(
                    'NPC vehFire sprayComplete coords diag',
                    'src=' .. tostring(src)
                        .. ' nearby radius=' .. tostring(r)
                        .. ' but server has ' .. tostring(#allRows)
                        .. ' active vehFires: ' .. table.concat(parts, ' | ')
                )
            end
        else
            ERS_SmartFires_Log(
                'NPC vehFire sprayComplete coords diag',
                'src=' .. tostring(src) .. ' GetActiveVehicleFires(no filter) failed err=' .. tostring(allRows)
            )
        end
    end

    if stopped > 0 then
        for _, callout in ipairs(ActiveCalloutsList) do
            if tonumber(callout.hostId) == tonumber(src) then
                if SFV2 and SFV2.InvalidateScope then SFV2.InvalidateScope(callout) end
                ERS_TriggerCalloutUserInterfaceForHost(callout.hostId)
                break
            end
        end
    end
end)

--- Read-only query for active SmartFires vehicle incidents inside `radius`
--- of `(x, y, z)`. Replies via `:sfNpcActiveVehFiresResult` with a list of
--- `{ vehNet, coords = {x, y, z} }`. Used by the NPC firefighter "chase
--- remaining vehicle fires" phase to decide whether the crew still has work
--- to do — this handler does NOT stop any fires, it only reports them, so
--- the actual extinguishment continues to flow through the regular per-spray
--- `:sfNpcVehicleFireSprayCompleteAtCoords` path (one wreck per spray cycle).
---
--- Always replies, even on error, so the client's awaiting fetcher does not
--- hang. `qid` is an opaque correlation id picked by the client.
RegisterNetEvent(Config.EventPrefix .. ':sfNpcQueryActiveVehFires')
AddEventHandler(Config.EventPrefix .. ':sfNpcQueryActiveVehFires', function(qid, x, y, z, radius)
    local src = source

    local function reply(list)
        TriggerClientEvent(
            Config.EventPrefix .. ':sfNpcActiveVehFiresResult',
            src,
            qid,
            list or {}
        )
    end

    if type(qid) ~= 'string' then return end
    if not UsingSmartFiresV2 or GetResourceState('SmartFires') ~= 'started' then
        reply({})
        return
    end

    local cx, cy, cz = tonumber(x), tonumber(y), tonumber(z)
    local r = tonumber(radius)
    if not cx or not cy or not cz or not r or r <= 0 then
        reply({})
        return
    end

    local ok, rows = pcall(function()
        return exports['SmartFires']:GetActiveVehicleFires({
            center = vector3(cx, cy, cz),
            radius = r,
        })
    end)
    if not ok or type(rows) ~= 'table' then
        ERS_SmartFires_Log(
            'NPC vehFire query',
            'src=' .. tostring(src) .. ' GetActiveVehicleFires failed err=' .. tostring(rows)
        )
        reply({})
        return
    end

    local out = {}
    for _, row in ipairs(rows) do
        local nid = row and tonumber(row.vehNet)
        local rc = row and row.coords
        local rx = rc and tonumber(rc.x)
        local ry = rc and tonumber(rc.y)
        local rz = rc and tonumber(rc.z)
        if nid and nid > 0 and rx and ry and rz then
            out[#out + 1] = {
                vehNet = nid,
                coords = { x = rx, y = ry, z = rz },
            }
        end
    end

    if #out > 0 then
        ERS_SmartFires_Log(
            'NPC vehFire query',
            'src=' .. tostring(src)
                .. ' at=' .. string.format('%.1f,%.1f,%.1f', cx, cy, cz)
                .. ' r=' .. tostring(r)
                .. ' found=' .. tostring(#out)
        )
    end

    reply(out)
end)

--- Client/NPC: full spawn-site visual purge (SmartFires FX at forest multi-spawn callouts).
RegisterNetEvent(Config.EventPrefix .. ':sfRequestSpawnCleanup')
AddEventHandler(Config.EventPrefix .. ':sfRequestSpawnCleanup', function(calloutFireIds)
    if not UsingSmartFiresV2 or type(calloutFireIds) ~= 'table' then
        return
    end
    local idSet = {}
    for _, id in ipairs(calloutFireIds) do
        if id ~= nil then
            idSet[tostring(id)] = true
        end
    end
    if not next(idSet) then
        return
    end
    for _, callout in ipairs(ActiveCalloutsList) do
        local match = false
        for _, id in ipairs(callout.fireList or {}) do
            if id ~= nil and idSet[tostring(id)] then
                match = true
                break
            end
        end
        if not match then
            for _, id in ipairs(callout.sfAllSpawnIds or {}) do
                if id ~= nil and idSet[tostring(id)] then
                    match = true
                    break
                end
            end
        end
        if match then
            ERS_SmartFires_StopAllRegisteredSpawnHosts(callout)
            Wait(100)
            ERS_SmartFires_V2BroadcastStopForGoneSpawnIds(callout)
            local sites = ERS_SmartFires_BroadcastSpawnSiteCleanup(callout, calloutFireIds, 'npc_spawn_cleanup')
            ERS_SmartFires_Log(
                'NPC_SPAWN_CLEANUP',
                'callout=' .. tostring(callout.calloutId) .. ' sites=' .. tostring(sites)
            )
            return
        end
    end
end)

--- Client/NPC: immediate gone-incident FX sweep + HUD sync (ghost flames at dead spawn ids).
RegisterNetEvent(Config.EventPrefix .. ':sfRequestGoneFxSweep')
AddEventHandler(Config.EventPrefix .. ':sfRequestGoneFxSweep', function(calloutFireIds)
    if not UsingSmartFiresV2 or type(calloutFireIds) ~= 'table' then
        return
    end
    local idSet = {}
    for _, id in ipairs(calloutFireIds) do
        if id ~= nil then
            idSet[tostring(id)] = true
        end
    end
    if not next(idSet) then
        return
    end
    for _, callout in ipairs(ActiveCalloutsList) do
        local match = false
        for _, id in ipairs(callout.fireList or {}) do
            if id ~= nil and idSet[tostring(id)] then
                match = true
                break
            end
        end
        if not match then
            for _, id in ipairs(callout.sfAllSpawnIds or {}) do
                if id ~= nil and idSet[tostring(id)] then
                    match = true
                    break
                end
            end
        end
        if match then
            local stopped = ERS_SmartFires_V2BroadcastStopForGoneSpawnIds(callout)
            local nativeSites = ERS_SmartFires_BroadcastSpawnSiteCleanup(callout, calloutFireIds, 'gone_fx_sweep')
            -- Recompute HUD via the canonical-deduped scope path. The legacy
            -- `ERS_SmartFires_V2RefreshCalloutHud` is intentionally not called
            -- here: it ran a parallel node-count-based locker that stomped the
            -- scope-derived baseline every gone-FX event, locking the HUD at
            -- the pre-merge spawn peak (e.g. "8/27" for a 31-spawn forest_fire).
            SFV2.InvalidateScope(callout)
            SFV2.GetHudCounts(callout)
            TriggerClientEvent(Config.EventPrefix .. ':updateCalloutData', -1, ActiveCalloutsList)
            if callout.hostId then
                ERS_TriggerCalloutUserInterfaceForHost(callout.hostId)
            end
            ERS_SmartFires_Log(
                'GONE_FX_SWEEP',
                'callout=' .. tostring(callout.calloutId)
                .. ' stopped=' .. tostring(stopped)
                .. ' nativeSites=' .. tostring(nativeSites)
            )
            return
        end
    end
end)
