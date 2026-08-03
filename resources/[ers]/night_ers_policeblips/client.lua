local unitBlips = {}
local helpBlips = {}
local helpTargets = {}
local pendingHelp

local function notify(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, false)
end

local function removeBlipSafe(blip)
    if blip and DoesBlipExist(blip) then
        RemoveBlip(blip)
    end
end

local function clearUnitBlips()
    for sourceId, blip in pairs(unitBlips) do
        removeBlipSafe(blip)
        unitBlips[sourceId] = nil
    end
end

local function createUnitBlip(unit)
    local player = GetPlayerFromServerId(unit.source)
    local blip

    if player ~= -1 and NetworkIsPlayerActive(player) then
        blip = AddBlipForEntity(GetPlayerPed(player))
        ShowHeadingIndicatorOnBlip(blip, true)
    else
        blip = AddBlipForCoord(unit.coords.x, unit.coords.y, unit.coords.z)
    end

    SetBlipSprite(blip, Config.PoliceBlip.sprite)
    SetBlipColour(blip, Config.PoliceBlip.colour)
    SetBlipScale(blip, Config.PoliceBlip.scale)
    SetBlipAsShortRange(blip, false)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(('%s - %s'):format(Config.PoliceBlip.name, unit.name))
    EndTextCommandSetBlipName(blip)

    return blip
end

RegisterNetEvent('night_ers_policeblips:updateUnits', function(units)
    local received = {}
    local ownSource = GetPlayerServerId(PlayerId())

    for _, unit in ipairs(units or {}) do
        local sourceId = tonumber(unit.source)

        if sourceId and sourceId ~= ownSource and unit.coords then
            received[sourceId] = true

            local player = GetPlayerFromServerId(sourceId)
            local shouldUseEntity = player ~= -1 and NetworkIsPlayerActive(player)
            local blip = unitBlips[sourceId]
            local isEntityBlip = blip and DoesBlipExist(blip) and GetBlipInfoIdEntityIndex(blip) ~= 0

            if not blip or not DoesBlipExist(blip) or shouldUseEntity ~= isEntityBlip then
                removeBlipSafe(blip)
                blip = createUnitBlip(unit)
                unitBlips[sourceId] = blip
            elseif not shouldUseEntity then
                SetBlipCoords(blip, unit.coords.x, unit.coords.y, unit.coords.z)
            end
        end
    end

    for sourceId, blip in pairs(unitBlips) do
        if not received[sourceId] then
            removeBlipSafe(blip)
            unitBlips[sourceId] = nil
        end
    end
end)

RegisterNetEvent('night_ers_policeblips:notify', notify)

local function clearPendingHelp(requestId)
    if pendingHelp and (not requestId or pendingHelp.id == requestId) then
        pendingHelp = nil
    end
end

RegisterNetEvent('night_ers_policeblips:helpOffer', function(request)
    if not request or not request.coords or not request.source then
        return
    end

    if pendingHelp then
        TriggerServerEvent('night_ers_policeblips:respondHelp', pendingHelp.id, false)
    end

    pendingHelp = request
    PlaySoundFrontend(-1, 'TIMER_STOP', 'HUD_MINI_GAME_SOUNDSET', true)
    notify(
        ('~r~SOLICITUD DE AYUDA~s~~n~La unidad %s necesita refuerzos.~n~~g~[%s] Aceptar  ~r~[%s] Rechazar'):format(
            request.name or request.source,
            Config.Help.acceptKey,
            Config.Help.rejectKey
        )
    )
end)

