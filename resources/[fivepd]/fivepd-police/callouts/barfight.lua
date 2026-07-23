print("^5[PRUEBA RUTA] BARFIGHT NUEVO CARGADO^7")
-- SMVLPD - Callout: Pelea en un bar
-- Port inicial basado en BarFight.cs

local barFightActive = false
local barFightAccepted = false
local barFightSceneSpawned = false

local barFightBlip = nil
local fighter1 = nil
local fighter2 = nil

local selectedLocation = nil

-- Ubicaciones tomadas del callout original
local barLocations = {
    vector3(498.53, -1539.00, 29.27),
    vector3(-554.80, 285.28, 82.18),
    vector3(-1392.61, -587.24, 30.25),
    vector3(1215.87, -413.62, 67.82),
    vector3(252.23, -1012.42, 29.27),
    vector3(226.25, 302.41, 105.53),
	vector3(127.18, -1285.72, 29.28),
	vector3(138.84, -1451.73, 29.16),
	vector3(-638.84, -1254.99, 11.03),
	vector3(-1819.35, -1182.52, 14.30),
	vector3(-1313.80, -1334.99, 4.66)

}

local function NotifyBarFight(message)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    DrawNotification(false, false)
end

local function RemoveBarFightBlip()
    if barFightBlip and DoesBlipExist(barFightBlip) then
        RemoveBlip(barFightBlip)
    end

    barFightBlip = nil
end

RegisterCommand("barfight", function()

    if barFightActive then
        NotifyBarFight("~y~Ya tienes activo el aviso de pelea.")
        return
    end

    selectedLocation = barLocations[math.random(1, #barLocations)]

    barFightActive = true
    barFightAccepted = false
    barFightSceneSpawned = false
    NotifyBarFight(
        "~b~CENTRAL: ~w~Pelea en curso en un establecimiento.~n~" ..
        "~y~Pulsa Y para aceptar el aviso."
    )

    print("^3[BARFIGHT] Nuevo aviso creado.^7")
end, false)

-- Aceptación con Y
CreateThread(function()

    while true do

        Wait(0)

        if barFightActive and not barFightAccepted then

            if IsControlJustReleased(0, 246) then

                barFightAccepted = true

                NotifyBarFight(
                    "~g~Aviso aceptado.~n~" ..
                    "~w~Dirígete al establecimiento indicado."
                )

                barFightBlip = AddBlipForCoord(
                    selectedLocation.x,
                    selectedLocation.y,
                    selectedLocation.z
                )

                SetBlipSprite(barFightBlip, 161)
                SetBlipColour(barFightBlip, 1)
                SetBlipScale(barFightBlip, 1.0)
                SetBlipRoute(barFightBlip, true)

                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString("Pelea en establecimiento")
                EndTextCommandSetBlipName(barFightBlip)

                SetNewWaypoint(
                    selectedLocation.x,
                    selectedLocation.y
                )

                print("^2[BARFIGHT] Aviso aceptado.^7")
            end
        end
    end
end)

-- Crear escena al acercarse
CreateThread(function()

    while true do

        Wait(500)

        if barFightActive
        and barFightAccepted
        and not barFightSceneSpawned
        and selectedLocation then

            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)

            local distance = #(
                playerCoords - selectedLocation
            )

            if distance < 80.0 then

                barFightSceneSpawned = true

                local model1 = joaat("a_m_m_bevhills_02")
                local model2 = joaat("a_m_y_business_02")

                RequestModel(model1)
                RequestModel(model2)

                while not HasModelLoaded(model1)
                or not HasModelLoaded(model2) do
                    Wait(50)
                end

                fighter1 = CreatePed(
                    4,
                    model1,
                    selectedLocation.x,
                    selectedLocation.y,
                    selectedLocation.z,
                    90.0,
                    true,
                    true
                )

                fighter2 = CreatePed(
                    4,
                    model2,
                    selectedLocation.x + 1.5,
                    selectedLocation.y,
                    selectedLocation.z,
                    270.0,
                    true,
                    true
                )

                SetEntityAsMissionEntity(
                    fighter1,
                    true,
                    true
                )

                SetEntityAsMissionEntity(
                    fighter2,
                    true,
                    true
                )

                SetModelAsNoLongerNeeded(model1)
                SetModelAsNoLongerNeeded(model2)

                -- Registrar a LOS DOS implicados en PD5M.
                -- No decidimos culpabilidad desde el script: ambos quedan
                -- disponibles para identificación, cacheo y arresto normal.
                local fighter1NetID = PedToNet(fighter1)
                local fighter2NetID = PedToNet(fighter2)

                TriggerEvent(
                    "pd5m:bridge:RegisterCalloutSuspect",
                    fighter1NetID
                )

                TriggerEvent(
                    "pd5m:bridge:RegisterCalloutSuspect",
                    fighter2NetID
                )

                NotifyBarFight(
                    "~b~CENTRAL: ~w~Unidad en escena.~n~" ..
                    "~r~Los dos implicados están peleándose.~n~" ..
                    "~y~Intervén y controla la situación."
                )

                print(
                    "^2[BARFIGHT] Escena creada. Implicados registrados: "
                    .. tostring(fighter1NetID)
                    .. " / "
                    .. tostring(fighter2NetID)
                    .. "^7"
                )

                -- Pequeña espera para que las entidades
                -- estén completamente creadas
                Wait(1500)

                TaskCombatPed(
                    fighter1,
                    fighter2,
                    0,
                    16
                )

                TaskCombatPed(
                    fighter2,
                    fighter1,
                    0,
                    16
                )
            end
        end
    end
end)

