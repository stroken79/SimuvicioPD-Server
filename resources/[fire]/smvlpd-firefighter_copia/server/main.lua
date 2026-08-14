local impactProgress = {}

local function debug(message)
    if Config.Debug then print(('[smvlpd-firefighter] %s'):format(message)) end
end

local function isFirefighterOnDuty(source)
    if GetResourceState('night_ers') ~= 'started' then return false end
    return exports['night_ers']:getIsPlayerOnShift(source)
        and exports['night_ers']:getPlayerActiveServiceType(source) == 'fire'
end

local function coordsOf(row)
    local coords = row and (row.coords or row.coordinates or row.Coords)
    if not coords then return nil end
    local x, y, z = tonumber(coords.x), tonumber(coords.y), tonumber(coords.z)
    return x and y and z and vector3(x, y, z) or nil
end

local function applyToRows(source, kind, impact, rows, stopExport, range, requiredTime)
    local now, stopped = GetGameTimer(), 0
    for id, row in pairs(rows or {}) do
        local coords = coordsOf(row)
        if coords and #(coords - impact) <= range then
            local targetId = row.id or row.fireId or row.smokeId or id
            local key = ('%s:%s'):format(kind, tostring(targetId))
            local progress = impactProgress[key]
            if not progress or now - progress.lastImpact > Config.WaterDamageInterval * 2 then
                progress = { accumulated = 0 }
                impactProgress[key] = progress
            end
            progress.lastImpact = now
            progress.accumulated = progress.accumulated + Config.WaterDamageInterval
            if progress.accumulated >= requiredTime then
                local ok = pcall(function() exports['SmartFiresLite'][stopExport](targetId) end)
                impactProgress[key] = nil
                if ok then stopped = stopped + 1 end
            end
        end
    end
    return stopped
end

local function applyToEntityFire(source, impact, entityNetId, range)
    entityNetId = tonumber(entityNetId)
    if not entityNetId or entityNetId <= 0 then return false end
    local entity = NetworkGetEntityFromNetworkId(entityNetId)
    if not entity or entity == 0 or not DoesEntityExist(entity) then return false end
    if #(GetEntityCoords(entity) - impact) > math.min(range, 5.0) then return false end

    local now = GetGameTimer()
    local key = 'entity:' .. entityNetId
    local progress = impactProgress[key]
    if not progress or now - progress.lastImpact > Config.WaterDamageInterval * 2 then
        progress = { accumulated = 0 }
        impactProgress[key] = progress
    end
    progress.lastImpact = now
    progress.accumulated = progress.accumulated + Config.WaterDamageInterval
    if progress.accumulated < Config.ExtinguishTime then return false end

    impactProgress[key] = nil
    TriggerClientEvent('smvlpd-firefighter:client:stopEntityFire', -1, entityNetId)
    debug(('Stopped native entity fire %s after water exposure.'):format(entityNetId))
    return true
end

RegisterNetEvent('smvlpd-firefighter:server:waterImpact', function(kind, rawCoords)
    local source = source
    if (kind ~= 'hose' and kind ~= 'cannon') or not isFirefighterOnDuty(source) then return end
    if type(rawCoords) ~= 'table' then return end
    local x, y, z = tonumber(rawCoords.x), tonumber(rawCoords.y), tonumber(rawCoords.z)
    if not x or not y or not z then return end
    local impact = vector3(x, y, z)

    if kind == 'cannon' then
        local ped = GetPlayerPed(source)
        local vehicle = ped ~= 0 and GetVehiclePedIsIn(ped, false) or 0
        if vehicle == 0 or GetPedInVehicleSeat(vehicle, -1) ~= ped
            or not Config.WaterCannonVehicles[GetEntityModel(vehicle)] then
            return
        end
    end

    -- SmartFiresLite's documented surface is the only fire API used here.
    local fires = exports['SmartFiresLite']:GetAllFires()
    local smokes = exports['SmartFiresLite']:GetAllSmokes()
    local range = kind == 'cannon' and Config.CannonMaxDistance or Config.HoseRange
    local count = applyToRows(source, 'fire', impact, fires, 'StopFireById', range, Config.ExtinguishTime)
    count = count + applyToRows(source, 'smoke', impact, smokes, 'StopSmokeById', range, Config.SmokeClearTime)
    if applyToEntityFire(source, impact, rawCoords.entityNetId, range) then
        count = count + 1
    end
    if count > 0 then
        debug(('%s stopped %s SmartFiresLite targets.'):format(kind, count))
        TriggerClientEvent('smvlpd-firefighter:client:extinguished', source, kind, count)
    end
end)

AddEventHandler('playerDropped', function()
    -- Progress is keyed by target, not player; expiry on the next impact keeps
    -- simultaneous firefighters independent and prevents persistent state.
end)
