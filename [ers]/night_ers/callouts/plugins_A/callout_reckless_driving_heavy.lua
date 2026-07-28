Config.Callouts["reckless_driving_heavy"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Reckless driving in a heavy vehicle",
    CalloutDescriptions = {
        "Investigate reports of a heavy vehicle being driven erratically; secure the scene and evaluate the situation.",
        "Alert: dispatch units to handle reports of a heavy vehicle driving dangerously; ensure public safety.",
        "Units required: respond to reports of a heavy vehicle operating recklessly and assess potential risks.",
        "Notice: check reports of hazardous driving by a heavy vehicle and implement necessary safety measures.",
        "Alert: respond promptly to reports of reckless driving in a heavy vehicle; prioritize safety and detailed assessment.",
        "Incident reported: look into reports of a heavy vehicle driving irresponsibly to understand the threat level.",
        "Investigate reports of a heavy vehicle driving erratically; coordinate with traffic control and secure the vicinity.",
        "Situation alert: address reports of a heavy vehicle being driven dangerously; work with relevant authorities.",
        "Alert: handle reports of a heavy vehicle driving recklessly and adhere to safety protocols for potential hazards.",
        "Response needed: investigate reports of reckless heavy vehicle driving and take steps to ensure community safety.",
    },        
    CalloutUnitsRequired = {
        description = "Police",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(933.4853, -3190.7881, 5.9008),
        [2] = vector3(-895.2436, -115.3364, 37.9570),
        [3] = vector3(823.2411, -1524.7156, 28.9780),
        [4] = vector3(741.8983, -2499.1797, 20.2135),
        [5] = vector3(304.0816, -2550.3000, 5.7018),
        [6] = vector3(-275.2318, -2577.4436, 5.9796),
        [7] = vector3(-896.3196, -1824.5986, 35.3967),
        [8] = vector3(-524.4230, -504.6884, 25.3055),
        [9] = vector3(-1490.4974, -262.6434, 50.2380),
        [10] = vector3(-3151.9204, 935.8858, 14.4236),
        [11] = vector3(-2652.2512, 2654.8267, 16.6594),
        [12] = vector3(-1586.2675, 4921.5903, 61.4198),
        [13] = vector3(-402.6738, 5972.9756, 31.7093),
        [14] = vector3(2640.0142, 5105.3809, 44.8056),
        [15] = vector3(2748.8899, 3414.4187, 56.3821),
        [16] = vector3(2541.0632, 3269.8059, 52.8347),
        [17] = vector3(1959.9297, 3082.1833, 46.7531),
        [18] = vector3(1305.5258, 2640.0676, 37.7118),
        [19] = vector3(-34.6396, 2788.5928, 56.5891),
        [20] = vector3(-1114.0311, 2663.7812, 18.1515),
    },
    PedChanceToFleeFromPlayer = 0,       -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 0,         -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 0,            -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 0,        -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 0,     -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 1000,  -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "none",   -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_unarmed",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)

        local vehicle
        local driver

        for index, vehNetId in pairs(vehicleList) do
            local veh = NetToVeh(vehNetId)
            if DoesEntityExist(veh) then
                vehicle = veh
                ERS_RequestNetControlForEntity(vehicle) 
                ERS_SetRandomDamageToVehicle(vehicle)
            end
        end

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                driver = ped
                ERS_RequestNetControlForEntity(driver) 
                TaskSetBlockingOfNonTemporaryEvents(driver, true)
                ERS_SetPedAsDrunkPed(driver) 
                TaskVehicleDriveWander(driver, vehicle, 10.0, 786603)
            end
        end

        ERS_CreateTemporaryBlipForEntities(vehicleList, 15000)
        ERS_CreateTemporaryBlipForEntities(pedList, 15000)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        -- Build vehicle
        local vehModel = ERS_GetRandomModel(Config.randomHeavyVehicles2)
        local vehType = "automobile"
        local vehCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local vehHeading = math.random(360)
        local vehNetId = ERS_CreateVehicle(vehModel, vehType, vehCoords, vehHeading)
        local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
        table.insert(vehicleList, vehNetId)

        -- Build ped
        local pedModel = ERS_GetRandomModel(Config.randomPeds)
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z+3.0)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        SetPedIntoVehicle(ped, vehicle, -1)
        table.insert(pedList, pedNetId)
    
        return true
    end
}