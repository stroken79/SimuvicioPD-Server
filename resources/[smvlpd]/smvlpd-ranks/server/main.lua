local activeCharacters = {}
local playerRanks = {}
local playerPoints = {}
local activeServices = {}
local activeCallouts = {}
local activeExternalCallouts = {}
local serviceSummaries = {}

local supportedServices = {
    police = true,
    ambulance = true,
    fire = true,
    tow = true
}

local function getNightErsService(source)
    if GetResourceState('night_ers') ~= 'started' then return nil end

    local okShift, isOnShift = pcall(function()
        return exports['night_ers']:getIsPlayerOnShift(source)
    end)
    if not okShift or isOnShift ~= true then return nil end

    local okService, serviceType = pcall(function()
        return exports['night_ers']:getPlayerActiveServiceType(source)
    end)

    if okService and supportedServices[serviceType] then
        return serviceType
    end

    return nil
end

local function getServiceRanks(serviceType)
    return Config.Ranks[serviceType] or {}
end

local function getServiceRankPoints(serviceType)
    return Config.RankPoints[serviceType] or {}
end

local function getRank(rankId, serviceType)
    local ranks = getServiceRanks(serviceType)
    return ranks[tonumber(rankId) or 1] or ranks[1]
end

local function isManager(source)
    -- La consola siempre puede gestionar rangos.
    if source == 0 then return true end

    -- Mantiene el permiso ACE como acceso administrativo de emergencia.
    if IsPlayerAceAllowed(source, Config.ManagementAce) then return true end

    local serviceType = activeServices[source]
    local rank = getRank(playerRanks[source], serviceType)
    return rank and rank.administrative == true
end


local function getAutomaticRank(points, serviceType)
    points = tonumber(points) or 0
    local result = 1
    local rankPoints = getServiceRankPoints(serviceType)
    for rankId = 1, #rankPoints do
        if points >= (rankPoints[rankId] or 0) then
            result = rankId
        else
            break
        end
    end
    return result
end

local function getNextRankInfo(rankId, points, serviceType)
    rankId = tonumber(rankId) or 1
    points = tonumber(points) or 0
    local rankPoints = getServiceRankPoints(serviceType)
    if not rankPoints[rankId + 1] then
        return { max = true }
    end
    local nextId = rankId + 1
    local required = rankPoints[nextId]
    return {
        id = nextId,
        label = getRank(nextId, serviceType).label,
        required = required,
        remaining = math.max(0, required - points)
    }
end

