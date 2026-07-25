RegisterNetEvent("smvlpd_dev:spawnVehicle", function(modelName)

    if not modelName then
        TriggerEvent('chat:addMessage', {
            color = {255,0,0},
            args = {"DEV", "Uso: /spawnpd <modelo>"}
        })
        return
    end

    local model = GetHashKey(modelName)

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