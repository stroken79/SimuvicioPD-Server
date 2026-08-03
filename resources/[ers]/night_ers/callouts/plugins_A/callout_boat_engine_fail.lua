-- (Boat Rescue: https://store.nights-software.com/package/5317442) --
Config.Callouts["boat_engine_fail"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Engine failure (boat) on open sea",
    CalloutDescriptions = {
        "Emergency: respond to reports of a boat with engine failure on the open sea; ensure the safety of all passengers.",
        "Urgent alert: dispatch rescue units to assist a boat experiencing engine failure; provide immediate assistance.",
        "Critical response required: attend to a boat with engine failure; perform necessary rescue operations.",
        "Notice: check reports of a boat's engine failure; ensure quick intervention and safety measures.",
        "Alert: respond promptly to reports of a boat stranded due to engine failure; prioritize passenger safety.",
        "Incident reported: investigate engine failure on a boat to prevent hazardous situations; coordinate with maritime authorities.",
        "Immediate action: address reports of a boat's engine failure; implement rescue operations and ensure safety.",
        "Situation alert: assist a boat with engine failure; secure the area and provide necessary support.",
        "Emergency response: handle reports of a boat's engine failure and follow rescue protocols to ensure safety.",
        "Response needed: investigate engine failure reports urgently; take appropriate actions to rescue and protect passengers.",
    },                            
    CalloutUnitsRequired = {
        description = "Police, Fire, Boat Rescue Tow service.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = true,
        towRequired = true,
    },
    CalloutLocations = {
        [1] = vector3(-1828.5118, -1539.2891, 1.1647),
        [2] = vector3(-1536.9678, -1863.2750, -0.0101),
        [3] = vector3(-2189.4231, -1072.1609, 0.1496),
        [4] = vector3(-3929.3704, 70.6058, -0.2150),
        [5] = vector3(-5044.5020, 1350.0837, 0.0183),
        [6] = vector3(-2429.7378, 4771.9009, 1.4950),
        [7] = vector3(-298.7473, 8313.3652, 0.7064),
        [8] = vector3(5283.5317, 6131.5645, -0.5446),
        [9] = vector3(4567.7446, 1925.2971, -0.8195),
        [10] = vector3(3883.2461, -1492.2983, 0.7835),
        [11] = vector3(3072.8665, -4442.4038, -0.4688),
        [12] = vector3(1674.0967, -4297.9985, -0.1545),
        [13] = vector3(-1717.0173, -3889.8708, 0.1580),
        [14] = vector3(-1988.5629, -2549.8674, 0.7593),
        [15] = vector3(-2661.4233, -3227.2847, -0.4570),
        [16] = vector3(-4903.6616, -2509.2512, 1.0533),
        [17] = vector3(-4419.8789, -1269.2566, 1.3760),
        [18] = vector3(-4626.2852, 1312.8241, -0.3191),
        [19] = vector3(-2859.7668, -1289.2007, -0.4757),
        [20] = vector3(-1515.1837, -5266.1289, -0.8206),
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


        for index, vehNetId in pairs(vehicleList) do
            local veh = NetToVeh(vehNetId)
            if DoesEntityExist(veh) then
                ERS_RequestNetControlForEntity(veh)
                ERS_SetRandomDamageToVehicle(veh)
                SetVehicleEngineOn(veh, false, true, false)
            end
        end

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                -- Let them stay in the passenger seat.
            end
        end
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)


        -- Build vehicle
        local vehModel = ERS_GetRandomModel(Config.randomBoats) 
        local vehType = "boat"
        local vehCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local vehHeading = math.random(360)
        local vehNetId = ERS_CreateVehicle(vehModel, vehType, vehCoords, vehHeading)
        local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
        table.insert(vehicleList, vehNetId)

        -- Build boat captain
        local seatIndex = 0
        local pedModel = ERS_GetRandomModel(Config.randomPeds)
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z+3.0)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        SetPedIntoVehicle(ped, vehicle, seatIndex)
        table.insert(pedList, pedNetId)
    
        return true
    end
}