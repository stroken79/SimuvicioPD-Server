local function isFirefighterOnDuty()
    return GetResourceState('night_ers') == 'started'
        and exports['night_ers']:getIsPlayerOnShift()
        and exports['night_ers']:getPlayerActiveServiceType() == 'fire'
end

function FirefighterDebug(message)
    if Config.Debug then
        print(('[smvlpd-firefighter] %s'):format(message))
    end
end

function IsFirefighterOnDuty()
    return isFirefighterOnDuty()
end

function IsCompatibleFireVehicle(vehicle, capability)
    if not vehicle or vehicle == 0 or not DoesEntityExist(vehicle) then return false end
    local data = Config.FireVehicles[GetEntityModel(vehicle)]
    return data ~= nil and data[capability] == true
end

function NotifyFirefighter(message, notifyType)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, false)
end
