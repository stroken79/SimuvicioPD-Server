local activeCharacters = {}
local playerRanks = {}
local playerPoints = {}
local activeCallouts = {}
local activeExternalCallouts = {}
local serviceSummaries = {}

local function getRank(rankId)
    return Config.Ranks[tonumber(rankId) or 1] or Config.Ranks[1]
end

local function isManager(source)
    -- La consola siempre puede gestionar rangos.
    if source == 0 then return true end

    -- Mantiene el permiso ACE como acceso administrativo de emergencia.
    if IsPlayerAceAllowed(source, Config.ManagementAce) then return true end

    -- El Director General (rango 12) tiene control total de la gestión de rangos EMS.
    return tonumber(playerRanks[source]) == 12
end


local function getAutomaticRank(points)
    points = tonumber(points) or 0
    local result = 1
    for rankId = 1, 9 do
        if points >= (Config.RankPoints[rankId] or 0) then
            result = rankId
        else
            break
        end
    end
    return result
end

local function getNextRankInfo(rankId, points)
    rankId = tonumber(rankId) or 1
    points = tonumber(points) or 0

    -- Los rangos administrativos no ascienden por puntos.
    if rankId >= 10 then
        return {
            max = true,
            administrative = true
        }
    end

    local nextId = rankId + 1
    local required = Config.RankPoints[nextId]

    return {
        id = nextId,
        label = getRank(nextId).label,
        required = required,
        remaining = math.max(0, required - points)
    }
end

local function setPlayerRank(source, characterId, rankId, assignedBy)
    rankId = tonumber(rankId)
    if not Config.Ranks[rankId] then return false, 'Rango no valido.' end

    MySQL.insert.await([[INSERT INTO smvlpd_ems_ranks (character_id, rank_id, assigned_by)
        VALUES (?, ?, ?)
        ON DUPLICATE KEY UPDATE rank_id = VALUES(rank_id), assigned_by = VALUES(assigned_by), updated_at = CURRENT_TIMESTAMP]], {
        characterId, rankId, assignedBy
    })

    playerRanks[source] = rankId
    Player(source).state:set('smvlpdEMSRank', rankId, true)
    TriggerClientEvent('smvlpd-ems-ranks:client:rankUpdated', source, rankId, getRank(rankId).label)
    return true
end

