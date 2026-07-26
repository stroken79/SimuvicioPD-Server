lib.callback.register('smvlpd-garage:server:getVehicles', function(source)

    local models = exports['smvlpd-ranks']:GetAllowedVehicles(source)

    local vehicles = {}

    if not models then
        return vehicles
    end

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

    local allowed = exports['smvlpd-ranks']:GetAllowedVehicles(src)

    local authorised = false

    for _, vehicle in ipairs(allowed) do
        if vehicle == model then
            authorised = true
            break
        end
    end

    if not authorised then
        print(('[smvlpd-garage] %s intentó sacar %s sin permiso.'):format(src, model))
        return
    end

    TriggerClientEvent(
        'smvlpd-garage:client:spawnVehicle',
        src,
        model,
        garageId
    )

end)