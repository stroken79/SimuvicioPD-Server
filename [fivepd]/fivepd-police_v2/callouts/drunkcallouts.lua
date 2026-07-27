print("^2[DRUNK CALLOUTS] Modulo cargado correctamente^7")

local pedModels = {
    "a_m_m_bevhills_02",
    "a_m_m_business_01",
    "a_m_m_eastsa_01",
    "a_m_m_skater_01",
    "a_m_y_business_02",
    "a_m_y_hipster_01",
    "a_m_y_skater_01",
    "a_f_y_business_01",
    "a_f_y_hipster_02"
}

local trafficVehicles = {
    "speedo",
    "speedo2",
    "stanier",
    "stinger",
    "stingergt",
    "stratum",
    "stretch",
    "taco",
    "tornado",
    "tornado2",
    "tornado3",
    "tornado4",
    "tourbus",
    "vader",
    "voodoo2",
    "dune5",
    "youga",
    "taxi",
    "tailgater",
    "sentinel2",
    "sentinel",
    "sandking2",
    "sandking",
    "ruffian",
    "rumpo",
    "rumpo2",
    "oracle2",
    "oracle",
    "ninef2",
    "ninef",
    "minivan",
    "gburrito",
    "emperor2",
    "emperor"
}

local function Pick(value)
    if type(value) == "table" then
        return value[math.random(1, #value)]
    end

    return value
end

local function LoadModel(modelName)
    local model = joaat(modelName)

    RequestModel(model)

    while not HasModelLoaded(model) do
        Wait(50)
    end

    return model
end

local function RandomRoad()
    local playerCoords = GetEntityCoords(PlayerPedId())

    for _ = 1, 30 do
        local angle = math.random() * math.pi * 2.0
        local distance = math.random(350, 750)
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

    return vector3(playerCoords.x + 500.0, playerCoords.y, playerCoords.z), 0.0
end

local function SpawnPed(runtime, spawnCoords, spawnHeading)
    local model = LoadModel(Pick(pedModels))
    local ped = CreatePed(
        4,
        model,
        spawnCoords.x,
        spawnCoords.y,
        spawnCoords.z,
        spawnHeading,
        true,
        true
    )

    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, false)
    SetPedFleeAttributes(ped, 0, false)
    SetPedKeepTask(ped, true)
    SetPedIsDrunk(ped, true)

    SetModelAsNoLongerNeeded(model)
    runtime.trackEntity(ped)
    runtime.addSuspect(ped)

    return ped
end

local function SpawnVehicle(runtime, modelName)
    local model = LoadModel(modelName)
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
    SetVehicleDoorsLocked(vehicle, 1)
    SetModelAsNoLongerNeeded(model)
    runtime.trackEntity(vehicle)

    return vehicle
end

local function SpawnDrunkDriver(runtime, options)
    local vehicle = SpawnVehicle(runtime, Pick(options.vehicle))
    local driver = SpawnPed(
        runtime,
        vector3(runtime.coords.x + 2.0, runtime.coords.y, runtime.coords.z),
        runtime.heading
    )

    SetPedIntoVehicle(driver, vehicle, -1)

    if options.pursuit then
        TaskVehicleDriveWander(driver, vehicle, 35.0, 524852)
        TaskSmartFleePed(driver, PlayerPedId(), 1000.0, -1, false, false)
        runtime.notify("~o~CENTRAL: ~w~El conductor se da a la fuga.")
    else
        TaskVehicleDriveWander(driver, vehicle, 22.0, 524852)
    end

    runtime.addBlip(vehicle, 225, options.colour or 1, options.blipName)
end

local function MakeDrunkDriverCallout(options)
    return {
        title = options.title,
        dispatch = options.dispatch,
        accept = "~g~Aviso aceptado.~n~~w~Localiza el vehiculo.",
        arrival = options.arrival,
        blipName = options.blipName,
        blipSprite = 225,
        blipColour = options.colour or 1,
        spawnRadius = 160.0,
        finishHelp = "Pulsa ~INPUT_CONTEXT~ para cerrar el aviso de conductor ebrio",

        prepare = function()
            local coords, heading = RandomRoad()
            return coords, heading, {}
        end,

        spawn = function(runtime)
            SpawnDrunkDriver(runtime, options)
        end
    }
end

PoliceCallouts.Register({
    {
        title = "Pelea de personas ebrias",
        dispatch = "~b~CENTRAL: ~w~Pelea entre dos personas aparentemente ebrias.",
        accept = "~g~Aviso aceptado.~n~~w~Dirigete al lugar indicado.",
        arrival = "~b~CENTRAL: ~w~Implicados localizados.~n~~r~Estan peleandose.",
        blipName = "Pelea de ebrios",
        blipSprite = 161,
        blipColour = 1,
        spawnRadius = 90.0,
        finishHelp = "Pulsa ~INPUT_CONTEXT~ para cerrar el aviso de pelea",

        prepare = function()
            local coords, heading = RandomRoad()
            return coords, heading, {}
        end,

        spawn = function(runtime)
            local ped1 = SpawnPed(runtime, runtime.coords, 90.0)
            local ped2 = SpawnPed(
                runtime,
                vector3(runtime.coords.x + 1.6, runtime.coords.y, runtime.coords.z),
                270.0
            )

            runtime.addBlip(ped1, 1, 1, "Implicado ebrio")
            runtime.addBlip(ped2, 1, 1, "Implicado ebrio")

            TaskCombatPed(ped1, ped2, 0, 16)
            TaskCombatPed(ped2, ped1, 0, 16)
        end
    },
    MakeDrunkDriverCallout({
        title = "Conductor ebrio en fuga",
        dispatch = "~b~CENTRAL: ~w~Un conductor ebrio circula de forma peligrosa.",
        arrival = "~r~Conductor ebrio localizado.~n~~y~Intenta fugarse.",
        blipName = "Conductor ebrio en fuga",
        vehicle = trafficVehicles,
        pursuit = true
    }),
    MakeDrunkDriverCallout({
        title = "Conductor ebrio",
        dispatch = "~b~CENTRAL: ~w~Aviso por posible conductor ebrio.",
        arrival = "~b~CENTRAL: ~w~Conductor ebrio localizado.~n~~y~Realiza la parada.",
        blipName = "Conductor ebrio",
        vehicle = trafficVehicles,
        colour = 5
    }),
    MakeDrunkDriverCallout({
        title = "Motorista ebrio",
        dispatch = "~b~CENTRAL: ~w~Una persona conduce una moto bajo los efectos del alcohol.",
        arrival = "~r~Motorista ebrio localizado.~n~~y~Intenta fugarse.",
        blipName = "Motorista ebrio",
        vehicle = "bati",
        pursuit = true
    })
})