local function setPlayerRank(source, characterId, rankId, assignedBy)
    rankId = tonumber(rankId)
    local serviceType = activeServices[source]
    if not supportedServices[serviceType] then return false, 'No hay un servicio activo.' end
    if not getServiceRanks(serviceType)[rankId] then return false, 'Rango no valido para este servicio.' end

    MySQL.insert.await([[INSERT INTO smvlpd_police_ranks (character_id, service_type, rank_id, assigned_by)
        VALUES (?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE rank_id = VALUES(rank_id), assigned_by = VALUES(assigned_by), updated_at = CURRENT_TIMESTAMP]], {
        characterId, serviceType, rankId, assignedBy
    })

    playerRanks[source] = rankId
    Player(source).state:set('smvlpdPoliceRank', rankId, true)
    TriggerClientEvent('smvlpd-ranks:client:rankUpdated', source, rankId, getRank(rankId, serviceType).label, serviceType)
    return true
end

MySQL.ready(function()
    MySQL.query.await([[CREATE TABLE IF NOT EXISTS smvlpd_police_ranks (
        character_id INT UNSIGNED NOT NULL,
        service_type VARCHAR(20) NOT NULL DEFAULT 'police',
        rank_id TINYINT UNSIGNED NOT NULL DEFAULT 1,
        assigned_by VARCHAR(80) NULL,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (character_id, service_type),
        CONSTRAINT fk_smvlpd_police_rank_character FOREIGN KEY (character_id)
            REFERENCES smvlpd_characters(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4]])
    MySQL.query.await([[CREATE TABLE IF NOT EXISTS smvlpd_police_points (
        character_id INT UNSIGNED NOT NULL,
        service_type VARCHAR(20) NOT NULL DEFAULT 'police',
        points INT UNSIGNED NOT NULL DEFAULT 0,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (character_id, service_type),
        CONSTRAINT fk_smvlpd_police_points_character FOREIGN KEY (character_id)
            REFERENCES smvlpd_characters(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4]])

    local rankServiceColumn = tonumber(MySQL.scalar.await([[SELECT COUNT(*) FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'smvlpd_police_ranks' AND COLUMN_NAME = 'service_type']])) or 0
    if rankServiceColumn == 0 then
        MySQL.query.await("ALTER TABLE smvlpd_police_ranks ADD COLUMN service_type VARCHAR(20) NOT NULL DEFAULT 'police' AFTER character_id")
    end

    local rankServiceInPrimary = tonumber(MySQL.scalar.await([[SELECT COUNT(*) FROM information_schema.KEY_COLUMN_USAGE
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'smvlpd_police_ranks'
        AND CONSTRAINT_NAME = 'PRIMARY' AND COLUMN_NAME = 'service_type']])) or 0
    if rankServiceInPrimary == 0 then
        MySQL.query.await('ALTER TABLE smvlpd_police_ranks DROP PRIMARY KEY, ADD PRIMARY KEY (character_id, service_type)')
    end

    local pointsServiceColumn = tonumber(MySQL.scalar.await([[SELECT COUNT(*) FROM information_schema.COLUMNS
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'smvlpd_police_points' AND COLUMN_NAME = 'service_type']])) or 0
    if pointsServiceColumn == 0 then
        MySQL.query.await("ALTER TABLE smvlpd_police_points ADD COLUMN service_type VARCHAR(20) NOT NULL DEFAULT 'police' AFTER character_id")
    end


    local pointsServiceInPrimary = tonumber(MySQL.scalar.await([[SELECT COUNT(*) FROM information_schema.KEY_COLUMN_USAGE
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'smvlpd_police_points'
        AND CONSTRAINT_NAME = 'PRIMARY' AND COLUMN_NAME = 'service_type']])) or 0
    if pointsServiceInPrimary == 0 then
        MySQL.query.await('ALTER TABLE smvlpd_police_points DROP PRIMARY KEY, ADD PRIMARY KEY (character_id, service_type)')
    end

    -- Importa una sola vez los datos del antiguo recurso smvlpd-ems-ranks.
    -- INSERT IGNORE conserva cualquier progreso de ambulance ya existente aqui.
    local oldEmsRanks = tonumber(MySQL.scalar.await([[SELECT COUNT(*) FROM information_schema.TABLES
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'smvlpd_ems_ranks']])) or 0
    if oldEmsRanks > 0 then
        
    end

    local oldEmsPoints = tonumber(MySQL.scalar.await([[SELECT COUNT(*) FROM information_schema.TABLES
        WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = 'smvlpd_ems_points']])) or 0
    if oldEmsPoints > 0 then
        MySQL.query.await([[INSERT IGNORE INTO smvlpd_police_points
            (character_id, service_type, points, updated_at)
            SELECT character_id, 'ambulance', points, updated_at FROM smvlpd_ems_points]])
    end

    print('[smvlpd-ranks] Sistema de rangos y puntos por servicio listo.')
end)

local function clearActiveProgress(playerSource)
    activeCallouts[playerSource] = nil
    activeExternalCallouts[playerSource] = nil
    serviceSummaries[playerSource] = nil
    activeServices[playerSource] = nil
    playerRanks[playerSource] = nil
    playerPoints[playerSource] = nil
    Player(playerSource).state:set('smvlpdActiveService', nil, true)
    Player(playerSource).state:set('smvlpdPoliceRank', 0, true)
    Player(playerSource).state:set('smvlpdPolicePoints', 0, true)
    TriggerClientEvent('smvlpd-ranks:client:serviceChanged', playerSource, nil)
end

local function loadServiceProgress(playerSource, characterId, serviceType)
    if not supportedServices[serviceType] then
        clearActiveProgress(playerSource)
        return
    end

    local previousService = activeServices[playerSource]
    if previousService and previousService ~= serviceType then
        activeCallouts[playerSource] = nil
        activeExternalCallouts[playerSource] = nil
        serviceSummaries[playerSource] = nil
    end

    activeServices[playerSource] = serviceType

    MySQL.insert.await(
        'INSERT IGNORE INTO smvlpd_police_points (character_id, service_type, points) VALUES (?, ?, 0)',
        { characterId, serviceType }
    )

    local points = tonumber(MySQL.scalar.await(
        'SELECT points FROM smvlpd_police_points WHERE character_id = ? AND service_type = ?',
        { characterId, serviceType }
    )) or 0
    playerPoints[playerSource] = points

    local rankId = tonumber(MySQL.scalar.await(
        'SELECT rank_id FROM smvlpd_police_ranks WHERE character_id = ? AND service_type = ?',
        { characterId, serviceType }
    ))

    Player(playerSource).state:set('smvlpdActiveService', serviceType, true)
    Player(playerSource).state:set('smvlpdPolicePoints', points, true)

    if not rankId then
        setPlayerRank(playerSource, characterId, 1, 'system')
    else
        playerRanks[playerSource] = rankId
        Player(playerSource).state:set('smvlpdPoliceRank', rankId, true)
        TriggerClientEvent('smvlpd-ranks:client:rankUpdated', playerSource, rankId, getRank(rankId, serviceType).label, serviceType)
    end

    TriggerClientEvent('smvlpd-ranks:client:serviceChanged', playerSource, serviceType)
end

local function loadCharacter(playerSource, characterId)

    characterId = tonumber(characterId)
    
    if not characterId then return end

    local license = GetPlayerIdentifierByType(playerSource, 'license')
    local ownsCharacter = MySQL.scalar.await('SELECT id FROM smvlpd_characters WHERE id = ? AND license = ?', { characterId, license })
    if not ownsCharacter then return end

    activeCharacters[playerSource] = characterId
    local serviceType = getNightErsService(playerSource)
    if serviceType then
        loadServiceProgress(playerSource, characterId, serviceType)
    else
        clearActiveProgress(playerSource)
    end
end

RegisterNetEvent('ErsIntegration::OnToggleShift', function(reportedSource, isOnShift, serviceType)

    local playerSource = source

    if playerSource == 0 then
        playerSource = tonumber(reportedSource)
    end

    if not playerSource or not activeCharacters[playerSource] then
        return
    end

    if isOnShift == true and supportedServices[serviceType] then
        loadServiceProgress(
            playerSource,
            activeCharacters[playerSource],
            serviceType
        )
    elseif isOnShift == false then
        clearActiveProgress(playerSource)
    end

end)

RegisterNetEvent('smvlpd-ranks:server:syncClientService', function(serviceType)
    local playerSource = source
    local characterId = activeCharacters[playerSource]
    if not characterId then return end

    if supportedServices[serviceType] then
        if activeServices[playerSource] ~= serviceType then
            loadServiceProgress(playerSource, characterId, serviceType)
        else
            -- Fuerza de nuevo el HUD si el evento inicial se perdio.
            TriggerClientEvent('smvlpd-ranks:client:serviceChanged', playerSource, serviceType)
        end
    elseif activeServices[playerSource] then
        clearActiveProgress(playerSource)
    end
end)

CreateThread(function()
    while true do
        Wait(1000)

        for playerSource, characterId in pairs(activeCharacters) do
            local serviceType = getNightErsService(playerSource)

            if serviceType ~= activeServices[playerSource] then
                if serviceType then
                    loadServiceProgress(playerSource, characterId, serviceType)
                elseif activeServices[playerSource] then
                    clearActiveProgress(playerSource)
                end
            end
        end
    end
end)

RegisterNetEvent('smvlpd-ranks:server:characterLoaded', function(characterId)
    loadCharacter(source, characterId)
end)



lib.callback.register('smvlpd-ranks:server:getRank', function(source)

    local serviceType = activeServices[source]
    if not serviceType then return nil end

    local rankId = playerRanks[source] or 1
    local rank = getRank(rankId, serviceType)

    local characterId = activeCharacters[source]

    local surname = ""

    if characterId then
        surname = MySQL.scalar.await(
            "SELECT last_name FROM smvlpd_characters WHERE id = ?",
            { characterId }
        ) or ""
    end
    return {
        id = rankId,
        label = rank.label,
        uniform = (Config.Uniforms[serviceType] or {})[rankId],
        image = rank.image,
        player = surname,
        service = serviceType
    }

end)


lib.callback.register('smvlpd-ranks:server:getPoints', function(source)
    local serviceType = activeServices[source]
    if not serviceType then return nil end
    local rankId = playerRanks[source] or 1
    local points = playerPoints[source] or 0
    local rank = getRank(rankId, serviceType)
    return {
        points = points,
        rankId = rankId,
        rankLabel = rank.label,
        administrative = rank.administrative == true,
        nextRank = getNextRankInfo(rankId, points, serviceType),
        service = serviceType
    }
end)

-- API interna para futuras integraciones con callouts y acciones policiales.
-- No se expone al cliente para evitar que un jugador pueda otorgarse puntos.
local function addPoints(source, amount, reason)
    source = tonumber(source)
    amount = math.floor(tonumber(amount) or 0)
    if not source or amount <= 0 then return false, 'Cantidad de puntos no valida.' end

    local characterId = activeCharacters[source]
    if not characterId then return false, 'El jugador no tiene un personaje activo.' end
    local serviceType = activeServices[source]
    if not serviceType then return false, 'El jugador no esta de servicio.' end

    local oldRank = playerRanks[source] or 1
    local newPoints = (playerPoints[source] or 0) + amount

    MySQL.update.await('UPDATE smvlpd_police_points SET points = ? WHERE character_id = ? AND service_type = ?', {
        newPoints, characterId, serviceType
    })
    playerPoints[source] = newPoints
    Player(source).state:set('smvlpdPolicePoints', newPoints, true)

    local summary = serviceSummaries[source]
    if summary then
        summary.total = summary.total + amount
        summary.entries[#summary.entries + 1] = { amount = amount, reason = reason or 'Servicio policial' }
    end

    TriggerClientEvent('smvlpd-ranks:client:pointsAdded', source, amount, newPoints, reason or 'Servicio policial')

    -- Los rangos administrativos nunca son modificados por puntos.
    if not getRank(oldRank, serviceType).administrative then
        local newRank = getAutomaticRank(newPoints, serviceType)
        if newRank > oldRank then
            setPlayerRank(source, characterId, newRank, 'automatic_points')
            TriggerClientEvent('smvlpd-ranks:client:promoted', source, newRank, getRank(newRank, serviceType).label, newPoints)
        end
    end
    return true
end

exports('AddPolicePoints', addPoints)
exports('AddEMSPoints', addPoints)

-- API exclusiva de servidor para los recursos de avisos externos (como ERS).
local function awardExternalCallout(source, calloutId, calloutName)
    if not activeExternalCallouts[source] then
        return false, 'El jugador no tiene un aviso ERS activo.'
    end

    activeExternalCallouts[source] = nil

    local rewardId = Config.ERSCalloutDifficulties[tostring(calloutId or '')] or 'calloutNormal'
    local amount = Config.PointRewards[rewardId]

    return addPoints(
        source,
        amount,
        'Aviso ERS completado: ' .. tostring(calloutName or 'Aviso policial')
    )
end

exports('AwardExternalPoliceCallout', awardExternalCallout)
exports('AwardExternalEMSCallout', awardExternalCallout)

exports('BeginExternalPoliceCallout', function(source)
    if not activeCharacters[source] then return false end

    activeExternalCallouts[source] = { lastAwardAt = {} }
    serviceSummaries[source] = serviceSummaries[source] or { total = 0, entries = {} }

    return true
end)

exports('BeginExternalEMSCallout', function(source)
    if not activeCharacters[source] or activeServices[source] ~= 'ambulance' then return false end
    activeExternalCallouts[source] = { lastAwardAt = {} }
    serviceSummaries[source] = serviceSummaries[source] or { total = 0, entries = {} }
    return true
end)

exports('CancelExternalPoliceCallout', function(source)
    activeExternalCallouts[tonumber(source)] = nil
    return true
end)

exports('CancelExternalEMSCallout', function(source)
    activeExternalCallouts[tonumber(source)] = nil
    return true
end)

RegisterNetEvent('smvlpd-ranks:server:calloutStarted', function(title)
    if not activeCharacters[source] then return end
    activeCallouts[source] = { title = tostring(title or 'Aviso policial'), lastAwardAt = {} }
    serviceSummaries[source] = serviceSummaries[source] or { total = 0, entries = {} }
end)

RegisterNetEvent('smvlpd-ranks:server:awardCalloutAction', function(actionId)
    local callout = activeCallouts[source] or activeExternalCallouts[source]
    local reward = Config.PointRewards[actionId]
    if not callout or not reward then return end

    callout.lastAwardAt = callout.lastAwardAt or {}
    local now = GetGameTimer()
    local cooldown = math.max(0, tonumber(Config.ActionRewardCooldownMs) or 1500)
    local lastAwardAt = tonumber(callout.lastAwardAt[actionId]) or 0
    if lastAwardAt > 0 and (now - lastAwardAt) < cooldown then return end

    callout.lastAwardAt[actionId] = now
    local labels = {
        arrest = 'Arresto', citation = 'Multa', breathalyzer = 'Alcoholimetria', drugTest = 'Prueba de drogas', tow = 'Grua',
        searchPerson = 'Registro de persona', searchVehicle = 'Registro de vehiculo', documents = 'Documentacion',
        investigation = 'Investigacion', minorAction = 'Otra accion'
    }
    addPoints(source, reward, labels[actionId] or 'Accion policial')
end)

RegisterNetEvent('smvlpd-ranks:server:calloutCompleted', function()
    local callout = activeCallouts[source]
    if not callout then return end

    local rewardId = Config.CalloutDifficulties[callout.title] or 'calloutNormal'
    addPoints(source, Config.PointRewards[rewardId], 'Aviso completado: ' .. callout.title)
    activeCallouts[source] = nil
end)

RegisterNetEvent('smvlpd-ranks:server:requestServiceSummary', function()
    local summary = serviceSummaries[source] or { total = 0, entries = {} }
    TriggerClientEvent('smvlpd-ranks:client:serviceSummary', source, summary.total, summary.entries)
    serviceSummaries[source] = { total = 0, entries = {} }
end)

RegisterNetEvent('smvlpd-ranks:server:requestWeapon', function(weaponName)
    local source = source
    local serviceType = activeServices[source]
    local rankId = playerRanks[source] or 1
    local rank = getRank(rankId, serviceType)
    if rank.administrative then
        return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'Los rangos administrativos no tienen armeria propia.' })
    end

    for _, weapon in ipairs(rank.weapons) do
        if weapon.name == weaponName then
            TriggerClientEvent('smvlpd-ranks:client:receiveWeapon', source, weapon)
            return
        end
    end

    print(('[smvlpd-ranks] %s intento retirar un arma no autorizada.'):format(GetPlayerName(source) or source))
end)
RegisterNetEvent('smvlpd-ranks:server:requestLoadout', function()

    local source = source
    local serviceType = activeServices[source]
    local rankId = playerRanks[source] or 1
    local rank = getRank(rankId, serviceType)

    if rank.administrative then
        rank = getRank(getAutomaticRank(math.huge, serviceType), serviceType)
    end

    TriggerClientEvent(
        'smvlpd-ranks:client:receiveLoadout',
        source,
        rank.weapons
    )

end)
RegisterNetEvent('smvlpd-ranks:server:requestAmmo', function()

    local source = source
    local serviceType = activeServices[source]
    local rankId = playerRanks[source] or 1
    local rank = getRank(rankId, serviceType)

    if rank.administrative then
        rank = getRank(getAutomaticRank(math.huge, serviceType), serviceType)
    end

    TriggerClientEvent(
        'smvlpd-ranks:client:receiveAmmo',
        source,
        rank.weapons
    )

end)

RegisterNetEvent('smvlpd-ranks:server:requestManagement', function()
    local source = source

    if not isManager(source) then
        return TriggerClientEvent('ox_lib:notify', source, {
            type = 'error',
            description = 'No tienes permiso para gestionar rangos.'
        })
    end

    local players = {}

    for _, playerId in ipairs(GetPlayers()) do
        playerId = tonumber(playerId)

        if activeCharacters[playerId] then

            local serviceType = activeServices[playerId]

            if serviceType then

                local rankId = playerRanks[playerId] or 1
                local rank = getRank(rankId, serviceType)

                players[#players + 1] = {
                    serverId = playerId,
                    name = GetPlayerName(playerId) or ('ID %s'):format(playerId),
                    service = serviceType,
                    rankId = rankId,
                    rankLabel = rank.label,
                }

            end
        end
    end

    TriggerClientEvent(
        'smvlpd-ranks:client:openManagement',
        source,
        players
    )
end)



RegisterNetEvent('smvlpd-ranks:server:setRank', function(targetId, rankId)
    local source = source
    if not isManager(source) then
        return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'No tienes permiso para gestionar rangos.' })
    end

    targetId = tonumber(targetId)
    local characterId = targetId and activeCharacters[targetId]
    if not characterId then
        return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'Ese jugador no tiene un personaje activo.' })
    end

    local ok, message = setPlayerRank(targetId, characterId, rankId, GetPlayerIdentifierByType(source, 'license') or 'console')
    if not ok then return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = message }) end
    TriggerClientEvent('ox_lib:notify', source, { type = 'success', description = 'Rango actualizado correctamente.' })
