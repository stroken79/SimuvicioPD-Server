local wasOnDuty = false

CreateThread(function()
    while true do
        Wait(1000)

        local success, onDuty = pcall(function()
            return exports['night_ers']:getIsPlayerOnShift()
        end)

        if success then

            if onDuty and not wasOnDuty then

    wasOnDuty = true

    local service = exports['night_ers']:getPlayerActiveServiceType()

    if service == "police" then
        TriggerEvent('smvlpd:duty:onDuty')
    end

            elseif not onDuty and wasOnDuty then
                wasOnDuty = false
                TriggerEvent('smvlpd:duty:offDuty')
            end

        end
    end
end)