--====================== SERVERSIDE EXPORTS ======================--

-- local isOnShift = exports['night_ers']:getIsPlayerOnShift(src)
exports('getIsPlayerOnShift', function(src)
    return getIsPlayerOnShift(src)
end)

-- local getPlayerActiveServiceType = exports['night_ers']:getPlayerActiveServiceType(src)
exports('getPlayerActiveServiceType', function(src)
    -- Returns: "police", "ambulance", "fire", "tow" or nil
    return getPlayerActiveServiceType(src)
end)

-- exports['night_ers']:toggleShift(source, shiftType)
exports('toggleShift', function(source, shiftType)
    ToggleShift(source, shiftType) -- shiftType can be "police", "ambulance", "fire" or "tow"
end)

-- exports['night_ers']:trackPlayerCallout(source, targetSource)
exports('trackPlayerCallout', function(source, targetSource)
    TrackUnit(source, targetSource)
end)

-- exports['night_ers']:setPlayerCalloutOffersEnabled(source, enabled)
exports('setPlayerCalloutOffersEnabled', function(source, enabled)
    SetPlayerCalloutOffersEnabled(source, enabled)
end)

-- exports['night_ers']:getCallouts()
exports('getCallouts', function()
    local jsonReadyTable = cloneWithoutFunctions(Config.Callouts)
    return jsonReadyTable
end)

-- exports['night_ers']:GetRandomModel(modelList)
exports('GetRandomModel', function(modelList)
    return ERS_GetRandomModel(modelList)
end)

-- exports['night_ers']:GetRandomPedModel()
exports('GetRandomPedModel', function()
    local list = Config.randomPeds or { "a_m_m_bevhills_01", "a_m_y_hipster_01" }
    return ERS_GetRandomModel(list)
end)

-- In night_ers (e.g. in a shared or config file)
exports('GetFireConfig', function()
    return {
        RandomHugeFireOrSmokeSize   = Config.RandomHugeFireOrSmokeSize,
        RandomLargeFireOrSmokeSize  = Config.RandomLargeFireOrSmokeSize,
        RandomMediumFireOrSmokeSize = Config.RandomMediumFireOrSmokeSize,
        RandomSmallFireOrSmokeSize  = Config.RandomSmallFireOrSmokeSize,
        NormalFireTypes  = Config.NormalFireTypes,
        ElectricalFire   = Config.ElectricalFire,
        ChemicalFire     = Config.ChemicalFire,
        BonFire          = Config.BonFire,
        UsingSmartFires     = UsingSmartFires,
        UsingSmartFiresV2   = UsingSmartFiresV2,
        UsingSmartFiresLite = UsingSmartFiresLite,
    }
end)

-- Pack / external resources: server-side Smart Fires via night_ers bridge (v1 full / Lite / v2).
-- These three helpers are the only sanctioned spawn path for callout fires.
-- They wrap CreateFire / CreateSmoke / StopFire with version routing, gap
-- pacing, and resource-state validation. The caller MUST capture the returned
-- id and append it to its own `fireList` / `smokeList` (FiveM serializes table
-- arguments across resources via msgpack, so the helper cannot mutate the
-- caller's list directly).
--
-- exports['night_ers']:ERS_AddCalloutFire(coords, fireType, size, opts) -> incidentId|nil
exports('ERS_AddCalloutFire', function(coords, fireType, size, opts)
    return ERS_AddCalloutFire(coords, fireType, size, opts)
end)

-- exports['night_ers']:ERS_AddCalloutSmoke(coords, smokeType, size) -> smokeId|nil
exports('ERS_AddCalloutSmoke', function(coords, smokeType, size)
    return ERS_AddCalloutSmoke(coords, smokeType, size)
end)

-- exports['night_ers']:ERS_StopCalloutFire(id) -> ok
exports('ERS_StopCalloutFire', function(id)
    return ERS_StopCalloutFire(id)
end)

-- Smart Fires v2 only: diagnostic status for a stored CreateFire id (`active` / `merged` / `gone` / `invalid`).
exports('ERS_GetSmartFireIncidentStatus', function(incidentId)
    return ERS_SmartFires_GetIncidentStatus(incidentId)
end)

exports('ERS_CountOutstandingFireTargets', function(fireList, sceneCenter, radiusM)
    return ERS_SmartFires_V2CountOutstandingFireTargets(fireList, sceneCenter, radiusM)
end)

exports('ERS_HasLiveFireContribution', function(storedId)
    return ERS_SmartFires_V2HasLiveContribution(storedId)
end)

-- exports['night_ers']:createCallout(callout)
-- exports['night_ers']:getPostal(x, y) — server 2D postal (static data or rHUD get_postal(vector2))
exports('getPostal', function(x, y)
    return getPostal(x, y)
end)

-- exports['night_ers']:getPostalForPlayer(source) — ModernHUD / SimpleHUD getPostal(source), else ped coords + getPostal
exports('getPostalForPlayer', function(source)
    return getPostalForPlayer(source)
end)

-- exports['night_ers']:SendCalloutOfferToPlayer(source[, calloutId[, timeoutMs]])
-- Third arg: omitted / false / -1 / invalid ⇒ 5000 ms max wait for a reply from that player's client; positive number = custom ms (always capped — no infinite wait).
exports('SendCalloutOfferToPlayer', function(source, calloutId, timeoutMs)
    return SendCalloutOfferToPlayer(source, calloutId, timeoutMs)
end)

exports('createCallout', function(callout)
    local newCalloutID = callout.id .. '-' .. os.time()
    Config.Callouts[newCalloutID] = Config.Callouts[callout.id]
    Config.Callouts[newCalloutID].id = newCalloutID
    Config.Callouts[newCalloutID].CalloutLocations = callout.data.CalloutLocations
    Config.Callouts[newCalloutID].PedWeaponData = callout.data.PedWeaponData
    Config.Callouts[newCalloutID].PedActionOnNoActionFound = callout.data.PedActionOnNoActionFound
    Config.Callouts[newCalloutID].PedChanceToFleeFromPlayer = callout.data.PedChanceToFleeFromPlayer
    Config.Callouts[newCalloutID].PedChanceToObtainWeapons = callout.data.PedChanceToObtainWeapons
    Config.Callouts[newCalloutID].PedChanceToAttackPlayer = callout.data.PedChanceToAttackPlayer
    Config.Callouts[newCalloutID].PedChanceToSurrender = callout.data.PedChanceToSurrender
    local returnData = {
        calloutId = newCalloutID,
    }
    return returnData
end)