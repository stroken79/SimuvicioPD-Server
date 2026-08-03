Config.Callouts["stolen_plane"] = {
    
    Enabled = true,
    Priority = 1,
    CalloutName = "Reports of theft of a plane",
    CalloutDescriptions = {
        "Emergency: respond immediately to reports of a plane theft; secure the airspace and prevent unauthorized takeoff.",
        "Urgent alert: dispatch units to the location of the reported plane theft; coordinate with aviation authorities to track and recover the aircraft.",
        "Critical response: attend to a report of a stolen plane; prioritize the safety of passengers and ground crew while apprehending the suspect.",
        "Immediate action: investigate reports of a plane theft; secure the airport and ensure the aircraft remains grounded.",
        "Alert: respond promptly to a plane theft incident; take necessary measures to intercept the aircraft before it leaves the area.",
        "Incident reported: handle a situation involving a stolen plane; work with air traffic control to monitor and manage the threat.",
        "Situation alert: assist in tracking a stolen plane; ensure the safety of all individuals involved and recover the aircraft.",
        "Emergency response: deal with a plane theft incident; follow aviation security protocols to prevent the plane from taking off.",
        "Immediate intervention: respond to reports of a plane theft; prioritize grounding the aircraft and apprehending the suspect.",
        "Response needed: investigate reports of a stolen plane urgently; take appropriate actions to recover the aircraft and ensure airspace security.",
    },                                                                                           
    CalloutUnitsRequired = {
        description = "Police.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(-1606.8677, -2780.2085, 13.9583), -- Make sure there is enough space for the plane to take off in all directions.
        [2] = vector3(-1382.6349, -3018.6328, 13.9576),
        [3] = vector3(-927.0759, -3282.0020, 13.9533),
        [4] = vector3(-1564.1737, -2630.7725, 13.9516),
        [5] = vector3(-1361.4224, -2278.6238, 13.9500),
        [6] = vector3(1599.8428, 3210.6877, 40.4612),
        [7] = vector3(1164.2180, 3096.4104, 40.4341),
        [8] = vector3(1991.5559, 4750.9058, 41.1150),
        [9] = vector3(2118.0952, 4804.4136, 41.1790),
        [10] = vector3(1410.3528, 3098.2681, 40.4363),
    },                      
    PedChanceToFleeFromPlayer = 100,    -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 0,        -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 0,           -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 0,       -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 10000,-- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 15000,-- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "flee",  -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_unarmed",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)

        local aircraft

        for index, vehNetId in pairs(vehicleList) do
            local veh = NetToVeh(vehNetId)
            if DoesEntityExist(veh) then
                ERS_RequestNetControlForEntity(veh)
                aircraft = veh
                SetVehicleEngineOn(aircraft, true, true, false)
            end
        end
        
        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped)
                Citizen.Wait(1000)
                -- ERS_SetPedToFleeFromPlayer(ped)

                -- Specify the destination coordinates
                local destinationX = calloutDataClient.Coordinates.x+1000.0
                local destinationY = calloutDataClient.Coordinates.y-1000.0
                local destinationZ = calloutDataClient.Coordinates.z+250.0
                
                TaskPlaneMission(ped, aircraft, 0, 0, destinationX, destinationY, destinationZ, 4, 100.0, 100.0, 0.0, 2000.0, 400.0)
                -- TaskPlaneMission(pilot, aircraft, targetVehicle, targetPed, destinationX, destinationY, destinationZ, missionFlag, angularDrag, unk, targetHeading, maxZ, minZ)
            end
        end

        ERS_CreateTemporaryBlipForEntities(vehicleList, 30000)
        ERS_CreateTemporaryBlipForEntities(pedList, 30000)

        --ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        -- Build vehicle
        local vehModel = ERS_GetRandomModel(Config.randomPlanes)
        local vehType = "plane"
        local vehCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local vehHeading = math.random(360)
        local vehNetId = ERS_CreateVehicle(vehModel, vehType, vehCoords, vehHeading)
        local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
        table.insert(vehicleList, vehNetId)

        -- Build pilot
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