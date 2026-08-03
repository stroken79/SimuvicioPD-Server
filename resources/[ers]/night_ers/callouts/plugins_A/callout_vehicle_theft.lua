Config.Callouts["vehicle_theft"] = {
    Enabled = false,
    Priority = 1,
    CalloutName = "Vehicle Theft",
    CalloutDescriptions = {
        "Reports of vehicle theft, details pending",
        "Suspected vehicle theft reported, further information needed",
        "Incident involving stolen vehicle, assess situation for safety",
        "Vehicle theft reported, prioritize response for recovery",
        "Reported theft of motor vehicle, investigate promptly",
        "Vehicle reported missing, coordinate search and recovery efforts",
        "Stolen vehicle reported, assess potential risks",
        "Suspected theft of vehicle, approach investigation with caution",
        "Reports of vehicle theft, prioritize response for recovery",
        "Vehicle theft incident reported, coordinate with authorities",
    },            
    CalloutUnitsRequired = {
        description = "Police.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(376.85, -83.60, 67.28),
        [2] = vector3(252.45, -991.78, 29.15),
        [3] = vector3(442.52, -544.01, 28.28),
        [4] = vector3(676.55, -219.48, 44.30),
        [5] = vector3(365.68, -108.07, 66.25),
        [6] = vector3(-817.47, -126.34, 37.52),
        [7] = vector3(-309.89, -15.74, 48.35),
        [8] = vector3(-2354.87, -285.41, 14.13),
        [9] = vector3(-1000.02, -602.68, 18.39),
        [10] = vector3(199.27, 6574.46, 31.80),
        [11] = vector3(1391.85, 6500.05, 19.76),
        [12] = vector3(1723.97, 6387.80, 34.03),
        [13] = vector3(2553.27, 5194.82, 50.78),
        [14] = vector3(-136.89, 6224.72, 31.34),
        [15] = vector3(2600.13, 5119.80, 44.78),
        [16] = vector3(2446.42, 4009.14, 37.06),
        [17] = vector3(1831.28, 3258.06, 44.10),
        [18] = vector3(1977.05, 3081.72, 47.07),
        [19] = vector3(2558.44, 2702.69, 41.77),
        [20] = vector3(2854.36, 2819.08, 53.09),
        [21] = vector3(254.91, 2848.28, 43.59),
        [22] = vector3(85.82, 3595.74, 39.75),
        [23] = vector3(-821.40, 5761.81, 5.54),
        [24] = vector3(-300.05, 6057.30, 31.35),
        [25] = vector3(2348.26, 4878.92, 41.82),
        [26] = vector3(2489.21, 4123.94, 38.17),
        [27] = vector3(2899.84, 4458.32, 48.28),
        [28] = vector3(2785.74, 3469.58, 55.32),
        [29] = vector3(2005.33, 3069.22, 47.05),
        [30] = vector3(879.49, 2851.35, 56.73),
        [31] = vector3(320.66, 3410.22, 36.72),
        [32] = vector3(-1505.61, 4974.42, 62.52),
        [33] = vector3(-762.73, 5547.37, 33.49),
        [34] = vector3(-142.31, 6351.43, 31.49),
        [35] = vector3(-76.59, 1869.51, 198.46),
        [36] = vector3(-70.88, 895.65, 235.50),
        [37] = vector3(634.44, 632.47, 128.91),
        [38] = vector3(926.51, -86.54, 78.76),
        [39] = vector3(245.43, -1523.13, 29.14),
        [40] = vector3(202.76, -1855.99, 27.20),
    },
    PedChanceToFleeFromPlayer = 90,     -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 10,       -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 10,          -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 25,      -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 0,    -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 2000, -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "flee",  -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_knife",
        "weapon_pistol",
    },
    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)
        local vehicle = nil
        local driver = nil

        for index, vehNetId in pairs(vehicleList) do
            local veh = NetToVeh(vehNetId)
            if DoesEntityExist(veh) then
                vehicle = veh
                ERS_RequestNetControlForEntity(vehicle) 
            end
        end

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                driver = ped
                ERS_RequestNetControlForEntity(driver) 
                if not IsPedOnAnyBike(driver) then
                    SmashVehicleWindow(vehicle, 0) -- break driver window
                end
                if not IsPedInAnyVehicle(driver, true) then
                    TaskEnterVehicle(driver, vehicle, 5000, -1, 2.0, 1, 0)
                    Wait(5000)
                    ERS_SetPedToFleeFromPlayer(driver)
                else
                    ERS_SetPedToFleeFromPlayer(driver)
                end             
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
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z +1.0)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        SetPedIntoVehicle(ped, vehicle, -1)
        table.insert(pedList, pedNetId)

        calloutBuilt = true

        return true
    end
}