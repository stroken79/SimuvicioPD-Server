
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


local isOnDuty = false
-- Punto de entrada/salida de servicio policial
CreateThread(function()
    local dutyPos = vector3(441.29, -975.70, 30.69)

    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        local distance = #(pos - dutyPos)

        if distance < 20.0 then
            sleep = 0

            DrawMarker(
                1,
                dutyPos.x, dutyPos.y, dutyPos.z - 1.0,
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                1.0, 1.0, 0.4,
                0, 100, 255, 180,
                false, true, 2, false, nil, nil, false
            )

            if distance < 1.5 then
                BeginTextCommandDisplayHelp("STRING")
                AddTextComponentSubstringPlayerName(
                    "Pulsa ~INPUT_CONTEXT~ para entrar o salir de servicio"
                )
                EndTextCommandDisplayHelp(0, false, true, -1)

                if IsControlJustReleased(0, 38) then
    isOnDuty = not isOnDuty
    TriggerEvent('pd5m:setDuty', isOnDuty)

    if isOnDuty then
        SetNotificationTextEntry("STRING")
        AddTextComponentString("~g~Has entrado de servicio")
        DrawNotification(false, false)

        print("^2[fivepd-police] EN SERVICIO^7")
    else
        SetNotificationTextEntry("STRING")
        AddTextComponentString("~r~Has salido de servicio")
        DrawNotification(false, false)

        print("^1[fivepd-police] FUERA DE SERVICIO^7")
    end
end
            end
        end

        Wait(sleep)
    end
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
