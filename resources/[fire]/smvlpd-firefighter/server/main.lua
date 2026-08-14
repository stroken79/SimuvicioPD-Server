local impactProgress = {}

local function debug(message)
    if Config.Debug then
        print(('[smvlpd-firefighter] %s'):format(message))
    end
end

local function isFirefighterOnDuty(source)
    if GetResourceState('night_ers') ~= 'started' then return false end

    local ok1, onShift = pcall(function()
        return exports['night_ers']:getIsPlayerOnShift(source)
    end)
    local ok2, service = pcall(function()
        return exports['night_ers']:getPlayerActiveServiceType(source)
    end)

    return ok1 and ok2 and onShift == true and service == 'fire'
end

local function coordsOf(row)
    if row == nil then return nil end

    if type(row) == 'vector3' then
        return row
    end

    if type(row) ~= 'table' then return nil end

    local candidates = {
        row.coords, row.coordinates, row.Coords,
        row.position, row.Position,
        row.location, row.Location,
        row.pos, row.Pos,
        row.coordinate, row.Coordinate
    }

    for _, c in ipairs(candidates) do
        if type(c) == 'vector3' then return c end
        if type(c) == 'table' then
            local x = tonumber(c.x or c[1])
            local y = tonumber(c.y or c[2])
            local z = tonumber(c.z or c[3])
            if x and y and z then return vector3(x, y, z) end
        end
    end

    local x = tonumber(row.x or row.X or row[1])
    local y = tonumber(row.y or row.Y or row[2])
    local z = tonumber(row.z or row.Z or row[3])
    if x and y and z then return vector3(x, y, z) end

    return nil
end

local function getTargetId(id, row, kind)
    if type(row) == 'table' then
        return row.id or row.fireId or row.smokeId or row.incidentId or id
    end
    return id
end

local function normalizeDirection(direction)
    if type(direction) ~= 'table' then return nil end
    local x = tonumber(direction.x or direction[1])
    local y = tonumber(direction.y or direction[2])
    local z = tonumber(direction.z or direction[3])
    if not x or not y or not z then return nil end

    local v = vector3(x, y, z)
    local len = #v
    if len <= 0.0001 then return nil end
    return v / len
end

-- Distance from a point to the finite water-stream segment.
-- This is the important part for SmartFires smoke: smoke particles have no
-- collision, so a normal GTA raycast cannot hit them.
local function pointToWaterStreamDistance(point, origin, direction, maxDistance)
    local offset = point - origin
    local along = offset.x * direction.x
        + offset.y * direction.y
        + offset.z * direction.z

    along = math.max(0.0, math.min(maxDistance, along))

    local closest = origin + direction * along
    return #(point - closest), along
end

local supportCooldown = {}

local function requestSupport(source, reason)
    local now = GetGameTimer()
    local last = supportCooldown[source] or 0
    if now - last < (Config.SupportNoticeCooldown or 15000) then
        return
    end
    supportCooldown[source] = now
    TriggerClientEvent('smvlpd-firefighter:client:requestSupport', source, reason)
end

local function applyToSmartFires(kind, impact, range, requiredTime, stream)
    local exportName = kind == 'smoke' and 'StopSmokeById' or 'StopFireById'
    local getName = kind == 'smoke' and 'GetAllSmokes' or 'GetAllFires'

    if GetResourceState('SmartFiresLite') ~= 'started' then
        return 0
    end

    local ok, rows = pcall(function()
        return exports['SmartFiresLite'][getName]()
    end)

    if not ok or type(rows) ~= 'table' then
        debug(('SmartFiresLite %s returned no table.'):format(getName))
        return 0
    end

    local now = GetGameTimer()
    local stopped = 0
    local found = 0
    local tolerance = tonumber(Config.SmokeAimTolerance) or 5.0

    for id, row in pairs(rows) do
        local coords = coordsOf(row)

        if coords then
            local distance
            local along

            if stream and stream.origin and stream.direction then
                distance, along = pointToWaterStreamDistance(
                    coords,
                    stream.origin,
                    stream.direction,
                    stream.maxDistance or range
                )

                -- Don't allow a target behind the player or beyond the hose.
                if along < 0.0 or along > (stream.maxDistance or range) then
                    distance = math.huge
                end
            else
                distance = #(coords - impact)
                along = 0.0
            end

            if distance <= (kind == 'smoke' and tolerance or range) then
                found = found + 1

                local targetId = getTargetId(id, row, kind)
                local key = ('%s:%s'):format(kind, tostring(targetId))
                local progress = impactProgress[key]

                if not progress or now - progress.lastImpact > Config.WaterDamageInterval * 2 then
                    progress = { accumulated = 0 }
                    impactProgress[key] = progress
                end

                progress.lastImpact = now
                progress.accumulated = progress.accumulated + Config.WaterDamageInterval

                if progress.accumulated >= requiredTime then
                    local stopOk = pcall(function()
                        exports['SmartFiresLite'][exportName](targetId)
                    end)

                    impactProgress[key] = nil

                    if stopOk then
                        stopped = stopped + 1
                        debug(('%s stopped: %s at %.1fm from stream.'):format(
                            kind, tostring(targetId), distance
                        ))
                    end
                end
            end
        end
    end

    if Config.Debug and kind == 'smoke' then
        debug(('Smoke stream scan: %d target(s) in stream, %d stopped.'):format(found, stopped))
    end

    return stopped
