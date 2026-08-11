local function isFireOnDuty(source)
    if GetResourceState('night_ers') ~= 'started' then return false end
    return exports['night_ers']:getIsPlayerOnShift(source) == true
        and exports['night_ers']:getPlayerActiveServiceType(source) == Config.ServiceType
end

exports('IsPlayerOnDuty', isFireOnDuty)
