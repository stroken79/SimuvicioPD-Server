print("^2[KIDNAPPING CALLOUTS] Modulo cargado correctamente^7")

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
            return nodeCoords, nodeHeading or 0.0, {}
        end
    end

    return vector3(playerCoords.x + 500.0, playerCoords.y, playerCoords.z), 0.0, {}
end

local function SpawnPed(runtime, spawnCoords, heading, options)
    options = options or {}

    local model = LoadModel(Pick(pedModels))
    local ped = CreatePed(
        4,
        model,
        spawnCoords.x,
        spawnCoords.y,
        spawnCoords.z,
        heading,
        true,
        true
    )

    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, false)
    SetPedFleeAttributes(ped, 0, false)
    SetPedKeepTask(ped, true)

    if options.weapon then
        GiveWeaponToPed(ped, joaat(options.weapon), options.ammo or 30, false, true)
    end

    SetModelAsNoLongerNeeded(model)
    runtime.trackEntity(ped)

    if options.suspect then
        runtime.addSuspect(ped)
    end

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

local function SpawnKidnapping(runtime, options)
    local vehicle = SpawnVehicle(runtime, Pick(options.vehicle))
    local driver = SpawnPed(
        runtime,
        vector3(runtime.coords.x + 2.0, runtime.coords.y, runtime.coords.z),
        runtime.heading,
        {
            suspect = true,
            weapon = "WEAPON_PISTOL",
            ammo = 30
        }
    )

    SetPedIntoVehicle(driver, vehicle, -1)

    local victim = SpawnPed(
        runtime,
        vector3(runtime.coords.x + 1.0, runtime.coords.y, runtime.coords.z),
        runtime.heading,
        {}
    )

    SetPedIntoVehicle(victim, vehicle, options.victimSeat or 0)
    TaskHandsUp(victim, 1000000, driver, -1, true)

    if options.secondSuspect then
        local passenger = SpawnPed(
            runtime,
            vector3(runtime.coords.x + 1.0, runtime.coords.y, runtime.coords.z),
            runtime.heading,
            {
                suspect = true,
                weapon = "WEAPON_SMG",
                ammo = 150
            }
        )

        SetPedIntoVehicle(passenger, vehicle, 2)

        CreateThread(function()
            Wait(6000)

            if DoesEntityExist(passenger) and not IsEntityDead(passenger) then
                TaskCombatPed(passenger, PlayerPedId(), 0, 16)
            end
        end)
    end

    TaskVehicleDriveWander(driver, vehicle, 35.0, 524852)
    TaskSmartFleePed(driver, PlayerPedId(), 1000.0, -1, false, false)

    runtime.notify("~o~CENTRAL: ~w~El conductor huye con la victima en el vehiculo.")
    runtime.addBlip(vehicle, 225, 1, options.blipName)
    runtime.addBlip(driver, 1, 1, "Secuestrador")
    runtime.addBlip(victim, 1, 3, "Victima")
end

local function MakeKidnappingCallout(options)
    return {
        title = options.title,
        dispatch = options.dispatch,
        accept = "~g~Aviso aceptado.~n~~w~Intercepta el vehiculo sospechoso.",
        arrival = options.arrival,
        blipName = options.blipName,
        blipSprite = 225,
        blipColour = 1,
        spawnRadius = 160.0,
        finishHelp = "Pulsa ~INPUT_CONTEXT~ para cerrar el aviso de secuestro",

        prepare = RandomRoad,

        spawn = function(runtime)
            SpawnKidnapping(runtime, options)
        end
    }
end

PoliceCallouts.Register({
    MakeKidnappingCallout({
        title = "Secuestro en furgoneta",
        dispatch = "~b~CENTRAL: ~w~Dos sospechosos han secuestrado a una persona en una furgoneta.",
        arrival = "~r~Furgoneta localizada.~n~~y~Hay una victima dentro y al menos dos sospechosos armados.",
        blipName = "Secuestro en furgoneta",
        vehicle = "speedo",
        secondSuspect = true,
        victimSeat = 1
    }),
    MakeKidnappingCallout({
        title = "Secuestro",
        dispatch = "~b~CENTRAL: ~w~Un sospechoso ha secuestrado a una persona.",
        arrival = "~r~Vehiculo localizado.~n~~y~Hay una victima dentro.",
        blipName = "Secuestro",
        vehicle = trafficVehicles,
        victimSeat = 0
    })
})