end)
local function GetAllowedVehicles(source)

    source = tonumber(source)
    if not source then
        return {}
    end

    -- Primero usamos la caché del sistema de rangos.
    local rankId = tonumber(playerRanks[source])
    local serviceType = activeServices[source]

    -- Si la caché todavía no se ha sincronizado con ERS, recuperamos el
    -- servicio actual directamente de ERS y el rango persistido del statebag.
    if not serviceType and GetResourceState('night_ers') == 'started' then
        local ok, currentService = pcall(function()
            return exports['night_ers']:getPlayerActiveServiceType(source)
        end)
        if ok and currentService then
            serviceType = currentService
        end
    end

    if not rankId then
        local state = Player(source).state
        rankId = tonumber(state.smvlpdPoliceRank)
    end

    rankId = rankId or 1

    local vehiclesByService = Config.ServiceVehicles and Config.ServiceVehicles[serviceType]

    if not vehiclesByService then
        print(('[RANKS] Sin tabla de vehiculos para servicio %s (jugador %s).'):format(
            tostring(serviceType), source
        ))
        return {}
    end

    local vehicles = vehiclesByService[rankId] or {}

    print(('[RANKS] Servicio=%s Rango=%s Vehiculos=%s'):format(
        tostring(serviceType), tostring(rankId), json.encode(vehicles)
    ))

    return vehicles
