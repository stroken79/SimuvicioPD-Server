local armoryOpen = false

CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)

        for _, armory in pairs(Config.Armories) do
            local distance = #(coords - armory.coords)

            if distance < 5.0 then
                sleep = 0

                DrawMarker(
                    21,
                    armory.coords.x,
                    armory.coords.y,
                    armory.coords.z + 0.1,
                    0.0,0.0,0.0,
                    0.0,0.0,0.0,
                    0.40,0.40,0.40,
                    0,100,255,150,
                    false,true,2,false,nil,nil,false
                )

                if distance < 1.5 then

    lib.showTextUI('[E] Abrir Armería')

    if IsControlJustReleased(0, 38) then
        

        if not exports['pd5m']:IsOnDuty() then

            lib.notify({
                title = 'Armería',
                description = 'Debes estar de servicio para acceder a la armería.',
                type = 'error'
            })

        else

            if not armoryOpen then
    armoryOpen = true
    lib.hideTextUI()
    OpenArmory()
end

        end

    end
                else
                    lib.hideTextUI()
                end
            end
        end

        Wait(sleep)
    end
end)

function OpenArmory()

    lib.registerContext({
        id = 'smvlpd_armory',
        title = 'Armería LSPD',

        onExit = function()
            armoryOpen = false
        end,

        options = {
            {
    title = '📦 Recoger equipamiento reglamentario',
    onSelect = function()
        armoryOpen = false
        GiveStandardEquipment()
    end
},
            {
    title = '🦺 Recoger chaleco',
    onSelect = function()

        armoryOpen = false
        GiveArmour()

    end
},
            {
    title = '🔫 Recoger munición',
    onSelect = function()

        armoryOpen = false
        GiveAmmo()

    end
},
            {
    title = '📤 Devolver equipamiento',
    onSelect = function()

        armoryOpen = false
        ReturnEquipment()

    end
}
        }
    })

    lib.showContext('smvlpd_armory')

end
local function GetFlashlightComponent(weapon)

    if weapon == "WEAPON_COMBATPISTOL"
    or weapon == "WEAPON_PISTOL_MK2"
    or weapon == "WEAPON_HEAVYPISTOL" then
        return "COMPONENT_AT_PI_FLSH"
    end

    if weapon == "WEAPON_PUMPSHOTGUN_MK2"
    or weapon == "WEAPON_SMG_MK2"
    or weapon == "WEAPON_CARBINERIFLE_MK2" then
        return "COMPONENT_AT_AR_FLSH"
    end

    return nil
end
function GiveStandardEquipment()

    armoryOpen = false

    TriggerServerEvent('smvlpd-ranks:server:requestLoadout')



end
function GiveArmour()

    SetPedArmour(PlayerPedId(), 100)

    lib.notify({
        title = 'Armería',
        description = 'Chaleco entregado.',
        type = 'success'
    })

end
function GiveAmmo()

    TriggerServerEvent('smvlpd-ranks:server:requestAmmo')

end
function ReturnEquipment()

    local ped = PlayerPedId()

    RemoveAllPedWeapons(ped, true)
    SetPedArmour(ped, 0)

    lib.notify({
        title = 'Armería',
        description = 'Equipamiento devuelto.',
        type = 'success'
    })

end