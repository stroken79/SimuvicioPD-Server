print("^2[HEAVY SHOOTING CALLOUTS] Modulo cargado correctamente^7")

local pedModels = {
    "a_m_m_skater_01",
    "a_m_m_soucent_01",
    "a_m_y_soucent_02",
    "a_m_y_stbla_01",
    "a_m_y_stbla_02",
    "a_m_y_stwhi_01",
    "g_m_y_ballaeast_01",
    "g_m_y_famdnf_01"
}

local heavyWeapons = {
    1119849093, -- WEAPON_MINIGUN
    1785463520,
    -608341376,
    961495388
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
        local angle = math.random() * math.pi * 2.0
        local distance = math.random(200, 450)
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

    return vector3(playerCoords.x + 220.0, playerCoords.y, playerCoords.z), 0.0
end

local function Offset(base, x, y, z)
    return vector3(base.x + x, base.y + y, base.z + (z or 0.0))
end

local function SpawnShooter(runtime, spawnCoords, heading, weaponHash, accuracy)
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
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedFleeAttributes(ped, 0, false)
    SetPedCombatAttributes(ped, 46, true)
    SetPedCombatAbility(ped, 2)
    SetPedCombatMovement(ped, 2)
    SetPedCombatRange(ped, 2)
    SetPedKeepTask(ped, true)
    SetPedArmour(ped, 100)
    SetEntityMaxHealth(ped, 300)
    SetEntityHealth(ped, 300)
    SetPedAccuracy(ped, accuracy)
    SetPedShootRate(ped, 700)

    GiveWeaponToPed(ped, weaponHash, 9999, false, true)

    SetModelAsNoLongerNeeded(model)
    runtime.trackEntity(ped)
    runtime.addSuspect(ped)

    return ped
end

PoliceCallouts.Register({
    {
        title = "Tiradores con armas pesadas",
        dispatch = "~b~CENTRAL: ~r~Cuatro tiradores con armamento pesado han sido vistos en la zona. Responde en codigo 3 alto.",
        accept = "~g~Aviso aceptado.~n~~w~Dirigete a la ubicacion indicada con extrema precaucion.",
        arrival = "~r~Tiradores localizados.~n~~y~Neutraliza la amenaza y protege la zona.",
        blipName = "Tiradores activos",
        blipSprite = 9,
        blipColour = 1,
        spawnRadius = 120.0,
        finishHelp = "Pulsa ~INPUT_CONTEXT~ para cerrar el aviso de tiradores",

        prepare = function()
            local coords, heading = RandomStreet()
            return coords, heading, {}
        end,

        spawn = function(runtime)
            local offsets = {
                vector3(0.0, 0.0, 0.0),
                vector3(4.0, 1.5, 0.0),
                vector3(-3.5, -2.0, 0.0),
                vector3(1.5, -5.0, 0.0)
            }

            local accuracies = { 50, 80, 90, 90 }
            local shooters = {}

            for i = 1, 4 do
                local spawnCoords = Offset(runtime.coords, offsets[i].x, offsets[i].y, offsets[i].z)
                local shooter = SpawnShooter(
                    runtime,
                    spawnCoords,
                    runtime.heading,
                    heavyWeapons[i],
                    accuracies[i]
                )

                shooters[#shooters + 1] = shooter
                runtime.addBlip(shooter, 1, 1, "Tirador armado")
            end

            for _, shooter in ipairs(shooters) do
                TaskCombatPed(shooter, PlayerPedId(), 0, 16)
            end
        end
    }
})
