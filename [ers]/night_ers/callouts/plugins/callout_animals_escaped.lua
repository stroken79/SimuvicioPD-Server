Config.Callouts["animals_escaped"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Escaped farm animals",
    CalloutDescriptions = {
        "Emergency: respond to reports of Escaped farm animals; ensure the safety of people and animals in the area.",
        "Urgent alert: dispatch units to corral Escaped farm animals; prevent them from causing accidents or damage.",
        "Critical response required: attend to reports of Escaped farm animals; secure the area and prevent them from wandering further.",
        "Notice: check reports of Escaped farm animals; implement measures to safely return them to their enclosure.",
        "Alert: respond promptly to reports of Escaped farm animals; prioritize the safety of both the farm animals and the public.",
        "Incident reported: investigate Escaped farm animals sightings; coordinate with local authorities and farmers to manage the situation.",
        "Immediate action: address reports of Escaped farm animals; use appropriate methods to round them up and ensure their safety.",
        "Situation alert: assist with corralling Escaped farm animals; ensure the area is safe and the farm animals are unharmed.",
        "Emergency response: handle reports of Escaped farm animals and follow protocols to safely capture and return them.",
        "Response needed: investigate reports of Escaped farm animals urgently; take appropriate actions to prevent harm and secure the animals.",
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
        [2] = vector3(1466.7488, 992.6075, 114.9633),
        [3] = vector3(1499.7604, 1483.1517, 105.4204),
        [4] = vector3(1517.8981, 1748.6394, 109.8674),
        [5] = vector3(235.0015, 2621.3835, 46.2649),
        [6] = vector3(2559.9636, 4217.8853, 41.0057),
        [7] = vector3(2681.3750, 4837.1987, 33.4963),
        [8] = vector3(2231.8330, 5172.8379, 59.2566),
        [9] = vector3(-458.1834, 5884.9546, 32.9752),
        [10] = vector3(1484.6155, 4508.0635, 52.6044),
        [11] = vector3(2527.8472, 4688.5127, 33.6504),
        [12] = vector3(2695.5269, 4217.3936, 43.5792),
        [13] = vector3(641.7357, 1772.3513, 194.4283),
        [14] = vector3(-62.1715, 1856.3737, 200.6837),
        [15] = vector3(-2177.8003, -385.5692, 13.2969),
        [16] = vector3(1981.4440, 4971.6411, 42.1647),
        [17] = vector3(2244.5688, 5189.4077, 60.3518),
        [18] = vector3(2838.7747, 4742.7949, 47.9336),
        [19] = vector3(2986.2134, 4558.3813, 51.6006),
        [20] = vector3(895.3198, 294.8879, 87.3205),
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

        local randomAmountOfAnimals = math.random(1, 8)
        local randomAnimalPedModel = ERS_GetRandomModel(Config.cattleAnimals)
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