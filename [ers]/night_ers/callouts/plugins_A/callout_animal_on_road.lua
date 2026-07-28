Config.Callouts["animal_on_road"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Animal Blocking the Road",
    CalloutDescriptions = {
        "An unexpected type of animal has appeared on the road, causing a disruption in traffic flow.",
        "Emergency services have been called to intervene in a situation where an animal is impeding traffic on the road.",
        "Reports indicate a disturbance on the roadway, with an unidentified creature causing a commotion.",
        "A peculiar incident has unfolded on the road, requiring immediate attention to ensure public safety.",
        "Emergency services have been dispatched to address an obstruction on the road, involving an animal.",
        "A surprising encounter has occurred on the road, with an unknown creature causing a hindrance to traffic.",
        "Witnesses report an unusual occurrence on the road, with an unidentified animal creating a hazard for motorists.",
        "An incident has occurred on the road, with an animal posing a potential threat to drivers.",
        "Emergency services have been alerted to a situation where an unidentified creature is obstructing the roadway.",
        "Reports suggest an unexpected type of animal on the road, involving an animal that requires immediate assistance.",
    },
    CalloutUnitsRequired = {
        description = "Police, animal rescue.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(2080.73, 2626.99, 52.40),
        [2] = vector3(903.23, 161.76, 74.04), 
        [3] = vector3(1113.25, 417.18, 83.67),        
        [4] = vector3(1543.74, 892.82, 77.47),    
        [5] = vector3(1614.32, 1105.89, 82.08), 
        [6] = vector3(2052.10, 2595.61, 53.69),
        [7] = vector3(2236.29, 2788.25, 44.15), 
        [8] = vector3(2853.91, 3515.08, 54.34), 
        [9] = vector3(2859.30, 3601.57, 52.95), 
        [10] = vector3(2878.75, 4194.57, 50.14), 
        [11] = vector3(2775.87, 4404.12, 48.96), 
        [12] = vector3(2649.70, 5079.81, 44.83), 
        [13] = vector3(2114.19, 6027.16, 50.92), 
        [14] = vector3(1528.76, 6442.59, 23.29), 
        [15] = vector3(8900.44, 6471.33, 31.35), 
        [16] = vector3(-176.06, 6199.81, 31.19), 
        [17] = vector3(-477.35, 5862.80, 33.60),
        [18] = vector3(-1189.78, 5261.50, 52.16), 
        [19] = vector3(-2015.21, 4496.73, 57.07), 
        [20] = vector3(-2241.45, 4260.30, 45.70),     
        [21] = vector3(-2474.10, 3637.44, 13.92),   
        [22] = vector3(-2631.86, 2855.54, 16.70),   
        [23] = vector3(-2707.72, 2295.90, 18.40),   
        [24] = vector3(-3096.80, 1315.54, 20.22),   
        [25] = vector3(-2988.84, 374.60, 14.79),   
        [26] = vector3(-2553.09, -164.87, 20.33),   
        [27] = vector3(-2164.92, -343.06, 13.19),   
        [28] = vector3(-1821.37, -608.59, 11.26),   
        [29] = vector3(-926.08, -564.75, 18.87),   
        [30] = vector3(-887.70, -512.39, 21.50),  
        [31] = vector3(-471.13, -528.49, 25.33),  
        [32] = vector3(-146.59, -492.57, 29.13),  
        [33] = vector3(290.05, -522.58, 34.08),  
        [34] = vector3(-739.99, -1160.85, 10.67),  
        [35] = vector3(1112.01, -2084.58, 38.69),  
        [36] = vector3(1012.97, -900.33, 30.53),  
        [37] = vector3(1291.97, -645.74, 67.81),  
        [38] = vector3(1092.31, 758.75, 152.95),  
        [39] = vector3(239.35, 1337.28, 238.19),  
        [40] = vector3(-637.12, 1752.96, 210.16),  
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

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                ClearPedTasks(ped)

                if Config.Debug then
                    print("Found animal entity: "..ped)
                end

                TaskWanderStandard(ped, 10.0, 10)
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000)
        --ERS_PerformTimedActionOnPed(calloutDataClient, pedList)

    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        local diameter = 20

        local randomAmountOfAnimals = math.random(1, 8)
        local randomAnimalPedModel = ERS_GetRandomModel(Config.calloutAnimals)
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