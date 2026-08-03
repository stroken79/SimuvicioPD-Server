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
                TriggerEvent('smvlpd:duty:onDuty')

            elseif not onDuty and wasOnDuty then
                wasOnDuty = false
                TriggerEvent('smvlpd:duty:offDuty')
            end

        end
    end
end)