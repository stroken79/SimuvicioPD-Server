local supportRequests = {}
local nextSupportId = 0

local function Notify(target, message)
    TriggerClientEvent("fivepd-police:supportNotify", target, message)
end

RegisterNetEvent("fivepd-police:supportRequest")
AddEventHandler("fivepd-police:supportRequest", function(data)
    local sourcePlayer = source

    if type(data) ~= "table" or type(data.coords) ~= "table" then
        return
    end

    nextSupportId = nextSupportId + 1

    local request = {
        id = nextSupportId,
        owner = sourcePlayer,
        title = data.title or "Aviso policial",
        blipName = data.blipName or data.title or "Aviso policial",
        coords = {
            x = data.coords.x,
            y = data.coords.y,
            z = data.coords.z
        },
        suspects = data.suspects or {},
        joined = {}
    }

    supportRequests[request.id] = request
    TriggerClientEvent("fivepd-police:supportOffer", -1, request, sourcePlayer)
    Notify(sourcePlayer, "~b~CENTRAL: ~g~Solicitud de apoyo enviada.")
end)

RegisterNetEvent("fivepd-police:supportJoin")
AddEventHandler("fivepd-police:supportJoin", function(requestId)
    local sourcePlayer = source
    local request = supportRequests[requestId]

    if not request then
        Notify(sourcePlayer, "~y~Esa solicitud de apoyo ya no esta disponible.")
        return
    end

    if sourcePlayer == request.owner then
        Notify(sourcePlayer, "~y~Ya eres la unidad principal de este aviso.")
        return
    end

    request.joined[sourcePlayer] = true
    TriggerClientEvent("fivepd-police:supportJoined", sourcePlayer, request)
    Notify(request.owner, "~b~CENTRAL: ~w~Una unidad se ha unido al aviso.")
end)

RegisterNetEvent("fivepd-police:supportUpdateSuspects")
AddEventHandler("fivepd-police:supportUpdateSuspects", function(requestId, suspects)
    local request = supportRequests[requestId]

    if request and request.owner == source and type(suspects) == "table" then
        request.suspects = suspects

        for playerId in pairs(request.joined) do
            TriggerClientEvent("fivepd-police:supportSuspectsUpdated", playerId, requestId, suspects)
        end
    end
end)

RegisterNetEvent("fivepd-police:supportFinish")
AddEventHandler("fivepd-police:supportFinish", function(requestId, message)
    local request = supportRequests[requestId]

    if not request then
        return
    end

    if source ~= request.owner and not request.joined[source] then
        return
    end

    TriggerClientEvent("fivepd-police:supportFinished", request.owner, requestId, message or "Aviso finalizado.")

    for playerId in pairs(request.joined) do
        TriggerClientEvent("fivepd-police:supportFinished", playerId, requestId, message or "Aviso finalizado.")
    end

    supportRequests[requestId] = nil
end)

AddEventHandler("playerDropped", function()
    local sourcePlayer = source

    for requestId, request in pairs(supportRequests) do
        request.joined[sourcePlayer] = nil

        if request.owner == sourcePlayer then
            for playerId in pairs(request.joined) do
                TriggerClientEvent("fivepd-police:supportFinished", playerId, requestId, "La unidad principal se ha desconectado.")
            end

            supportRequests[requestId] = nil
        end
    end
end)
