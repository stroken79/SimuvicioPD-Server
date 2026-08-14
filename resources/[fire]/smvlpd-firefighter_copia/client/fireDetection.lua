local function raycastFromGameplayCamera(distance)
    local rot = GetGameplayCamRot(2)
    local pitch, yaw = math.rad(rot.x), math.rad(rot.z)
    local direction = vector3(-math.sin(yaw) * math.abs(math.cos(pitch)), math.cos(yaw) * math.abs(math.cos(pitch)), math.sin(pitch))
    local start = GetGameplayCamCoord()
    local target = start + direction * distance
    local ray = StartShapeTestRay(start.x, start.y, start.z, target.x, target.y, target.z, -1, PlayerPedId(), 7)
    local _, hit, coords, _, entity = GetShapeTestResult(ray)
    return hit == 1 and coords or target, entity
end

function ReportWaterImpact(kind, distance)
    local coords, entity = raycastFromGameplayCamera(distance)
    local entityNetId = entity and entity ~= 0 and NetworkGetNetworkIdFromEntity(entity) or nil
    TriggerServerEvent('smvlpd-firefighter:server:waterImpact', kind, {
        x = coords.x,
        y = coords.y,
        z = coords.z,
        entityNetId = entityNetId
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
