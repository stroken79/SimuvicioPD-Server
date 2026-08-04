local DutyPlayers = {}

RegisterNetEvent("smvlpd-ems:server:setDuty", function(state)
    local src = source

    DutyPlayers[src] = state
end)

AddEventHandler("playerDropped", function()
    DutyPlayers[source] = nil
end)

lib.callback.register("smvlpd-ems:server:isOnDuty", function(source)
    return DutyPlayers[source] or false
end)

exports("IsPlayerOnDuty", function(source)
    return DutyPlayers[source] or false
end)