end
lib.callback.register('smvlpd-ranks:server:getAllowedVehicles', function(source)
    return GetAllowedVehicles(source)
end)

lib.callback.register('smvlpd-ranks:server:getAllowedVehicles', function(source)
    return GetAllowedVehicles(source)
end)

exports('GetAllowedVehicles', GetAllowedVehicles)

AddEventHandler('playerDropped', function()
    activeCharacters[source] = nil
    activeServices[source] = nil
    playerRanks[source] = nil
    playerPoints[source] = nil
    activeCallouts[source] = nil
    activeExternalCallouts[source] = nil
    serviceSummaries[source] = nil
end)
AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    Wait(1000)

    for _, playerId in ipairs(GetPlayers()) do

        playerId = tonumber(playerId)

        local characterId = exports['smvlpd-character']:GetActiveCharacter(playerId)

        if characterId then
            loadCharacter(playerId, characterId)
        end

    end
end)
RegisterCommand('darpuntos', function(source, args)

    if source ~= 0 then
        return
    end

    local id = tonumber(args[1])
    local puntos = tonumber(args[2])

    if not id or not puntos then
        print("Uso: darpuntos <id> <puntos>")
        return
    end

    local ok, err = addPoints(id, puntos, "Prueba")

    if ok then
        print(("Se han añadido %s puntos al jugador %s."):format(puntos, id))
    else
        print(err)
    end

end, true)

