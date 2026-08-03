-- ============================================================================
--  Smart Fires bridge (top-level dispatcher)
-- ============================================================================
--  Cross-version entry point for every Smart Fires call in ERS. Routes
--  CreateFire/StopFire/etc. to the right backend (v1, Lite, or v2) and hosts
--  the public callout helpers (`ERS_AddCalloutFire`, `_Smoke`, `_StopCallout`).
--
--  Per-version implementations:
--    server/smartfires/v1/bridge.lua    - Smart Fires (full v1) wrappers
--    server/smartfires/lite/bridge.lua  - Smart Fires Lite wrappers
--    server/smartfires/v2/bridge.lua    - Smart Fires v2 (the bulk)
--
--  Sibling V2 modules under `server/smartfires/v2/` (scope, hud, spawn, npc,
--  teardown, events) implement the SFV2.* contract (see
--  `shared/smartfires_v2_contract.lua`).
--
--  Backend selection is driven by `UsingSmartFiresV2 / UsingSmartFires /
--  UsingSmartFiresLite` (set in `server.lua` from convars and resource
--  state). Every dispatcher below early-returns when no SmartFires resource
--  is running so the callout pipeline degrades gracefully.
-- ============================================================================

local SF_RES = 'SmartFires'
local SFL_RES = 'SmartFiresLite'

-- ============================================================================
--  Shared utilities
-- ============================================================================

--- Structured Smart Fires trace, gated by the internal `SFV2._INTERNAL_DEBUG`
--- switch in `shared/smartfires_v2_contract.lua` (or full `Config.Debug`).
--- All lines: `[ERS-SF] <STEP> | <detail>`.
function ERS_SmartFires_Log(step, detail)
    local enabled = SFV2 and SFV2.IsDebug and SFV2.IsDebug()
    if enabled then
        print('[ERS-SF] ' .. tostring(step) .. (detail and (' | ' .. tostring(detail)) or ''))
    end
end

--- Normalize a vector3/vector4/{x,y,z} table into a plain vector3. Returns
--- nil for anything that doesn't carry coordinates.
function ERS_SmartFires_CoordsToVector(c)
    if not c then
        return nil
    end
    local t = type(c)
    if t == 'vector3' or t == 'vector4' then
        return vector3(c.x + 0.0, c.y + 0.0, c.z + 0.0)
    end
    if t == 'table' then
        local x = tonumber(c.x) or tonumber(c.X)
        local y = tonumber(c.y) or tonumber(c.Y)
        local z = tonumber(c.z) or tonumber(c.Z)
        if x and y and z then
            return vector3(x, y, z)
        end
    end
    return nil
end

function ERS_SmartFires_HasAnyFireResourceStarted()
    return GetResourceState(SF_RES) == 'started' or GetResourceState(SFL_RES) == 'started'
end

-- ============================================================================
--  Version dispatchers
-- ============================================================================

--- Cross-version CreateFire wrapper. The public `ERS_AddCalloutFire` helper
--- below sits on top of this; callout code should prefer the helper so the
--- callout's `fireList` bookkeeping is maintained.
---@param coords vector3|table
---@param radius number
---@param fireType string|nil  on V2, pass `'indoors'` to force indoor placement
---                            regardless of where coords probe. Any other type
---                            is still classified indoor automatically when
---                            the coords sit inside a probed interior.
---@param opts table|nil  options table (V2 only; V1/Lite ignore it):
---                       - `interiorId` (number, default 0 = auto-probe coords):
---                         force a specific interior id when the coord-based
---                         probe misses the right one.
---@return any|nil  incidentId / fireId (depends on backend version)
function ERS_SmartFires_CreateFireAtCoords(coords, radius, fireType, opts)
    fireType = fireType or 'normal'
    if UsingSmartFiresV2 then
        return ERS_SmartFires_V2_CreateFireAtCoords(coords, radius, fireType, opts)
    end
    if UsingSmartFires then
        return ERS_SmartFires_V1_CreateFireAtCoords(coords, radius, fireType)
    end
    return ERS_SmartFires_Lite_CreateFireAtCoords(coords, radius, fireType)
end

