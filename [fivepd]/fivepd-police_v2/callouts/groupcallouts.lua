print("^2[GROUP CALLOUTS] Modulo cargado correctamente^7")

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

local meleeWeapons = {
    "WEAPON_BOTTLE",
    "WEAPON_CROWBAR",
    "WEAPON_GOLFCLUB"
}

local gunWeapons = {
    "WEAPON_PISTOL",
    "WEAPON_COMBATPISTOL",
    "WEAPON_APPISTOL"
}

local function Pick(value)
    return value[math.random(1, #value)]
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

local function Offset(base, x, y, z)
    return vector3(base.x + x, base.y + y, base.z + (z or 0.0))
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
        GiveWeaponToPed(ped, joaat(options.weapon), options.ammo or 1, false, true)
    end

    SetModelAsNoLongerNeeded(model)
    runtime.trackEntity(ped)

    if options.suspect then
        runtime.addSuspect(ped)
    end

    return ped
end

local function SpawnGroup(runtime, count, options)
    local peds = {}

    for i = 1, count do
        local side = i % 2 == 0 and -1 or 1
        local distance = math.ceil(i / 2) * 1.5
        local ped = SpawnPed(
            runtime,
            Offset(runtime.coords, side * distance, math.random(-2, 2) + 0.0, 0.0),
            math.random(0, 359) + 0.0,
            options
        )

        peds[#peds + 1] = ped
        runtime.addBlip(ped, 1, options.blipColour or 1, options.blipName or "Implicado")
    end

    return peds
end

PoliceCallouts.Register({
    {
        title = "Ataque grupal a civil",
        dispatch = "~b~CENTRAL: ~w~Tres sospechosos armados estan atacando a un civil.",
        accept = "~g~Aviso aceptado.~n~~w~Dirigete al punto indicado.",
        arrival = "~r~Ataque localizado.~n~~y~Protege a la victima y controla a los sospechosos.",
        blipName = "Ataque grupal",
        blipSprite = 161,
        blipColour = 1,
        spawnRadius = 120.0,
        finishHelp = "Pulsa ~INPUT_CONTEXT~ para cerrar el aviso de ataque grupal",

        prepare = RandomRoad,

        spawn = function(runtime)
            local victim = SpawnPed(runtime, runtime.coords, runtime.heading, {})
            local suspects = {}

            for i = 1, 3 do
                local suspect = SpawnPed(
                    runtime,
                    Offset(runtime.coords, i * 1.5, math.random(-1, 1) + 0.0, 0.0),
                    runtime.heading,
                    {
                        suspect = true,
                        weapon = meleeWeapons[i],
                        ammo = 1
                    }
                )

                suspects[#suspects + 1] = suspect
                runtime.addBlip(suspect, 1, 1, "Agresor")
                TaskCombatPed(suspect, victim, 0, 16)
            end

            runtime.addBlip(victim, 1, 3, "Victima")
            TaskSmartFleePed(victim, suspects[1], 100.0, 30000, false, false)
        end
    },
    {
        title = "Tiroteo grupal",
        dispatch = "~b~CENTRAL: ~w~Cuatro individuos armados se estan disparando entre ellos.",
        accept = "~g~Aviso aceptado.~n~~w~Dirigete al punto indicado.",
        arrival = "~r~Tiroteo localizado.~n~~y~Mantente a cubierto.",
        blipName = "Tiroteo grupal",
        blipSprite = 161,
        blipColour = 1,
        spawnRadius = 120.0,
        finishHelp = "Pulsa ~INPUT_CONTEXT~ para cerrar el aviso de tiroteo",

        prepare = RandomRoad,

        spawn = function(runtime)
            local peds = {}

            for i = 1, 4 do
                local ped = SpawnPed(
                    runtime,
                    Offset(runtime.coords, i * 4.0, math.random(-3, 3) + 0.0, 0.0),
                    runtime.heading,
                    {
                        suspect = true,
                        weapon = Pick(gunWeapons),
                        ammo = 60
                    }
                )

                peds[#peds + 1] = ped
                runtime.addBlip(ped, 1, 1, "Sospechoso armado")
            end

            for i = 1, #peds do
                local target = peds[i + 1] or peds[1]
                TaskCombatPed(peds[i], target, 0, 16)
            end
        end
    },
    {
        title = "Pelea grupal",
        dispatch = "~b~CENTRAL: ~w~Diez personas se estan peleando entre ellas.",
        accept = "~g~Aviso aceptado.~n~~w~Dirigete al punto indicado.",
        arrival = "~r~Pelea grupal localizada.~n~~y~Hay muchos implicados.",
        blipName = "Pelea grupal",
        blipSprite = 161,
        blipColour = 1,
        spawnRadius = 120.0,
        finishHelp = "Pulsa ~INPUT_CONTEXT~ para cerrar el aviso de pelea grupal",

        prepare = RandomRoad,

        spawn = function(runtime)
            local peds = SpawnGroup(runtime, 10, {
                suspect = true,
                blipColour = 1,
                blipName = "Implicado"
            })

            for i = 1, #peds do
                local target = peds[i + 1] or peds[1]
                TaskCombatPed(peds[i], target, 0, 16)
            end
        end
    }
})