local function adminRankMessage(source, message, messageType)
    if source == 0 then
        print(('[smvlpd-ranks] %s'):format(message))
    else
        TriggerClientEvent('ox_lib:notify', source, {
            type = messageType or 'inform',
            description = message
        })
    end
end

local function changeRankByOne(source, args, direction)
    if not isManager(source) then
        return adminRankMessage(source, 'No tienes permiso para modificar rangos.', 'error')
    end

    local targetId = tonumber(args[1])
    if not targetId then
        local command = direction > 0 and 'subirrango' or 'bajarrango'
        return adminRankMessage(source, ('Uso: /%s <id>'):format(command), 'error')
    end

    local characterId = activeCharacters[targetId]
    local serviceType = activeServices[targetId]
    if not characterId or not supportedServices[serviceType] then
        return adminRankMessage(source, 'El jugador debe tener un personaje y estar de servicio.', 'error')
    end

    local ranks = getServiceRanks(serviceType)
    local oldRankId = tonumber(playerRanks[targetId]) or 1
    local newRankId = oldRankId + direction

    if not ranks[newRankId] then
        local limit = direction > 0 and 'maximo' or 'minimo'
        return adminRankMessage(source, ('El jugador ya esta en el rango %s de %s.'):format(
            limit, (Config.ServiceLabels and Config.ServiceLabels[serviceType]) or serviceType
        ), 'error')
    end

    local assignedBy = source == 0 and 'console'
        or (GetPlayerIdentifierByType(source, 'license') or ('server:%s'):format(source))
    local ok, err = setPlayerRank(targetId, characterId, newRankId, assignedBy)
    if not ok then
        return adminRankMessage(source, err or 'No se pudo modificar el rango.', 'error')
    end

    local action = direction > 0 and 'subido' or 'bajado'
    local rankLabel = getRank(newRankId, serviceType).label
    adminRankMessage(source, ('Has %s a %s al rango %s (%s).'):format(
        action, GetPlayerName(targetId) or ('ID %s'):format(targetId), rankLabel,
        (Config.ServiceLabels and Config.ServiceLabels[serviceType]) or serviceType
    ), 'success')

    TriggerClientEvent('ox_lib:notify', targetId, {
        type = direction > 0 and 'success' or 'inform',
        description = ('Tu nuevo rango de %s es %s.'):format(
            (Config.ServiceLabels and Config.ServiceLabels[serviceType]) or serviceType, rankLabel
        )
    })
end

RegisterCommand('subirrango', function(source, args)
    changeRankByOne(source, args, 1)
end, false)

RegisterCommand('bajarrango', function(source, args)
    changeRankByOne(source, args, -1)
end, false)