MySQL.ready(function()
    MySQL.query.await([[CREATE TABLE IF NOT EXISTS smvlpd_ems_ranks (
        character_id INT UNSIGNED NOT NULL,
        rank_id TINYINT UNSIGNED NOT NULL DEFAULT 1,
        assigned_by VARCHAR(80) NULL,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (character_id),
        CONSTRAINT fk_smvlpd_ems_rank_character FOREIGN KEY (character_id)
            REFERENCES smvlpd_characters(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4]])
    MySQL.query.await([[CREATE TABLE IF NOT EXISTS smvlpd_ems_points (
        character_id INT UNSIGNED NOT NULL,
        points INT UNSIGNED NOT NULL DEFAULT 0,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (character_id),
        CONSTRAINT fk_smvlpd_ems_points_character FOREIGN KEY (character_id)
            REFERENCES smvlpd_characters(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4]])

    print('[smvlpd-ems-ranks] Sistema de rangos EMS iniciado.')
end)

local function loadCharacter(playerSource, characterId)

    characterId = tonumber(characterId)
    if not characterId then return end

    local license = GetPlayerIdentifierByType(playerSource, 'license')
    local ownsCharacter = MySQL.scalar.await('SELECT id FROM smvlpd_characters WHERE id = ? AND license = ?', { characterId, license })
    if not ownsCharacter then return end

    activeCharacters[playerSource] = characterId

    MySQL.insert.await('INSERT IGNORE INTO smvlpd_ems_points (character_id, points) VALUES (?, 0)', { characterId })

    local points = tonumber(MySQL.scalar.await('SELECT points FROM smvlpd_ems_points WHERE character_id = ?', { characterId })) or 0
    playerPoints[playerSource] = points
    Player(playerSource).state:set('smvlpdEMSPoints', points, true)

    local rankId = tonumber(MySQL.scalar.await('SELECT rank_id FROM smvlpd_ems_ranks WHERE character_id = ?', { characterId })) or 1

    if not MySQL.scalar.await('SELECT 1 FROM smvlpd_ems_ranks WHERE character_id = ?', { characterId }) then
        setPlayerRank(playerSource, characterId, 1, 'system')
    else
        playerRanks[playerSource] = rankId
        Player(playerSource).state:set('smvlpdEMSRank', rankId, true)
        TriggerClientEvent('smvlpd-ems-ranks:client:rankUpdated', playerSource, rankId, getRank(rankId).label)
    end
end

RegisterNetEvent('smvlpd-ems-ranks:server:characterLoaded', function(characterId)
    loadCharacter(source, characterId)
end)

lib.callback.register('smvlpd-ems-ranks:server:getRank', function(source)

    local rankId = playerRanks[source] or 1
    local rank = getRank(rankId)

    local characterId = activeCharacters[source]

    local surname = ""

    if characterId then
        surname = MySQL.scalar.await(
            "SELECT last_name FROM smvlpd_characters WHERE id = ?",
            { characterId }
        ) or ""
    end
    print("Apellido HUD:", surname)

    return {
        id = rankId,
        label = rank.label,
        uniform = Config.Uniforms[rankId],
        image = rank.image,
        player = surname
    }

end)


lib.callback.register('smvlpd-ems-ranks:server:getPoints', function(source)
    local rankId = playerRanks[source] or 1
    local points = playerPoints[source] or 0
    local rank = getRank(rankId)
    return {
        points = points,
        rankId = rankId,
        rankLabel = rank.label,
        administrative = rankId >= 10,
        nextRank = getNextRankInfo(rankId, points)
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

    local oldRank = playerRanks[source] or 1
    local newPoints = (playerPoints[source] or 0) + amount

    MySQL.update.await('UPDATE smvlpd_ems_points SET points = ? WHERE character_id = ?', { newPoints, characterId })
    playerPoints[source] = newPoints
    Player(source).state:set('smvlpdEMSPoints', newPoints, true)

    local summary = serviceSummaries[source]
    if summary then
        summary.total = summary.total + amount
        summary.entries[#summary.entries + 1] = { amount = amount, reason = reason or 'Servicio EMS' }
    end

    TriggerClientEvent('smvlpd-ems-ranks:client:pointsAdded', source, amount, newPoints, reason or 'Servicio EMS')

    -- Los rangos administrativos nunca son modificados por puntos.
    if oldRank <= 9 then
        local newRank = getAutomaticRank(newPoints)
        if newRank > oldRank then
            setPlayerRank(source, characterId, newRank, 'automatic_points')
            TriggerClientEvent('smvlpd-ems-ranks:client:promoted', source, newRank, getRank(newRank).label, newPoints)
        end
    end
    return true
end

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
    'Servicio EMS completado: ' .. tostring(calloutName or 'Aviso EMS')
)
end

exports('AwardExternalEMSCallout', awardExternalCallout)

exports('BeginExternalEMSCallout', function(source)
    if not activeCharacters[source] then return false end

    activeExternalCallouts[source] = true
    serviceSummaries[source] = serviceSummaries[source] or { total = 0, entries = {} }

    return true
end)

RegisterNetEvent('smvlpd-ems-ranks:server:calloutStarted', function(title)
    if not activeCharacters[source] then return end
    activeCallouts[source] = { title = tostring(title or 'Aviso EMS'), claimed = {} }
    serviceSummaries[source] = serviceSummaries[source] or { total = 0, entries = {} }
end)

RegisterNetEvent('smvlpd-ems-ranks:server:awardCalloutAction', function(actionId)
    local callout = activeCallouts[source]
    local reward = Config.PointRewards[actionId]
    if not callout or callout.claimed[actionId] or not reward then return end

    callout.claimed[actionId] = true
    local labels = {
        arrest = 'Arresto', citation = 'Multa', breathalyzer = 'Alcoholimetria', drugTest = 'Prueba de drogas', tow = 'Grua',
        searchPerson = 'Registro de persona', searchVehicle = 'Registro de vehiculo', documents = 'Documentacion',
        investigation = 'Investigacion', minorAction = 'Otra accion'
    }
    addPoints(source, reward, labels[actionId] or 'Intervención EMS')
end)

RegisterNetEvent('smvlpd-ems-ranks:server:calloutCompleted', function()
    local callout = activeCallouts[source]
    if not callout then return end

    local rewardId = Config.CalloutDifficulties[callout.title] or 'calloutNormal'
    addPoints(source, Config.PointRewards[rewardId], 'Aviso completado: ' .. callout.title)
    activeCallouts[source] = nil
end)

RegisterNetEvent('smvlpd-ems-ranks:server:requestServiceSummary', function()
    local summary = serviceSummaries[source] or { total = 0, entries = {} }
    TriggerClientEvent('smvlpd-ems-ranks:client:serviceSummary', source, summary.total, summary.entries)
    serviceSummaries[source] = { total = 0, entries = {} }
end)

RegisterNetEvent('smvlpd-ems-ranks:server:requestWeapon', function(weaponName)
    local source = source
    local rankId = playerRanks[source] or 1
    local rank = getRank(rankId)
    if rank.administrative then
        return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'Los rangos administrativos no tienen armeria propia.' })
    end

    for _, weapon in ipairs(rank.weapons) do
        if weapon.name == weaponName then
            TriggerClientEvent('smvlpd-ems-ranks:client:receiveWeapon', source, weapon)
            return
        end
    end

    print(('[smvlpd-ems-ranks] %s intento retirar un arma no autorizada.'):format(GetPlayerName(source) or source))
end)
RegisterNetEvent('smvlpd-ems-ranks:server:requestLoadout', function()

    local source = source

    local rankId = playerRanks[source] or 1
    local rank = getRank(rankId)

    if rank.administrative then
        rank = getRank(11)
    end

    TriggerClientEvent(
        'smvlpd-ems-ranks:client:receiveLoadout',
        source,
        rank.weapons
    )

end)
RegisterNetEvent('smvlpd-ems-ranks:server:requestAmmo', function()

    local source = source

    local rankId = playerRanks[source] or 1
    local rank = getRank(rankId)

    if rank.administrative then
        rank = getRank(11)
    end

    TriggerClientEvent(
        'smvlpd-ems-ranks:client:receiveAmmo',
        source,
        rank.weapons
    )

end)

RegisterNetEvent('smvlpd-ems-ranks:server:requestManagement', function()
    local source = source
    if not isManager(source) then
        return TriggerClientEvent('ox_lib:notify', source, { type = 'error', description = 'No tienes permiso para gestionar rangos.' })
    end

    local players = {}
    for _, playerId in ipairs(GetPlayers()) do
        playerId = tonumber(playerId)
        if activeCharacters[playerId] then
            local rankId = playerRanks[playerId] or 1
            players[#players + 1] = {
                serverId = playerId,
                name = GetPlayerName(playerId) or ('ID %s'):format(playerId),
                rankId = rankId,
                rankLabel = getRank(rankId).label,
            }
        end
    end
    TriggerClientEvent('smvlpd-ems-ranks:client:openManagement', source, players)
end)

RegisterNetEvent('smvlpd-ems-ranks:server:setRank', function(targetId, rankId)
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

    local rankId = playerRanks[source] or 1

    print("[RANKS] Vehículos rango "..rankId..": "..json.encode(Config.Vehicles[rankId]))

    return Config.Vehicles[rankId] or {}

end

exports('GetAllowedVehicles', GetAllowedVehicles)

AddEventHandler('playerDropped', function()
    activeCharacters[source] = nil
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