end

RegisterNetEvent('smvlpd-firefighter:server:waterImpact', function(kind, rawCoords)
    local source = source

    if (kind ~= 'hose' and kind ~= 'cannon') or not isFirefighterOnDuty(source) then
        return
    end

    if type(rawCoords) ~= 'table' then return end

    local x, y, z = tonumber(rawCoords.x), tonumber(rawCoords.y), tonumber(rawCoords.z)
    if not x or not y or not z then return end

    local impact = vector3(x, y, z)

    local stream = nil
    if type(rawCoords.origin) == 'table' and type(rawCoords.direction) == 'table' then
        local ox = tonumber(rawCoords.origin.x)
        local oy = tonumber(rawCoords.origin.y)
        local oz = tonumber(rawCoords.origin.z)
        local direction = normalizeDirection(rawCoords.direction)

        if ox and oy and oz and direction then
            stream = {
                origin = vector3(ox, oy, oz),
                direction = direction,
                maxDistance = tonumber(rawCoords.maxDistance) or (
                    kind == 'cannon' and Config.CannonMaxDistance or Config.HoseRange
                )
            }
        end
    end

    if kind == 'cannon' then
        local ped = GetPlayerPed(source)
        local vehicle = ped ~= 0 and GetVehiclePedIsIn(ped, false) or 0

        if vehicle == 0
            or GetPedInVehicleSeat(vehicle, -1) ~= ped
            or not Config.WaterCannonVehicles[GetEntityModel(vehicle)] then
            return
        end
    end

    local range = kind == 'cannon' and Config.CannonMaxDistance or Config.HoseRange

    local fireCount = applyToSmartFires(
        'fire',
        impact,
        range,
        Config.ExtinguishTime,
        stream
    )

    -- ERS smoke objectives are deliberately handled by ERS support units.
    -- If the water stream is aimed at SmartFires smoke, tell the firefighter
    -- to request the appropriate support unit instead of trying to fake the
    -- ERS completion locally.
    local smokeRange = Config.SmokeClearRange or range
    local smokeTargets = 0

    if GetResourceState('SmartFiresLite') == 'started' then
        local ok, rows = pcall(function()
            return exports['SmartFiresLite']:GetAllSmokes()
        end)

        if ok and type(rows) == 'table' then
            local tolerance = tonumber(Config.SmokeAimTolerance) or 5.0

            for id, row in pairs(rows) do
                local coords = coordsOf(row)
                if coords and stream and stream.origin and stream.direction then
                    local distance, along = pointToWaterStreamDistance(
                        coords,
                        stream.origin,
                        stream.direction,
                        stream.maxDistance or smokeRange
                    )

                    if along >= 0.0
                        and along <= (stream.maxDistance or smokeRange)
                        and distance <= tolerance then
                        smokeTargets = smokeTargets + 1
                    end
                elseif coords and #(coords - impact) <= smokeRange then
                    smokeTargets = smokeTargets + 1
                end
            end
        end
    end

    if smokeTargets > 0 then
        requestSupport(
            source,
            'Hay humo en la zona y ERS requiere una unidad de apoyo para despejarlo.'
        )
    end

    if fireCount > 0 then
        TriggerClientEvent(
            'smvlpd-firefighter:client:extinguished',
            source,
            kind,
            fireCount
        )
    end
end)

AddEventHandler('playerDropped', function()
    impactProgress[source] = nil
    supportCooldown[source] = nil
end)
