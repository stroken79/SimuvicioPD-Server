-- ============================================================================
--  Smart Fires v1 (London Studios — full release) bridge
-- ============================================================================
--  Thin wrappers around the v1 export surface. Called by the top-level
--  dispatcher in `server/smartfires/bridge.lua` when `UsingSmartFires` is
--  true (the convar `SmartFiresV2` is off and `SmartFires` resource started).
--
--  v1 has no incident lifecycle, no merge, no flame-node concept — every
--  function below is essentially a 1:1 forward to the v1 export. The
--  per-version naming (`ERS_SmartFires_V1_*`) lets the top-level dispatcher
--  pick the right backend at call-time without touching the underlying
--  resource directly.
--
--  Do NOT add v2 logic here. Add it under `server/smartfires/v2/` instead.
-- ============================================================================

local SF_RES = 'SmartFires'

--- v1 CreateFire wrapper. opts is accepted for signature parity with the
--- dispatcher but ignored — v1 has no merge / interior overrides.
function ERS_SmartFires_V1_CreateFireAtCoords(coords, radius, fireType)
    return exports[SF_RES]:CreateFire(coords, radius, fireType)
end

function ERS_SmartFires_V1_CreateSmokeAtCoords(coords, radius, smokeType)
    return exports[SF_RES]:CreateSmoke(coords, radius, smokeType)
end

function ERS_SmartFires_V1_StopFire(id)
    if id == nil then return false end
    exports[SF_RES]:StopFireById(id)
    return true
end

function ERS_SmartFires_V1_StopSmoke(id)
    if id == nil then return false end
    exports[SF_RES]:StopSmokeById(id)
    return true
end

function ERS_SmartFires_V1_IsFireStillActive(id)
    if id == nil then return false end
    return exports[SF_RES]:IsFireStillActive(id)
end

function ERS_SmartFires_V1_IsSmokeStillActive(id)
    if id == nil then return false end
    return exports[SF_RES]:IsSmokeStillActive(id)
end

--- v1 `GetAllFires` returns an incident-id-keyed map. Top-level
--- `ERS_SmartFires_GetFiresIncidentMap` consumes it directly.
function ERS_SmartFires_V1_GetFiresIncidentMap()
    if GetResourceState(SF_RES) ~= 'started' then return {} end
    local ok, fires = pcall(function() return exports[SF_RES]:GetAllFires() end)
    if not ok or type(fires) ~= 'table' then return {} end
    return fires
end

function ERS_SmartFires_V1_GetSmokesIncidentMap()
    if GetResourceState(SF_RES) ~= 'started' then return {} end
    local ok, smokes = pcall(function() return exports[SF_RES]:GetAllSmokes() end)
    if not ok or type(smokes) ~= 'table' then return {} end
    return smokes
end
