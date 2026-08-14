CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        if vehicle ~= 0 and GetPedInVehicleSeat(vehicle, -1) == ped
            and IsFirefighterOnDuty()
            and IsCompatibleFireVehicle(vehicle, 'waterCannon')
            and IsControlPressed(0, Config.CannonControl) then
            -- The vehicle continues to render/control its own cannon. This only
            -- supplies impact coordinates to the SmartFiresLite adapter.
            ReportWaterImpact('cannon', Config.CannonMaxDistance)
            FirefighterDebug('Cannon water impact sampled.')
            Wait(Config.WaterDamageInterval)
        else
            Wait(100)
        end
    end
end)
