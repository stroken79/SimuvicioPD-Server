print("^2[ABANDONED VEHICLE] ARCHIVO CARGADO CORRECTAMENTE^7")
-- SMVLPD - Callout: Vehículo abandonado
-- Adaptación PD5M basada en AbandondedVehicle.cs
-- Flujo: /abandonedvehicle -> Y -> acudir -> inspeccionar -> finalizar con E

local calloutActive = false
local calloutAccepted = false
local sceneSpawned = false
local sceneLocated = false
local calloutFinished = false

local calloutBlip = nil
local sceneBlip = nil
local abandonedVehicle = nil
local burnedWreck = nil
local activeFires = {}

local selectedLocation = nil
local selectedHeading = 0.0
local burnedVariant = false

-- Ubicaciones del vehículo calcinado tomadas del callout FivePD original.
local burnedLocations = {
    vector3(1390.56, -761.90, 66.87),
    vector3(705.00, -291.22, 59.18),
    vector3(613.15, -885.36, 11.17),
    vector3(697.71, -1159.39, 24.29),
    vector3(1222.52, -2176.63, 41.82),
    vector3(-1228.82, -2039.08, 13.54),
    vector3(-1193.88, -1485.63, 4.38),
    vector3(-1697.74, -896.77, 8.09),
    vector3(-1538.43, 341.27, 86.50),
    vector3(-1221.95, -645.87, 40.36),
    vector3(-1555.36, -993.54, 13.02)
}

local compactModels = {
    "blista",
    "brioso",
    "dilettante",
    "issi2",
    "panto",
    "prairie",
    "rhapsody"
}

local function Notify(message)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(message)
    DrawNotification(false, false)
end

local function RemoveCalloutBlips()
    if calloutBlip and DoesBlipExist(calloutBlip) then
        RemoveBlip(calloutBlip)
    end

    if sceneBlip and DoesBlipExist(sceneBlip) then
        RemoveBlip(sceneBlip)
    end

    calloutBlip = nil
    sceneBlip = nil
end

local function StopSceneFires()
    for _, fireHandle in ipairs(activeFires) do
        if fireHandle then
            RemoveScriptFire(fireHandle)
        end
    end

    activeFires = {}
end

local function ResetCalloutState()
    RemoveCalloutBlips()
    StopSceneFires()

    calloutActive = false
    calloutAccepted = false
    sceneSpawned = false
    sceneLocated = false
    calloutFinished = false

    selectedLocation = nil
    selectedHeading = 0.0
    burnedVariant = false

    abandonedVehicle = nil
    burnedWreck = nil
end

local function FinishCallout(message)
    if not calloutActive or calloutFinished then
        return
    end

    calloutFinished = true

    Notify(
        "~b~CENTRAL: ~g~Aviso finalizado.~n~" ..
        "~w~" .. message
    )

    RemoveCalloutBlips()

    -- No borramos automáticamente un vehículo normal:
    -- queda disponible para la gestión policial/grúa del servidor.
    -- El objeto calcinado y sus fuegos sí se limpian al cerrar el aviso.
    StopSceneFires()

    if burnedWreck and DoesEntityExist(burnedWreck) then
        SetEntityAsMissionEntity(burnedWreck, true, true)
        DeleteObject(burnedWreck)
    end

    calloutActive = false
    calloutAccepted = false
    sceneSpawned = false
    sceneLocated = false

    selectedLocation = nil
    abandonedVehicle = nil
    burnedWreck = nil

    print("^2[ABANDONED VEHICLE] Aviso finalizado.^7")
end

local function FindRoadsideLocation()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)

    -- Intentamos encontrar un nodo de carretera a una distancia razonable.
    for _ = 1, 25 do
        local angle = math.random() * math.pi * 2.0
        local distance = math.random(500, 750)

        local probeX = playerCoords.x + math.cos(angle) * distance
        local probeY = playerCoords.y + math.sin(angle) * distance
        local probeZ = playerCoords.z

        local found, nodeCoords, nodeHeading =
            GetClosestVehicleNodeWithHeading(
                probeX,
                probeY,
                probeZ,
                1,
                3.0,
                0
            )

        if found and nodeCoords then
            return nodeCoords, nodeHeading or 0.0
        end
    end

    -- Respaldo si no se encuentra nodo.
    return vector3(
        playerCoords.x + 550.0,
        playerCoords.y,
        playerCoords.z
    ), 0.0
