-- ============================================================================
--  Smart Fires Lite (London Studios — free release) bridge
-- ============================================================================
--  Thin wrappers around the Lite export surface. Called by the top-level
--  dispatcher in `server/smartfires/bridge.lua` when `UsingSmartFiresLite`
--  is true (the convar `SmartFiresV2` is off and `SmartFiresLite` resource
--  started).
--
--  Lite mirrors the v1 surface byte-for-byte; the only difference is the
--  target resource name and the absence of advanced fire types (callouts
--  must pass `"normal"`).
--
--  Do NOT add v2 logic here. Add it under `server/smartfires/v2/` instead.
-- ============================================================================

local SFL_RES = 'SmartFiresLite'

function ERS_SmartFires_Lite_CreateFireAtCoords(coords, radius, fireType)
    return exports[SFL_RES]:CreateFire(coords, radius, fireType)
end

function ERS_SmartFires_Lite_CreateSmokeAtCoords(coords, radius, smokeType)
    return exports[SFL_RES]:CreateSmoke(coords, radius, smokeType)
end

function ERS_SmartFires_Lite_StopFire(id)
    if id == nil then return false end
    exports[SFL_RES]:StopFireById(id)
    return true
end

function ERS_SmartFires_Lite_StopSmoke(id)
    if id == nil then return false end
    exports[SFL_RES]:StopSmokeById(id)
    return true
end

function ERS_SmartFires_Lite_IsFireStillActive(id)
    if id == nil then return false end
    return exports[SFL_RES]:IsFireStillActive(id)
end

function ERS_SmartFires_Lite_IsSmokeStillActive(id)
    if id == nil then return false end
    return exports[SFL_RES]:IsSmokeStillActive(id)
end

function ERS_SmartFires_Lite_GetFiresIncidentMap()
    if GetResourceState(SFL_RES) ~= 'started' then return {} end
    local ok, fires = pcall(function() return exports[SFL_RES]:GetAllFires() end)
    if not ok or type(fires) ~= 'table' then return {} end
    return fires
end

function ERS_SmartFires_Lite_GetSmokesIncidentMap()
    if GetResourceState(SFL_RES) ~= 'started' then return {} end
    local ok, smokes = pcall(function() return exports[SFL_RES]:GetAllSmokes() end)
    if not ok or type(smokes) ~= 'table' then return {} end
    return smokes
end
