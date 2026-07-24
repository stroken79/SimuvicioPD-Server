local activeCharacters = {}
local playerRanks = {}
local playerPoints = {}

local function getRank(rankId)
    return Config.Ranks[tonumber(rankId) or 1] or Config.Ranks[1]
end

local function isManager(source)
    -- La consola siempre puede gestionar rangos.
    if source == 0 then return true end

    -- Mantiene el permiso ACE como acceso administrativo de emergencia.
    if IsPlayerAceAllowed(source, Config.ManagementAce) then return true end

    -- El Jefe de Policia (rango 14) tiene control total de la gestion de rangos.
    return tonumber(playerRanks[source]) == 14
end


local function getAutomaticRank(points)
    points = tonumber(points) or 0
    local result = 1
    for rankId = 1, 11 do
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
    if rankId >= 12 then
        return nil
    end
    if rankId >= 11 then
        return { max = true }
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

    MySQL.insert.await([[INSERT INTO smvlpd_police_ranks (character_id, rank_id, assigned_by)
        VALUES (?, ?, ?)
        ON DUPLICATE KEY UPDATE rank_id = VALUES(rank_id), assigned_by = VALUES(assigned_by), updated_at = CURRENT_TIMESTAMP]], {
        characterId, rankId, assignedBy
    })

    playerRanks[source] = rankId
    Player(source).state:set('smvlpdPoliceRank', rankId, true)
    TriggerClientEvent('smvlpd-ranks:client:rankUpdated', source, rankId, getRank(rankId).label)
    return true
end

MySQL.ready(function()
    MySQL.query.await([[CREATE TABLE IF NOT EXISTS smvlpd_police_ranks (
        character_id INT UNSIGNED NOT NULL,
        rank_id TINYINT UNSIGNED NOT NULL DEFAULT 1,
        assigned_by VARCHAR(80) NULL,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (character_id),
        CONSTRAINT fk_smvlpd_police_rank_character FOREIGN KEY (character_id)
            REFERENCES smvlpd_characters(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4]])
    MySQL.query.await([[CREATE TABLE IF NOT EXISTS smvlpd_police_points (
        character_id INT UNSIGNED NOT NULL,
        points INT UNSIGNED NOT NULL DEFAULT 0,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (character_id),
        CONSTRAINT fk_smvlpd_police_points_character FOREIGN KEY (character_id)
            REFERENCES smvlpd_characters(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4]])

    print('[smvlpd-ranks] Sistema de rangos y puntos listo.')
end)

RegisterNetEvent('smvlpd-ranks:server:characterLoaded', function(characterId)
    local source = source
    characterId = tonumber(characterId)
    if not characterId then return end

    local license = GetPlayerIdentifierByType(source, 'license')
    local ownsCharacter = MySQL.scalar.await('SELECT id FROM smvlpd_characters WHERE id = ? AND license = ?', { characterId, license })
    if not ownsCharacter then return end

    activeCharacters[source] = characterId

    MySQL.insert.await([[INSERT IGNORE INTO smvlpd_police_points (character_id, points) VALUES (?, 0)]], { characterId })
    local points = tonumber(MySQL.scalar.await('SELECT points FROM smvlpd_police_points WHERE character_id = ?', { characterId })) or 0
    playerPoints[source] = points
    Player(source).state:set('smvlpdPolicePoints', points, true)

    local rankId = tonumber(MySQL.scalar.await('SELECT rank_id FROM smvlpd_police_ranks WHERE character_id = ?', { characterId })) or 1
    if not MySQL.scalar.await('SELECT 1 FROM smvlpd_police_ranks WHERE character_id = ?', { characterId }) then
        setPlayerRank(source, characterId, 1, 'system')
    else
        playerRanks[source] = rankId
        Player(source).state:set('smvlpdPoliceRank', rankId, true)
        TriggerClientEvent('smvlpd-ranks:client:rankUpdated', source, rankId, getRank(rankId).label)
    end
end)

lib.callback.register('smvlpd-ranks:server:getRank', function(source)
    local rankId = playerRanks[source] or 1
    local rank = getRank(rankId)
    return { id = rankId, label = rank.label, uniform = Config.Uniforms[rankId] }
end)


lib.callback.register('smvlpd-ranks:server:getPoints', function(source)
    local rankId = playerRanks[source] or 1
    local points = playerPoints[source] or 0
    local rank = getRank(rankId)
    return {
        points = points,
        rankId = rankId,
        rankLabel = rank.label,
        administrative = rankId >= 12,
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

    MySQL.update.await('UPDATE smvlpd_police_points SET points = ? WHERE character_id = ?', { newPoints, characterId })
    playerPoints[source] = newPoints
    Player(source).state:set('smvlpdPolicePoints', newPoints, true)

    TriggerClientEvent('smvlpd-ranks:client:pointsAdded', source, amount, newPoints, reason or 'Servicio policial')

    -- Los rangos administrativos nunca son modificados por puntos.
    if oldRank <= 11 then
        local newRank = getAutomaticRank(newPoints)
        if newRank > oldRank then
            setPlayerRank(source, characterId, newRank, 'automatic_points')
            TriggerClientEvent('smvlpd-ranks:client:promoted', source, newRank, getRank(newRank).label, newPoints)
        end
    end
    return true
end

exports('AddPolicePoints', addPoints)

RegisterNetEvent('smvlpd-ranks:server:requestWeapon', function(weaponName)
    local source = source
    local rankId = playerRanks[source] or 1
    local rank = getRank(rankId)
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

RegisterNetEvent('smvlpd-ranks:server:requestManagement', function()
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
    TriggerClientEvent('smvlpd-ranks:client:openManagement', source, players)
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

AddEventHandler('playerDropped', function()
    activeCharacters[source] = nil
    playerRanks[source] = nil
    playerPoints[source] = nil
end)
