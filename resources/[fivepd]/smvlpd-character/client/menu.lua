local buddySpawned = false

local function OpenPoliceMenu()

    lib.registerContext({
        id = 'smvlpd_patrol_menu',
        title = 'SIMUVICIO PD',
        options = {

            {
                title = '👮 Patrullar solo',
                onSelect = function()
                end
            },

            buddySpawned and {

                title = '🚫 Retirar compañero IA',

                onSelect = function()
    TriggerEvent('smvlpd-socio:remove')
    buddySpawned = false

    Wait(100)

    OpenPoliceMenu()
end

            } or {

                title = '👮🤖 Solicitar compañero IA',

                onSelect = function()
    TriggerEvent('smvlpd-socio:spawn')
    buddySpawned = true

    Wait(100)

    OpenPoliceMenu()
end

            }

        }

    })

    lib.showContext('smvlpd_patrol_menu')

end

RegisterNetEvent('smvlpd:duty:onDuty', function()
    Wait(500)
    OpenPoliceMenu()
end)

RegisterCommand("smvlpdmenu", function()
    OpenPoliceMenu()
end)

RegisterKeyMapping("smvlpdmenu", "Abrir menú SimuvicioPD", "keyboard", "F10")