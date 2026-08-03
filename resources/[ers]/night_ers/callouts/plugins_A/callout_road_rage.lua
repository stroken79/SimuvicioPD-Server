Config.Callouts["road_rage"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Road Rage",
    CalloutDescriptions = {
        "Emergency: respond to reports of a road rage incident; ensure the safety of all individuals involved and de-escalate the situation.",
        "Urgent alert: dispatch units to the scene of a road rage altercation; prevent escalation and maintain public safety.",
        "Critical response required: attend to reports of road rage; secure the area and mediate the conflict.",
        "Notice: check reports of road rage; take immediate action to resolve the altercation and protect bystanders.",
        "Alert: respond promptly to a road rage incident; prioritize the safety of drivers and passengers, and restore order.",
        "Incident reported: investigate a road rage situation; coordinate with local authorities to manage the conflict effectively.",
        "Immediate action: address reports of road rage; use necessary measures to calm the situation and ensure safety.",
        "Situation alert: assist in resolving a road rage incident; ensure the area is secure and provide necessary support.",
        "Emergency response: handle reports of road rage; follow protocols to de-escalate the situation and ensure safety for all.",
        "Response needed: investigate reports of a road rage incident urgently; take appropriate actions to prevent harm and restore peace.",
    },                                                          
    CalloutUnitsRequired = {
        description = "Police.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(1192.63, 3536.41, 35.13),
        [2] = vector3(2593.25, 5313.96, 44.57),
        [3] = vector3(27.51, 255.42, 109.61),
        [4] = vector3(-1080.32, -765.26, 19.36),
        [5] = vector3(-1630.25, -991.21, 13.02),
        [6] = vector3(-2795.69, 39.72, 14.60),
        [7] = vector3(-3097.45, 1318.16, 19.89),
        [8] = vector3(-2595.10, 3123.73, 14.58),
        [9] = vector3(-304.33, 6229.86, 31.12),
        [10] = vector3(2243.96, 5922.29, 49.53),
        [11] = vector3(2640.64, 5117.21, 44.48),
        [12] = vector3(2183.72, 4748.46, 40.78),
        [13] = vector3(2170.03, 3783.03, 33.09),
        [14] = vector3(1579.06, 3719.70, 34.20),
        [15] = vector3(217.62, 3256.18, 41.40),
        [16] = vector3(142.01, 1648.18, 228.67),
        [17] = vector3(1233.60, 1269.89, 143.35),
        [18] = vector3(798.01, -52.39, 80.30),
        [19] = vector3(824.26, -1743.31, 29.09),
        [20] = vector3(169.02, -2661.49, 18.14),
        [21] = vector3(219.35, -2548.59, 5.85),
        [22] = vector3(280.12, -1854.27, 26.52),
        [23] = vector3(-669.76, -2067.38, 15.03),
        [24] = vector3(-949.97, -1213.69, 4.92),
        [25] = vector3(-862.40, -656.93, 27.53),
        [26] = vector3(-866.07, -939.28, 15.85),
        [27] = vector3(-188.73, -891.99, 29.34),
        [28] = vector3(-707.01, -1611.40, 22.79),
        [29] = vector3(738.92, -2466.61, 20.22),
        [30] = vector3(1240.60, -2054.46, 44.35),
        [31] = vector3(1969.42, -921.52, 79.16),
        [32] = vector3(2454.87, 977.85, 86.22),
        [33] = vector3(2207.62, 2999.60, 45.54),
        [34] = vector3(1696.63, 3510.35, 36.47),
        [35] = vector3(226.92, 2973.63, 42.71),
        [36] = vector3(-1254.90, 2537.62, 18.12),
        [37] = vector3(-1785.69, 4736.50, 57.01),
        [38] = vector3(-303.03, 6231.18, 31.45),
        [39] = vector3(-54.87, 6311.50, 31.33),
        [40] = vector3(1940.65, 6254.72, 43.52),
    },                     
    PedChanceToFleeFromPlayer = 0,      -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 0,        -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 0,           -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 100,      -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 10000,-- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 15000,-- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "none",  -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_bottle",
        "weapon_knife",
        "weapon_pistol"
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)


        local firstPedsList = {}
        local vehicle
        local suspectPedList = {}
        local suspectVehicle
        local plyGroupHash = GetPedRelationshipGroupHash(plyPed)
        local retval, suspectGroupHash = AddRelationshipGroup("SUSPECT_GROUP_HASH")

        SetRelationshipBetweenGroups(4, suspectGroupHash, plyGroupHash)
        SetRelationshipBetweenGroups(4, plyGroupHash, suspectGroupHash)

        for index, vehNetId in pairs(vehicleList) do
            local veh = NetToVeh(vehNetId)
            if DoesEntityExist(veh) then
                ERS_RequestNetControlForEntity(veh)

                if index == 1 then
                    vehicle = veh
                    --print("Found veh: "..vehicle)
                else
                    suspectVehicle = veh
                    --print("Found veh 2: "..suspectVehicle)
                end
            end
        end
        
        -- Set ped into teams
        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                if IsPedInVehicle(ped, vehicle, true) then
                    SetPedRelationshipGroupHash(ped, plyGroupHash)
                    SetEntityCanBeDamagedByRelationshipGroup(ped, true, plyGroupHash)
                    table.insert(firstPedsList, PedToNet(ped))
                else
                    SetPedRelationshipGroupHash(ped, suspectGroupHash)
                    SetEntityCanBeDamagedByRelationshipGroup(ped, false, suspectGroupHash)
                    table.insert(suspectPedList, PedToNet(ped))
                end
            end
        end

        for index, pedNetId in pairs(firstPedsList) do
            local driverEntity = GetPedInVehicleSeat(vehicle, -1)
            local ped = NetToPed(pedNetId)
            ERS_RequestNetControlForEntity(ped) 
            if ped == driverEntity then
                ERS_RequestNetControlForEntity(vehicle) 
                SetVehicleDoorsLocked(vehicle, 4) -- Lock peds inside.
                ERS_RequestNetControlForEntity(ped) 
                local suspectPed = NetToPed(suspectPedList[1])
                TaskReactAndFleePed(ped, suspectPed)
            else
                TaskSetBlockingOfNonTemporaryEvents(ped, true)
            end
        end

        for index, pedNetId in pairs(suspectPedList) do
            local driverEntity = GetPedInVehicleSeat(suspectVehicle, -1)
            local ped = NetToPed(pedNetId)
            ERS_RequestNetControlForEntity(ped) 
            if ped == driverEntity then
                ERS_RequestNetControlForEntity(ped) 
                TaskSetBlockingOfNonTemporaryEvents(ped, true)
                Wait(50)
                TaskVehicleEscort(ped, suspectVehicle, vehicle, -1, 50.0, 1082917029, 7.5, 0, -1)
                SetPedKeepTask(ped, true)
            else
                TaskSetBlockingOfNonTemporaryEvents(ped, true)

                SetCanPedEquipAllWeapons(ped, true)
                --SetPedCanSwitchWeapon(ped, true)
                SetPedCombatAttributes(ped, 2, true)  -- Can shoot from vehicle
                SetPedCombatAttributes(ped, 54, true)  -- Always equip best weapon.

                ERS_SpawnConfiguredWeaponForPed(ped, calloutDataClient)

                Citizen.SetTimeout(5000, function() 
                    if DoesEntityExist(ped) then
                        if not IsPedDeadOrDying(ped, true) then
                            ERS_RequestNetControlForEntity(ped) 
                            -- Make the ped shoot at the target entity indefinitely
                            local targetPed = NetToPed(firstPedsList[math.random(#firstPedsList)])
                            TaskCombatPed(ped, targetPed, 0, 16)
                            SetPedKeepTask(ped, true)
                            --TaskShootAtEntity(ped, targetPed, -1, GetHashKey("FIRING_PATTERN_FULL_AUTO"))
                            -- print("tasking to shoot for ped "..ped)
                        end
                    end
                end)
                
            end
        end

        ERS_CreateTemporaryBlipForEntities(firstPedsList, 30000)
        ERS_CreateTemporaryBlipForEntities(suspectPedList, 30000)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)


        local diameter = 25
        
        -- Build vehicle
        local vehModel = ERS_GetRandomModel(Config.randomVehicles)
        local vehType = "automobile"
        local vehCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local vehHeading = math.random(360)
        local vehNetId = ERS_CreateVehicle(vehModel, vehType, vehCoords, vehHeading)
        local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
        table.insert(vehicleList, vehNetId)

        -- Build drivers
        local seatIndex = -1
        for i = 1, 2 do
            local pedModel = ERS_GetRandomModel(Config.randomPeds)
            local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z + 2.0)
            local pedHeading = math.random(360)
            local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
            local ped = NetworkGetEntityFromNetworkId(pedNetId)
            SetPedIntoVehicle(ped, vehicle, seatIndex)
            seatIndex = seatIndex + 1
            table.insert(pedList, pedNetId)
        end

        -- Build suspect vehicle
        local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
        local suspectVehModel = ERS_GetRandomModel(Config.randomFourDoorVehiclesSpecific)
        local suspectVehType = "automobile"
        local suspectVehCoords = vector3(coords.x, coords.y, coords.z)
        local suspectVehHeading = math.random(360)
        local suspectVehNetId = ERS_CreateVehicle(suspectVehModel, suspectVehType, suspectVehCoords, suspectVehHeading)
        local suspectVehicle = NetworkGetEntityFromNetworkId(suspectVehNetId)
        table.insert(vehicleList, suspectVehNetId)

        -- Build suspect peds
        local randomAmountOfSuspects = math.random(2)
        seatIndex = -1
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