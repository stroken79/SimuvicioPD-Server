RegisterNetEvent("smvlpd_dev:spawnVehicle", function(modelName)

    if not modelName then
        TriggerEvent('chat:addMessage', {
            color = {255,0,0},
            args = {"DEV", "Uso: /spawnpd <modelo>"}
        })
        return
    end

    local model = GetHashKey(modelName)
    print("[SPAWNPD] IsModelInCdimage:", IsModelInCdimage(model))
    print("[SPAWNPD] IsModelValid:", IsModelValid(model))

    if not IsModelInCdimage(model) then
        TriggerEvent('chat:addMessage', {
            color = {255,0,0},
            args = {"DEV", "Modelo inexistente: "..modelName}
        })
        return
    end

    RequestModel(model)

    while not HasModelLoaded(model) do
        Wait(0)
    end
    print("[SPAWNPD] HasModelLoaded:", HasModelLoaded(model))

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    local vehicle = CreateVehicle(
        model,
        coords.x + 3.0,
        coords.y,
        coords.z,
        heading,
        true,
        false
    )

    SetPedIntoVehicle(ped, vehicle, -1)
    for i = 0, 20 do
    if DoesExtraExist(vehicle, i) then
        SetVehicleExtra(vehicle, i, false)
    end
end

    SetVehicleOnGroundProperly(vehicle)

    SetModelAsNoLongerNeeded(model)

    TriggerEvent('chat:addMessage', {
        color = {0,255,0},
        args = {"DEV", "Vehículo creado: "..modelName}
    })

end)
RegisterCommand("coords", function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    print(("vec3(%.2f, %.2f, %.2f)"):format(
        coords.x, coords.y, coords.z
    ))

    print(("vec4(%.2f, %.2f, %.2f, %.2f)"):format(
        coords.x, coords.y, coords.z, heading
    ))
end, false)
RegisterCommand("dv", function()

    local ped = PlayerPedId()

    if IsPedInAnyVehicle(ped, false) then

        local vehicle = GetVehiclePedIsIn(ped, false)

        SetEntityAsMissionEntity(vehicle, true, true)
        DeleteVehicle(vehicle)

        return

    end

    local coords = GetEntityCoords(ped)

    local vehicle = GetClosestVehicle(
        coords.x,
        coords.y,
        coords.z,
        5.0,
        0,
        71
    )

    if vehicle ~= 0 then

        SetEntityAsMissionEntity(vehicle, true, true)
        DeleteVehicle(vehicle)

    end

end, false)

RegisterCommand("livery", function(_, args)
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)

    if veh == 0 then
        print("^1No estás dentro de un vehículo.^0")
        return
    end

    if args[1] then
        local id = tonumber(args[1])

        if id then
            SetVehicleLivery(veh, id)
            print(("Livery cambiada a %s"):format(id))
        end
    else
        print(("Livery actual: %s"):format(GetVehicleLivery(veh)))
        print(("Número de liveries: %s"):format(GetVehicleLiveryCount(veh)))
    end
end)