print("^2[FIVEPD-POLICE] Gestor de avisos cargado correctamente^7")

PoliceCallouts = PoliceCallouts or {}

local AUTO_MIN_MS = 5 * 60 * 1000
local AUTO_MAX_MS = 9 * 60 * 1000
local REQUIRE_DUTY = true
local ACCEPT_KEY = 246 -- Y
local FINISH_KEY = 38 -- E
local ACCEPT_TIMEOUT_MS = 3 * 60 * 1000

if Config and Config.Callouts then
    AUTO_MIN_MS = (Config.Callouts.AutoMinMinutes or 5) * 60 * 1000
    AUTO_MAX_MS = (Config.Callouts.AutoMaxMinutes or 9) * 60 * 1000
    REQUIRE_DUTY = Config.Callouts.RequireDuty ~= false
end

if AUTO_MAX_MS < AUTO_MIN_MS then
    AUTO_MIN_MS, AUTO_MAX_MS = AUTO_MAX_MS, AUTO_MIN_MS
end

local registered = {}
local onDuty = false
local active = false
local accepted = false
local spawned = false
local located = false
local finishing = false
local calloutToken = 0

local current = nil
local coords = nil
local heading = 0.0
local context = nil
local routeBlip = nil
local entityBlips = {}
local entities = {}
local suspects = {}
local suspectNetIds = {}
local suspectProgress = {}
local fires = {}
local supportRequestId = nil
local supportActive = false
local supportOffer = nil
local supportRouteBlip = nil
local supportSuspectNetIds = {}

local function Notify(message)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    DrawNotification(false, false)
end

local function Help(message)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

local function RemoveBlips()
    if routeBlip and DoesBlipExist(routeBlip) then
        RemoveBlip(routeBlip)
    end

    for _, blip in ipairs(entityBlips) do
        if blip and DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end

    routeBlip = nil
    entityBlips = {}
end

local function RemoveSupportBlip()
    if supportRouteBlip and DoesBlipExist(supportRouteBlip) then
        RemoveBlip(supportRouteBlip)
    end

    supportRouteBlip = nil
end

local function StopFires()
    for _, fire in ipairs(fires) do
        if fire then
            RemoveScriptFire(fire)
        end
    end

    fires = {}
end

local function DeleteTrackedEntities()
    for _, entity in ipairs(entities) do
        if entity and DoesEntityExist(entity) then
            SetEntityAsMissionEntity(entity, true, true)

            if IsEntityAPed(entity) then
                DeletePed(entity)
            elseif IsEntityAVehicle(entity) then
                DeleteVehicle(entity)
            else
                DeleteObject(entity)
            end
        end
    end
end

local function Reset(deleteEntities)
    RemoveBlips()
    StopFires()

    if current and current.cleanup then
        current.cleanup(context or {}, deleteEntities == true)
    end

    if deleteEntities then
        DeleteTrackedEntities()
    end

    active = false
    accepted = false
    spawned = false
    located = false
    finishing = false
    current = nil
    coords = nil
    heading = 0.0
    context = nil
    entities = {}
    suspects = {}
    suspectNetIds = {}
    suspectProgress = {}
    supportRequestId = nil
    TriggerEvent("pd5m:hud:SetPoliceCalloutState", false)
end

local function IsCalloutSuspect(netId)
    for _, suspectNetId in ipairs(suspectNetIds) do
        if suspectNetId == netId then
            return true
        end
    end

    return false
end

local function GetSuspectProgress(netId)
    suspectProgress[netId] = suspectProgress[netId] or {
        id = false,
        licence = false,
        searched = false,
        test = false,
        weaponsKnown = false,
        weaponsCleared = true
    }

    return suspectProgress[netId]
end

