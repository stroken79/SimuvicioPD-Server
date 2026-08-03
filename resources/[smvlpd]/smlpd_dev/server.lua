RegisterCommand("spawnpd", function(source, args)
    TriggerClientEvent("smvlpd_dev:spawnVehicle", source, args[1])
end, false)