function ERS_SmartFires_CreateSmokeAtCoords(coords, radius, smokeType)
    smokeType = smokeType or 'normal'
    if UsingSmartFiresV2 then
        return ERS_SmartFires_V2_CreateSmokeAtCoords(coords, radius, smokeType)
    end
    if UsingSmartFires then
        return ERS_SmartFires_V1_CreateSmokeAtCoords(coords, radius, smokeType)
    end
    return ERS_SmartFires_Lite_CreateSmokeAtCoords(coords, radius, smokeType)
end

function ERS_SmartFires_StopFire(id)
    if id == nil then
        ERS_SmartFires_Log('STOP_FIRE skip', 'id=nil')
        return nil
    end
    if ERS_SmartFires_UsesV2IncidentApi() then
        return ERS_SmartFires_V2_StopFire(id)
    end
    if UsingSmartFires then
        return ERS_SmartFires_V1_StopFire(id)
    end
    return ERS_SmartFires_Lite_StopFire(id)
end

function ERS_SmartFires_StopSmoke(id)
    if id == nil then return false end
    if UsingSmartFiresV2 then
        return ERS_SmartFires_V2_StopSmoke(id)
    end
    if UsingSmartFires then
        return ERS_SmartFires_V1_StopSmoke(id)
    end
    return ERS_SmartFires_Lite_StopSmoke(id)
end

--- v2 active-check: `GetIncidentStatus` + server `GetAllFires`. v1/Lite call
--- their export directly.
function ERS_SmartFires_IsFireStillActive(storedId, debugLabel)
    if UsingSmartFiresV2 then
        local keep = ERS_SmartFires_V2_IsFireStillActive(storedId)
        if debugLabel and not keep then
            ERS_SmartFires_DebugIncident(debugLabel .. " -> inactive", storedId)
        end
        return keep
    end
    if UsingSmartFires then
        return ERS_SmartFires_V1_IsFireStillActive(storedId)
    end
    return ERS_SmartFires_Lite_IsFireStillActive(storedId)
end

function ERS_SmartFires_IsSmokeStillActive(storedId)
    if UsingSmartFiresV2 then
        return ERS_SmartFires_V2_IsSmokeStillActive(storedId)
    end
    if UsingSmartFires then
        return ERS_SmartFires_V1_IsSmokeStillActive(storedId)
    end
    return ERS_SmartFires_Lite_IsSmokeStillActive(storedId)
end

function ERS_SmartFires_ServerIsFireStillActiveForStop(id)
    if UsingSmartFiresV2 then
        return ERS_SmartFires_IsFireStillActive(id)
    end
    if UsingSmartFires then
        return ERS_SmartFires_V1_IsFireStillActive(id)
    end
    return ERS_SmartFires_Lite_IsFireStillActive(id)
end

function ERS_SmartFires_ServerIsSmokeStillActiveForStop(id)
    if UsingSmartFiresV2 then
        return ERS_SmartFires_IsSmokeStillActive(id)
    end
    if UsingSmartFires then
        return ERS_SmartFires_V1_IsSmokeStillActive(id)
    end
    return ERS_SmartFires_Lite_IsSmokeStillActive(id)
end

--- Keyed map [incidentId] = row from the right backend. Used by NPC scope /
--- spread-discovery code.
function ERS_SmartFires_GetFiresIncidentMap()
    if UsingSmartFiresV2 then
        return ERS_SmartFires_V2_GetFiresIncidentMap()
    end
    if UsingSmartFires then
        return ERS_SmartFires_V1_GetFiresIncidentMap()
    end
    if UsingSmartFiresLite then
        return ERS_SmartFires_Lite_GetFiresIncidentMap()
    end
    return {}
end

function ERS_SmartFires_GetSmokesIncidentMap()
    if UsingSmartFiresV2 then
        return ERS_SmartFires_V2_GetSmokesIncidentMap()
    end
    if UsingSmartFires then
        return ERS_SmartFires_V1_GetSmokesIncidentMap()
    end
    if UsingSmartFiresLite then
        return ERS_SmartFires_Lite_GetSmokesIncidentMap()
    end
    return {}
end

--- Callout `fireList`: keep while server still has a real flame node for this stored id.
--- V2 uses incident lifecycle + `GetAllFires` rows; v1/Lite delegate to their
--- backend's `IsFireStillActive`.
function ERS_SmartFires_ShouldKeepCalloutFireSlot(storedId)
    if not UsingSmartFiresV2 then
        return ERS_SmartFires_IsFireStillActive(storedId)
    end
    if ERS_SmartFires_V2HasLiveContribution(storedId) then
        return true
    end
    local status = ERS_SmartFires_GetIncidentStatus(storedId)
    if status and (status.state == 'gone' or status.state == 'invalid') then
        return false
    end
    return false
