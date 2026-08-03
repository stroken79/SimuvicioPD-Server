Config.Callouts["fire_ped"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Person on fire",
    CalloutDescriptions = {
        "Una persona esta en llamas y requiere la intervencion inmediata de los servicios de emergencia.",
        "Se necesitan equipos de emergencia para ayudar a una persona que se ha incendiado.",
        "Las autoridades reportan una persona envuelta en llamas, por lo que es necesario actuar urgentemente para salvar su vida.",
        "Una persona se incendio y se necesitan unidades de extincion de incendios adicionales para brindar ayuda critica.",
        "Se requiere una respuesta inmediata para salvar a una persona en llamas, poniendo en peligro su vida y la de quienes se encuentran cerca.",
        "Una persona esta en llamas y se necesitan refuerzos para ayudar a los bomberos locales a extinguir las llamas.",
        "Los equipos de bomberos solicitan refuerzos para controlar una situacion grave en la que una persona se esta quemando.",
        "Se ha realizado una llamada urgente de auxilio para atender a una persona en llamas, lo que ha sembrado el panico en los alrededores.",
        "Los socorristas estan en la escena de una persona en llamas y requieren apoyo adicional para evitar danos mayores.",
        "Una emergencia importante que involucra a una persona en llamas exige una intervencion inmediata para proteger vidas y evitar mas lesiones.",
    },                                  
    CalloutUnitsRequired = {
        description = "Police, Ambulance, Fire.",
        policeRequired = true,
        ambulanceRequired = true,
        fireRequired = true,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(-1617.85, -1039.77, 5.90),
        [2] = vector3(-221.79, -1617.18, 34.87),
        [3] = vector3(461.01, -1870.48, 26.98),
        [4] = vector3(-11.17, -1428.86, 31.10),
        [5] = vector3(2663.66, 3928.24, 42.34),
        [6] = vector3(2700.45, 3083.12, 42.76),
        [7] = vector3(2632.89, 2946.15, 40.42),
        [8] = vector3(2851.14, 3440.11, 50.92),
        [9] = vector3(2453.31, 3854.30, 38.94),
        [10] = vector3(2271.27, 3757.01, 38.42),
        [11] = vector3(1820.61, 3507.98, 38.32),
        [12] = vector3(1693.80, 3461.85, 37.02),
        [13] = vector3(1184.28, 3267.64, 39.20),
        [14] = vector3(-3040.17, 3745.06, 70.20),
        [15] = vector3(-4050.71, 5335.75, 83.14),
        [16] = vector3(-4043.33, 5599.94, 68.38),
        [17] = vector3(2874.65, 4868.66, 62.60),
        [18] = vector3(3000.50, 4099.68, 57.18),
        [19] = vector3(-92.55, 6150.44, 31.80),
        -- Add more to 40
    },
    PedChanceToFleeFromPlayer = 50,     -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 50,       -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 10,          -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 50,      -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 1000, -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 5000, -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "flee",  -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_knife",
        "weapon_hatchet",
        "weapon_crowbar",
        "weapon_bat",
        "weapon_pistol",
        "weapon_minismg",
        "weapon_smg",
        "weapon_assaultrifle",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)

        local victim
        local suspectPedList = {}
        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                TaskSetBlockingOfNonTemporaryEvents(ped, true)
                if index == 1 then
                    victim = ped
                    StartEntityFire(victim)
                    ERS_ApplyBloodToPed(victim)
                elseif index == 2 then
                    table.insert(suspectPedList, PedToNet(ped))
                    ERS_SetPedToFleeFromPlayer(ped)
                else
                    TaskTurnPedToFaceEntity(ped, victim, -1)
                    Wait(1000)
                    local scenario = ERS_SelectRandomBystanderScenario()
                    TaskStartScenarioInPlace(ped, scenario, 0, true)
                end
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, suspectPedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        local diameter = 10
        
        -- Build victim
        local pedModel = ERS_GetRandomModel(Config.randomPeds)
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        table.insert(pedList, pedNetId)

        -- Build suspect & bystander(s)
        local randomAmountOfBystanders = math.random(3)
        for i = 1, randomAmountOfBystanders do
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)

            local pedModel = ERS_GetRandomModel(Config.randomPeds)
            local pedCoords = vector3(coords.x, coords.y, coords.z)
            local pedHeading = math.random(360)
            local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
            local ped = NetworkGetEntityFromNetworkId(pedNetId)
            table.insert(pedList, pedNetId)
        end

        return true
    end
}