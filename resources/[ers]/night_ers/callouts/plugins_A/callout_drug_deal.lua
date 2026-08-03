Config.Callouts["drug_deal"] = {
    
    Enabled = true,
    Priority = 1,
    CalloutName = "Possible drugs dealing",
    CalloutDescriptions = {
        "A possible drugs dealing situation has been reported, requiring immediate police response.",
        "Emergency assistance is needed to investigate and address a possible drugs dealing scenario.",
        "Reports indicate a possible drugs dealing activity, necessitating urgent police intervention.",
        "A possible drugs dealing situation has been reported, and backup is needed to secure the area and conduct an investigation.",
        "Emergency services have been dispatched to address a possible drugs dealing situation.",
        "A request for assistance has been made by officers responding to a possible drugs dealing incident.",
        "Additional units are required to support officers responding to a possible drugs dealing situation.",
        "Emergency backup is required to assist officers in handling a possible drugs dealing scenario.",
        "A call for assistance has been issued by officers dealing with a possible drugs dealing situation.",
        "Reports suggest a situation where immediate police assistance is crucial to investigate and address a possible drugs dealing activity.",
    },                            
    CalloutUnitsRequired = {
        description = "Police.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(-1656.60, -150.07, 58.33),
        [2] = vector3(-964.03, -184.61, 37.80),
        [3] = vector3(-628.39, -234.97, 38.05),
        [4] = vector3(-586.74, -293.28, 35.07),
        [5] = vector3(-42.90, -419.81, 39.64),
        [6] = vector3(23.17, -434.85, 45.50),
        [7] = vector3(371.64, -363.52, 46.75),
        [8] = vector3(802.94, -828.72, 27.32),
        [9] = vector3(827.70, -1072.18, 29.00),
        [10] = vector3(1001.18, -1538.05, 30.83),
        [11] = vector3(954.11, -1679.79, 30.05),
        [12] = vector3(39.68, -2684.49, 6.17),
        [13] = vector3(-420.11, -2790.76, 6.01),
        [14] = vector3(-1142.01, -1969.37, 13.16),
        [15] = vector3(-1175.60, -1800.86, 3.90),
        [16] = vector3(-1998.75, 553.35, 112.60),
        [17] = vector3(-748.51, 5593.33, 41.65),
        [18] = vector3(-377.63, 6075.06, 31.46),
        [19] = vector3(-159.16, 6290.67, 31.48),
        [20] = vector3(-69.88, 6250.36, 31.08),
        [21] = vector3(1919.24, 4831.56, 46.02),
        [22] = vector3(2542.07, 4648.52, 34.07),
        [23] = vector3(2508.43, 4212.37, 40.15),
        [24] = vector3(1882.91, 3806.63, 32.76),
        [25] = vector3(1710.45, 3689.69, 34.82),
        [26] = vector3(382.12, -1227.18, 32.38),
        [27] = vector3(146.43, -1279.99, 29.04),
        [28] = vector3(501.40, -2159.42, 5.91),
        [29] = vector3(367.48, -2668.01, 6.00),
        [30] = vector3(-443.82, -2445.16, 6.00),
        [31] = vector3(-1217.72, -1804.72, 3.71),
        [32] = vector3(-1621.59, -1060.65, 13.09),
        [33] = vector3(326.59, -210.93, 54.08),
        [34] = vector3(685.86, 577.65, 130.46),
        [35] = vector3(-459.34, -1713.22, 18.67),
        [36] = vector3(-3081.01, 551.72, 2.34),
        [37] = vector3(-2197.92, 4260.04, 48.04),
        [38] = vector3(1687.92, 6417.40, 32.37),
        [39] = vector3(424.85, 6527.00, 27.70),
        [40] = vector3(155.67, 6608.80, 31.89),
    },                               
    PedChanceToFleeFromPlayer = 75,     -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 25,       -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 10,          -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 75,      -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 5000, -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 10000, -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "flee",  -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_pistol",
        "weapon_knife",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)
        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped)
                if index == 1 then
                    TaskSetBlockingOfNonTemporaryEvents(ped, true)
                    TaskTurnPedToFaceEntity(ped, NetToPed(pedList[2]), -1)
                    Wait(1000)
                    ClearPedTasks(ped)
                    Wait(500)
                    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_DRUG_DEALER", 0, true)
                else
                    TaskSetBlockingOfNonTemporaryEvents(ped, true)
                    TaskTurnPedToFaceEntity(ped, NetToPed(pedList[1]), -1)
                    Wait(1000)
                    ClearPedTasks(ped)
                    Wait(500)
                    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_DRUG_DEALER_HARD", 0, true)
                end
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)
               
        local diameter = 3
        
        -- Build suspect peds
        local suspects = 2
        for i = 1, suspects do
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
            local suspectPedModel = ERS_GetRandomModel(Config.randomPeds)
            local suspectPedCoords = vector3(coords.x, coords.y, coords.z)
            local suspectPedHeading = math.random(360)
            local suspectPedNetId = ERS_CreatePed(suspectPedModel, suspectPedCoords, suspectPedHeading)
            local suspectPed = NetworkGetEntityFromNetworkId(suspectPedNetId)
            table.insert(pedList, suspectPedNetId)
        end
    
        return true
    end
}