print("^2[ABANDONED VEHICLE CALLOUTS] Modulo cargado correctamente^7")

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

local function Pick(list)
    return list[math.random(1, #list)]
end

local function LoadModel(modelName)
    local model = joaat(modelName)

    RequestModel(model)

    while not HasModelLoaded(model) do
        Wait(50)
    end

    return model
end

local function RandomRoadsideLocation()
    local playerCoords = GetEntityCoords(PlayerPedId())

    for _ = 1, 25 do
        local angle = math.random() * math.pi * 2.0
        local distance = math.random(500, 750)
        local probeX = playerCoords.x + math.cos(angle) * distance
        local probeY = playerCoords.y + math.sin(angle) * distance

        local found, nodeCoords, nodeHeading =
            GetClosestVehicleNodeWithHeading(
                probeX,
                probeY,
                playerCoords.z,
                1,
                3.0,
                0
            )

        if found and nodeCoords then
            return nodeCoords, nodeHeading or 0.0
        end
    end

    return vector3(playerCoords.x + 550.0, playerCoords.y, playerCoords.z), 0.0
end

local function SpawnBurnedScene(runtime)
    local model = LoadModel("prop_rub_carwreck_14")
    local wreck = CreateObject(
        model,
        runtime.coords.x,
        runtime.coords.y,
        runtime.coords.z - 1.20,
        true,
        true,
        false
    )

    SetEntityHeading(wreck, runtime.heading)
    SetEntityAsMissionEntity(wreck, true, true)
    SetModelAsNoLongerNeeded(model)

    runtime.trackEntity(wreck)
    runtime.context.burnedWreck = wreck

    for _ = 1, 8 do
        local offsetX = (math.random() - 0.5) * 1.4
        local offsetY = (math.random() - 0.5) * 1.4
        local fire = StartScriptFire(
            runtime.coords.x + offsetX,
            runtime.coords.y + offsetY,
            runtime.coords.z,
            10,
            false
        )

        runtime.addFire(fire)
    end

    runtime.addBlip(wreck, 436, 1, "Vehiculo calcinado")
end

local function SpawnAbandonedVehicle(runtime)
    local model = LoadModel(Pick(compactModels))
    local vehicle = CreateVehicle(
        model,
        runtime.coords.x,
        runtime.coords.y,
        runtime.coords.z,
        runtime.heading,
        true,
        true
    )

    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleOnGroundProperly(vehicle)
    SetVehicleEngineOn(vehicle, false, true, true)
    SetVehicleDoorsLocked(vehicle, 1)
    SetVehicleDirtLevel(vehicle, 8.0)
    SetVehicleNumberPlateText(vehicle, "ABN" .. tostring(math.random(100, 999)))
    SetModelAsNoLongerNeeded(model)

    runtime.trackEntity(vehicle)
    runtime.addBlip(vehicle, 326, 5, "Vehiculo abandonado")
end

PoliceCallouts.Register({
    {
        title = "Vehiculo abandonado",
        dispatch = "~b~CENTRAL: ~w~Se ha recibido un aviso por un vehiculo abandonado.",
        accept = "~g~Aviso aceptado.~n~~w~Dirigete a la ubicacion indicada.",
        arrival = "~b~CENTRAL: ~w~Vehiculo abandonado localizado.~n~~y~Comprueba la matricula y gestiona el vehiculo.",
        blipName = "Vehiculo abandonado",
        blipSprite = 225,
        blipColour = 5,
        spawnRadius = 120.0,
        finishHelp = "Pulsa ~INPUT_CONTEXT~ para finalizar la gestion del vehiculo abandonado",

        prepare = function()
            local burnedVariant = math.random(1, 100) >= 75
            local coords, heading

            if burnedVariant then
                coords = Pick(burnedLocations)
                heading = math.random(0, 359) + 0.0
            else
                coords, heading = RandomRoadsideLocation()
            end

            return coords, heading, {
                burnedVariant = burnedVariant
            }
        end,

        spawn = function(runtime)
            if runtime.context.burnedVariant then
                SpawnBurnedScene(runtime)
                runtime.notify("~b~CENTRAL: ~w~Vehiculo calcinado localizado.~n~~y~Asegura e inspecciona la escena.")
            else
                SpawnAbandonedVehicle(runtime)
            end
        end,

        cleanup = function(context, deleteEntities)
            if deleteEntities then
                return
            end

            if context and context.burnedWreck and DoesEntityExist(context.burnedWreck) then
                SetEntityAsMissionEntity(context.burnedWreck, true, true)
                DeleteObject(context.burnedWreck)
            end
        end
    }
})