end

function ERS_SmartFires_ShouldKeepCalloutSmokeSlot(storedId)
    if not UsingSmartFiresV2 then
        return ERS_SmartFires_IsSmokeStillActive(storedId)
    end
    local want = tostring(storedId)
    for key, row in pairs(ERS_SmartFires_GetSmokesIncidentMap()) do
        if tostring(key) == want then
            return true
        end
        if row then
            local inc = row.incidentId or row.originalId
            if inc ~= nil and tostring(inc) == want then
                return true
            end
        end
    end
    return false
end

-- ============================================================================
--  Cross-version teardown helpers
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

--- NPC backup / per-slot clear: always stop the stored CreateFire id (v2 partial stop after merge).
--- v2 cancel / teardown: stop each distinct incident id once.
function ERS_SmartFires_StopAllCalloutFires(fireList)
    if not fireList then
        ERS_SmartFires_Log('STOP_ALL skip', 'fireList=nil')
        return
    end
    ERS_SmartFires_Log('STOP_ALL begin', SF_IdsSummary(fireList))

    local seen = {}
    for _, id in ipairs(fireList) do
        if id ~= nil then
            local key = tostring(id)
            if not seen[key] then
                seen[key] = true
                local stopId = ERS_SmartFires_UsesV2IncidentApi()
                    and (ERS_SmartFires_V2ResolveMasterIncidentId(id) or id)
                    or id
                local ok = ERS_SmartFires_StopFire(stopId)
                ERS_SmartFires_Log('STOP_ALL', 'id=' .. tostring(stopId) .. ' ok=' .. tostring(ok))
            end
        end
    end

    ERS_SmartFires_Log('STOP_ALL end', SF_IdsSummary(fireList))
end

function ERS_SmartFires_StopAllCalloutSmokes(smokeList)
    if not smokeList or #smokeList < 1 then
        return
    end
    ERS_SmartFires_Log('STOP_ALL_SMOKES begin', SF_IdsSummary(smokeList))
    for _, id in ipairs(smokeList) do
        if id ~= nil then
            local ok = ERS_SmartFires_StopSmoke(id)
            ERS_SmartFires_Log('STOP_ALL_SMOKES', 'id=' .. tostring(id) .. ' ok=' .. tostring(ok))
        end
    end
    ERS_SmartFires_Log('STOP_ALL_SMOKES end', SF_IdsSummary(smokeList))
end