local function GetMissingRequirements(netId)
    local progress = GetSuspectProgress(netId)
    local missing = {}

    if not progress.id then
        missing[#missing + 1] = "pedir DNI"
    end

    if not progress.licence then
        missing[#missing + 1] = "pedir licencia"
    end

    if not progress.searched then
        missing[#missing + 1] = "cachear"
    end

    if not progress.test then
        missing[#missing + 1] = "hacer prueba de alcohol o drogas"
    end

    if progress.weaponsKnown and not progress.weaponsCleared then
        missing[#missing + 1] = "retirar armas"
    end

    return missing
end

local function Finish(message)
    if not active or finishing then
        return
    end

    finishing = true
    Notify("~b~CENTRAL: ~g~Aviso finalizado.~n~~w~" .. message)
    TriggerServerEvent('smvlpd-ranks:server:calloutCompleted')

    if supportRequestId then
        TriggerServerEvent("fivepd-police:supportFinish", supportRequestId, message)
    end

    Reset(true)
    print("^2[FIVEPD-POLICE] Aviso finalizado: " .. message .. "^7")
end

local function BuildRuntime()
    return {
        coords = coords,
        heading = heading,
        context = context,
        notify = Notify,
        finish = Finish,
        trackEntity = function(entity)
            entities[#entities + 1] = entity
            return entity
        end,
        addBlip = function(entity, sprite, colour, name)
            local blip = AddBlipForEntity(entity)
            SetBlipSprite(blip, sprite)
            SetBlipColour(blip, colour)
            SetBlipScale(blip, 0.85)

            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(name)
            EndTextCommandSetBlipName(blip)

            entityBlips[#entityBlips + 1] = blip
            return blip
        end,
        addSuspect = function(ped)
            suspects[#suspects + 1] = ped

            local netId = PedToNet(ped)
            suspectNetIds[#suspectNetIds + 1] = netId
            GetSuspectProgress(netId)

            TriggerEvent("pd5m:bridge:RegisterCalloutSuspect", netId)

            if supportRequestId then
                TriggerServerEvent("fivepd-police:supportUpdateSuspects", supportRequestId, suspectNetIds)
            end

            return netId
        end,
        addFire = function(fire)
            fires[#fires + 1] = fire
            return fire
        end
    }
end

function PoliceCallouts.Register(definitions)
    for _, definition in ipairs(definitions) do
        registered[#registered + 1] = definition
        print("^3[FIVEPD-POLICE] Aviso registrado: " .. definition.title .. "^7")
    end
end

local function StartRandomCallout(forced)
    if active then
        if forced then
            Notify("~y~Ya tienes un aviso activo. Usa /cancelcallout para cancelarlo.")
        end
        return false
    end

    if supportActive then
        if forced then
            Notify("~y~Ya estas unido como apoyo a otro aviso.")
        end
        return false
    end

    if REQUIRE_DUTY and not onDuty then
        if forced then
            Notify("~r~Debes estar de servicio para recibir avisos.")
        end
        return false
    end

    if #registered == 0 then
        if forced then
            Notify("~r~No hay avisos registrados.")
        end
        return false
    end

    current = registered[math.random(1, #registered)]
    coords, heading, context = current.prepare()
    context = context or {}

    active = true
    accepted = false
    spawned = false
    located = false
    finishing = false
    calloutToken = calloutToken + 1
    TriggerEvent("pd5m:hud:SetPoliceCalloutState", true)

    local thisCalloutToken = calloutToken

    Notify(current.dispatch .. "~n~~y~Pulsa Y para aceptar el aviso.")
    print("^3[FIVEPD-POLICE] Aviso generado: " .. current.title .. "^7")

    CreateThread(function()
        Wait(ACCEPT_TIMEOUT_MS)

        if active and not accepted and calloutToken == thisCalloutToken then
            Notify("~b~CENTRAL: ~y~Aviso cancelado.~n~~w~No fue aceptado a tiempo.")
            Reset(true)
            print("^3[FIVEPD-POLICE] Aviso cancelado por no aceptarse en 3 minutos.^7")
        end
    end)

    return true
end

RegisterNetEvent("pd5m:setDuty")
AddEventHandler("pd5m:setDuty", function(isOnDuty)
    onDuty = isOnDuty == true

    if not onDuty and active then
        Notify("~b~CENTRAL: ~w~Aviso cancelado al salir de servicio.")
        Reset(true)
    end

    if not onDuty and supportActive then
        RemoveSupportBlip()
        supportActive = false
        supportRequestId = nil
        supportSuspectNetIds = {}
        supportOffer = nil
        TriggerEvent("pd5m:hud:SetPoliceCalloutState", false)
        Notify("~b~CENTRAL: ~w~Apoyo cancelado al salir de servicio.")
    end
end)

RegisterCommand("callout", function()
    StartRandomCallout(true)
end, false)

RegisterCommand("cancelcallout", function()
    if not active then
        if supportActive then
            RemoveSupportBlip()
            supportActive = false
            supportRequestId = nil
            supportSuspectNetIds = {}
            supportOffer = nil
            TriggerEvent("pd5m:hud:SetPoliceCalloutState", false)
            Notify("~b~CENTRAL: ~w~Has abandonado el apoyo.")
            return
        end

        Notify("~y~No hay ningun aviso activo.")
        return
    end

    Notify("~b~CENTRAL: ~w~Aviso cancelado.")
    Reset(true)
end, false)

RegisterCommand("apoyo", function()
    if not active or not accepted or not current or not coords then
        Notify("~y~Debes tener un aviso aceptado para solicitar apoyo.")
        return
    end

    local data = {
        title = current.title,
        blipName = current.blipName or current.title,
        coords = {
            x = coords.x,
            y = coords.y,
            z = coords.z
        },
        suspects = suspectNetIds
    }

    TriggerServerEvent("fivepd-police:supportRequest", data)
end, false)

RegisterCommand("unirseapoyo", function()
    if not supportOffer then
        Notify("~y~No hay solicitudes de apoyo disponibles.")
        return
    end

    if active then
        Notify("~y~No puedes unirte a un apoyo con otro aviso activo.")
        return
    end

    TriggerServerEvent("fivepd-police:supportJoin", supportOffer.id)
end, false)

RegisterNetEvent("fivepd-police:supportNotify")
AddEventHandler("fivepd-police:supportNotify", function(message)
    Notify(message)
end)

RegisterNetEvent("fivepd-police:supportOffer")
AddEventHandler("fivepd-police:supportOffer", function(request, owner)
    if GetPlayerServerId(PlayerId()) == owner then
        supportRequestId = request.id
        return
    end

    if REQUIRE_DUTY and not onDuty then
        return
    end

    supportOffer = request
    Notify("~b~CENTRAL: ~y~Unidad solicita apoyo.~n~~w~" .. request.title .. "~n~~y~Usa /unirseapoyo para acudir.")
end)

RegisterNetEvent("fivepd-police:supportJoined")
AddEventHandler("fivepd-police:supportJoined", function(request)
    supportActive = true
    supportRequestId = request.id
    supportSuspectNetIds = request.suspects or {}
    supportOffer = nil
    TriggerEvent("pd5m:hud:SetPoliceCalloutState", true)

    RemoveSupportBlip()

    supportRouteBlip = AddBlipForCoord(request.coords.x, request.coords.y, request.coords.z)
    SetBlipSprite(supportRouteBlip, 161)
    SetBlipColour(supportRouteBlip, 3)
    SetBlipScale(supportRouteBlip, 1.0)
    SetBlipRoute(supportRouteBlip, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(request.blipName or request.title or "Apoyo policial")
    EndTextCommandSetBlipName(supportRouteBlip)

    SetNewWaypoint(request.coords.x, request.coords.y)
    Notify("~b~CENTRAL: ~g~Te has unido como apoyo.~n~~w~Dirigete al aviso.")
end)

RegisterNetEvent("fivepd-police:supportSuspectsUpdated")
AddEventHandler("fivepd-police:supportSuspectsUpdated", function(requestId, suspects)
    if supportActive and supportRequestId == requestId then
        supportSuspectNetIds = suspects or {}
    end
end)

RegisterNetEvent("fivepd-police:supportFinished")
AddEventHandler("fivepd-police:supportFinished", function(requestId, message)
    if supportRequestId ~= requestId then
        return
    end

    RemoveSupportBlip()

    if supportActive then
        Notify("~b~CENTRAL: ~g~Aviso finalizado.~n~~w~" .. (message or "Apoyo terminado."))
    end

    supportActive = false
    supportRequestId = nil
    supportSuspectNetIds = {}
    supportOffer = nil
    TriggerEvent("pd5m:hud:SetPoliceCalloutState", false)
end)

CreateThread(function()
    math.randomseed(GetGameTimer())

    while true do
        if (not REQUIRE_DUTY or onDuty) and not active and not supportActive then
            Wait(math.random(AUTO_MIN_MS, AUTO_MAX_MS))

            if (not REQUIRE_DUTY or onDuty) and not active and not supportActive then
                StartRandomCallout(false)
            end
        else
            Wait(1000)
        end
    end
end)

CreateThread(function()
    while true do
        Wait(0)

        if active and not accepted and IsControlJustReleased(0, ACCEPT_KEY) then
            accepted = true
            TriggerServerEvent('smvlpd-ranks:server:calloutStarted', current.title)

            Notify(current.accept)

            routeBlip = AddBlipForCoord(coords.x, coords.y, coords.z)
            SetBlipSprite(routeBlip, current.blipSprite or 161)
            SetBlipColour(routeBlip, current.blipColour or 1)
            SetBlipScale(routeBlip, 1.0)
            SetBlipRoute(routeBlip, true)

            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(current.blipName or current.title)
            EndTextCommandSetBlipName(routeBlip)

            SetNewWaypoint(coords.x, coords.y)
            print("^2[FIVEPD-POLICE] Aviso aceptado: " .. current.title .. "^7")
        end
    end
end)

CreateThread(function()
    while true do
        Wait(500)

        if active and accepted and not spawned and coords then
            if #(GetEntityCoords(PlayerPedId()) - coords) < (current.spawnRadius or 140.0) then
                spawned = true
                current.spawn(BuildRuntime())
                Notify(current.arrival)
                print("^2[FIVEPD-POLICE] Escena creada: " .. current.title .. "^7")
            end
        end

        if active and spawned and not located and coords then
            if #(GetEntityCoords(PlayerPedId()) - coords) < 35.0 then
                located = true

                if routeBlip and DoesBlipExist(routeBlip) then
                    SetBlipRoute(routeBlip, false)
                    RemoveBlip(routeBlip)
                    routeBlip = nil
                end
            end
        end
    end
end)

RegisterNetEvent("fivepd-police:suspectImprisoned")
AddEventHandler("fivepd-police:suspectImprisoned", function(imprisonedNetId)
    if supportActive and supportRequestId then
        for _, netId in ipairs(supportSuspectNetIds) do
            if netId == imprisonedNetId then
                TriggerServerEvent("fivepd-police:supportFinish", supportRequestId, "Sospechoso detenido y procesado.")
                return
            end
        end
    end

    if not active or not spawned then
        return
    end

    for _, netId in ipairs(suspectNetIds) do
        if netId == imprisonedNetId then
            Finish("Sospechoso detenido y procesado.")
            return
        end
    end
end)

RegisterNetEvent("fivepd-police:suspectReleased")
AddEventHandler("fivepd-police:suspectReleased", function(releasedNetId)
    if supportActive and supportRequestId then
        for _, netId in ipairs(supportSuspectNetIds) do
            if netId == releasedNetId then
                Notify("~b~CENTRAL: ~y~El apoyo no puede cerrar el aviso liberando al sospechoso.")
                return
            end
        end
    end

    if not active or not spawned then
        return
    end

    for _, netId in ipairs(suspectNetIds) do
        if netId == releasedNetId then
            local missing = GetMissingRequirements(releasedNetId)

            if #missing > 0 then
                Notify("~b~CENTRAL: ~y~Aviso no finalizado.~n~~w~Falta: " .. table.concat(missing, ", ") .. ".")
                return
            end

            Finish("Sospechoso identificado y liberado.")
            return
        end
    end
end)

RegisterNetEvent("fivepd-police:suspectAction")
AddEventHandler("fivepd-police:suspectAction", function(netId, action, data)
    if not active or not spawned or not IsCalloutSuspect(netId) then
        return
    end

    local progress = GetSuspectProgress(netId)

    if action == "id" then
        progress.id = true
    elseif action == "licence" then
        progress.licence = true
    elseif action == "searched" then
        progress.searched = true

        if data and data.hasWeapons then
            progress.weaponsKnown = true
            progress.weaponsCleared = false
        end
    elseif action == "test" then
        progress.test = true
    elseif action == "weaponsCleared" then
        progress.weaponsKnown = true
        progress.weaponsCleared = true
    end
end)
