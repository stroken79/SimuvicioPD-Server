local currentRank = {
    id = 1,
    label = "Novato"
}

local function updateHud(rank)

    currentRank = rank

    local pointData = lib.callback.await('smvlpd-ranks:server:getPoints', false)

    SendNUIMessage({
        action = "update",
        rank = rank.label,
        image = rank.image,
        player = rank.player,

        points = pointData and pointData.points or 0,
        nextRank = pointData and pointData.nextRank and pointData.nextRank.label or "Rango máximo",
        pointsLeft = pointData and pointData.nextRank and pointData.nextRank.remaining or 0
    })

end
local function notify(description, notifyType)
    lib.notify({ description = description, type = notifyType or 'inform' })
end

local function openArmory()
    local rank = lib.callback.await('smvlpd-ranks:server:getRank', false)
    if not rank then return notify('No se ha cargado tu rango todavia.', 'error') end

    local options = {}
    local rankData = Config.Ranks[rank.id]
    if rankData.administrative then return notify('Tu rango administrativo no tiene armeria propia.', 'error') end

    for _, weapon in ipairs(rankData.weapons) do
        options[#options + 1] = {
            title = weapon.name:gsub('WEAPON_', ''):gsub('_', ' '),
            description = ('Municion: %s'):format(weapon.ammo),
            icon = 'gun',
            event = 'smvlpd-ranks:client:requestWeapon',
            args = weapon.name,
        }
    end

    lib.registerContext({ id = 'smvlpd_rank_armory', title = ('Armeria - %s'):format(rank.label), options = options })
    lib.showContext('smvlpd_rank_armory')
end

RegisterNetEvent('smvlpd-ranks:client:requestWeapon', function(weaponName)
    TriggerServerEvent('smvlpd-ranks:server:requestWeapon', weaponName)
end)

RegisterNetEvent('smvlpd-ranks:client:receiveLoadout', function(weapons)

    local ped = PlayerPedId()

    RemoveAllPedWeapons(ped, true)

    SetPedArmour(ped, 100)

    for _, weapon in ipairs(weapons) do

        local weaponHash = joaat(weapon.name)

        GiveWeaponToPed(
            ped,
            weaponHash,
            weapon.ammo or 0,
            false,
            false
        )

        for _, component in ipairs(weapon.components or {}) do
            GiveWeaponComponentToPed(
                ped,
                weaponHash,
                joaat(component)
            )
        end

    end

    notify('Equipamiento reglamentario entregado.', 'success')

end)
RegisterNetEvent('smvlpd-ranks:client:receiveAmmo', function(weapons)

    local ped = PlayerPedId()

    for _, weapon in ipairs(weapons) do

        AddAmmoToPed(
            ped,
            joaat(weapon.name),
            weapon.ammo or 0
        )

    end

    notify('Munición repuesta.', 'success')

end)
RegisterNetEvent('smvlpd-ranks:client:rankUpdated', function(rankId, rankLabel)

    local rank = lib.callback.await('smvlpd-ranks:server:getRank', false)

    if rank then
        updateHud(rank)
    end

    notify(('Rango actual: %s'):format(rankLabel), 'success')

end)

RegisterNetEvent('smvlpd-ranks:client:showRank', function()
    local rank = lib.callback.await('smvlpd-ranks:server:getRank', false)
    if not rank then return end
    notify(('Rango: %s | Uniforme: %s'):format(rank.label, rank.uniform or 'Pendiente de configurar'))
end)

RegisterNetEvent('smvlpd-ranks:client:openManagement', function(players)
    local options = {}
    for _, player in ipairs(players) do
        options[#options + 1] = {
            title = ('[%s] %s'):format(player.serverId, player.name),
            description = ('Rango actual: %s'):format(player.rankLabel),
            icon = 'user-shield',
            event = 'smvlpd-ranks:client:chooseRank',
            args = player,
        }
    end
    lib.registerContext({ id = 'smvlpd_rank_management', title = 'Gestion de rangos', options = options })
    lib.showContext('smvlpd_rank_management')
end)

RegisterNetEvent('smvlpd-ranks:client:chooseRank', function(player)
    local options = {}
    for rankId, rank in ipairs(Config.Ranks) do
        options[#options + 1] = {
            title = rank.label,
            description = rankId == player.rankId and 'Rango actual' or nil,
            icon = rank.administrative and 'user-tie' or 'shield-halved',
            event = 'smvlpd-ranks:client:confirmRank',
            args = { targetId = player.serverId, rankId = rankId },
        }
    end
    lib.registerContext({ id = 'smvlpd_rank_choose', title = ('Rango para %s'):format(player.name), menu = 'smvlpd_rank_management', options = options })
    lib.showContext('smvlpd_rank_choose')
end)

RegisterNetEvent('smvlpd-ranks:client:confirmRank', function(data)
    TriggerServerEvent('smvlpd-ranks:server:setRank', data.targetId, data.rankId)
end)

