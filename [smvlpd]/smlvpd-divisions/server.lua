RegisterNetEvent("smvlpd-divisions:server:setDivision", function(division)
    local src = source

    Player(src).state.serviceDivision = division
end)

RegisterNetEvent("smvlpd-divisions:server:clearDivision", function()
    local src = source

    Player(src).state.serviceDivision = nil
end)