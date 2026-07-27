print("^2[ANIMAL CALLOUTS] Modulo cargado correctamente^7")

local civilianModels = {
    "a_m_m_business_01",
    "a_m_m_eastsa_01",
    "a_m_m_skater_01",
    "a_m_y_business_02",
    "a_m_y_hipster_01",
    "a_f_y_business_01",
    "a_f_y_hipster_02",
    "a_f_y_tourist_01"
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

local function RandomStreet()
    local playerCoords = GetEntityCoords(PlayerPedId())

    for _ = 1, 30 do
        local offsetX = math.random(100, 700) + 0.0
        local offsetY = math.random(100, 700) + 0.0
        local found, nodeCoords, nodeHeading =
            GetClosestVehicleNodeWithHeading(
                playerCoords.x + offsetX,
                playerCoords.y + offsetY,
                playerCoords.z,
                1,
                3.0,
                0
            )

        if found and nodeCoords then
            return nodeCoords, nodeHeading or 0.0
        end
    end

    return vector3(playerCoords.x + 300.0, playerCoords.y + 300.0, playerCoords.z), 0.0
end

local function Offset(base, x, y, z)
    return vector3(base.x + x, base.y + y, base.z + (z or 0.0))
end

local function SpawnPed(runtime, modelName, spawnCoords, heading, options)
    options = options or {}

    local model = LoadModel(modelName)
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
    SetBlockingOfNonTemporaryEvents(ped, options.blockEvents == true)
    SetPedFleeAttributes(ped, 0, false)
    SetPedKeepTask(ped, true)

    if options.animal then
        SetPedCombatAttributes(ped, 46, true)
        SetPedCombatAbility(ped, 2)
        SetPedCombatMovement(ped, 2)
        SetPedCombatRange(ped, 1)
        SetPedAccuracy(ped, 65)
        SetAnimalMood(ped, 1)
    end

    SetModelAsNoLongerNeeded(model)
    runtime.trackEntity(ped)

    if options.suspect then
        runtime.addSuspect(ped)
    end

    return ped
end

local function SpawnCivilian(runtime, spawnCoords, heading)
    return SpawnPed(runtime, Pick(civilianModels), spawnCoords, heading, {
        blockEvents = true
    })
end

local function SpawnAnimal(runtime, modelName, spawnCoords, heading)
    return SpawnPed(runtime, modelName, spawnCoords, heading, {
        animal = true,
        blockEvents = true,
        suspect = true
    })
end

PoliceCallouts.Register({
    {
        title = "Ataque de puma",
        dispatch = "~b~CENTRAL: ~r~Una persona esta siendo atacada por un puma. Responde en codigo 3.",
        accept = "~g~Aviso aceptado.~n~~w~Dirigete a la ubicacion indicada.",
        arrival = "~r~Ataque localizado.~n~~y~Protege a la victima y controla al animal.",
        blipName = "Ataque de puma",
        blipSprite = 9,
        blipColour = 1,
        spawnRadius = 150.0,
        finishHelp = "Pulsa ~INPUT_CONTEXT~ para cerrar el aviso de ataque animal",

        prepare = function()
            local coords, heading = RandomStreet()
            return coords, heading, {}
        end,

        spawn = function(runtime)
            local animal = SpawnAnimal(runtime, "a_c_mtlion", runtime.coords, runtime.heading)
            local victim = SpawnCivilian(runtime, Offset(runtime.coords, 2.0, 1.5, 0.0), runtime.heading)

            runtime.addBlip(animal, 141, 1, "Puma")
            runtime.addBlip(victim, 1, 3, "Victima")
            runtime.notify("~r~AnimalCallouts: ~y~La victima esta siendo perseguida por un puma.")

            TaskSmartFleePed(victim, animal, 120.0, 30000, false, false)
            Wait(500)
            TaskCombatPed(animal, victim, 0, 16)
        end
    },
    {
        title = "Ataque de jauria",
        dispatch = "~b~CENTRAL: ~r~Una persona esta siendo atacada por una jauria. Responde en codigo 3.",
        accept = "~g~Aviso aceptado.~n~~w~Dirigete a la ubicacion indicada.",
        arrival = "~r~Jauria localizada.~n~~y~Protege a la victima y despeja la zona.",
        blipName = "Ataque de jauria",
        blipSprite = 9,
        blipColour = 1,
        spawnRadius = 150.0,
        finishHelp = "Pulsa ~INPUT_CONTEXT~ para cerrar el aviso de jauria",

        prepare = function()
            local coords, heading = RandomStreet()
            return coords, heading, {}
        end,

        spawn = function(runtime)
            local victim = SpawnCivilian(runtime, Offset(runtime.coords, 2.0, 1.5, 0.0), runtime.heading)
            local animals = {
                SpawnAnimal(runtime, "a_c_chop", runtime.coords, runtime.heading),
                SpawnAnimal(runtime, "a_c_chop", Offset(runtime.coords, -2.0, 1.0, 0.0), runtime.heading),
                SpawnAnimal(runtime, "a_c_chop", Offset(runtime.coords, 2.5, -1.0, 0.0), runtime.heading)
            }

            runtime.addBlip(victim, 1, 3, "Victima")

            for _, animal in ipairs(animals) do
                runtime.addBlip(animal, 141, 1, "Perro agresivo")
                TaskCombatPed(animal, victim, 0, 16)
            end

            runtime.notify("~r~AnimalCallouts: ~y~La victima esta siendo atacada por una jauria.")
            TaskSmartFleePed(victim, animals[1], 120.0, 30000, false, false)

            Wait(2000)
            TaskCombatPed(animals[3], PlayerPedId(), 0, 16)
        end
    }
})
