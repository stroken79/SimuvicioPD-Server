local function getAllowedVehicles(source)
    return exports['smvlpd-ranks']:GetAllowedVehicles(source) or {}
end

lib.callback.register('smvlpd-garage:server:getVehicles', function(source)
    local models = getAllowedVehicles(source)
    local vehicles = {}

    for _, entry in ipairs(models) do
        local model = type(entry) == 'table' and entry.model or entry
        vehicles[#vehicles + 1] = {
            model = model,
            label = type(entry) == 'table' and entry.label or Config.VehicleLabels[model] or model,
            livery = type(entry) == 'table' and entry.livery or nil
        }
    end

    return vehicles
end)

RegisterNetEvent('smvlpd-garage:server:spawnVehicle', function(model, garageId)
    local src = source
    local authorised = false

    local selectedVehicle
    for _, entry in ipairs(getAllowedVehicles(src)) do
        local allowedModel = type(entry) == 'table' and entry.model or entry
        if allowedModel == model then
            authorised = true
            selectedVehicle = entry
            break
        end
    end

    if not authorised then
        print(('[smvlpd-garage] %s intentó sacar %s sin permiso.'):format(src, model))
        return
    end

    local livery = type(selectedVehicle) == 'table' and selectedVehicle.livery or nil
    TriggerClientEvent('smvlpd-garage:client:spawnVehicle', src, model, garageId, livery)
end)
