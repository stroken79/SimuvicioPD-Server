Config.Callouts["sr_stranded_island"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Wounded person stranded on an island",
    CalloutDescriptions = {
        "A wounded individual is stranded on an island; rescue teams are on their way.",
        "Medical personnel are urgently needed for an injured person isolated on an island.",
        "Rescue units have been deployed to assist a wounded person found on an island.",
        "A critical rescue operation is underway for an injured individual on an island.",
        "Swift medical intervention required for a person injured and stranded on an island.",
        "Responders are racing against time to save a wounded person on an island.",
        "A call for help has been made to rescue an injured person marooned on an island.",
        "Emergency response teams are heading to an island to aid a wounded individual.",
        "A person in distress has been located on an island; immediate rescue efforts are needed.",
        "Urgent assistance required for a person injured on an island; rescue teams mobilized.",
    },                                             
    CalloutUnitsRequired = {
        description = "Police, Ambulance, Fire.",
        policeRequired = true,
        ambulanceRequired = true,
        fireRequired = true,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(-2183.9011, 5183.6987, 16.6627),
        [2] = vector3(-2043.3984, 5266.8096, 17.7975),
        [3] = vector3(-1816.4592, 5488.5684, 7.9016),
        [4] = vector3(-1630.2252, 5442.6216, 12.8220),
        [5] = vector3(-1454.4152, 5413.7739, 22.8619),
        [6] = vector3(-103.3360, 7289.8325, 16.7094),
        [7] = vector3(15.7447, 7635.1982, 14.3738),
        [8] = vector3(230.6882, 7441.3452, 21.9909),
        [9] = vector3(3633.8091, 5672.4092, 8.6487),
        [10] = vector3(3685.1494, 4961.5391, 18.3950),
        [11] = vector3(3942.4944, 4642.4819, 18.2710),
        [12] = vector3(4122.7661, 4506.2070, 16.9941),
        [13] = vector3(4073.5979, 4211.8301, 14.0132),
        [14] = vector3(3479.4202, 2598.7239, 12.8363),
        [15] = vector3(3324.3218, 2194.2185, 1.4920),
        [16] = vector3(3084.3245, 1600.1307, 12.7106),
        [17] = vector3(3053.0583, 1437.5079, 13.5563),
        [18] = vector3(3113.5139, 1154.7980, 18.8581),
        [19] = vector3(2951.2944, 1019.1576, 10.8890),
        [20] = vector3(3015.9016, 883.7566, 8.0428),
        [21] = vector3(3213.9888, 593.5472, 4.3898),
        [22] = vector3(3117.5991, 606.0804, 9.6844),
        [23] = vector3(3137.9255, 562.7927, 3.6338),
        [24] = vector3(3210.8066, 177.3137, 18.3535),
        [25] = vector3(3163.3364, -68.5841, 17.3274),
        [26] = vector3(3251.6924, -144.8231, 16.3246),
        [27] = vector3(3030.9824, -302.7097, 15.1117),
        [28] = vector3(2640.5403, -1248.3137, 1.8464),
        [29] = vector3(2835.7522, -1427.0204, 11.3241),
        [30] = vector3(2329.3782, -2308.8440, 1.3600),
        [31] = vector3(2144.9788, -2607.6042, 8.3746),
        [32] = vector3(1798.7809, -2817.9043, 6.2547),
        [33] = vector3(1431.5016, -2812.7676, 5.4683),
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
                ERS_ApplyBloodToPed(ped)
                local scenario = ERS_SelectRandomWoundedPersonScenario()
                TaskStartScenarioInPlace(ped, scenario, 0, true)
                ERS_CreateFlareAtCoordinate(calloutDataClient.Coordinates)
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        -- Build ped
        local pedModel = ERS_GetRandomModel(Config.randomPeds)
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        table.insert(pedList, pedNetId)

        return true
    end
}