RegisterNetEvent('smvlpd-character:client:characterLoaded', function(character)

    TriggerServerEvent('smvlpd-ranks:server:characterLoaded', character.id)

    CreateThread(function()

        Wait(1000)

        local rank = lib.callback.await('smvlpd-ranks:server:getRank', false)

        if rank then
            updateHud(rank)
        end

    end)

end)

RegisterCommand('armeria', openArmory, false)
RegisterCommand('gestionrangos', function() TriggerServerEvent('smvlpd-ranks:server:requestManagement') end, false)
RegisterCommand('rango', function() TriggerEvent('smvlpd-ranks:client:showRank') end, false)


RegisterNetEvent('smvlpd-ranks:client:pointsAdded', function(amount, total, reason)

    notify(('+%s puntos | %s | Total: %s'):format(amount, reason or 'Servicio policial', total), 'success')

    local rank = lib.callback.await('smvlpd-ranks:server:getRank', false)

    if rank then
        updateHud(rank)
    end

end)

RegisterNetEvent('smvlpd-ranks:client:promoted', function(rankId, rankLabel, total)

    lib.alertDialog({
        header = 'ASCENSO',
        content = ('Has ascendido a **%s**.\n\nPuntos acumulados: **%s**'):format(rankLabel, total),
        centered = true,
        cancel = false
    })

    local rank = lib.callback.await('smvlpd-ranks:server:getRank', false)

    if rank then
        updateHud(rank)
    end

end)

RegisterNetEvent('smvlpd-ranks:client:serviceSummary', function(total, entries)
    if total <= 0 then return end

    local lines = {}
    for _, entry in ipairs(entries) do
        lines[#lines + 1] = ('+%s — %s'):format(entry.amount, entry.reason)
    end

    lib.alertDialog({
        header = 'RESUMEN DEL SERVICIO',
        content = ('Puntos obtenidos: **%s**\n\n%s'):format(total, table.concat(lines, '\n')),
        centered = true,
        cancel = false
    })
end)

local function awardCalloutAction(actionId)
    TriggerServerEvent('smvlpd-ranks:server:awardCalloutAction', actionId)
end

-- PD5M emite estos eventos cuando el agente usa las acciones de su menú.
-- El servidor ignora repeticiones y cualquier acción sin un aviso aceptado.
AddEventHandler('pd5m:int:arrestped', function() awardCalloutAction('arrest') end)
AddEventHandler('pd5m:int:fineped', function() awardCalloutAction('citation') end)
AddEventHandler('pd5m:int:breathalyzer', function() awardCalloutAction('breathalyzer') end)
AddEventHandler('pd5m:int:drugtest', function() awardCalloutAction('drugTest') end)
AddEventHandler('pd5m:int:search', function() awardCalloutAction('searchPerson') end)
AddEventHandler('pd5m:int:runid', function() awardCalloutAction('documents') end)
AddEventHandler('pd5m:int:runplate', function() awardCalloutAction('searchVehicle') end)
AddEventHandler('pd5m:int:InformPedInvestigation', function() awardCalloutAction('investigation') end)
AddEventHandler('pd5m:tow:flatbedpickup', function() awardCalloutAction('tow') end)
AddEventHandler('pd5m:int:confiscateitems', function() awardCalloutAction('minorAction') end)
AddEventHandler('pd5m:setDuty', function(isOnDuty)
    if not isOnDuty then
        TriggerServerEvent('smvlpd-ranks:server:requestServiceSummary')
    end
end)

RegisterCommand('puntos', function()
    local data = lib.callback.await('smvlpd-ranks:server:getPoints', false)
    if not data then return notify('No se han podido cargar tus puntos.', 'error') end

    local text
    if data.administrative then
        text = ('Rango: %s | Puntos acumulados: %s | Rango administrativo: sin ascenso automatico'):format(data.rankLabel, data.points)
    elseif data.nextRank and data.nextRank.max then
        text = ('Rango: %s | Puntos acumulados: %s | Has alcanzado el maximo rango por progresion'):format(data.rankLabel, data.points)
    else
        text = ('Rango: %s | Puntos: %s | Proximo: %s (%s) | Faltan: %s'):format(
            data.rankLabel, data.points, data.nextRank.label, data.nextRank.required, data.nextRank.remaining
        )
    end
    notify(text, 'inform')
end, false)
function GetPlayerPoliceRank()
    return currentRank
end

exports('GetPlayerPoliceRank', GetPlayerPoliceRank)

exports('HasWeaponAccess', ExportHasWeaponAccess)
exports('HasVehicleAccess', ExportHasVehicleAccess)

CreateThread(function()
    Wait(2000)

    local rank = lib.callback.await('smvlpd-ranks:server:getRank', false)

    if rank then
        updateHud(rank)
    end
end)

RegisterNetEvent('smvlpd-ranks:client:reloadRank', function()

    local character = exports['smvlpd-character']:GetCurrentCharacter()

    if character then
        TriggerServerEvent('smvlpd-ranks:server:characterLoaded', character.id)
    end

end)
