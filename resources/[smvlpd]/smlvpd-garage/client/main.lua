local activeTextUI

local function setTextUI(text)
    if activeTextUI == text then
        return
    end

    if activeTextUI then
        lib.hideTextUI()
    end

    if text then
        lib.showTextUI(text)
    end

    activeTextUI = text
end

local function openGarage(garageId)
    setTextUI(nil)
    local vehicles = lib.callback.await('smvlpd-garage:server:getVehicles', false)

    if not vehicles or #vehicles == 0 then
        lib.notify({
            title = 'Garaje',
            description = 'No tienes vehículos disponibles.',
            type = 'error'
        })
        return
    end

    local options = {}

    for _, vehicle in ipairs(vehicles) do
        options[#options + 1] = {
            title = vehicle.label,
            description = vehicle.model,
            icon = 'car',
            onSelect = function()
                TriggerServerEvent('smvlpd-garage:server:spawnVehicle', vehicle.model, garageId)
            end
        }
    end

    lib.registerContext({
        id = 'smvlpd_garage',
        title = 'Garaje policial',
        options = options
    })

    lib.showContext('smvlpd_garage')
end

local function drawMarker(position, color)
    DrawMarker(
        Config.Marker.type,
        position.x,
        position.y,
        position.z + 0.05,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        Config.Marker.size.x,
        Config.Marker.size.y,
        Config.Marker.size.z,
        color.r,
        color.g,
        color.b,
        color.a,
        false,
        true,
        2,
        false,
        nil,
        nil,
        false
    )
end

local function storeVehicle(ped)
    local vehicle = GetVehiclePedIsIn(ped, false)

    if vehicle == 0 then
        return
    end

    NetworkRequestControlOfEntity(vehicle)

    local timeout = 0
    while not NetworkHasControlOfEntity(vehicle) and timeout < 50 do
        Wait(10)
        NetworkRequestControlOfEntity(vehicle)
        timeout = timeout + 1
    end

    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)

    if DoesEntityExist(vehicle) then
        DeleteEntity(vehicle)
    end

    setTextUI(nil)
    lib.notify({
        title = 'Garaje',
        description = 'Vehículo guardado correctamente.',
        type = 'success'
    })
end

CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local inVehicle = IsPedInAnyVehicle(ped, false)
        local prompt
        local garageToOpen
        local canStoreVehicle = false

        for garageId, garage in pairs(Config.Garages) do
            local menuDistance = #(coords - garage.menu)

            if menuDistance < Config.DrawDistance then
                sleep = 0
                drawMarker(garage.menu, Config.Marker.color)

                if menuDistance < 1.5 then
                    prompt = '[E] Abrir garaje'
                    garageToOpen = garageId
                end
            end

            if inVehicle then
                for _, store in ipairs(garage.stores) do
                    local storeDistance = #(coords - store)

                    if storeDistance < 5.0 then
                        sleep = 0
                        drawMarker(store, { r = 255, g = 60, b = 60, a = 180 })

                        if storeDistance < 2.5 then
                            prompt = '[E] Guardar vehículo'
                            canStoreVehicle = true
                            garageToOpen = nil
                        end
                    end
                end
            end
        end

        setTextUI(prompt)

        if IsControlJustReleased(0, 38) then
            if canStoreVehicle then
                storeVehicle(ped)
            elseif garageToOpen then
                openGarage(garageToOpen)
            end
        end

        Wait(sleep)
    end
end)

RegisterNetEvent('smvlpd-garage:client:spawnVehicle', function(model, garageId)
    local garage = Config.Garages[garageId]

    if not garage then
        return
    end

    local spawn

    for _, point in ipairs(garage.spawns) do
        if not IsAnyVehicleNearPoint(point.x, point.y, point.z, 3.0) then
            spawn = point
            break
        end
    end

    if not spawn then
        lib.notify({
            title = 'Garaje',
            description = 'Todos los puntos de salida están ocupados.',
            type = 'error'
        })
        return
    end

    lib.requestModel(model)

    local vehicle = CreateVehicle(
        joaat(model),
        spawn.x,
        spawn.y,
        spawn.z,
        spawn.w,
        true,
        false
    )

    if vehicle == 0 then
        lib.notify({
            title = 'Garaje',
            description = 'No se ha podido crear el vehículo.',
            type = 'error'
        })
        return
    end

    SetVehicleOnGroundProperly(vehicle)
    SetPedIntoVehicle(PlayerPedId(), vehicle, -1)
    SetVehicleEngineOn(vehicle, true, true, false)
    SetModelAsNoLongerNeeded(joaat(model))
end)

RegisterNetEvent('smvlpd-garage:client:openGarage', function()
    openGarage('MissionRow')
end)
