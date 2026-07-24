print("^2[BEACH CALLOUTS] Modulo cargado correctamente^7")

local pedModels = {
    "a_m_m_beach_01",
    "a_m_m_beach_02",
    "a_m_y_beach_01",
    "a_m_y_beach_02",
    "a_m_y_beach_03",
    "a_f_m_beach_01",
    "a_f_y_beach_01",
    "a_f_y_topless_01",
    "a_m_y_musclbeac_01",
    "a_m_y_surfer_01"
}

local boatModels = {
    "dinghy",
    "jetmax",
    "speeder",
    "speeder2",
    "squalo",
    "suntrap",
    "toro",
    "tropic",
    "tropic2"
}

local locations = {
    activeShooter = { vector3(-1688.40, -1059.91, 13.06) },
    boatAshore = {
        vector3(-1576.69, -1221.67, 1.46),
        vector3(-1435.31, -1554.30, 1.51),
        vector3(-1767.66, -1014.86, 1.93)
    },
    drugDeal = {
        vector3(-1514.22, -1481.80, 2.22),
        vector3(-1247.45, -1512.56, 4.29),
        vector3(-1848.30, -1230.20, 13.02)
    },
    drunkPerson = {
        vector3(-1646.12, -1115.24, 13.03),
        vector3(-1325.32, -1535.14, 4.33),
        vector3(-2165.49, -463.56, 2.46)
    },
    fight = {
        vector3(-1464.61, -1471.88, 2.15),
        vector3(-1290.43, -1759.80, 2.15),
        vector3(-1453.23, -991.82, 6.20)
    },
    fireworks = {
        vector3(-1862.58, -1215.34, 13.02),
        vector3(-1821.02, -865.41, 3.88),
        vector3(-1219.98, -1657.79, 4.18)
    },
    robbery = {
        vector3(-1291.22, -1613.01, 4.10),
        vector3(-1553.91, -913.50, 9.15),
        vector3(-2020.81, -469.62, 11.47)
    }
}

