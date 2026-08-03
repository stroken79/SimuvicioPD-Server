print("^2[CAR CALLOUTS] Modulo cargado correctamente^7")

local pedModels = {
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
    "tornado",
    "tornado2",
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

local function SpawnPed(runtime, coords, heading, seat, vehicle, weaponName)
    local model = LoadModel(Pick(pedModels))
    local ped = CreatePed(4, model, coords.x, coords.y, coords.z, heading, true, true)

    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, false)
    SetPedFleeAttributes(ped, 0, false)
    SetPedKeepTask(ped, true)

    if vehicle then
        SetPedIntoVehicle(ped, vehicle, seat)
    end

    if weaponName then
        GiveWeaponToPed(ped, joaat(weaponName), 120, false, true)
    end

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

local function SpawnTrafficCallout(runtime, options)
    local vehicle = SpawnVehicle(runtime, Pick(options.vehicle))

    if options.emergency then
        SetVehicleSiren(vehicle, true)
    end

    local driver = SpawnPed(
        runtime,
        vector3(runtime.coords.x + 2.0, runtime.coords.y, runtime.coords.z),
        runtime.heading,
        -1,
        vehicle,
        options.weapons and options.weapons[1] or nil
    )

    local occupants = options.occupants or 1

    for i = 2, occupants do
        SpawnPed(
            runtime,
            vector3(runtime.coords.x + 2.0, runtime.coords.y, runtime.coords.z),
            runtime.heading,
            i - 2,
            vehicle,
            options.weapons and options.weapons[i] or nil
        )
    end

    if options.hostage then
        local model = LoadModel("s_m_y_cop_01")
        local hostage = CreatePed(
            4,
            model,
            runtime.coords.x + 1.0,
            runtime.coords.y,
            runtime.coords.z,
            runtime.heading,
            true,
            true
        )

        SetEntityAsMissionEntity(hostage, true, true)
        SetPedIntoVehicle(hostage, vehicle, 1)
        SetBlockingOfNonTemporaryEvents(hostage, true)
        SetModelAsNoLongerNeeded(model)
        runtime.trackEntity(hostage)
    end

    if options.reverse then
        runtime.context.reverse = true
        TaskVehicleTempAction(driver, vehicle, 23, 30000)

        CreateThread(function()
            while runtime.context.reverse and DoesEntityExist(vehicle) do
                SetVehicleForwardSpeed(vehicle, -4.0)
                Wait(700)
            end
        end)
    else
        TaskVehicleDriveWander(driver, vehicle, options.speed or 20.0, options.style or 525116)
    end

    if options.pursuit then
        TaskSmartFleePed(driver, PlayerPedId(), 1000.0, -1, false, false)
    end

    runtime.addBlip(vehicle, 225, options.colour or 1, options.blipName)
end

local function MakeCarCallout(options)
    return {
        title = options.title,
        dispatch = options.dispatch,
        accept = options.accept or "~g~Aviso aceptado.~n~~w~Localiza el vehiculo.",
        arrival = options.arrival,
        blipName = options.blipName,
        blipSprite = 225,
        blipColour = options.colour or 1,
        spawnRadius = 160.0,
        finishHelp = "Pulsa ~INPUT_CONTEXT~ para cerrar el aviso de trafico",

        prepare = function()
            local coords, heading = RandomRoad()
            return coords, heading, {}
        end,

        spawn = function(runtime)
            SpawnTrafficCallout(runtime, options)
        end,

        cleanup = function(context)
            context.reverse = false
        end
    }
end

