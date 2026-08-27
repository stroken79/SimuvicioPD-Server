local txAdmins = {}

AddEventHandler("txAdmin:events:adminAuth", function(eventData)
    if type(eventData) ~= "table" then return end

    local netid = tonumber(eventData.netid)
    if not netid then return end

    if eventData.isAdmin == true then
        txAdmins[netid] = true
    else
        txAdmins[netid] = nil
    end
end)

AddEventHandler("playerDropped", function()
    txAdmins[source] = nil
end)

RegisterCommand("adminuniform", function(source)
    if source == 0 then
        print("^1[smvlpd-admin-clothing]^7 Este comando solo puede usarse dentro del servidor.")
        return
    end

    if not txAdmins[source] then
        TriggerClientEvent(
            "smvlpd-admin-clothing:notify",
            source,
            "~r~No tienes permisos de administrador de txAdmin."
        )
        return
    end

    TriggerClientEvent("smvlpd-admin-clothing:toggle", source)
end, false)
