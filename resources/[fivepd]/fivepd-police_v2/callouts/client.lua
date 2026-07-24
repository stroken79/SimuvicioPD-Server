local calloutActive = false
local calloutAccepted = false
local calloutBlip = nil
local calloutCoords = vector3(215.76, -810.12, 30.73)
local calloutOnDuty = false
local sceneSpawned = false
local suspectPed = nil
local victimPed = nil


RegisterNetEvent('pd5m:setDuty')
AddEventHandler('pd5m:setDuty', function(onDuty)
    calloutOnDuty = onDuty

    if onDuty then
        print("^2[fivepd-police/callouts] Servicio ACTIVADO^7")
    else
        print("^1[fivepd-police/callouts] Servicio DESACTIVADO^7")
    end
end)

RegisterCommand("testcallout", function()
    if not calloutOnDuty then
        SetNotificationTextEntry("STRING")
        AddTextComponentString("~r~Debes estar de servicio para recibir avisos")
        DrawNotification(false, false)
        return
    end

    if calloutActive then
        SetNotificationTextEntry("STRING")
        AddTextComponentString("~y~Ya tienes un aviso activo")
        DrawNotification(false, false)
        return
    end

    calloutActive = true
    calloutAccepted = false

    SetNotificationTextEntry("STRING")
    AddTextComponentString("~b~CENTRAL: ~w~Posible altercado en curso~n~~y~Pulsa Y para aceptar")
    DrawNotification(false, false)

    print("^3[fivepd-police] TEST CALLOUT CREADO^7")
end, false)
CreateThread(function()
    while true do
        Wait(0)

        if calloutActive and not calloutAccepted then
            if IsControlJustReleased(0, 246) then -- Y
                calloutAccepted = true

                SetNotificationTextEntry("STRING")
                AddTextComponentString("~g~Aviso aceptado~n~~w~Dirígete al lugar indicado")
                DrawNotification(false, false)
				-- Crear blip del aviso
calloutBlip = AddBlipForCoord(
    calloutCoords.x,
    calloutCoords.y,
    calloutCoords.z
)

SetBlipSprite(calloutBlip, 161)
SetBlipColour(calloutBlip, 1)
SetBlipScale(calloutBlip, 1.0)
SetBlipRoute(calloutBlip, true)

BeginTextCommandSetBlipName("STRING")
AddTextComponentString("Aviso policial - Altercado")
EndTextCommandSetBlipName(calloutBlip)

SetNewWaypoint(calloutCoords.x, calloutCoords.y)

                print("^2[fivepd-police] CALLOUT ACEPTADO^7")
            end
        end
    end
end)
CreateThread(function()
    while true do
        Wait(500)

        if calloutActive and calloutAccepted then
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(playerCoords - calloutCoords)

            if distance < 40.0 then
			if not sceneSpawned then
    sceneSpawned = true

    local model = joaat("a_m_m_skater_01")

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(50)
    end

    suspectPed = CreatePed(
        4,
        model,
        calloutCoords.x,
        calloutCoords.y,
        calloutCoords.z,
        90.0,
        true,
        true
    )

    victimPed = CreatePed(
        4,
        model,
        calloutCoords.x + 2.0,
        calloutCoords.y,
        calloutCoords.z,
        270.0,
        true,
        true
    )

    SetEntityAsMissionEntity(suspectPed, true, true)
    SetEntityAsMissionEntity(victimPed, true, true)
	-- Registrar al sospechoso en el sistema nativo de PD5M
local suspectNetID = PedToNet(suspectPed)

TriggerEvent(
    'pd5m:bridge:RegisterCalloutSuspect',
    suspectNetID
)
CreateThread(function()
    local surrenderTriggered = false

    while calloutActive
        and DoesEntityExist(suspectPed)
        and not IsEntityDead(suspectPed)
        and not surrenderTriggered do

        Wait(100)

        local aiming, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())

        if aiming and entity == suspectPed then
            surrenderTriggered = true

            -- Cancelar cualquier huida o tarea anterior
            ClearPedTasksImmediately(suspectPed)

            -- Entregar el control al sistema nativo de rendición de PD5M
            TriggerEvent(
                'pd5m:int:HavePedSurrender',
                suspectPed
            )

            print(
                "^3[fivepd-police] SOSPECHOSO ENVIADO AL SISTEMA DE RENDICIÓN DE PD5M^7"
            )
        end
    end
end)
   -- TaskCombatPed(suspectPed, victimPed, 0, 16)
   -- Mantener al sospechoso cerca de la escena sin forzar combate