RegisterNetEvent('night_ers_policeblips:helpAccepted', function(request)
    clearPendingHelp(request.id)

    local requestSource = tonumber(request.source)
    removeBlipSafe(helpBlips[requestSource])

    local blip = AddBlipForCoord(request.coords.x, request.coords.y, request.coords.z)
    helpBlips[requestSource] = blip
    helpTargets[requestSource] = {
        coords = request.coords,
        name = request.name or requestSource
    }

    SetBlipSprite(blip, Config.Help.sprite)
    SetBlipColour(blip, Config.Help.colour)
    SetBlipScale(blip, Config.Help.scale)
    SetBlipFlashes(blip, true)
    SetBlipAsShortRange(blip, false)
    SetBlipRoute(blip, true)
    SetBlipRouteColour(blip, Config.Help.colour)

    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(('%s - %s'):format(Config.Help.name, request.name or requestSource))
    EndTextCommandSetBlipName(blip)

    PlaySoundFrontend(-1, 'SELECT', 'HUD_FRONTEND_DEFAULT_SOUNDSET', true)
    notify(('~g~AYUDA ACEPTADA~s~~n~Ruta marcada hacia la unidad %s.'):format(request.name or requestSource))

    SetTimeout(Config.Help.durationSeconds * 1000, function()
        if helpBlips[requestSource] == blip then
            removeBlipSafe(blip)
            helpBlips[requestSource] = nil
            helpTargets[requestSource] = nil
        end
    end)
end)

CreateThread(function()
    while true do
        Wait(500)

        local ownCoords = GetEntityCoords(PlayerPedId())

        for sourceId, target in pairs(helpTargets) do
            local targetCoords = vector3(target.coords.x, target.coords.y, target.coords.z)
            local player = GetPlayerFromServerId(sourceId)

            if player ~= -1 and NetworkIsPlayerActive(player) then
                targetCoords = GetEntityCoords(GetPlayerPed(player))
                target.coords = {
                    x = targetCoords.x,
                    y = targetCoords.y,
                    z = targetCoords.z
                }

                local blip = helpBlips[sourceId]
                if blip and DoesBlipExist(blip) then
                    SetBlipCoords(blip, targetCoords.x, targetCoords.y, targetCoords.z)
                end
            end

            if #(ownCoords - targetCoords) <= Config.Help.arrivalDistance then
                removeBlipSafe(helpBlips[sourceId])
                helpBlips[sourceId] = nil
                helpTargets[sourceId] = nil
                notify(('~g~HAS LLEGADO~s~~n~Estas junto a la unidad %s.'):format(target.name))
            end
        end
    end
end)

RegisterNetEvent('night_ers_policeblips:helpRejected', function(requestId)
    clearPendingHelp(requestId)
    notify('~y~Has rechazado la solicitud de ayuda.')
end)

RegisterNetEvent('night_ers_policeblips:helpExpired', function(requestId)
    if pendingHelp and pendingHelp.id == requestId then
        pendingHelp = nil
        notify('~y~La solicitud de ayuda ha caducado.')
    end
end)

RegisterCommand('night_ers_accept_help', function()
    if not pendingHelp then
        return
    end

    local requestId = pendingHelp.id
    pendingHelp = nil
    TriggerServerEvent('night_ers_policeblips:respondHelp', requestId, true)
end, false)

RegisterCommand('night_ers_reject_help', function()
    if not pendingHelp then
        return
    end

    local requestId = pendingHelp.id
    pendingHelp = nil
    TriggerServerEvent('night_ers_policeblips:respondHelp', requestId, false)
end, false)

RegisterKeyMapping('night_ers_accept_help', 'Aceptar solicitud de ayuda policial', 'keyboard', Config.Help.acceptKey)
RegisterKeyMapping('night_ers_reject_help', 'Rechazar solicitud de ayuda policial', 'keyboard', Config.Help.rejectKey)

CreateThread(function()
    TriggerEvent('chat:addSuggestion', '/' .. Config.Help.command, 'Solicita ayuda a todas las patrullas de policia en servicio.')
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        return
    end

    clearUnitBlips()

    for sourceId, blip in pairs(helpBlips) do
        removeBlipSafe(blip)
        helpBlips[sourceId] = nil
        helpTargets[sourceId] = nil
    end
end)
