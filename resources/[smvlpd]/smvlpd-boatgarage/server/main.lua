AddEventHandler('onResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    for _, dependency in ipairs({ 'ox_lib', 'night_ers', 'smvlpd-ranks' }) do
        if GetResourceState(dependency) ~= 'started' then
            print(('[smvlpd-boatgarage] Dependencia no iniciada: %s'):format(dependency))
        end
    end
end)
