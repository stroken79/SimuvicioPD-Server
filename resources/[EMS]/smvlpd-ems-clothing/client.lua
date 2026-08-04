local onDuty = false

CreateThread(function()

    for _, locker in pairs(Config.LockerLocations) do

        exports.ox_target:addSphereZone({
            coords = locker.coords,
            radius = 1.5,
            debug = false,
            options = {
                {
                    name = "ems_locker",
                    icon = Config.TargetIcon,
                    label = Config.TargetLabel,
                    onSelect = function()
                        OpenEMSLocker()
                    end
                }
            }
        })

    end

end)

function OpenEMSLocker()

    lib.registerContext({
        id = 'ems_locker_menu',
        title = Config.MenuTitle,
        options = {

            {
                title = "🚑 Entrar de servicio",
                description = "Ponerse el uniforme correspondiente.",
                onSelect = function()

                    EnterDuty()

                end
            },

            {
                title = "👕 Cambiar uniforme",
                description = "Volver a aplicar el uniforme.",
                onSelect = function()

                    ChangeUniform()

                end
            },

            {
                title = "👤 Volver a civil",
                description = "Quitarse el uniforme.",
                onSelect = function()

                    ExitDuty()

                end
            }

        }
    })

    lib.showContext('ems_locker_menu')

end

function EnterDuty()

    if onDuty then
        lib.notify({
            title = "EMS",
            description = "Ya estás de servicio.",
            type = "error"
        })
        TriggerServerEvent("smvlpd-ems:server:setDuty", true)
        return
    end

    onDuty = true

    lib.notify({
        title = "EMS",
        description = "Has entrado de servicio.",
        type = "success"
    })

    -- Aquí cargaremos el uniforme

end

function ChangeUniform()

    if not onDuty then
        return
    end

    -- Aquí volveremos a aplicar el uniforme

end

function ExitDuty()

    if not onDuty then
        return
    end

    onDuty = false

    lib.notify({
        title = "EMS",
        description = "Has salido de servicio.",
        type = "inform"
    })
    TriggerServerEvent("smvlpd-ems:server:setDuty", false)

    -- Aquí recuperaremos la ropa civil

end

