local function getAllowedVehicles(source)
    return exports['smvlpd-ranks']:GetAllowedVehicles(source) or {}
end

lib.callback.register('smvlpd-garage:server:getVehicles', function(source)
    local models = getAllowedVehicles(source)
    local vehicles = {}

    for _, model in ipairs(models) do
        vehicles[#vehicles + 1] = {
            model = model,
            label = model
        }
    end

    return vehicles
end)

RegisterNetEvent('smvlpd-garage:server:spawnVehicle', function(model, garageId)
    local src = source
    local authorised = false

    for _, vehicle in ipairs(getAllowedVehicles(src)) do
        if vehicle == model then
            authorised = true
            break
        end
    end

    if not authorised then
        print(('[smvlpd-garage] %s intentó sacar %s sin permiso.'):format(src, model))
        return
    end

    TriggerClientEvent('smvlpd-garage:client:spawnVehicle', src, model, garageId)
end)
