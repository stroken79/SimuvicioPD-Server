local helpCooldowns = {}
local helpRequests = {}
local nextHelpRequestId = 0
local unitNames = {}

local function getUnitName(sourceId)
    local cached = unitNames[sourceId]

    if cached and cached.expiresAt > os.time() then
        return cached.name
    end

    local name

    if GetResourceState('smvlpd-character') == 'started' then
        local ok, characterId = pcall(function()
            return exports['smvlpd-character']:GetActiveCharacter(sourceId)
        end)

        if ok and characterId then
            local character = MySQL.single.await(
                'SELECT first_name, last_name FROM smvlpd_characters WHERE id = ? LIMIT 1',
                { characterId }
            )

            if character then
                local firstName = tostring(character.first_name or '')
                local lastName = tostring(character.last_name or '')
                local fullName = (firstName .. ' ' .. lastName):gsub('^%s+', ''):gsub('%s+$', '')

                if fullName ~= '' then
                    name = fullName
                end
            end
        end
    end

    name = name or ('Unidad ' .. sourceId)
    unitNames[sourceId] = {
        name = name,
        expiresAt = os.time() + 10
    }

    return name
end

local function getNightErsShift(sourceId)
    if GetResourceState('night_ers') ~= 'started' then
        return false, nil
    end

    local okShift, isOnShift = pcall(function()
        return exports['night_ers']:getIsPlayerOnShift(sourceId)
    end)

    if not okShift or isOnShift ~= true then
        return false, nil
    end

    local okService, serviceType = pcall(function()
        return exports['night_ers']:getPlayerActiveServiceType(sourceId)
    end)

    if not okService then
        return false, nil
    end

    return Config.ServiceBlips[serviceType] ~= nil, serviceType
end

local function getServiceUnits()
    local units = {}

    for _, playerId in ipairs(GetPlayers()) do
        local sourceId = tonumber(playerId)
        local isSupportedService, serviceType = getNightErsShift(sourceId)

        if isSupportedService then
            local ped = GetPlayerPed(sourceId)

            if ped and ped ~= 0 then
                local coords = GetEntityCoords(ped)

                units[#units + 1] = {
                    source = sourceId,
                    name = getUnitName(sourceId),
                    service = serviceType,
                    coords = {
                        x = coords.x,
                        y = coords.y,
                        z = coords.z
                    }
                }
            end
        end
    end

    return units
end

CreateThread(function()
    while true do
        Wait(Config.UpdateInterval)

        local units = getServiceUnits()
        local recipients = {}

        for _, unit in ipairs(units) do
            recipients[unit.source] = true
            TriggerClientEvent('night_ers_policeblips:updateUnits', unit.source, units)
        end

        for _, playerId in ipairs(GetPlayers()) do
            local sourceId = tonumber(playerId)

            if not recipients[sourceId] then
                TriggerClientEvent('night_ers_policeblips:updateUnits', sourceId, {})
            end
        end
    end
end)

RegisterCommand(Config.Help.command, function(sourceId)
    if sourceId == 0 then
        print(('[night_ers_policeblips] /%s solo puede utilizarse dentro del juego.'):format(Config.Help.command))
        return
    end

    local isSupportedService, requesterService = getNightErsShift(sourceId)

    if not isSupportedService then
        TriggerClientEvent('night_ers_policeblips:notify', sourceId, 'Debes estar en un servicio compatible para solicitar ayuda.')
        return
    end

    local now = os.time()
    local availableAt = helpCooldowns[sourceId] or 0

    if availableAt > now then
        TriggerClientEvent(
            'night_ers_policeblips:notify',
            sourceId,
            ('Debes esperar %s segundos antes de volver a solicitar ayuda.'):format(availableAt - now)
        )
        return
    end

    local ped = GetPlayerPed(sourceId)

    if not ped or ped == 0 then
        TriggerClientEvent('night_ers_policeblips:notify', sourceId, 'No se pudo obtener tu posicion.')
        return
    end

    local coords = GetEntityCoords(ped)
    local requesterName = getUnitName(sourceId)
    local units = getServiceUnits()
    local recipients = {}

    for _, unit in ipairs(units) do
        if unit.source ~= sourceId and unit.service == requesterService then
            recipients[unit.source] = true
        end
    end

    if not next(recipients) then
        TriggerClientEvent('night_ers_policeblips:notify', sourceId, 'No hay otras unidades de tu servicio disponibles.')
        return
    end

    helpCooldowns[sourceId] = now + Config.Help.cooldownSeconds

    nextHelpRequestId = nextHelpRequestId + 1
    local requestId = nextHelpRequestId
    local request = {
        id = requestId,
        source = sourceId,
        name = requesterName,
        service = requesterService,
        coords = {
            x = coords.x,
            y = coords.y,
            z = coords.z
        },
        recipients = recipients,
        expiresAt = now + Config.Help.offerSeconds
    }

    helpRequests[requestId] = request

    for recipient in pairs(recipients) do
        TriggerClientEvent('night_ers_policeblips:helpOffer', recipient, {
            id = request.id,
            source = request.source,
            name = request.name,
            coords = request.coords,
            expiresIn = Config.Help.offerSeconds
        })
    end

    TriggerClientEvent('night_ers_policeblips:notify', sourceId, 'Solicitud enviada a las unidades de tu servicio.')

    SetTimeout(Config.Help.offerSeconds * 1000, function()
        local activeRequest = helpRequests[requestId]

        if not activeRequest then
            return
        end

        for recipient in pairs(activeRequest.recipients) do
            TriggerClientEvent('night_ers_policeblips:helpExpired', recipient, requestId)
        end

        helpRequests[requestId] = nil
    end)
end, false)

RegisterNetEvent('night_ers_policeblips:respondHelp', function(requestId, accepted)
    local responder = source
    requestId = tonumber(requestId)

    local request = requestId and helpRequests[requestId]

    if not request or not request.recipients[responder] or request.expiresAt < os.time() then
        TriggerClientEvent('night_ers_policeblips:notify', responder, 'La solicitud de ayuda ya no esta disponible.')
        return
    end

    local isSupportedService, responderService = getNightErsShift(responder)

    if not isSupportedService or responderService ~= request.service then
        request.recipients[responder] = nil
        TriggerClientEvent('night_ers_policeblips:notify', responder, 'Debes estar en el mismo servicio que la unidad solicitante.')
        return
    end

    request.recipients[responder] = nil

    local responderName = getUnitName(responder)

    if accepted == true then
        TriggerClientEvent('night_ers_policeblips:helpAccepted', responder, {
            id = request.id,
            source = request.source,
            name = request.name,
            coords = request.coords
        })
        TriggerClientEvent(
            'night_ers_policeblips:notify',
            request.source,
            ('La unidad %s ha aceptado tu solicitud de ayuda.'):format(responderName)
        )
    else
        TriggerClientEvent('night_ers_policeblips:helpRejected', responder, request.id)
        TriggerClientEvent(
            'night_ers_policeblips:notify',
            request.source,
            ('La unidad %s ha rechazado tu solicitud de ayuda.'):format(responderName)
        )
    end

    if not next(request.recipients) then
        helpRequests[requestId] = nil
    end
end)

AddEventHandler('playerDropped', function()
    helpCooldowns[source] = nil
    unitNames[source] = nil

    for requestId, request in pairs(helpRequests) do
        request.recipients[source] = nil

        if request.source == source then
            for recipient in pairs(request.recipients) do
                TriggerClientEvent('night_ers_policeblips:helpExpired', recipient, requestId)
            end

            helpRequests[requestId] = nil
        end
    end
end)