local function Pick(value)
    return value[math.random(1, #value)]
end

local function PickLocation(list)
    return Pick(list), math.random(0, 359) + 0.0, {}
end

local function LoadModel(modelName)
    local model = joaat(modelName)

    RequestModel(model)

    while not HasModelLoaded(model) do
        Wait(50)
    end

    return model
end

local function SpawnPed(runtime, coords, heading, options)
    options = options or {}

    local model = LoadModel(options.model or Pick(pedModels))
    local ped = CreatePed(4, model, coords.x, coords.y, coords.z, heading, true, true)

    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, false)
    SetPedFleeAttributes(ped, 0, false)
    SetPedKeepTask(ped, true)

    if options.drunk then
        SetPedIsDrunk(ped, true)
    end

    if options.dead then
        SetEntityHealth(ped, 0)
    end

    if options.weapon then
        GiveWeaponToPed(ped, joaat(options.weapon), options.ammo or 120, false, true)
    end

    SetModelAsNoLongerNeeded(model)
    runtime.trackEntity(ped)

    if options.suspect then
        runtime.addSuspect(ped)
    end

    return ped
end

local function SpawnBoat(runtime, modelName)
    local model = LoadModel(modelName)
    local boat = CreateVehicle(
        model,
        runtime.coords.x,
        runtime.coords.y,
        runtime.coords.z,
        runtime.heading,
        true,
        true
    )

    SetEntityAsMissionEntity(boat, true, true)
    SetVehicleOnGroundProperly(boat)
    SetVehicleEngineOn(boat, false, true, true)
    SetVehicleDirtLevel(boat, 6.0)
    SetModelAsNoLongerNeeded(model)
    runtime.trackEntity(boat)

    return boat
end

local function Offset(base, x, y, z)
    return vector3(base.x + x, base.y + y, base.z + (z or 0.0))
end

local function SpawnCrowd(runtime, count, options)
    local peds = {}

    for i = 1, count do
        local side = i % 2 == 0 and -1 or 1
        local distance = math.ceil(i / 2) * 1.4
        local ped = SpawnPed(
            runtime,
            Offset(runtime.coords, side * distance, math.random(-2, 2) + 0.0, 0.0),
            math.random(0, 359) + 0.0,
            options
        )

        peds[#peds + 1] = ped
        runtime.addBlip(ped, 1, options and options.blipColour or 1, options and options.blipName or "Implicado")
    end

    return peds
end

PoliceCallouts.Register({
    {
        title = "Tirador activo en el muelle",
        dispatch = "~b~CENTRAL: ~w~Informes de tirador activo en el muelle. Multiples victimas abatidas.",
        accept = "~g~Aviso aceptado.~n~~w~Dirigete al muelle con maxima precaucion.",
        arrival = "~r~Tirador activo localizado.~n~~y~Hay victimas en la zona.",
        blipName = "Tirador activo",
        blipSprite = 161,
        blipColour = 1,
        spawnRadius = 220.0,
        finishHelp = "Pulsa ~INPUT_CONTEXT~ para cerrar el aviso de tirador activo",

        prepare = function()
            return PickLocation(locations.activeShooter)
        end,

        spawn = function(runtime)
            local suspect = SpawnPed(runtime, runtime.coords, runtime.heading, {
                suspect = true,
                weapon = "WEAPON_ASSAULTRIFLE"
            })

            runtime.addBlip(suspect, 1, 1, "Tirador")

            for i = 1, 5 do
                local victim = SpawnPed(runtime, Offset(runtime.coords, i - 3, math.random(-3, 3), 0.0), 0.0, {
                    dead = true
                })

                runtime.addBlip(victim, 280, 3, "Victima")
            end

            TaskShootAtEntity(suspect, PlayerPedId(), -1, joaat("FIRING_PATTERN_FULL_AUTO"))
        end
    },
    {
        title = "Embarcacion varada",
        dispatch = "~b~CENTRAL: ~w~Una embarcacion ha encallado en la playa.",
        accept = "~g~Aviso aceptado.~n~~w~Dirigete a la costa indicada.",
        arrival = "~b~CENTRAL: ~w~Embarcacion localizada.~n~~y~Comprueba a los ocupantes.",
        blipName = "Embarcacion varada",
        blipSprite = 427,
        blipColour = 5,
        spawnRadius = 150.0,
        finishHelp = "Pulsa ~INPUT_CONTEXT~ para cerrar el aviso de embarcacion",

        prepare = function()
            return PickLocation(locations.boatAshore)
        end,

        spawn = function(runtime)
            local boat = SpawnBoat(runtime, Pick(boatModels))
            local driver = SpawnPed(runtime, Offset(runtime.coords, 2.0, 0.0, 0.0), runtime.heading, {
                drunk = true,
                suspect = true
            })
            local passenger = SpawnPed(runtime, Offset(runtime.coords, 1.0, 1.0, 0.0), runtime.heading, {
                suspect = true,
                weapon = "WEAPON_PISTOL",
                ammo = 20
            })

            TaskWanderStandard(driver, 10.0, 10)
            TaskSmartFleePed(passenger, PlayerPedId(), 80.0, 30000, false, false)
            runtime.addBlip(boat, 427, 5, "Embarcacion varada")
            runtime.addBlip(driver, 1, 5, "Ocupante")
            runtime.addBlip(passenger, 1, 1, "Ocupante armado")
        end
    },
    {
        title = "Venta de drogas en la playa",
        dispatch = "~b~CENTRAL: ~w~Dos personas han sido vistas vendiendo drogas en la playa.",
        accept = "~g~Aviso aceptado.~n~~w~Dirigete a la zona indicada.",
        arrival = "~b~CENTRAL: ~w~Sospechosos localizados.~n~~y~Pueden intentar huir.",
        blipName = "Venta de drogas",
        blipSprite = 51,
        blipColour = 1,
        spawnRadius = 160.0,
        finishHelp = "Pulsa ~INPUT_CONTEXT~ para cerrar el aviso de drogas",

        prepare = function()
            return PickLocation(locations.drugDeal)
        end,

        spawn = function(runtime)
            local suspect1 = SpawnPed(runtime, runtime.coords, runtime.heading, {
                suspect = true,
                drunk = true
            })
            local suspect2 = SpawnPed(runtime, Offset(runtime.coords, 1.5, 0.0, 0.0), runtime.heading, {
                suspect = true,
                drunk = true
            })

            runtime.addBlip(suspect1, 1, 1, "Sospechoso")
            runtime.addBlip(suspect2, 1, 1, "Sospechoso")

            local roll = math.random(1, 100)

            if roll <= 40 then
                GiveWeaponToPed(suspect2, joaat("WEAPON_PISTOL"), 40, false, true)
                TaskSmartFleePed(suspect1, PlayerPedId(), 120.0, 30000, false, false)
                TaskShootAtEntity(suspect2, PlayerPedId(), -1, joaat("FIRING_PATTERN_FULL_AUTO"))
            elseif roll <= 65 then
                TaskSmartFleePed(suspect1, PlayerPedId(), 120.0, 30000, false, false)
                TaskSmartFleePed(suspect2, PlayerPedId(), 120.0, 30000, false, false)
            else
                TaskHandsUp(suspect1, 100000, PlayerPedId(), -1, true)
                TaskSmartFleePed(suspect2, PlayerPedId(), 120.0, 30000, false, false)
            end
        end
    },
    {
        title = "Persona ebria causando problemas",
        dispatch = "~b~CENTRAL: ~w~Varias personas ebrias estan causando problemas en la playa.",
        accept = "~g~Aviso aceptado.~n~~w~Dirigete a la zona indicada.",
        arrival = "~b~CENTRAL: ~w~Personas ebrias localizadas.",
        blipName = "Personas ebrias",
        blipSprite = 1,
        blipColour = 5,
        spawnRadius = 160.0,
        finishHelp = "Pulsa ~INPUT_CONTEXT~ para cerrar el aviso de personas ebrias",

        prepare = function()
            return PickLocation(locations.drunkPerson)
        end,

        spawn = function(runtime)
            local suspect1 = SpawnPed(runtime, runtime.coords, runtime.heading, {
                suspect = true,
                drunk = true
            })
            local suspect2 = SpawnPed(runtime, Offset(runtime.coords, 1.4, 0.0, 0.0), runtime.heading, {
                suspect = true,
                drunk = true
            })

            TaskWanderStandard(suspect1, 10.0, 10)
            TaskWanderStandard(suspect2, 10.0, 10)
            TaskSmartFleePed(suspect1, PlayerPedId(), 90.0, 20000, false, false)

            runtime.addBlip(suspect1, 1, 5, "Persona ebria")
            runtime.addBlip(suspect2, 1, 5, "Persona ebria")
        end
    },
    {
        title = "Pelea multitudinaria en la playa",
        dispatch = "~b~CENTRAL: ~w~Pelea multitudinaria en curso en la playa.",
        accept = "~g~Aviso aceptado.~n~~w~Dirigete a la zona indicada.",
        arrival = "~r~Pelea localizada.~n~~y~Hay varios implicados.",
        blipName = "Pelea en la playa",
        blipSprite = 1,
        blipColour = 1,
        spawnRadius = 160.0,
        finishHelp = "Pulsa ~INPUT_CONTEXT~ para cerrar el aviso de pelea",

        prepare = function()
            return PickLocation(locations.fight)
        end,

        spawn = function(runtime)
            local peds = SpawnCrowd(runtime, 8, {
                suspect = true,
                blipColour = 1,
                blipName = "Implicado"
            })

            for i = 1, #peds do
                local target = peds[i + 1] or peds[1]
                TaskCombatPed(peds[i], target, 0, 16)
            end
        end
    },
    {
        title = "Grupo lanzando fuegos artificiales",
        dispatch = "~b~CENTRAL: ~w~Un grupo esta lanzando fuegos artificiales en la playa.",
        accept = "~g~Aviso aceptado.~n~~w~Dirigete a la zona indicada.",
        arrival = "~b~CENTRAL: ~w~Grupo localizado.~n~~y~Pueden dispersarse.",
        blipName = "Fuegos artificiales",
        blipSprite = 1,
        blipColour = 5,
        spawnRadius = 220.0,
        finishHelp = "Pulsa ~INPUT_CONTEXT~ para cerrar el aviso de fuegos artificiales",

        prepare = function()
            return PickLocation(locations.fireworks)
        end,

        spawn = function(runtime)
            local peds = SpawnCrowd(runtime, 8, {
                suspect = true,
                weapon = "WEAPON_FIREWORK",
                ammo = 25,
                blipColour = 5,
                blipName = "Implicado"
            })

            CreateThread(function()
                Wait(8000)

                if not peds[1] or not DoesEntityExist(peds[1]) then
                    return
                end

                local roll = math.random(1, 100)

                if roll <= 10 then
                    for _, ped in ipairs(peds) do
                        if DoesEntityExist(ped) then
                            TaskShootAtCoord(ped, runtime.coords.x, runtime.coords.y + 30.0, runtime.coords.z + 35.0, 5000, joaat("FIRING_PATTERN_SINGLE_SHOT"))
                        end
                    end
                elseif roll <= 65 then
                    for _, ped in ipairs(peds) do
                        if DoesEntityExist(ped) then
                            TaskSmartFleePed(ped, PlayerPedId(), 150.0, 30000, false, false)
                        end
                    end
                else
                    for i, ped in ipairs(peds) do
                        if DoesEntityExist(ped) then
                            if i <= 4 then
                                TaskSmartFleePed(ped, PlayerPedId(), 150.0, 30000, false, false)
                            else
                                TaskCombatPed(ped, PlayerPedId(), 0, 16)
                            end
                        end
                    end
                end
            end)
        end
    },
    {
        title = "Robo en la playa",
        dispatch = "~b~CENTRAL: ~w~Una persona esta siendo robada en la playa.",
        accept = "~g~Aviso aceptado.~n~~w~Dirigete a la zona indicada.",
        arrival = "~r~Robo localizado.~n~~y~El sospechoso puede ir armado.",
        blipName = "Robo en la playa",
        blipSprite = 1,
        blipColour = 1,
        spawnRadius = 160.0,
        finishHelp = "Pulsa ~INPUT_CONTEXT~ para cerrar el aviso de robo",

        prepare = function()
            return PickLocation(locations.robbery)
        end,

        spawn = function(runtime)
            local victim = SpawnPed(runtime, Offset(runtime.coords, 1.4, 0.0, 0.0), runtime.heading, {})
            local suspect = SpawnPed(runtime, runtime.coords, runtime.heading, {
                suspect = true
            })

            runtime.addBlip(victim, 1, 3, "Victima")
            runtime.addBlip(suspect, 1, 1, "Sospechoso")

            TaskSmartFleePed(victim, suspect, 80.0, 30000, false, false)

            local roll = math.random(1, 100)

            if roll <= 40 then
                GiveWeaponToPed(suspect, joaat("WEAPON_HAMMER"), 1, false, true)
                TaskCombatPed(suspect, victim, 0, 16)
            elseif roll <= 65 then
                GiveWeaponToPed(suspect, joaat("WEAPON_PISTOL"), 40, false, true)
                TaskCombatPed(suspect, PlayerPedId(), 0, 16)
            else
                GiveWeaponToPed(suspect, joaat("WEAPON_KNIFE"), 1, false, true)
                TaskCombatPed(suspect, victim, 0, 16)

                CreateThread(function()
                    Wait(12000)

                    if DoesEntityExist(suspect) and not IsEntityDead(suspect) then
                        TaskCombatPed(suspect, PlayerPedId(), 0, 16)
                    end
                end)
            end
        end
    }
})
