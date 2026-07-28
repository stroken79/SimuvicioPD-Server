Config.Callouts["driving_seizure"] = {
    
    Enabled = true,
    Priority = 1,
    CalloutName = "Seizure whilst driving",
    CalloutDescriptions = {
        "Caller reports a driver experiencing a seizure, immediate medical assistance required.",
        "Emergency call: driver in distress due to a seizure, vehicle out of control, urgent help needed.",
        "Emergency! Driver reported having a seizure while driving, potential crash imminent.",
        "Witness reports driver having a seizure, vehicle dangerously swerving, immediate intervention needed.",
        "Help needed: driver suffering a seizure, car has come to a stop in traffic.",
        "Urgent: seizure reported behind the wheel, potential for serious accident, medical support required.",
        "Caller indicates a driver experiencing a seizure, vehicle stopped in hazardous position, emergency services needed.",
        "Serious situation: driver reported having a seizure, car blocking road, immediate assistance needed.",
        "Witness reports a medical emergency: driver having a seizure, potential for crash, first responders required.",
        "Report of a driver having a seizure, vehicle out of control, urgent medical and police response needed.",
    },                               
    CalloutUnitsRequired = {
        description = "Police, Ambulance.",
        policeRequired = true,
        ambulanceRequired = true,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        vector3(1979.71, 3304.68, 45.11),
        vector3(225.16, 3321.39, 39.90),
        vector3(-1639.10, 2439.46, 26.53),
        vector3(1120.33, 6464.17, 22.34),
        vector3(2387.42, 5150.40, 47.46),
        vector3(1899.05, 1711.78, 64.59),
        vector3(2548.83, 1648.64, 28.56),
        vector3(1411.67, -1541.59, 58.01),
        vector3(143.48, -1448.40, 29.11),
        vector3(1924.75, 2464.45, 54.67),
        vector3(-1409.08, -64.58, 52.87),
        vector3(-2657.79, 1505.18, 116.97),
        vector3(-212.14, -704.14, 33.81),
        vector3(-552.52, -638.08, 33.79),
        vector3(-440.72, -216.01, 36.44),
        vector3(-372.92, 140.30, 65.95),
        vector3(-95.07, 102.84, 73.05),
        vector3(1940.38, 2453.16, 54.57),
        vector3(2877.37, 4247.51, 51.10),
        vector3(2626.18, 5118.11, 44.77),
        vector3(-1369.54, 4799.75, 129.20),
        vector3(75.27, 3649.59, 39.55),
        vector3(224.40, 3139.16, 42.25),
        vector3(1186.58, 2673.98, 37.77),
        vector3(2040.88, 3010.99, 45.28),
        vector3(106.20, -996.31, 29.40),
        vector3(1532.84, 867.58, 77.12),
        vector3(1912.90, 527.79, 173.50),
        vector3(2412.35, 1053.58, 80.19),
        vector3(2772.77, 3319.06, 56.13),
        vector3(2663.66, 3928.24, 42.34),
        vector3(2700.45, 3083.12, 42.76),
        vector3(2632.89, 2946.15, 40.42),
        vector3(2851.14, 3440.11, 50.92),
        vector3(2453.31, 3854.30, 38.94),
        vector3(2271.27, 3757.01, 38.42),
        vector3(1820.61, 3507.98, 38.32),
        vector3(1693.80, 3461.85, 37.02),
        vector3(1184.28, 3267.64, 39.20),
        vector3(-3040.17, 3745.06, 70.20),
        vector3(-4050.71, 5335.75, 83.14),
        vector3(-4043.33, 5599.94, 68.38),
        vector3(2874.65, 4868.66, 62.60),
        vector3(3000.50, 4099.68, 57.18),
        vector3(-92.55, 6150.44, 31.80),
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


        local vehicle

        for index, vehNetId in pairs(vehicleList) do
            local veh = NetToVeh(vehNetId)
            if DoesEntityExist(veh) then
                vehicle = veh
                ERS_RequestNetControlForEntity(vehicle) 
            else
                if Config.Debug then
                    print("Could not find vehicle entity.")
                end
            end
            Wait(500)
        end

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                TaskSetBlockingOfNonTemporaryEvents(ped, true)
                TaskVehicleDriveWander(ped, vehicle, 17.0, drivingStyle) -- drivingStyle is pre-configured, you can replace this with your own driving style hash if you like.
                Wait(2000)
                SetEntityHealth(ped, 0)
            end
        end

        ERS_CreateTemporaryBlipForEntities(vehicleList, 15000)
        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)
        -- Build vehicle
        local vehModel = ERS_GetRandomModel(Config.randomVehicles)
        local vehType = "automobile"
        local vehCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local vehHeading = math.random(360)
        local vehNetId = ERS_CreateVehicle(vehModel, vehType, vehCoords, vehHeading)
        local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
        table.insert(vehicleList, vehNetId)

        -- Build ped
        local pedModel = ERS_GetRandomModel(Config.randomPeds)
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z + 2.0)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        SetPedIntoVehicle(ped, vehicle, -1)
        table.insert(pedList, pedNetId)

        return true
    end
}