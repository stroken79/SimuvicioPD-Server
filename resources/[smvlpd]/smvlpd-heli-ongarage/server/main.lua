AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    for _, dependency in ipairs({ 'ox_lib', 'night_ers', 'smvlpd-ranks' }) do
        if GetResourceState(dependency) ~= 'started' then
            print(('[smvlpd-heli-ongarage] Dependencia no iniciada: %s'):format(dependency))
        end
    end

    print('[smvlpd-heli-ongarage] Recurso iniciado. Configura helipuertos y helicópteros en config.lua.')
end)