PoliceCallouts.Register({
    MakeCarCallout({
        title = "Vehiculo sobredimensionado",
        dispatch = "~b~CENTRAL: ~w~Un vehiculo de gran tamano causa problemas de trafico.",
        arrival = "~b~CENTRAL: ~w~Vehiculo localizado.~n~~y~Deten e identifica al conductor.",
        blipName = "Vehiculo sobredimensionado",
        vehicle = "dump",
        speed = 15.0,
        style = 525116,
        colour = 5
    }),
    MakeCarCallout({
        title = "Persecucion de sospechosos armados",
        dispatch = "~b~CENTRAL: ~w~Sospechosos armados huyen tras un robo.",
        arrival = "~r~Sospechosos armados y peligrosos.~n~~y~Procede con precaucion.",
        blipName = "Sospechosos armados",
        vehicle = trafficVehicles,
        occupants = 2,
        weapons = { "WEAPON_SMG", "WEAPON_PISTOL" },
        speed = 35.0,
        style = 524852,
        pursuit = true
    }),
    MakeCarCallout({
        title = "Conductor temerario",
        dispatch = "~b~CENTRAL: ~w~Un vehiculo circula de forma temeraria.",
        arrival = "~b~CENTRAL: ~w~Conductor temerario localizado.",
        blipName = "Conductor temerario",
        vehicle = trafficVehicles,
        speed = 25.0,
        style = 525116
    }),
    MakeCarCallout({
        title = "Vehiculo marcha atras",
        dispatch = "~b~CENTRAL: ~w~Un vehiculo circula marcha atras por la via.",
        arrival = "~b~CENTRAL: ~w~Vehiculo localizado.~n~~y~Retiralo de la circulacion.",
        blipName = "Vehiculo marcha atras",
        vehicle = trafficVehicles,
        reverse = true
    }),
    MakeCarCallout({
        title = "Conductor demasiado lento",
        dispatch = "~b~CENTRAL: ~w~Un vehiculo circula muy lento y retiene el trafico.",
        arrival = "~b~CENTRAL: ~w~Conductor lento localizado.",
        blipName = "Conductor lento",
        vehicle = trafficVehicles,
        speed = 2.0,
        style = 387,
        colour = 5
    }),
    MakeCarCallout({
        title = "Vehiculo muy pequeno",
        dispatch = "~b~CENTRAL: ~w~Un vehiculo muy pequeno causa problemas en la via.",
        arrival = "~b~CENTRAL: ~w~Vehiculo localizado.",
        blipName = "Vehiculo muy pequeno",
        vehicle = "airtug",
        speed = 5.0,
        style = 524675,
        colour = 5
    }),
    MakeCarCallout({
        title = "Ambulancia robada",
        dispatch = "~b~CENTRAL: ~w~Han robado una ambulancia.",
        arrival = "~r~Ambulancia robada localizada.",
        blipName = "Ambulancia robada",
        vehicle = "ambulance",
        speed = 35.0,
        style = 524852,
        pursuit = true,
        emergency = true
    }),
    MakeCarCallout({
        title = "Camion de bomberos robado",
        dispatch = "~b~CENTRAL: ~w~Han robado un camion de bomberos.",
        arrival = "~r~Camion de bomberos robado localizado.",
        blipName = "Camion robado",
        vehicle = "firetruk",
        speed = 35.0,
        style = 524852,
        pursuit = true,
        emergency = true
    }),
    MakeCarCallout({
        title = "Vehiculo policial robado",
        dispatch = "~b~CENTRAL: ~w~Han robado un vehiculo policial.",
        arrival = "~r~Vehiculo policial robado localizado.",
        blipName = "Patrulla robada",
        vehicle = "police",
        speed = 35.0,
        style = 524852,
        pursuit = true,
        emergency = true
    }),
    MakeCarCallout({
        title = "Patrulla robada con rehen",
        dispatch = "~b~CENTRAL: ~w~Han robado una patrulla con un agente como rehen.",
        arrival = "~r~Patrulla robada localizada.~n~~y~Hay un rehen dentro.",
        blipName = "Patrulla con rehen",
        vehicle = "police",
        occupants = 2,
        weapons = { "WEAPON_PISTOL" },
        hostage = true,
        speed = 35.0,
        style = 524852,
        pursuit = true,
        emergency = true
    }),
    MakeCarCallout({
        title = "Furgoneta con sospechosos armados",
        dispatch = "~b~CENTRAL: ~w~Sospechosos armados huyen en una furgoneta.",
        arrival = "~r~Furgoneta localizada.~n~~y~Varios sospechosos armados.",
        blipName = "Furgoneta armada",
        vehicle = "speedo",
        occupants = 3,
        weapons = { "WEAPON_PISTOL", "WEAPON_SMG", "WEAPON_SMG" },
        speed = 35.0,
        style = 524852,
        pursuit = true
    })
})