ClearPedTasksImmediately(suspectPed)

-- Evitar que salga huyendo a toda velocidad,
-- pero permitir que PD5M controle su reacción al policía
SetPedFleeAttributes(suspectPed, 0, false)
SetBlockingOfNonTemporaryEvents(suspectPed, false)

TaskStandStill(suspectPed, -1)
    TaskSmartFleePed(victimPed, suspectPed, 40.0, 15000, false, false)
	

    SetModelAsNoLongerNeeded(model)

    print("^2[fivepd-police] ESCENA DEL ALTERCADO CREADA^7")
end
                SetNotificationTextEntry("STRING")
                AddTextComponentString("~b~CENTRAL: ~w~Has llegado a la zona del aviso")
                DrawNotification(false, false)

                print("^3[fivepd-police] JUGADOR EN LA ESCENA DEL CALLOUT^7")

                -- Evita que el mensaje se repita continuamente
                calloutAccepted = false
            end
        end
    end
end)
CreateThread(function()
    while true do
        Wait(1000)

        if sceneSpawned and calloutActive and suspectPed ~= nil and DoesEntityExist(suspectPed) then

            -- CASO 1: sospechoso neutralizado
            if IsEntityDead(suspectPed) then

                SetNotificationTextEntry("STRING")
                AddTextComponentString(
                    "~b~CENTRAL: ~g~Aviso finalizado~n~~w~Sospechoso neutralizado"
                )
                DrawNotification(false, false)

                if calloutBlip ~= nil and DoesBlipExist(calloutBlip) then
                    RemoveBlip(calloutBlip)
                    calloutBlip = nil
                end

                calloutActive = false
                calloutAccepted = false
                sceneSpawned = false

                print(
                    "^2[fivepd-police] CALLOUT FINALIZADO - SOSPECHOSO NEUTRALIZADO^7"
                )
            end
        end
    end
end)
      RegisterNetEvent('fivepd-police:suspectImprisoned')
      AddEventHandler('fivepd-police:suspectImprisoned', function(imprisonedNetID)

    -- Solo actuar si hay un callout activo
    if not calloutActive or not sceneSpawned then
        return
    end

    -- Comprobar que tenemos un sospechoso válido
    if suspectPed == nil then
        return
    end

    -- Comparar el detenido encarcelado con el sospechoso del callout
    local suspectNetID = PedToNet(suspectPed)

    if suspectNetID ~= imprisonedNetID then
        return
    end

    -- El sospechoso correcto ha sido ingresado en prisión
    SetNotificationTextEntry("STRING")
    AddTextComponentString(
        "~b~CENTRAL: ~g~Aviso finalizado~n~~w~Sospechoso encarcelado"
    )
    DrawNotification(false, false)

    -- Eliminar el blip del aviso si todavía existe
    if calloutBlip ~= nil and DoesBlipExist(calloutBlip) then
        RemoveBlip(calloutBlip)
        calloutBlip = nil
    end

    -- Finalizar y limpiar estado del callout
    calloutActive = false
    calloutAccepted = false
    sceneSpawned = false

    suspectPed = nil
    victimPed = nil

    print(
        "^2[fivepd-police] CALLOUT FINALIZADO - SOSPECHOSO ENCARCELADO^7"
    )
end)




RegisterCommand("revive", function()
    local ped = PlayerPedId()

    if not IsEntityDead(ped) and GetEntityHealth(ped) > 0 then
        SetNotificationTextEntry("STRING")
        AddTextComponentString("~y~No necesitas ser reanimado")
        DrawNotification(false, false)
        return
    end

    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    NetworkResurrectLocalPlayer(
        coords.x,
        coords.y,
        coords.z + 0.5,
        heading,
        true,
        false
    )

    ped = PlayerPedId()

    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    ClearPedBloodDamage(ped)
    ClearPedTasksImmediately(ped)
    ResetPedVisibleDamage(ped)
    SetPlayerInvincible(PlayerId(), false)
    FreezeEntityPosition(ped, false)

    SetNotificationTextEntry("STRING")
    AddTextComponentString("~g~Jugador reanimado")
    DrawNotification(false, false)

    print("^2[fivepd-police] JUGADOR REANIMADO CON /revive^7")
end, false)
