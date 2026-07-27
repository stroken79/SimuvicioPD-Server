Config.Callouts["fire_ped"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Person on fire",
    CalloutDescriptions = {
        "A person is on fire and requires immediate intervention from emergency services.",
        "Emergency teams are needed to assist a person who has caught fire.",
        "Authorities report a person engulfed in flames, necessitating urgent action to save their life.",
        "A person has caught fire, and additional firefighting units are needed to provide critical aid.",
        "Immediate response required to save a person on fire, endangering their life and those nearby.",
        "A person is on fire, and reinforcements are needed to assist local fire services in extinguishing the flames.",
        "Fire crews are requesting backup to control a severe situation where a person is burning.",
        "An urgent call for assistance has been made to deal with a person on fire, spreading panic in the vicinity.",
        "Responders are on the scene of a person on fire and require additional support to prevent further harm.",
        "A significant emergency involving a person on fire demands immediate intervention to protect lives and prevent further injury.",
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