function ERS_SmartFires_AppendNpcFireTasksNearCoords(targetCoordinates, rangeM, taskList)
    if not taskList or not targetCoordinates then
        return 0
    end
    local center = ERS_SmartFires_CoordsToVector(targetCoordinates)
    if not center then
        return 0
    end
    local range = tonumber(rangeM) or 100.0
    local known = {}
    for _, e in ipairs(taskList) do
        if e and e.fireId ~= nil then
            known[tostring(e.fireId)] = true
        end
    end
    local added = 0
    for fireId, row in pairs(ERS_SmartFires_GetFiresIncidentMap()) do
        local key = tostring(fireId)
        if not known[key] and row and row.coords then
            local pos = ERS_SmartFires_CoordsToVector(row.coords)
            if pos and #(center - pos) <= range then
                known[key] = true
                taskList[#taskList + 1] = { fireId = fireId, fireData = row }
                added = added + 1
            end
        end
    end
    return added
end

function ERS_SmartFires_AppendNpcSmokeTasksNearCoords(targetCoordinates, rangeM, taskList)
    if not taskList or not targetCoordinates then
        return 0
    end
    local center = ERS_SmartFires_CoordsToVector(targetCoordinates)
    if not center then
        return 0
    end
    local range = tonumber(rangeM) or 100.0
    local known = {}
    for _, e in ipairs(taskList) do
        if e and e.smokeId ~= nil then
            known[tostring(e.smokeId)] = true
        end
    end
    local added = 0
    for smokeId, row in pairs(ERS_SmartFires_GetSmokesIncidentMap()) do
        local key = tostring(smokeId)
        if not known[key] and row and row.coords then
            local pos = ERS_SmartFires_CoordsToVector(row.coords)
            if pos and #(center - pos) <= range then
                known[key] = true
                taskList[#taskList + 1] = { smokeId = smokeId, smokeData = row }
                added = added + 1
            end
        end
    end
    return added
end

-- ============================================================================
--  Public callout helpers (V1 / Lite / V2 transparent)
-- ============================================================================
--  These are the only sanctioned way to spawn / stop callout fires in ERS.
--  They wrap CreateFireAtCoords / CreateSmokeAtCoords / StopFire with version
--  routing, gap pacing (V2), and resource-state validation. Callouts ALWAYS
--  capture the returned id and append it to their own `fireList` / `smokeList`
--  themselves:
--
--      local id = ERS_AddCalloutFire(coords, fireType, fireSize)
--      if id then fireList[#fireList + 1] = id end
--
--  Why is the table.insert on the caller? FiveM serializes table arguments
--  across resource boundaries via msgpack — when a callout pack (e.g. CP1)
--  calls `exports['night_ers']:ERS_AddCalloutFire(...)`, the pack's local
--  fireList is COPIED into night_ers's VM. Any mutation here would happen on
--  the copy and never reach the pack's original list, leaving ERS with an
--  empty `callout.fireList` (no HUD, no NPC backup, no teardown). Returning
--  the id and letting the caller do the `table.insert` in its own VM is the
--  only pattern that works correctly for both in-resource and cross-resource
--  callers.
--
--  Exposed as globals (for in-resource callouts in
--  `night_ers/callouts/plugins/`) and re-exported in `exports_server.lua` for
--  CP1 / external packs. Calling vanilla `exports['SmartFires']:CreateFire(...)`
--  inside an ERS callout is NOT supported: ERS HUD, NPC backup and cleanup
--  all read off the `fireList` these helpers populate.
-- ============================================================================

--- Spawn a fire for a callout. Callers must append the returned id to their
--- own `fireList` so ERS can track it (see header for why the helper does not
--- do this internally).
---@param coords vector3|table
---@param fireType string  exact backend fire type. Common values: any preset
---                        from Config.NormalFireTypes / ChemicalFire /
---                        ElectricalFire / BonFire on V1/V2; `'normal'` on
---                        Lite. Pass `'indoors'` (V2) to force an indoor
---                        incident regardless of coord probe.
---@param size number  size value (typically picked from
---                    Config.Random*FireOrSmokeSize)
---@param opts table|nil  options table (V2 only; V1/Lite ignore it):
---                       - `interiorId` (number, default 0 = auto-probe coords):
---                         force a specific interior id. SmartFires already
---                         auto-detects indoor placement from the coords, so
---                         only set this when the auto-probe misses the right
---                         interior (rare; custom MLOs).
---                       Note: all fires use SmartFires' default merge
---                       behaviour. Spawns close enough to each other are
---                       absorbed into one host on the HUD. Space coords
---                       beyond the engine's merge radius if you need each
---                       spawn to stay a distinct front.
---@return any|nil  incidentId / fireId; nil if SmartFires is not running
function ERS_AddCalloutFire(coords, fireType, size, opts)
    if not (UsingSmartFiresV2 or UsingSmartFires or UsingSmartFiresLite) then return nil end
    if not ERS_SmartFires_HasAnyFireResourceStarted() then return nil end
    return ERS_SmartFires_CreateFireAtCoords(coords, size, fireType, opts)
end

--- Spawn a smoke for a callout. Callers must append the returned id to their
--- own `smokeList`.
---@param coords vector3|table
---@param smokeType string  backend smoke type
---@param size number  size value
---@return any|nil  smokeId; nil if SmartFires is not running
function ERS_AddCalloutSmoke(coords, smokeType, size)
    if not (UsingSmartFiresV2 or UsingSmartFires or UsingSmartFiresLite) then return nil end
    if not ERS_SmartFires_HasAnyFireResourceStarted() then return nil end
    return ERS_SmartFires_CreateSmokeAtCoords(coords, size, smokeType)
end

--- Stop a fire previously added via `ERS_AddCalloutFire`. Callers are
--- responsible for removing the id from their own `fireList` (see header).
---@param id any  incidentId returned by ERS_AddCalloutFire
---@return boolean ok  true when StopFire succeeded or the incident was already gone
function ERS_StopCalloutFire(id)
    if id == nil then return false end
    local result = ERS_SmartFires_StopFire(id)
    return result ~= false
end
