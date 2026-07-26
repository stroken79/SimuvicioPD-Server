local function openGarage(garageId)

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

                TriggerServerEvent(
                    'smvlpd-garage:server:spawnVehicle',
                    vehicle.model,
                    garageId
                )

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


CreateThread(function()

    for garageId, garage in pairs(Config.Garages) do

        exports.ox_target:addSphereZone({

            coords = garage.menu,

            radius = 1.5,

            debug = false,

            options = {

                {

                    name = 'smvlpd_garage_' .. garageId,

                    icon = 'fa-solid fa-car',

                    label = 'Abrir garaje policial',

                    onSelect = function()

                        openGarage(garageId)

                    end

                }

            }

        })

    end

end)


RegisterNetEvent('smvlpd-garage:client:spawnVehicle', function(model, garageId)

    local garage = Config.Garages[garageId]

    if not garage then
        return
    end

    local spawn = garage.spawn

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