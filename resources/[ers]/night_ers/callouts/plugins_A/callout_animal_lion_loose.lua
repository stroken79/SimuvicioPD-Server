Config.Callouts["animal_lion_loose"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Lion on the loose",
    CalloutDescriptions = {
        "Respond to a report of a lion on the loose; ensure public safety and coordinate with animal control.",
        "Alert: wild lion spotted in the area; deploy units to contain the animal and protect civilians.",
        "Units needed: emergency call for a lion on the loose; focus on securing the area and preventing any harm.",
        "Notice: lion reported roaming freely; act promptly to control the situation and provide assistance.",
        "Alert: report of a lion on the loose; intervention needed to secure the scene and ensure safety.",
        "Incident reported: lion sighted in the vicinity; take action to deliver urgent response and support.",
        "Respond to a situation involving a loose lion; prioritize public safety and coordinate with wildlife experts.",
        "Situation alert: lion on the loose; provide immediate assistance and ensure the area is secure.",
        "Alert: report of a lion roaming freely; respond swiftly to address the emergency and offer necessary support.",
        "Response needed: lion on the loose; ensure public safety, provide aid, and secure the area.",
    },                                                         
    CalloutUnitsRequired = {
        description = "Police",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(1934.6595, 3031.3896, 45.7164),
        [2] = vector3(-214.8435, 1035.7235, 234.5423),
        [3] = vector3(-466.8387, -1162.0983, 23.6649),
        [4] = vector3(-2076.1177, -437.1109, 9.8332),
        [5] = vector3(-2281.7795, 474.2083, 172.9490),
        [6] = vector3(-2295.1606, 188.0179, 167.6016),
        [7] = vector3(-2939.5046, 650.9875, 24.1793),
        [8] = vector3(-3188.0657, 1012.1148, 20.0270),
        [9] = vector3(-1552.5914, 1392.1687, 125.7523),
        [10] = vector3(-435.6132, 1137.1411, 325.9044),
        [11] = vector3(-95.6399, 1867.1407, 198.5176),
        [12] = vector3(925.4871, 2210.6370, 48.5551),
        [13] = vector3(1518.1306, 1657.1375, 111.3717),
        [14] = vector3(1526.4376, 1083.3717, 113.4257),
        [15] = vector3(2120.0583, 2712.8020, 49.2382),
        [16] = vector3(2398.5566, 3368.1067, 47.5749),
        [17] = vector3(2025.1345, 3822.0681, 33.0109),
        [18] = vector3(1698.8066, 4934.4023, 42.0782),
        [19] = vector3(2336.7585, 5165.4336, 50.9019),
        [20] = vector3(-496.6979, 6083.9131, 29.3845),
    },               
    PedChanceToFleeFromPlayer = 100,      -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 10,        -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 0,           -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 0,       -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 10000,    -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 15000, -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "flee",-- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_unarmed",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)


        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                TaskReactAndFleePed(ped, plyPed)
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 30000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        -- Build lion
        local AnimalPedModel = "a_c_mtlion"
        local animalPedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z+1.0)
        local animalPedHeading = math.random(360)
        local animalPedNetId = ERS_CreatePed(AnimalPedModel, animalPedCoords, animalPedHeading)
        local animalPed = NetworkGetEntityFromNetworkId(animalPedNetId)
        table.insert(pedList, animalPedNetId)

        return true
    end
}