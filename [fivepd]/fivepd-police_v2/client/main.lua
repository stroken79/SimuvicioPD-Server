
RegisterNetEvent("fivepd-police:garage", function()

    local ped = PlayerPedId()

    local vehicle = GetHashKey("police")

    RequestModel(vehicle)

    while not HasModelLoaded(vehicle) do
        Wait(0)
    end

    local car = CreateVehicle(
    vehicle,
    436.48,
    -996.42,
    25.77,
    176.64,
    true,
    false
)

    SetVehicleOnGroundProperly(car)

    SetPedIntoVehicle(
        ped,
        car,
        -1
    )

    SetModelAsNoLongerNeeded(vehicle)

end)


CreateThread(function()
    local lastVehicle = 0

    while true do
        Wait(500)

        local ped = PlayerPedId()

        if IsPedInAnyVehicle(ped, false) then
            local vehicle = GetVehiclePedIsIn(ped, false)

            -- Solo actuar al entrar/cambiar de vehículo
            if vehicle ~= lastVehicle then
                lastVehicle = vehicle

                -- Clase 18 = vehículos de emergencia
                if GetVehicleClass(vehicle) == 18 then
                    SetVehRadioStation(vehicle, "OFF")
                    SetVehicleRadioEnabled(vehicle, false)
                end
            end
        else
            lastVehicle = 0
        end
    end
end)