-- Rendición del sospechoso al apuntarle
CreateThread(function()

    local interventionTriggered = false

    while true do

        Wait(100)

        -- Preparar el sistema para un nuevo callout
        if not barFightActive then
            interventionTriggered = false
        end

        if barFightActive
        and barFightSceneSpawned
        and not interventionTriggered then

            local aiming, entity =
                GetEntityPlayerIsFreeAimingAt(
                    PlayerId()
                )

            -- Comprobar si estamos apuntando a cualquiera
            -- de los dos implicados
            local aimingAtFighter1 =
                fighter1
                and DoesEntityExist(fighter1)
                and not IsEntityDead(fighter1)
                and entity == fighter1

            local aimingAtFighter2 =
                fighter2
                and DoesEntityExist(fighter2)
                and not IsEntityDead(fighter2)
                and entity == fighter2

            if aiming
            and (aimingAtFighter1 or aimingAtFighter2) then

                interventionTriggered = true

                -- Detener inmediatamente la pelea de ambos
                if fighter1
                and DoesEntityExist(fighter1)
                and not IsEntityDead(fighter1) then

                    ClearPedTasksImmediately(fighter1)
                    SetBlockingOfNonTemporaryEvents(
                        fighter1,
                        true
                    )
                    TaskStandStill(fighter1, -1)
                end

                if fighter2
                and DoesEntityExist(fighter2)
                and not IsEntityDead(fighter2) then

                    ClearPedTasksImmediately(fighter2)
                    SetBlockingOfNonTemporaryEvents(
                        fighter2,
                        true
                    )
                    TaskStandStill(fighter2, -1)
                end

                -- La persona a la que apunta el agente
                -- entra en el sistema nativo de rendición PD5M
                local surrenderPed = nil

                if aimingAtFighter1 then
                    surrenderPed = fighter1
                elseif aimingAtFighter2 then
                    surrenderPed = fighter2
                end

                if surrenderPed then

                    TriggerEvent(
                        "pd5m:int:HavePedSurrender",
                        surrenderPed
                    )

                    NotifyBarFight(
                        "~b~CENTRAL: ~w~La pelea ha cesado.~n~" ..
                        "~y~Controla a los dos implicados con las opciones normales de PD5M.~n~" ..
                        "~w~La responsabilidad se determinará posteriormente."
                    )

                    print(
                        "^3[BARFIGHT] Pelea detenida. " ..
                        "Implicado enviado al sistema " ..
                        "de rendición PD5M.^7"
                    )
                end
            end
        end
    end
end)

-- Finalización por muerte del sospechoso
CreateThread(function()

    while true do

        Wait(1000)

        if barFightActive
        and barFightSceneSpawned
        and fighter2
        and DoesEntityExist(fighter2)
        and IsEntityDead(fighter2) then

            NotifyBarFight(
                "~b~CENTRAL: ~g~Aviso finalizado.~n~" ..
                "~w~Sospechoso neutralizado."
            )

            RemoveBarFightBlip()

            barFightActive = false
            barFightAccepted = false
            barFightSceneSpawned = false

            fighter1 = nil
            fighter2 = nil

            print(
                "^2[BARFIGHT] Aviso finalizado - " ..
                "sospechoso neutralizado.^7"
            )
        end
    end
end)

-- Finalización al encarcelar al sospechoso
RegisterNetEvent(
    "fivepd-police:suspectImprisoned"
)

AddEventHandler(
    "fivepd-police:suspectImprisoned",
    function(imprisonedNetID)

        if not barFightActive
        or not barFightSceneSpawned
        or not fighter2
        or not DoesEntityExist(fighter2) then
            return
        end

        local suspectNetID = PedToNet(fighter2)

        if suspectNetID ~= imprisonedNetID then
            return
        end

        NotifyBarFight(
            "~b~CENTRAL: ~g~Aviso finalizado.~n~" ..
            "~w~Sospechoso encarcelado."
        )

        RemoveBarFightBlip()

        barFightActive = false
        barFightAccepted = false
        barFightSceneSpawned = false

        fighter1 = nil
        fighter2 = nil

        print(
            "^2[BARFIGHT] Aviso finalizado - " ..
            "sospechoso encarcelado.^7"
        )
    end
)
