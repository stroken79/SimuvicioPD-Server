print("^2[WILDERNESS CALLOUTS] Modulo cargado correctamente^7")

local pedModels = {
    "a_m_m_hillbilly_01",
    "a_m_m_hillbilly_02",
    "a_m_m_tramp_01",
    "a_m_y_hiker_01",
    "a_f_y_hiker_01",
    "a_m_y_hippy_01",
    "a_f_y_hippie_01",
    "a_m_m_farmer_01"
}

local locations = {
    cultHostage = { vector3(-1114.12, 4923.71, 217.97) },
    hikerStuck = {
        vector3(-765.13, 4342.06, 146.31),
        vector3(-789.05, 4546.31, 114.62)
    },
    hikerAttacked = {
        vector3(-589.33, 5067.92, 135.29),
        vector3(-571.75, 4920.47, 169.62),
        vector3(-1022.15, 4715.98, 240.98)
    },
    deadBody = {
        vector3(449.10, 5513.02, 755.49),
        vector3(1200.55, 5782.78, 519.18),
        vector3(2042.01, 5378.45, 172.68)
    },
    weedFarm = { vector3(2209.90, 5613.07, 53.87) }
}

local cultWeapons = {
    "WEAPON_SMG",
    "WEAPON_REVOLVER",
    "WEAPON_FIREWORK",
    "WEAPON_MUSKET",
    "WEAPON_ASSAULTRIFLE",
    "WEAPON_CARBINERIFLE",
    "WEAPON_HEAVYSNIPER",
    "WEAPON_KNIFE"
}

local farmWeapons = {
    "WEAPON_SMG",
    "WEAPON_REVOLVER",
    "WEAPON_FIREWORK",
    "WEAPON_MUSKET"
}

