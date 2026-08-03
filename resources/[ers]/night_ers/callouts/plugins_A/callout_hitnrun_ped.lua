Config.Callouts["hitnrun_ped"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Person injured by a hit and run",
    CalloutDescriptions = {
        "Respond immediately to a hit and run incident; a person has been injured and requires urgent medical attention.",
        "Emergency situation: a person has been injured in a hit and run; deploy units to provide aid and investigate the scene.",
        "Urgent call for assistance: a pedestrian has been struck by a vehicle in a hit and run; prioritize medical care and apprehend the suspect.",
        "Critical incident: hit and run accident has left a person injured; respond swiftly to administer first aid and gather evidence.",
        "Alert: hit and run injury reported; dispatch emergency services to the scene and initiate an investigation.",
        "Medical emergency: a person has been injured in a hit and run collision; immediate response required to stabilize the victim.",
        "Respond to a hit and run accident; a person is injured and needs immediate medical assistance and police intervention.",
        "Incident report: hit and run with injuries; coordinate emergency medical response and begin suspect pursuit.",
        "Immediate attention needed: hit and run incident has injured a pedestrian; deploy units to provide medical aid and secure the area.",
        "Urgent callout: a person has been hurt in a hit and run; respond quickly to deliver medical care and start the investigation.",
    },            
    CalloutUnitsRequired = {
        description = "Police, Ambulance.",
        policeRequired = true,
        ambulanceRequired = true,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(360.2204, 138.8387, 103.1109),
        [2] = vector3(849.5053, -1654.5782, 29.5378),
        [3] = vector3(588.4799, -1567.0813, 28.08),
        [4] = vector3(800.1418, -1236.6493, 26.33),
        [5] = vector3(707.9493, -1005.7271, 31.3463),
        [6] = vector3(448.7665, -673.7277, 28.3050),
        [7] = vector3(262.0800, -566.6970, 43.3105),
        [8] = vector3(176.7358, -369.7930, 43.2604),
        [9] = vector3(625.9312, -68.4128, 74.5798),
        [10] = vector3(1084.7811, -381.4534, 67.0580),
        [11] = vector3(1292.6527, 1177.0769, 106.7214),
        [12] = vector3(90.7200, 2091.1211, 144.3520),
        [13] = vector3(-261.4592, 2624.8979, 62.2469),
        [14] = vector3(224.2785, 2990.6072, 42.5603),
        [15] = vector3(-105.8972, 3621.5845, 44.8156),
        [16] = vector3(-1072.8307, 4422.5562, 19.4816),
        [17] = vector3(-1059.8085, 5330.0630, 45.3925),
        [18] = vector3(-573.9376, 5461.4917, 60.7385),
        [19] = vector3(-439.3835, 6080.7036, 31.2503),
        [20] = vector3(1811.5784, 5048.5771, 58.8800),
        [21] = vector3(2604.6880, 5100.0615, 44.7871),
        [22] = vector3(2584.1018, 4735.4443, 33.6795),
        [23] = vector3(2505.2319, 4113.7695, 38.4423),
        [24] = vector3(3084.3508, 5041.8159, 24.2629),
        [25] = vector3(1572.7377, 3715.8696, 34.5017),
    },                      
    PedChanceToFleeFromPlayer = 75,      -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 20,        -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 20,           -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 10,       -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 10000, -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 15000, -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "none",   -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_knife",
        "weapon_hammer",
        "weapon_crowbar",
        "weapon_bat",
        "weapon_pistol",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)


        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                if index == 1 then
                    ERS_SetMovementAnimClipSetToPed(ped, "move_m@injured")
                    ERS_RequestNetControlForEntity(ped) 
                    ERS_ApplyBloodToPed(ped)
                    SetEntityHealth(ped, 0)
                else
                    ERS_SetPedToFleeFromPlayer(ped)   
                end
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)


        local diameter = 20

        -- Build ped
        local pedModel = ERS_GetRandomModel(Config.randomPeds)
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        table.insert(pedList, pedNetId)

        -- Build suspect vehicle
        local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
        local suspectVehModel = ERS_GetRandomModel(Config.randomVehicles)
        local suspectVehType = "automobile"
        local suspectVehCoords = vector3(coords.x, coords.y, coords.z)
        local suspectVehHeading = math.random(360)
        local suspectVehNetId = ERS_CreateVehicle(suspectVehModel, suspectVehType, suspectVehCoords, suspectVehHeading)
        local suspectVehicle = NetworkGetEntityFromNetworkId(suspectVehNetId)
        table.insert(vehicleList, suspectVehNetId)

        -- Build suspect peds
        local randomAmountOfSuspects = math.random(2)
        local seatIndex = -1
        for i = 1, randomAmountOfSuspects do
            local pedModel = ERS_GetRandomModel(Config.randomPeds)
            local pedCoords = vector3(coords.x, coords.y, coords.z+2.0)
            local pedHeading = math.random(360)
            local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
            local ped = NetworkGetEntityFromNetworkId(pedNetId)
            SetPedIntoVehicle(ped, suspectVehicle, seatIndex)
            seatIndex = seatIndex + 1
            table.insert(pedList, pedNetId)
        end

        return true
    end
}