end

RegisterCommand("abandonedvehicle", function()

    if calloutActive then
        Notify("~y~Ya tienes activo el aviso de vehículo abandonado.")
        return
    end

    -- Igual que el original: aproximadamente 25% será vehículo calcinado.
    burnedVariant = math.random(1, 100) >= 75

    if burnedVariant then
        selectedLocation =
            burnedLocations[math.random(1, #burnedLocations)]

        selectedHeading = math.random(0, 359) + 0.0
    else
        selectedLocation, selectedHeading =
            FindRoadsideLocation()
    end

    calloutActive = true
    calloutAccepted = false
    sceneSpawned = false
    sceneLocated = false
    calloutFinished = false

    Notify(
        "~b~CENTRAL: ~w~Se ha recibido un aviso por un vehículo abandonado.~n~" ..
        "~y~Pulsa Y para aceptar el aviso."
    )

    print(
        "^3[ABANDONED VEHICLE] Nuevo aviso. Variante: "
        .. (burnedVariant and "CALCINADO" or "NORMAL")
        .. "^7"
    )
end, false)

-- Aceptación con Y, igual que el sistema usado por barfight.lua.
CreateThread(function()
    while true do
        Wait(0)

        if calloutActive and not calloutAccepted then
            if IsControlJustReleased(0, 246) then
                calloutAccepted = true

                Notify(
                    "~g~Aviso aceptado.~n~" ..
                    "~w~Dirígete a la ubicación indicada."
                )

                calloutBlip = AddBlipForCoord(
                    selectedLocation.x,
                    selectedLocation.y,
                    selectedLocation.z
                )

                SetBlipSprite(calloutBlip, 225)
                SetBlipColour(calloutBlip, 5)
                SetBlipScale(calloutBlip, 1.0)
                SetBlipRoute(calloutBlip, true)

                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString("Vehículo abandonado")
                EndTextCommandSetBlipName(calloutBlip)

                SetNewWaypoint(
                    selectedLocation.x,
                    selectedLocation.y
                )

                print("^2[ABANDONED VEHICLE] Aviso aceptado.^7")
            end
        end
    end
end)

-- Crear la escena al aproximarse.
CreateThread(function()
    while true do
        Wait(500)

        if calloutActive
        and calloutAccepted
        and not sceneSpawned
        and selectedLocation then

            local playerCoords = GetEntityCoords(PlayerPedId())
            local distance = #(playerCoords - selectedLocation)

            if distance < 120.0 then
                sceneSpawned = true

                if burnedVariant then
                    local model = joaat("prop_rub_carwreck_14")

                    RequestModel(model)

                    while not HasModelLoaded(model) do
                        Wait(50)
                    end

                    burnedWreck = CreateObject(
                        model,
                        selectedLocation.x,
                        selectedLocation.y,
                        selectedLocation.z - 1.20,
                        true,
                        true,
                        false
                    )

                    SetEntityHeading(
                        burnedWreck,
                        selectedHeading
                    )

                    SetEntityAsMissionEntity(
                        burnedWreck,
                        true,
                        true
                    )

                    SetModelAsNoLongerNeeded(model)

                    -- Menos fuegos que el original para evitar una escena
                    -- excesivamente pesada. No hay explosión automática.
                    for i = 1, 8 do
                        local offsetX =
                            (math.random() - 0.5) * 1.4
                        local offsetY =
                            (math.random() - 0.5) * 1.4

                        local fireHandle = StartScriptFire(
                            selectedLocation.x + offsetX,
                            selectedLocation.y + offsetY,
                            selectedLocation.z,
                            10,
                            false
                        )

                        table.insert(
                            activeFires,
                            fireHandle
                        )
                    end

                    sceneBlip =
                        AddBlipForEntity(burnedWreck)

                    SetBlipSprite(sceneBlip, 436)
                    SetBlipColour(sceneBlip, 1)

                else
                    local modelName =
                        compactModels[
                            math.random(1, #compactModels)
                        ]

                    local model = joaat(modelName)

                    RequestModel(model)

                    while not HasModelLoaded(model) do
                        Wait(50)
                    end

                    abandonedVehicle = CreateVehicle(
                        model,
                        selectedLocation.x,
                        selectedLocation.y,
                        selectedLocation.z,
                        selectedHeading,
                        true,
                        true
                    )

                    SetEntityAsMissionEntity(
                        abandonedVehicle,
                        true,
                        true
                    )

                    SetVehicleOnGroundProperly(
                        abandonedVehicle
                    )

                    SetVehicleEngineOn(
                        abandonedVehicle,
                        false,
                        true,
                        true
                    )

                    SetVehicleDoorsLocked(
                        abandonedVehicle,
                        1
                    )

                    SetVehicleDirtLevel(
                        abandonedVehicle,
                        8.0
                    )

                    -- Vehículo vacío y abandonado.
                    SetVehicleNumberPlateText(
                        abandonedVehicle,
                        "ABN" .. tostring(math.random(100, 999))
                    )

                    SetModelAsNoLongerNeeded(model)

                    sceneBlip =
                        AddBlipForEntity(abandonedVehicle)

                    SetBlipSprite(sceneBlip, 326)
                    SetBlipColour(sceneBlip, 5)
                end

                print("^2[ABANDONED VEHICLE] Escena creada.^7")
            end
        end
    end
end)

-- Al llegar a la escena, retirar la ruta y dar instrucciones simples.
CreateThread(function()
    while true do
        Wait(500)

        if calloutActive
        and sceneSpawned
        and not sceneLocated
        and selectedLocation then

            local playerCoords =
                GetEntityCoords(PlayerPedId())

            local distance =
                #(playerCoords - selectedLocation)

            if distance < 35.0 then
                sceneLocated = true

                if calloutBlip
                and DoesBlipExist(calloutBlip) then
                    SetBlipRoute(calloutBlip, false)
                    RemoveBlip(calloutBlip)
                    calloutBlip = nil
                end

                if burnedVariant then
                    Notify(
                        "~b~CENTRAL: ~w~Vehículo calcinado localizado.~n~" ..
                        "~y~Asegura e inspecciona la escena.~n~" ..
                        "~w~Acércate y pulsa E cuando termines."
                    )
                else
                    Notify(
                        "~b~CENTRAL: ~w~Vehículo abandonado localizado.~n~" ..
                        "~y~Comprueba la matrícula y gestiona el vehículo.~n~" ..
                        "~w~Acércate y pulsa E cuando termines."
                    )
                end
            end
        end
    end
end)

-- Resolución sencilla: E junto al vehículo/escena.
-- No añadimos menús ni modificamos interaction_cl.lua.
CreateThread(function()
    while true do
        local sleep = 500

        if calloutActive
        and sceneLocated
        and not calloutFinished
        and selectedLocation then

            local playerCoords =
                GetEntityCoords(PlayerPedId())

            local distance =
                #(playerCoords - selectedLocation)

            if distance <= 5.0 then
                sleep = 0

                BeginTextCommandDisplayHelp("STRING")

                if burnedVariant then
                    AddTextComponentSubstringPlayerName(
                        "Pulsa ~INPUT_CONTEXT~ para finalizar la inspección del vehículo calcinado"
                    )
                else
                    AddTextComponentSubstringPlayerName(
                        "Pulsa ~INPUT_CONTEXT~ para finalizar la gestión del vehículo abandonado"
                    )
                end

                EndTextCommandDisplayHelp(
                    0,
                    false,
                    true,
                    -1
                )

                if IsControlJustReleased(0, 38) then
                    if burnedVariant then
                        FinishCallout(
                            "Vehículo calcinado documentado. La escena queda cerrada."
                        )
                    else
                        FinishCallout(
                            "Vehículo abandonado comprobado y puesto a disposición para su retirada."
                        )
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

-- Comando de emergencia para cancelar solo este aviso durante pruebas.
RegisterCommand("cancelabandonedvehicle", function()
    if not calloutActive then
        Notify("~y~No hay ningún aviso de vehículo abandonado activo.")
        return
    end

    Notify("~b~CENTRAL: ~w~Aviso de vehículo abandonado cancelado.")

    RemoveCalloutBlips()
    StopSceneFires()

    if burnedWreck and DoesEntityExist(burnedWreck) then
        SetEntityAsMissionEntity(burnedWreck, true, true)
        DeleteObject(burnedWreck)
    end

    ResetCalloutState()

    print("^3[ABANDONED VEHICLE] Aviso cancelado.^7")
end, false)
