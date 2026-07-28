Config.Callouts["atm_robbery"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "ATM Robbery",
    CalloutDescriptions = {
        "An ATM robbery is in progress, requiring immediate police response.",
        "Emergency assistance is needed to apprehend suspects involved in an ATM robbery.",
        "Reports indicate an ongoing ATM robbery, necessitating urgent police intervention.",
        "An ATM robbery has occurred, and backup is needed to secure the area and apprehend suspects.",
        "Emergency services have been dispatched to address an ATM robbery situation.",
        "A request for assistance has been made by officers responding to an ATM robbery.",
        "Additional units are required to support officers responding to an ATM robbery.",
        "Emergency backup is required to assist officers in apprehending suspects involved in an ATM robbery.",
        "A call for assistance has been issued by officers dealing with an ATM robbery.",
        "Reports suggest an ATM robbery situation where immediate police assistance is crucial to prevent further harm.",
    },            
    CalloutUnitsRequired = {
        description = "Police.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(89.57, 2.16, 68.32),
        [2] = vector3(-526.49, -1222.79, 18.45),
        [3] = vector3(-2072.48, -317.19, 13.31),
        [4] = vector3(-821.56, -1081.90, 11.13),
        [5] = vector3(1686.74, 4815.88, 42.00),
        [6] = vector3(-386.89, 6045.78, 31.50),
        [7] = vector3(1171.52, 2702.44, 38.17),
        [8] = vector3(1968.11, 3743.56, 32.34),
        [9] = vector3(2558.85, 351.04, 108.62),
        [10] = vector3(1153.75, -326.80, 69.20),
        [11] = vector3(-56.91, -1752.17, 29.42),
        [12] = vector3(-3241.02, 997.58, 12.55),
        [13] = vector3(-1827.18, 784.90, 138.30),
        [14] = vector3(-1091.54, 2708.55, 18.94),
        [15] = vector3(112.45, -819.25, 31.33),
        [16] = vector3(-256.17, -716.03, 33.52),
        [17] = vector3(174.22, 6637.88, 31.57),
        [18] = vector3(236.82, 217.53, 106.28),
        [19] = vector3(264.62, 212.09, 106.28), 
        [20] = vector3(285.68, 143.90, 104.17),
        [21] = vector3(356.78, 173.14, 103.06),
        [22] = vector3(-867.09, -185.77, 37.68),
        [23] = vector3(-1205.37, -324.53, 37.85),
        [24] = vector3(-1316.03, -834.95, 16.96),
        [25] = vector3(-712.91, -819.26, 23.72),
        [26] = vector3(-618.66, -706.90, 30.05),
        [27] = vector3(296.23, -894.14, 29.22),
        [28] = vector3(155.44, 6642.41, 31.61),
        [29] = vector3(-717.36, -915.76, 19.21),
        [30] = vector3(1735.46, 6410.89, 35.03), 
        [31] = vector3(-660.72, -853.97, 24.48),
        [32] = vector3(540.2889, 2671.1113, 42.1565),
        [33] = vector3(-95.5408, 6457.1987, 31.4610),
        [34] = vector3(-97.4098, 6455.3574, 31.4676),
        [35] = vector3(-594.5259, -1161.6271, 22.3242),
    },            
    PedChanceToFleeFromPlayer = 75,     -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 25,       -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 10,          -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 25,      -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 5000, -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 15000, -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "flee", -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_knife",
        "weapon_bat",
        "weapon_hammer",
        "weapon_wrench",
        "weapon_pistol",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                ClearPedTasks(ped)
                TaskSetBlockingOfNonTemporaryEvents(ped, true)
                ERS_SetPedToFleeFromPlayer(ped)
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)

    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)
        -- Build suspect
        local pedModel = ERS_GetRandomModel(Config.randomPeds)
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        table.insert(pedList, pedNetId)

        return true
    end
}