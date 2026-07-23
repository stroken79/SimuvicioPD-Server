local activeCharacters = {}
local databaseReady = false

local function getLicense(source)
    for _, identifier in ipairs(GetPlayerIdentifiers(source)) do
        if identifier:sub(1, 8) == 'license:' then return identifier end
    end
end

local function decodeCharacter(row)
    row.appearance = row.appearance and json.decode(row.appearance) or nil
    row.last_position = row.last_position and json.decode(row.last_position) or nil
    return row
end

MySQL.ready(function()
    MySQL.query.await([[CREATE TABLE IF NOT EXISTS smvlpd_characters (
        id INT UNSIGNED NOT NULL AUTO_INCREMENT,
        license VARCHAR(80) NOT NULL,
        slot TINYINT UNSIGNED NOT NULL DEFAULT 1,
        first_name VARCHAR(32) NOT NULL,
        last_name VARCHAR(32) NOT NULL,
        gender ENUM('male','female') NOT NULL,
        appearance LONGTEXT NOT NULL,
        last_position JSON NULL,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
        PRIMARY KEY (id), UNIQUE KEY uq_smvlpd_character_slot (license, slot)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;]])
    databaseReady = true
    print('[smvlpd-character] Standalone character system ready.')
end)

RegisterNetEvent('smvlpd-character:server:requestCharacters', function()
    local source, license = source, getLicense(source)
    while not databaseReady do Wait(0) end
    if not license then return DropPlayer(source, 'No se encontró tu identificador license de FiveM.') end
    local rows = MySQL.query.await('SELECT id, slot, first_name, last_name, gender FROM smvlpd_characters WHERE license = ? ORDER BY slot', { license })
    TriggerClientEvent('smvlpd-character:client:showCharacters', source, rows)
end)

RegisterNetEvent('smvlpd-character:server:createCharacter', function(firstName, lastName, gender, appearance)
    local source, license = source, getLicense(source)
    while not databaseReady do Wait(0) end
    if not license or type(appearance) ~= 'table' then return end
    firstName, lastName = tostring(firstName or ''), tostring(lastName or '')
    if #firstName < 2 or #firstName > 32 or #lastName < 2 or #lastName > 32 then return end
    gender = gender == 'female' and 'female' or 'male'
    local count = tonumber(MySQL.scalar.await('SELECT COUNT(*) FROM smvlpd_characters WHERE license = ?', { license })) or 0
    if count >= Config.MaxCharacters then
        return TriggerClientEvent('smvlpd-character:client:notify', source, 'Has alcanzado el límite de personajes.')
    end
    local id = MySQL.insert.await('INSERT INTO smvlpd_characters (license, slot, first_name, last_name, gender, appearance) VALUES (?, ?, ?, ?, ?, ?)', {
        license, count + 1, firstName, lastName, gender, json.encode(appearance)
    })
    local character = decodeCharacter(MySQL.single.await('SELECT * FROM smvlpd_characters WHERE id = ? AND license = ?', { id, license }))
    activeCharacters[source] = character.id
    TriggerClientEvent('smvlpd-character:client:characterLoaded', source, character)
end)

RegisterNetEvent('smvlpd-character:server:selectCharacter', function(id)
    local source, license = source, getLicense(source)
    while not databaseReady do Wait(0) end
    if not license or type(id) ~= 'number' then return end
    local row = MySQL.single.await('SELECT * FROM smvlpd_characters WHERE id = ? AND license = ?', { id, license })
    if not row then return TriggerClientEvent('smvlpd-character:client:notify', source, 'Personaje no válido.') end
    local character = decodeCharacter(row)
    activeCharacters[source] = character.id
    TriggerClientEvent('smvlpd-character:client:characterLoaded', source, character)
end)

RegisterNetEvent('smvlpd-character:server:saveCharacter', function(id, appearance, position)
    local source, license = source, getLicense(source)
    while not databaseReady do Wait(0) end
    if activeCharacters[source] ~= id or type(appearance) ~= 'table' or type(position) ~= 'table' then return end
    MySQL.update.await('UPDATE smvlpd_characters SET appearance = ?, last_position = ? WHERE id = ? AND license = ?', {
        json.encode(appearance), json.encode(position), id, license
    })
end)

AddEventHandler('playerDropped', function()
    activeCharacters[source] = nil
end)
