-- SMVLPD / PD5M - Aviso: Cadáver encontrado
-- Adaptado del callout FivePD "Dead Body"
-- Flujo: /deadbody -> Y -> acudir -> localizar cadáver -> X > FORENSE para finalizar

local active = false
local accepted = false
local spawned = false
local located = false

local victim = nil
local calloutBlip = nil
local victimBlip = nil
local location = nil

-- Ubicaciones del callout original
local locations = {
    vector3(-1567.34, 749.92, 192.58),
    vector3(-1573.06, 771.45, 189.19),
    vector3(-1462.25, 179.30, 54.77),
    vector3(-27.44, -1307.06, 29.56),
    vector3(-570.42, -1676.99, 19.62),
    vector3(379.06, -1830.08, 28.67),
    vector3(124.96, -1185.44, 29.50),
    vector3(-97.25, -1001.56, 21.28),
    vector3(266.03, -2430.39, 8.04),
    vector3(-1464.79, -1092.01, 0.29)
}

local pedModels = {
    "a_m_m_business_01",
    "a_m_m_skidrow_01",
    "a_m_m_hillbilly_01",
    "a_m_y_business_02",
    "a_m_y_stwhi_01",
    "a_f_m_bevhills_01",
    "a_f_y_business_01",
    "a_f_y_tourist_01",
    "a_f_y_hipster_01"
}

local function Notify(text)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(text)
    DrawNotification(false, false)
end

local function Cleanup()
    if calloutBlip and DoesBlipExist(calloutBlip) then
        RemoveBlip(calloutBlip)
    end

    if victimBlip and DoesBlipExist(victimBlip) then
        RemoveBlip(victimBlip)
    end

    if victim and DoesEntityExist(victim) then
        SetEntityAsMissionEntity(victim, true, true)
        DeletePed(victim)
    end

    active = false
    accepted = false
    spawned = false
    located = false

    victim = nil
    calloutBlip = nil
    victimBlip = nil
    location = nil
end

RegisterCommand("deadbody", function()
    if active then
        Notify("~y~Ya hay un aviso de cadáver encontrado activo.")
        return
    end

    location = locations[math.random(1, #locations)]

    active = true
    accepted = false
    spawned = false
    located = false

    Notify(
        "~b~CENTRAL: ~w~Se ha recibido un aviso por una persona aparentemente fallecida.~n~" ..
        "~y~Pulsa Y para aceptar el aviso."
    )

    print("^3[DEAD BODY] Aviso generado.^7")
end, false)

-- Aceptar con Y
CreateThread(function()
    while true do
        Wait(0)

        if active and not accepted and IsControlJustReleased(0, 246) then
            accepted = true

            calloutBlip = AddBlipForCoord(
                location.x,
                location.y,
                location.z
            )

            SetBlipSprite(calloutBlip, 280)
            SetBlipColour(calloutBlip, 3)
            SetBlipScale(calloutBlip, 1.0)
            SetBlipRoute(calloutBlip, true)

            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Persona fallecida")
            EndTextCommandSetBlipName(calloutBlip)

            SetNewWaypoint(location.x, location.y)

            Notify(
                "~g~Aviso aceptado.~n~" ..
                "~w~Dirígete al lugar indicado y comprueba la situación."
            )
        end
    end
end)

-- Crear cadáver al aproximarse
CreateThread(function()
    while true do
        Wait(500)

        if active
        and accepted
        and not spawned
        and location
        and #(GetEntityCoords(PlayerPedId()) - location) < 120.0 then

            spawned = true

            local modelName = pedModels[math.random(1, #pedModels)]
            local model = joaat(modelName)

            RequestModel(model)

            while not HasModelLoaded(model) do
                Wait(50)
            end

            victim = CreatePed(
                4,
                model,
                location.x,
                location.y,
                location.z,
                math.random(0, 359) + 0.0,
                true,
                true
            )

            SetEntityAsMissionEntity(victim, true, true)
            SetEntityHealth(victim, 0)

            victimBlip = AddBlipForEntity(victim)
            SetBlipSprite(victimBlip, 280)
            SetBlipColour(victimBlip, 3)
            SetBlipScale(victimBlip, 0.8)

            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Víctima")
            EndTextCommandSetBlipName(victimBlip)

            SetModelAsNoLongerNeeded(model)

            print("^2[DEAD BODY] Cadáver creado: " .. modelName .. "^7")
        end
    end
end)

-- Llegada a la escena
CreateThread(function()
    while true do
        Wait(500)

        if active
        and spawned
        and not located
        and victim
        and DoesEntityExist(victim) then

            local distance =
                #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(victim))

            if distance < 35.0 then
                located = true

                if calloutBlip and DoesBlipExist(calloutBlip) then
                    SetBlipRoute(calloutBlip, false)
                    RemoveBlip(calloutBlip)
                    calloutBlip = nil
                end

                Notify(
                    "~b~CENTRAL: ~w~Persona localizada.~n~" ..
                    "~y~Asegura la escena y comprueba el estado de la víctima.~n~" ..
                    "~w~Usa el menú X y selecciona FORENSE para solicitar la retirada."
                )
            end
        end
    end
end)

-- Finalización automática al retirar el cadáver con el forense de PD5M.
-- No modifica ni intercepta el menú X.
CreateThread(function()
    while true do
        Wait(500)

        if active and located and spawned then
            if victim == nil or not DoesEntityExist(victim) then
                if calloutBlip and DoesBlipExist(calloutBlip) then RemoveBlip(calloutBlip) end
                if victimBlip and DoesBlipExist(victimBlip) then RemoveBlip(victimBlip) end

                calloutBlip = nil
                victimBlip = nil

                Notify(
                    "~b~CENTRAL: ~g~Aviso finalizado.~n~" ..
                    "~w~Servicios forenses se han hecho cargo del cuerpo."
                )

                active = false
                accepted = false
                spawned = false
                located = false
                location = nil
                victim = nil

                print("^2[DEAD BODY] Aviso finalizado tras retirada del cadáver por forense.^7")
            end
        end
    end
end)

RegisterCommand("canceldeadbody", function()
    if active then
        Notify("~b~CENTRAL: ~w~Aviso de cadáver encontrado cancelado.")
        Cleanup()
    end
end, false)

print("^2[DEAD BODY] Archivo cargado correctamente.^7")