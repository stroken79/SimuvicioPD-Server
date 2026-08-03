Config.Callouts["drug_warehouse"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Drug smugglers warehouse located",
    CalloutDescriptions = {
        "Emergency: respond immediately to reports of a drug smuggling warehouse; secure the area and apprehend suspects.",
        "Urgent alert: dispatch units to the location of a drug smuggling operation; prevent the suspects from escaping and seize contraband.",
        "Critical response: attend to a report of a drug smuggling warehouse; prioritize securing evidence and detaining all involved.",
        "Immediate action: investigate reports of a drug smuggling warehouse; take necessary measures to shut down the operation.",
        "Alert: respond promptly to the discovery of a drug smuggling warehouse; ensure the safety of officers and gather all evidence.",
        "Incident reported: handle a situation involving a drug smuggling warehouse; coordinate with narcotics units to manage the operation.",
        "Situation alert: assist in raiding a drug smuggling warehouse; secure the location and arrest all suspects.",
        "Emergency response: deal with a discovered drug smuggling warehouse; follow protocols to seize drugs and arrest individuals.",
        "Immediate intervention: respond to reports of a drug smuggling warehouse; prioritize the apprehension of suspects and confiscation of illegal substances.",
        "Response needed: investigate reports of a drug smuggling operation urgently; take appropriate actions to dismantle the operation and secure the area.",
    },                                                                                 
    CalloutUnitsRequired = {
        description = "Police.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(-519.6938, -2835.9790, 6.0004),
        [2] = vector3(-47.4459, -2224.0042, 7.8117),
        [3] = vector3(-153.1731, -2665.0564, 6.0002),
        [4] = vector3(72.0018, -2737.7595, 6.0031),
        [5] = vector3(184.9508, -3120.9741, 5.7819),
        [6] = vector3(1177.8940, -3243.2639, 5.9581),
        [7] = vector3(1016.7790, -2332.0244, 30.4876),
        [8] = vector3(1065.3457, -1961.4900, 31.0145),
        [9] = vector3(1765.0731, -1532.6378, 112.4530),
        [10] = vector3(2985.3704, 3495.2598, 71.3819),
        [11] = vector3(2227.7437, 5167.9551, 58.5628),
        [12] = vector3(1377.2062, 4369.2319, 44.0381),
        [13] = vector3(10.6306, 6335.0142, 31.2360),
        [14] = vector3(2372.3931, 3115.5803, 48.0733),
        [15] = vector3(26.8874, 3710.8281, 39.6957),
        [16] = vector3(-88.7946, 2802.2861, 53.3044),
        [17] = vector3(216.7919, 2455.8967, 56.5108),
        [18] = vector3(170.9110, 2249.3745, 91.2255),
        [19] = vector3(-3169.1328, 1293.6431, 14.3532),
        [20] = vector3(-296.7219, -2714.0962, 6.0003),
    },                      
    PedChanceToFleeFromPlayer = 20,     -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 80,       -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 0,           -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 100,     -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 10000,-- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 15000,-- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "attack",-- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_assaultrifle",
        "weapon_pistol",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)


        local plyGroupHash = GetPedRelationshipGroupHash(plyPed)
        local retval, suspectGroupHash = AddRelationshipGroup("SUSPECT_GROUP_HASH")

        SetRelationshipBetweenGroups(4, suspectGroupHash, plyGroupHash)
        SetRelationshipBetweenGroups(4, plyGroupHash, suspectGroupHash)

        for index, objNetId in pairs(objectList) do
            local obj = NetToObj(objNetId)
            if DoesEntityExist(obj) then
                ERS_RequestNetControlForEntity(obj) 
                PlaceObjectOnGroundProperly(obj)
            end
        end

        for index, vehNetId in pairs(vehicleList) do
            local veh = NetToVeh(vehNetId)
            if DoesEntityExist(veh) then
                ERS_RequestNetControlForEntity(veh)
                for i = 1, 2 do
                    SetVehicleDoorOpen(veh, i, false, true)
                end
            end
        end

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                SetPedRelationshipGroupHash(ped, suspectGroupHash)
                SetEntityCanBeDamagedByRelationshipGroup(ped, false, suspectGroupHash)
                ERS_SpawnConfiguredWeaponForPed(ped, calloutDataClient)
                if index == 1 then
                    if IsPedInAnyVehicle(ped, false) then
                        ERS_SetPedToFleeFromPlayer(ped)
                    end
                else
                    SetPedAccuracy(ped, 50)
                    TaskCombatPed(ped, plyPed, 0, 16)
                end
            end
        end
    
        ERS_CreateTemporaryBlipForEntities(pedList, 60000)
        ERS_CreateTemporaryBlipForEntities(vehicleList, 60000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)


        local diameter = 30

        -- Build suspect vehicle
        local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
        local suspectVehModel = ERS_GetRandomModel(Config.randomDrugTrucks)
        local suspectVehType = "automobile"
        local suspectVehCoords = vector3(coords.x, coords.y, coords.z+1.0)
        local suspectVehHeading = math.random(360)
        local suspectVehNetId = ERS_CreateVehicle(suspectVehModel, suspectVehType, suspectVehCoords, suspectVehHeading)
        local suspectVehicle = NetworkGetEntityFromNetworkId(suspectVehNetId)
        table.insert(vehicleList, suspectVehNetId)

        -- Build suspect ped(s)
        local seatIndex = -1
        local randomAmountOfSuspects = math.random(5, 10)
        for i = 1, randomAmountOfSuspects do
            coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
            local suspectPedModel = ERS_GetRandomModel(Config.randomGangPeds)
            local suspectPedCoords = vector3(coords.x, coords.y, coords.z+2.0)
            local suspectPedHeading = math.random(360)
            local suspectPedNetId = ERS_CreatePed(suspectPedModel, suspectPedCoords, suspectPedHeading)
            local suspectPed = NetworkGetEntityFromNetworkId(suspectPedNetId)
            if i == 1 then
                SetPedIntoVehicle(suspectPed, suspectVehicle, seatIndex)
                seatIndex = seatIndex + 1
            end
            table.insert(pedList, suspectPedNetId)
        end

        -- Build objects
        diameter = 10
        local randomAmountOfObjects = math.random(10)
        for i = 1, randomAmountOfObjects do
            coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
            local objModel = ERS_GetRandomModel(Config.randomDrugObjects)
            local objCoords = vector3(coords.x, coords.y, coords.z)
            local objHeading = math.random(360)
            local objNetId = ERS_CreateObject(objModel, objCoords, objHeading)
            if objNetId then    
                local obj = NetworkGetEntityFromNetworkId(objNetId)
                table.insert(objectList, objNetId)
            else
                DebugPrint("^1ERROR ^7Could not create object: "..objModel)
            end
        end

        return true
    end
}