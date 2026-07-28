Config.Callouts["house_fire"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "House on fire",
    CalloutDescriptions = {
        "A fire has been reported in a house, requiring immediate attention from fire services.",
        "Emergency services are needed to extinguish a fire at a house.",
        "Reports indicate a fire has broken out in a house, necessitating urgent firefighting intervention.",
        "A fire has been identified in a house, and additional fire personnel are needed for containment and extinguishment.",
        "Emergency services have been requested to respond to a house fire.",
        "A request for assistance has been made by authorities dealing with a house fire.",
        "Additional units are required to support fire personnel managing a house fire.",
        "Emergency backup is required to assist fire authorities in handling a house fire.",
        "A call for assistance has been issued by responders dealing with a house fire.",
        "Reports suggest a situation where immediate firefighting intervention is crucial to manage and address a house fire.",
    },                                 
    CalloutUnitsRequired = {
        description = "Fire",
        policeRequired = false,
        ambulanceRequired = false,
        fireRequired = true,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(445.45, -1710.66, 33.41),
        [2] = vector3(277.36, -1991.81, 25.62),
        [3] = vector3(282.22, -1904.35, 30.82),
        [4] = vector3(330.79, -1742.28, 33.04),
        [5] = vector3(-32.65, -1442.02, 36.82),
        [6] = vector3(837.10, -563.42, 63.17),
        [7] = vector3(894.56, -541.69, 62.39),
        [8] = vector3(987.85, -525.33, 63.64),
        [9] = vector3(1046.10, -475.70, 68.93),
        [10] = vector3(1098.44, -466.17, 70.96),
        [11] = vector3(1239.85, -593.63, 72.97),
        [12] = vector3(1250.33, -514.95, 72.65),
        [13] = vector3(1262.64, -434.51, 73.99),
        [14] = vector3(984.57, -432.42, 68.42),
        [15] = vector3(441.03, -1709.35, 32.70),
        [16] = vector3(407.69, -1754.85, 34.15),
        [17] = vector3(237.97, -1684.21, 33.65),
        [18] = vector3(-1228.04, -1210.43, 13.24),
        [19] = vector3(504.18, -1816.16, 33.72),
        [20] = vector3(1635.71, 3724.45, 38.79),
        [21] = vector3(17.46, 3687.95, 43.77),
        [22] = vector3(-47.13, 6642.09, 37.08),
        [23] = vector3(-25.51, 6594.60, 36.38),
        [24] = vector3(-44.05, 6580.23, 36.23),
        [25] = vector3(-128.24, 6558.08, 34.58),
        [26] = vector3(33.77, 6662.45, 37.33),
        [27] = vector3(57.97, 6652.39, 38.47),
        [28] = vector3(-217.44, 6442.18, 36.55),
        [29] = vector3(-247.01, 6418.63, 35.71),
        [30] = vector3(-272.36, 6401.78, 34.99),
        [31] = vector3(-303.71, 6323.91, 36.04),
        [32] = vector3(-363.81, 6204.56, 36.21),
        [33] = vector3(-1047.91, 431.58, 82.57),
        [34] = vector3(-812.03, 179.45, 72.16),
        [35] = vector3(-14.35, -1438.48, 31.10),
        [36] = vector3(152.00, -1823.93, 30.55),
        [37] = vector3(81.88, -1961.12, 24.35),
        [38] = vector3(71.64, -1940.27, 24.46),
        [39] = vector3(-1667.94, -440.37, 48.09),
        [40] = vector3(-1600.54, -353.38, 54.58),            
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
                TaskSetBlockingOfNonTemporaryEvents(ped, true)
                PlayPain(ped, 8, 200)
                ERS_ApplyBloodToPed(ped)
                Wait(2500)
                SetEntityHealth(ped, 0)
                
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        local diameter = 2
        local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)

        -- Build a small sized fire
        if UsingSmartFiresV2 or UsingSmartFires then
            local fireSize = Config.RandomMediumFireOrSmokeSize[math.random(#Config.RandomMediumFireOrSmokeSize)]
            local fireType = Config.NormalFireTypes[math.random(#Config.NormalFireTypes)]
            fireList[#fireList + 1] = ERS_AddCalloutFire(vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z-0.5), fireType, fireSize)
        elseif UsingSmartFiresLite then
            local fireSize = Config.RandomSmallFireOrSmokeSize[math.random(#Config.RandomSmallFireOrSmokeSize)]
            fireList[#fireList + 1] = ERS_AddCalloutFire(vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z-0.5), "normal", fireSize)
        end

        -- Build victim
        local pedModel = ERS_GetRandomModel(Config.randomPeds)
        local pedCoords = vector3(coords.x, coords.y, coords.z)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        table.insert(pedList, pedNetId)

        return true
    end
}