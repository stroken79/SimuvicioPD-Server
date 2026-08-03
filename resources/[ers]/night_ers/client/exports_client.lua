--====================== CLIENTSIDE EXPORTS ======================--

exports('isPullOverSteeringModeEnabled', function()
    return isKeyboardSteeringMode
end)

-- local isOnShift = exports['night_ers']:getIsPlayerOnShift()
exports('getIsPlayerOnShift', function()
    -- Returns: true or false
    return isPlayerOnShift
end)

-- local getPlayerActiveServiceType = exports['night_ers']:getPlayerActiveServiceType()
exports('getPlayerActiveServiceType', function()
    -- Returns: "police", "ambulance", "fire", "tow" or nil
    return selectedService
end)

exports('getIsPlayerAttachedToCallout', function()
    -- Returns: true or false
    return isAttachedToCallout
end)

exports('LoadAnimDict', function(dict)
    return LoadAnimDict(dict)
end)

exports('getIsPlayerOfferedACallout', function()
    -- Returns: true or false
    return isOfferedCallout
end)

exports('getIsPlayerTrackingUnit', function()
    -- Returns: true or false
    return isTrackingUnit.isTracking
end)

exports('getIsPedAnAnimalPed', function(ped)
    return ERS_IsPedAnAnimalPed(ped)
end)

exports('toggleDispatchMessages', function()
    ToggleDispatchMessages()
end)

exports('toggleCallouts', function()
    ToggleCallouts()
end)

exports('playRadioAnimation', function()
    PlayRadioAnimation()
end)

exports('toggleHints', function()
    ToggleHints()
end)

exports('toggleShift', function(shiftType)
    ToggleShift(shiftType) -- shiftType can be "police", "ambulance", "fire" or "tow"
end)

exports('trackPlayerCallout', function(targetSource)
    TrackUnit(targetSource)
end)

exports('ERS_PedEquipWeapon', function(pedEntityId, weaponModelName, ammo)
    ERS_PedEquipWeapon(pedEntityId, weaponModelName, ammo)
end)

exports('SetERSVehicleInfoDisplay', function(display)
    SetERSVehicleInfoDisplay(display)
end)

exports('SetERSIDCardInfoDisplay', function(display)
    SetERSIDCardInfoDisplay(display)
end)

--====================== EXTERNAL: NPC BACKUP (other resources) ======================--
-- Client-side only; ensure / dependency on night_ers. Pursuit backups require pursuit mode.
--
-- Pursuit dispatch — unitType matches Config.PursuitBackupTypes[].PursuitType ("light"|"medium"|"heavy"|"air"|"army").
-- Calling RequestNPCPursuitBackup again with the same unitType while pending toggles cancel. Returns dispatched, reason (see ERS_RequestOrCancelPursuitBackupByType).
exports('RequestNPCPursuitBackup', function(unitType)
    return ERS_RequestOrCancelPursuitBackupByType(unitType)
end)

-- Explicit pursuit cancel; optional serverDeleteDelayMs (see pursuit_client CancelPursuitBackupRequest).
exports('CancelNPCPursuitBackup', function(serverDeleteDelayMs)
    CancelPursuitBackupRequest(tonumber(serverDeleteDelayMs) or 0)
end)

-- Road / service backup — backupType: ambulance|police|taxi|tow|roadservice|coroner|animalrescue|mechanic|fire (any casing).
-- Request: returns dispatched, reason — dispatched true when backupType matched and entered internal Request* path; false + reason "unknown_backup_type" otherwise.
exports('RequestNPCBackup', function(backupType)
    return RequestNPCBackupByType(backupType)
end)

exports('CancelNPCBackup', function(backupType, mustNotify)
    CancelNPCBackupByType(backupType, mustNotify)
end)

-- Legacy export names — same behaviour as the four above (kept for old integrations; undocumented).
exports('ERS_RequestOrCancelPursuitBackupByType', function(unitType)
    return ERS_RequestOrCancelPursuitBackupByType(unitType)
end)
exports('RequestNPCBackupByType', function(backupType)
    return RequestNPCBackupByType(backupType)
end)
exports('CancelNPCBackupByType', function(backupType, mustNotify)
    CancelNPCBackupByType(backupType, mustNotify)
end)

exports('ERS_ConnectClosestVehicle', function()
    ERS_ConnectClosestVehicle()
end)

exports('getIsImperialEnabled', function()
    return Config.UseImperial
end)

--====================== CALLOUT PACK EXPORTS (client plugins) ======================--

exports('RequestNetControlForEntity', function(entity)
    ERS_RequestNetControlForEntity(entity)
end)

exports('ApplyBloodToPed', function(ped)
    ERS_ApplyBloodToPed(ped)
end)

exports('SelectRandomWoundedPersonScenario', function()
    return ERS_SelectRandomWoundedPersonScenario()
end)

exports('SelectRandomPartyScenario', function()
    return ERS_SelectRandomPartyScenario()
end)

exports('CreateTemporaryBlipForEntities', function(entityNetIdList, durationMs)
    ERS_CreateTemporaryBlipForEntities(entityNetIdList, durationMs)
end)

exports('PerformTimedActionOnPed', function(calloutDataClient, pedList)
    ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
end)

exports('SetMovementAnimClipSetToPed', function(ped, clipSetName)
    ERS_SetMovementAnimClipSetToPed(ped, clipSetName)
end)

exports('StartPursuit', function(pedNetId)
    return StartPursuit(pedNetId)
end)

exports('ERS_DeleteEntityFromCallout', function(entity)
    ERS_DeleteEntityFromCallout(entity)
end)


--====================== TEST COMMANDS ======================--

-- RegisterCommand('testclientexports', function()

    -- local isOnShift = exports['night_ers']:getIsPlayerOnShift()
    -- print(isOnShift)

    -- local getPlayerActiveServiceType = exports['night_ers']:getPlayerActiveServiceType()
    -- print(getPlayerActiveServiceType)

    -- local isPlayerAttachedToCallout = exports['night_ers']:getIsPlayerAttachedToCallout()
    -- print(isPlayerAttachedToCallout)

    -- local isPlayerTrackingUnit = exports['night_ers']:getIsPlayerTrackingUnit()
    -- print(isPlayerTrackingUnit)

    -- exports['night_ers']:playRadioAnimation()

    -- exports['night_ers']:toggleDispatchMessages()

    -- exports['night_ers']:toggleHints()

    -- exports['night_ers']:toggleShift()

    -- exports['night_ers']:trackPlayerCallout(targetSource) -- targetSource is the target player server id

    -- exports['night_ers']:ERS_PedEquipWeapon(pedEntityId, weaponModelName, ammo)

    -- exports['night_ers']:SetERSVehicleInfoDisplay(false) -- Or true...
 
    -- exports['night_ers']:SetERSIDCardInfoDisplay(false) -- Or true...

    -- exports['night_ers']:RequestNPCPursuitBackup("light")

    -- exports['night_ers']:CancelNPCPursuitBackup()

    -- exports['night_ers']:RequestNPCBackup("tow")

    -- exports['night_ers']:CancelNPCBackup("tow", true)

    -- exports['night_ers']:ERS_ConnectClosestVehicle()
    
-- end, false)