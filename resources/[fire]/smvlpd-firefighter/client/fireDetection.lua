local localEntityProgress = {}

local function getCameraRay(distance)
    local rot = GetGameplayCamRot(2)
    local pitch = math.rad(rot.x)
    local yaw = math.rad(rot.z)

    local direction = vector3(
        -math.sin(yaw) * math.abs(math.cos(pitch)),
        math.cos(yaw) * math.abs(math.cos(pitch)),
        math.sin(pitch)
    )

    local origin = GetGameplayCamCoord()
    local target = origin + direction * distance

    local ray = StartShapeTestRay(
        origin.x, origin.y, origin.z,
        target.x, target.y, target.z,
        -1, PlayerPedId(), 7
    )

    local _, hit, hitCoords, _, entity = GetShapeTestResult(ray)

    return origin, direction, (hit == 1 and hitCoords or target), entity
end

local function getSafeNetworkId(entity)
    if not entity or entity == 0 or not DoesEntityExist(entity) then
        return nil
    end

    if not NetworkGetEntityIsNetworked(entity) then
        return nil
    end

    local netId = NetworkGetNetworkIdFromEntity(entity)
    return netId and netId > 0 and netId or nil
end

local function processLocalEntityFire(entity)
    if not entity or entity == 0 or not DoesEntityExist(entity) then return end
    if not IsEntityOnFire(entity) then return end

    local now = GetGameTimer()
    local state = localEntityProgress[entity]

    if not state or now - state.lastImpact > Config.WaterDamageInterval * 2 then
        state = { accumulated = 0 }
        localEntityProgress[entity] = state
    end

    state.lastImpact = now
    state.accumulated = state.accumulated + Config.WaterDamageInterval

    if state.accumulated >= Config.ExtinguishTime then
        StopEntityFire(entity)
        localEntityProgress[entity] = nil
        FirefighterDebug(('Local native fire extinguished on entity %s.'):format(entity))
    end
end

function ReportWaterImpact(kind, distance)
    local origin, direction, hitCoords, entity = getCameraRay(distance)
    local entityNetId = getSafeNetworkId(entity)

    if entity and entity ~= 0 and DoesEntityExist(entity) and IsEntityOnFire(entity) then
        if IsEntityAPed(entity) then
            -- ERS can resolve burning people through its support-unit system.
            -- Do not fight that native fire locally; ask the player to request
            -- the support unit from the ERS menu.
            TriggerEvent(
                'smvlpd-firefighter:client:requestSupport',
                'Una persona está en llamas. Solicita una unidad de apoyo desde el menú ERS.'
            )
        else
            processLocalEntityFire(entity)
        end
    end

    TriggerServerEvent('smvlpd-firefighter:server:waterImpact', kind, {
        x = hitCoords.x,
        y = hitCoords.y,
        z = hitCoords.z,
        entityNetId = entityNetId,

        -- The smoke particle has no collision, so its raycast never returns
        -- the smoke position. Send the actual camera ray to the server so it
        -- can find SmartFires smoke lying along the water stream.
        origin = {
            x = origin.x,
            y = origin.y,
            z = origin.z
        },
        direction = {
            x = direction.x,
            y = direction.y,
            z = direction.z
        },
        maxDistance = distance
    })
end

CreateThread(function()
    while true do
        if IsFireHoseEquipped() and IsControlPressed(0, 24) then
            ReportWaterImpact('hose', Config.HoseRange)
            Wait(Config.WaterDamageInterval)
        else
            Wait(100)
        end
    end
end)

CreateThread(function()
    while true do
        Wait(1000)

        for entity, state in pairs(localEntityProgress) do
            if not DoesEntityExist(entity) or not IsEntityOnFire(entity) then
                localEntityProgress[entity] = nil
            elseif GetGameTimer() - state.lastImpact > Config.WaterDamageInterval * 2 then
                localEntityProgress[entity] = nil
            end
        end
    end
end)
