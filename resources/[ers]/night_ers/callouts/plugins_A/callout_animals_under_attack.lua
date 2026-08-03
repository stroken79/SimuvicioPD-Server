Config.Callouts["animals_under_attack"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Farm animals under attack by wild animals",
    CalloutDescriptions = {
        "Emergency: respond immediately to reports of Farm animals being attacked by wild animals; ensure the safety of the herd.",
        "Urgent alert: dispatch units to the location where Farm animals are under attack; protect the livestock and manage the threat.",
        "Critical response: attend to an incident involving Farm animals being attacked; prioritize safeguarding the animals and mitigating the danger.",
        "Immediate action: investigate reports of wild animals attacking Farm animals; secure the area and protect the herd.",
        "Alert: respond to a situation where Farm animals are being attacked by animals; take necessary measures to ensure their safety.",
        "Incident reported: handle reports of livestock under attack; coordinate with local authorities and animal control to manage the situation.",
        "Situation alert: assist in protecting Farm animals from an animal attack; ensure the safety of the livestock and contain the threat.",
        "Emergency response: deal with an incident of Farm animals being attacked by wild animals; follow protocols to protect the herd and secure the area.",
        "Immediate intervention: respond to reports of Farm animals under attack; prioritize the safety of the animals and take necessary actions.",
        "Response needed: investigate an incident where Farm animals are being attacked by animals; take appropriate measures to protect the livestock and manage the situation.",
    },                                                                             
    CalloutUnitsRequired = {
        description = "Police.",
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
        [21] = vector3(2254.5916, 4926.0264, 40.9015),
    },                      
    PedChanceToFleeFromPlayer = 25,      -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 50,        -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 10,           -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 100,      -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 15000, -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 30000, -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "attack", -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_knife",
        "weapon_bat",
        "weapon_hammer",
        "weapon_wrench",
        "weapon_pistol",
        "weapon_microsmg",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)

        local wildAnimal
        local cattlePedsList = {}
        local coords = calloutDataClient.Coordinates

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                if index == 1 then
                    wildAnimal = ped

                    local function StartAnimalAttackLoop(wildAnimal, cattlePedsList)
                        Citizen.CreateThread(function()
                            ERS_RequestNetControlForEntity(wildAnimal) 
                            while not IsPedDeadOrDying(wildAnimal, true) and #cattlePedsList > 0 do
                                for i = #cattlePedsList, 1, -1 do
                                    if IsPedDeadOrDying(NetToPed(cattlePedsList[i]), true) then
                                        table.remove(cattlePedsList, i)
                                    end
                                end
                    
                                if #cattlePedsList > 0 then
                                    local targetPed = NetToPed(cattlePedsList[math.random(#cattlePedsList)])
                                    TaskCombatPed(wildAnimal, targetPed, 0, 16)
                                end
                    
                                Citizen.Wait(2500)
                            end
                    
                            if IsPedDeadOrDying(wildAnimal, true) then
                                if Config.Debug then
                                    print("The wild animal is dead or deleted...")
                                end
                            else
                                if Config.Debug then
                                    print("All cattle animals are dead or deleted, stopped loop and tasking to attack player.")
                                end
                                TaskCombatPed(wildAnimal, plyPed, 0, 16)
                            end
                        end)
                    end

                    Citizen.SetTimeout(1000, function() 
                        StartAnimalAttackLoop(wildAnimal, cattlePedsList)
                    end)
                else
                    table.insert(cattlePedsList, pedNetId)
                    TaskWanderInArea(ped, coords.x, coords.y, coords.z, 40.0, 5000, 10000)
                end
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        local diameter = 20

        -- Build wild animal
        local randomWildAnimalPedModel = ERS_GetRandomModel(Config.wildAnimals)
        local wildAnimalPedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local wildAnimalPedHeading = math.random(360)
        local wildAnimalPedNetId = ERS_CreatePed(randomWildAnimalPedModel, wildAnimalPedCoords, wildAnimalPedHeading)
        local wildAnimalPed = NetworkGetEntityFromNetworkId(wildAnimalPedNetId)
        table.insert(pedList, wildAnimalPedNetId)

        -- Build cattle animals of the same type.
        local randomAmountOfAnimals = math.random(1, 8)
        local randomAnimalPedModel = ERS_GetRandomModel(Config.cattleAnimals)
        for i = 1, randomAmountOfAnimals do
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