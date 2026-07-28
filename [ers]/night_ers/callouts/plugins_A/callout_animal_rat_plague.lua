Config.Callouts["animal_rat_plague"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Extreme rat plague",
    CalloutDescriptions = {
        "Emergency: respond to reports of an extreme rat plague; ensure the safety of residents and contain the infestation.",
        "Urgent alert: dispatch pest control units to address a severe rat infestation; prevent the spread of disease and damage.",
        "Critical response required: attend to reports of a rat plague; secure the area and implement extermination measures.",
        "Notice: check reports of a rat infestation; take immediate action to control the population and protect public health.",
        "Alert: respond promptly to reports of an extreme rat plague; prioritize the safety of the community and prevent further spread.",
        "Incident reported: investigate severe rat infestation; coordinate with pest control services to manage the situation effectively.",
        "Immediate action: address reports of a rat plague; use appropriate methods to eradicate the rats and ensure safety.",
        "Situation alert: assist with controlling an extreme rat infestation; secure the area and implement necessary measures.",
        "Emergency response: handle reports of a rat plague and follow protocols to contain and eliminate the infestation.",
        "Response needed: investigate reports of a severe rat infestation urgently; take appropriate actions to protect public health and safety.",
    },                                        
    CalloutUnitsRequired = {
        description = "Police, Animal Rescue.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(-156.5135, 1941.9556, 195.2362),
        [2] = vector3(1986.7726, 3050.1509, 47.2151),
        [3] = vector3(1714.2148, 3695.8870, 34.4959),
        [4] = vector3(3.2913, -1739.9449, 29.3052),
        [5] = vector3(-467.1143, -1707.0049, 18.8235),
        [6] = vector3(-817.2072, -1332.6687, 5.1324),
        [7] = vector3(-1004.5860, -1460.5331, 4.9887),
        [8] = vector3(-1121.3344, -1982.2427, 13.1626),
        [9] = vector3(-806.9633, -1097.7111, 10.6082),
        [10] = vector3(506.8831, 3111.2585, 40.6679),
        [11] = vector3(1960.8220, 3770.2551, 32.2001),
        [12] = vector3(2504.1604, 4080.2524, 38.6310),
        [13] = vector3(-345.4866, -1563.9071, 25.2083),
        [14] = vector3(-211.5286, 6287.9878, 31.4894),
        [15] = vector3(248.5705, 6474.3198, 30.7680),
    },               
    PedChanceToFleeFromPlayer = 0,      -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 0,        -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 0,           -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 0,       -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 0,    -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 1000, -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "none",  -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_unarmed",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)

        local coords = calloutDataClient.Coordinates 

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                ClearPedTasks(ped)

                TaskWanderInArea(ped, coords.x, coords.y, coords.z, 20.0, 5000, 10000)
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 30000)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        local diameter = 20

        local randomAmountOfAnimals = math.random(25, 50)
        local randomAnimalPedModel = "a_c_rat"
        for i = 1, randomAmountOfAnimals do
            -- Build animals of the same type.
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
            local animalPedCoords = vector3(coords.x, coords.y, coords.z)
            local animalPedHeading = math.random(360)
            local animalPedNetId = ERS_CreatePed(randomAnimalPedModel, animalPedCoords, animalPedHeading)
            local animalPed = NetworkGetEntityFromNetworkId(animalPedNetId)
            table.insert(pedList, animalPedNetId)
        end
        return true
    end
}