local function Pick(list)
    return list[math.random(1, #list)]
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

local function Offset(base, x, y, z)
    return vector3(base.x + x, base.y + y, base.z + (z or 0.0))
end

local function SpawnPed(runtime, spawnCoords, heading, options)
    options = options or {}

    local model = LoadModel(options.model or Pick(pedModels))
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
        GiveWeaponToPed(ped, joaat(options.weapon), options.ammo or 120, false, true)
    end

    if options.dead then
        SetEntityHealth(ped, 0)
    end

    SetModelAsNoLongerNeeded(model)
    runtime.trackEntity(ped)

    if options.suspect then
        runtime.addSuspect(ped)
    end

    return ped
end

PoliceCallouts.Register({
    {
        title = "Secta con rehenes",
        dispatch = "~b~CENTRAL: ~w~Una secta retiene a cuatro personas como rehenes en el monte.",
        accept = "~g~Aviso aceptado.~n~~w~Dirigete a la ubicacion indicada.",
        arrival = "~r~Campamento localizado.~n~~y~Sospechosos fuertemente armados con rehenes.",
        blipName = "Secta con rehenes",
        blipSprite = 161,
        blipColour = 1,
        spawnRadius = 220.0,
        finishHelp = "Pulsa ~INPUT_CONTEXT~ para cerrar el aviso de rehenes",

        prepare = function()
            return PickLocation(locations.cultHostage)
        end,

        spawn = function(runtime)
            local suspects = {}
            local hostages = {}

            for i = 1, 10 do
                local suspect = SpawnPed(
                    runtime,
                    Offset(runtime.coords, math.random(-5, 8) + 0.0, math.random(-5, 5) + 0.0, 0.0),
                    math.random(0, 359) + 0.0,
                    {
                        suspect = true,
                        weapon = Pick(cultWeapons),
                        ammo = 130
                    }
                )

                suspects[#suspects + 1] = suspect
                runtime.addBlip(suspect, 1, 1, "Sectario armado")
            end

            for i = 1, 4 do
                local hostage = SpawnPed(
                    runtime,
                    Offset(runtime.coords, i * 1.2, -2.0, 0.0),
                    runtime.heading,
                    {}
                )

                hostages[#hostages + 1] = hostage
                runtime.addBlip(hostage, 1, 3, "Rehen")
                TaskHandsUp(hostage, 1000000, PlayerPedId(), -1, true)
                TaskSmartFleePed(hostage, suspects[math.min(i, #suspects)], 120.0, 30000, false, false)
            end

            for _, suspect in ipairs(suspects) do
                TaskCombatPed(suspect, PlayerPedId(), 0, 16)
            end
        end
    },
    {
        title = "Senderista atrapado",
        dispatch = "~b~CENTRAL: ~w~Un senderista esta atrapado y necesita ayuda.",
        accept = "~g~Aviso aceptado.~n~~w~Dirigete a la ubicacion indicada.",
        arrival = "~b~CENTRAL: ~w~Senderista localizado.~n~~y~Comprueba su estado.",
        blipName = "Senderista atrapado",
        blipSprite = 280,
        blipColour = 5,
        spawnRadius = 180.0,
        finishHelp = "Pulsa ~INPUT_CONTEXT~ para cerrar el aviso del senderista",

        prepare = function()
            return PickLocation(locations.hikerStuck)
        end,

        spawn = function(runtime)
            local hiker = SpawnPed(runtime, runtime.coords, runtime.heading, {})
            runtime.addBlip(hiker, 1, 5, "Senderista")

            local roll = math.random(1, 100)

            if roll <= 40 then
                TaskStandStill(hiker, -1)
            elseif roll <= 65 then
                TaskSmartFleePed(hiker, PlayerPedId(), 80.0, 20000, false, false)
            else
                GiveWeaponToPed(hiker, joaat("WEAPON_PISTOL"), 100, false, true)
                runtime.addSuspect(hiker)
                TaskCombatPed(hiker, PlayerPedId(), 0, 16)
            end
        end
    },
    {
        title = "Senderista atacado",
        dispatch = "~b~CENTRAL: ~w~Un senderista esta siendo atacado por un desconocido.",
        accept = "~g~Aviso aceptado.~n~~w~Dirigete a la ubicacion indicada.",
        arrival = "~r~Ataque localizado.~n~~y~Protege a la victima.",
        blipName = "Senderista atacado",
        blipSprite = 161,
        blipColour = 1,
        spawnRadius = 180.0,
        finishHelp = "Pulsa ~INPUT_CONTEXT~ para cerrar el aviso de ataque",

        prepare = function()
            return PickLocation(locations.hikerAttacked)
        end,

        spawn = function(runtime)
            local victim = SpawnPed(runtime, runtime.coords, runtime.heading, {})
            local suspect = SpawnPed(runtime, Offset(runtime.coords, 1.5, 0.0, 0.0), runtime.heading, {
                suspect = true
            })

            runtime.addBlip(victim, 1, 3, "Victima")
            runtime.addBlip(suspect, 1, 1, "Sospechoso")
            TaskSmartFleePed(victim, suspect, 100.0, 30000, false, false)

            local roll = math.random(1, 100)

            if roll <= 40 then
                GiveWeaponToPed(suspect, joaat("WEAPON_NIGHTSTICK"), 1, false, true)
                TaskCombatPed(suspect, victim, 0, 16)
            elseif roll <= 65 then
                GiveWeaponToPed(suspect, joaat("WEAPON_KNIFE"), 1, false, true)
                TaskCombatPed(suspect, PlayerPedId(), 0, 16)
            else
                GiveWeaponToPed(suspect, joaat("WEAPON_PISTOL"), 100, false, true)
                TaskCombatPed(suspect, PlayerPedId(), 0, 16)
            end
        end
    },
    {
        title = "Cadaver encontrado en sendero",
        dispatch = "~b~CENTRAL: ~w~Se ha encontrado un cadaver en un sendero.",
        accept = "~g~Aviso aceptado.~n~~w~Dirigete a la ubicacion indicada.",
        arrival = "~b~CENTRAL: ~w~Cadaver localizado.~n~~y~Asegura la escena.",
        blipName = "Cadaver en sendero",
        blipSprite = 280,
        blipColour = 3,
        spawnRadius = 180.0,
        finishHelp = "Pulsa ~INPUT_CONTEXT~ para cerrar el aviso de cadaver",

        prepare = function()
            return PickLocation(locations.deadBody)
        end,

        spawn = function(runtime)
            local victim = SpawnPed(runtime, runtime.coords, runtime.heading, {
                dead = true
            })

            runtime.addBlip(victim, 280, 3, "Cadaver")
        end
    },
    {
        title = "Plantacion de marihuana",
        dispatch = "~b~CENTRAL: ~w~Posible plantacion de marihuana localizada.",
        accept = "~g~Aviso aceptado.~n~~w~Dirigete a la ubicacion indicada.",
        arrival = "~r~Plantacion localizada.~n~~y~Hay varios sospechosos armados.",
        blipName = "Plantacion",
        blipSprite = 140,
        blipColour = 2,
        spawnRadius = 180.0,
        finishHelp = "Pulsa ~INPUT_CONTEXT~ para cerrar el aviso de plantacion",

        prepare = function()
            return PickLocation(locations.weedFarm)
        end,

        spawn = function(runtime)
            local suspects = {}

            for i = 1, 4 do
                local suspect = SpawnPed(
                    runtime,
                    Offset(runtime.coords, math.random(-4, 4) + 0.0, math.random(-4, 4) + 0.0, 0.0),
                    math.random(0, 359) + 0.0,
                    {
                        suspect = true,
                        weapon = farmWeapons[i],
                        ammo = 130
                    }
                )

                suspects[#suspects + 1] = suspect
                runtime.addBlip(suspect, 1, 1, "Sospechoso")
            end

            local roll = math.random(1, 100)

            if roll <= 40 then
                for _, suspect in ipairs(suspects) do
                    TaskCombatPed(suspect, PlayerPedId(), 0, 16)
                end
            elseif roll <= 65 then
                for _, suspect in ipairs(suspects) do
                    TaskSmartFleePed(suspect, PlayerPedId(), 180.0, 30000, false, false)
                end
            else
                for i, suspect in ipairs(suspects) do
                    if i <= 2 then
                        TaskCombatPed(suspect, PlayerPedId(), 0, 16)
                    else
                        TaskSmartFleePed(suspect, PlayerPedId(), 180.0, 30000, false, false)
                    end
                end
            end
        end
    }
})
