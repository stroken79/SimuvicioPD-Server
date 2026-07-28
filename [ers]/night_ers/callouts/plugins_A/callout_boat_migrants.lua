Config.Callouts["boat_migrants"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Reports of migrants arriving on a boat",
    CalloutDescriptions = {
        "Investigate reports of migrants arriving on a boat; secure the area and ensure their safety.",
        "Alert: dispatch units to respond to reports of migrants arriving on a boat; provide immediate assistance.",
        "Units required: respond to reports of a boat carrying migrants and take necessary actions to assist them.",
        "Notice: check reports of migrants arriving on a boat; implement measures to ensure their wellbeing.",
        "Alert: respond promptly to reports of migrants arriving on a boat; prioritize their safety and care.",
        "Incident reported: look into reports of migrants arriving on a boat to provide necessary aid and support.",
        "Investigate reports of a boat carrying migrants; coordinate with relevant authorities to address the situation.",
        "Situation alert: address reports of migrants arriving on a boat; ensure the area is secured and help is provided.",
        "Alert: handle reports of migrants arriving on a boat and follow protocols to ensure their safety and support.",
        "Response needed: investigate reports of migrants arriving on a boat and take appropriate actions to assist and protect them.",
    },                
    CalloutUnitsRequired = {
        description = "Police",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(-1417.2120, -1615.8606, 0.1448),
        [2] = vector3(-1809.3936, -973.8002, 1.9747),
        [3] = vector3(-2076.4451, -611.0533, 1.3401),
        [4] = vector3(-3030.3972, -0.8509, 1.7006),
        [5] = vector3(-3169.9976, 289.5727, 2.1437),
        [6] = vector3(-3265.2388, 895.5994, -0.4368),
        [7] = vector3(-3125.7136, 1656.5962, 0.4893),
        [8] = vector3(-2685.5750, 2533.6912, 0.7223),
        [9] = vector3(-2393.0715, 2630.3701, -0.0339),
        [10] = vector3(-1868.3955, 2566.3022, 0.1976),
        [11] = vector3(-1549.2698, 2626.0557, 1.5337),
        [12] = vector3(-2553.6880, 3923.9187, 1.6076),
        [13] = vector3(-2093.0620, 4599.1460, 1.1754),
        [14] = vector3(-1394.5308, 5285.9351, 0.8501),
        [15] = vector3(-885.7209, 5840.6069, 0.8044),
        [16] = vector3(6.6508, 7059.5547, -0.6106),
        [17] = vector3(3395.8420, 5637.5762, 0.9500),
        [18] = vector3(2977.9421, 1821.2184, 1.2231),
        [19] = vector3(2940.1265, 311.0411, 0.7346),
        [20] = vector3(1601.8865, -2747.1536, 0.9043),
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
                if not IsPedInAnyBoat(ped) then
                    ERS_SetMovementAnimClipSetToPed(ped, "move_m@injured")
                    TaskWanderStandard(ped, 10.0, 10)
                else
                    TaskReactAndFleePed(ped, plyPed)
                end
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 30000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)


        local diameter = 20

        -- Build vehicle
        local vehModel = "dinghy"
        local vehType = "boat"
        local vehCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local vehHeading = math.random(360)
        local vehNetId = ERS_CreateVehicle(vehModel, vehType, vehCoords, vehHeading)
        local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
        table.insert(vehicleList, vehNetId)

        -- Build boat captain
        local seatIndex = -1
        local pedModel = ERS_GetRandomModel(Config.randomPeds)
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z+3.0)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        SetPedIntoVehicle(ped, vehicle, seatIndex)
        table.insert(pedList, pedNetId)

        -- Build migrant peds
        local randomAmountOfPeds = math.random(2,10)
        for i = 0, randomAmountOfPeds do
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
            local pedModel = ERS_GetRandomModel(Config.randomPeds)
            local pedCoords = vector3(coords.x, coords.y, coords.z + 1.0)
            local pedHeading = math.random(360)
            local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
            local ped = NetworkGetEntityFromNetworkId(pedNetId)
            table.insert(pedList, pedNetId)
        end
        
        return true
    end
}