
Config.Callouts["traffic_incident"] = {
    Enabled = false,
    Priority = 1,
    CalloutName = "Traffic Incident",
    CalloutDescriptions = {
        "Reported road traffic collision, further details needed",
        "Collision involving vehicles, assess scene for safety",
        "Incident on road reported, extent of damage unclear",
        "Traffic incident with unknown injuries, approach carefully",
        "Vehicle collision reported, assistance required",
        "Accident scene identified, evaluate for emergency response",
        "Collision on roadway, prioritize safety and assistance",
        "Traffic incident reported, coordinate response accordingly",
        "Roadway blocked due to collision, assess for hazards",
        "Vehicle collision with unspecified injuries, response needed",
        -- Add more if you like.
    },
    CalloutUnitsRequired = {
        description = "Police, ambulance, fire, tow.",
        policeRequired = true,
        ambulanceRequired = true,
        fireRequired = true,
        towRequired = true,
    },
    CalloutLocations = {
        [1] = vector3(1552.06, 911.62, 77.36),          -- LS Freeway
        [2] = vector3(1127.38, 467.26, 90.36),          -- LS Freeway > LS offramp
        [3] = vector3(27.51, 255.42, 109.61),           -- Eclipse Blvd. West Vinewood
        [4] = vector3(-1080.32, -765.26, 19.36),        -- South Rockford Dr. Vespucci Canals
        [5] = vector3(-1630.25, -991.21, 13.02),        -- Red Desert Ave. Del Perro Beach
        [6] = vector3(-2795.69, 39.72, 14.60),          -- Great Ocean Hwy. Pacific Bluffs
        [7] = vector3(-3097.45, 1318.16, 19.89),        -- Barbarenio Rd. Chumash
        [8] = vector3(-2595.10, 3123.73, 14.58),        -- Great Ocean Hwy, Lago Zancudo Tunnel
        [9] = vector3(-304.33, 6229.86, 31.12),         -- Duluoz Ave. Paleto Bay
        [10] = vector3(2243.96, 5922.29, 49.53),        -- Senora Fwy. Braddock Tunnel
        [11] = vector3(2640.64, 5117.21, 44.48),        -- Union Rd. San Chianski Mountain Range
        [12] = vector3(2183.72, 4748.46, 40.78),        -- Joad Ln. Grapeseed
        [13] = vector3(2170.03, 3783.03, 33.09),        -- East Joshua Road Sandy Shores
        [14] = vector3(1579.06, 3719.70, 34.20),        -- Cholla Springs Ave Sandy Shores
        [15] = vector3(217.62, 3256.18, 41.40),         -- Joshua Rd. Grand Senora Desert
        [16] = vector3(142.01, 1648.18, 228.67),        -- Baytree Canyon Rd. Vinewood Hills
        [17] = vector3(1233.60, 1269.89, 143.35),       -- Mt Haan Rd. Vinewood Hills
        [18] = vector3(798.01, -52.39, 80.30),          -- Vinewood Park Dr. East Vinewood
        [19] = vector3(824.26, -1743.31, 29.09),        -- Popular St. Cypress Flats
        [20] = vector3(169.02, -2661.49, 18.14),        -- Elysian Fields Fwy. Elysian Island
        [21] = vector3(219.35, -2548.59, 5.85),         -- Plaice Pl. Elysian Island
        [22] = vector3(280.12, -1854.27, 26.52),        -- Roy Lowenstein Blvd. Rancho
        [23] = vector3(-669.76, -2067.38, 15.03),       -- Daves Ave La Puerta
        [24] = vector3(-949.97, -1213.69, 4.92),        -- Prosperity St. Vespucci Canals
        [25] = vector3(-862.40, -656.93, 27.53),        -- San Andreas Avenue Little Seoul
        [26] = vector3(-866.07, -939.28, 15.85),        -- South Rockford Dr.
        [27] = vector3(-188.73, -891.99, 29.34),        -- Alta Str.
        [28] = vector3(-707.01, -1611.40, 22.79),       -- Dutch London Str.
        [29] = vector3(738.92, -2466.61, 20.22),        -- Hanger Way
        [30] = vector3(1240.60, -2054.46, 44.35),       -- El Rancho Blvd.
        [31] = vector3(1969.42, -921.52, 79.16),        -- Sustancia Rd.
        [32] = vector3(2454.87, 977.85, 86.22),         -- Palomino Hwy.
        [33] = vector3(2207.62, 2999.60, 45.54),        -- Route 68
        [34] = vector3(1696.63, 3510.35, 36.47),        -- East Joshua Rd.
        [35] = vector3(226.92, 2973.63, 42.71),         -- Route 68 Approach
        [36] = vector3(-1254.90, 2537.62, 18.12),       -- Route 68
        [37] = vector3(-1785.69, 4736.50, 57.01),       -- Great Ocean Hwy. Bridge
        [38] = vector3(-303.03, 6231.18, 31.45),        -- Paleto Bay
        [39] = vector3(-54.87, 6311.50, 31.33),         -- Paleto Bay
        [40] = vector3(1940.65, 6254.72, 43.52),        -- Route 1
    },        
    PedChanceToFleeFromPlayer = 0,      -- Value between 0 and 100 -> 0 is no chance. The lower the less chance.
    PedChanceToAttackPlayer = 0,        -- Value between 0 and 100 -> 0 is no chance. The lower the less chance.
    PedChanceToSurrender = 0,           -- Value between 0 and 100 -> 0 is no chance. The lower the less chance.
    PedChanceToObtainWeapons = 0,       -- Value between 0 and 100 -> 0 is no chance. The lower the less chance.
    PedActionMinimumTimeoutInMs = 0,    -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 1000, -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "none",  -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = {       -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_unarmed",   -- Basically none.
    },
    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)
        for index, vehNetId in pairs(vehicleList) do
            local veh = NetToVeh(vehNetId)
            if DoesEntityExist(veh) then
                ERS_RequestNetControlForEntity(veh) 
                ERS_SetRandomDamageToVehicle(veh)
            end
        end

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then

                ERS_RequestNetControlForEntity(ped)

                local pedCoords = GetEntityCoords(ped)
                local chanceToSurvive = math.random(0, 1)            

                ERS_SetMovementAnimClipSetToPed(ped, "move_m@injured")

                if chanceToSurvive < 1 then
                    -- Dead
                    SetEntityHealth(ped, 0)
                    TaskSetBlockingOfNonTemporaryEvents(ped, true)
                    ERS_ApplyBloodToPed(ped)
                    SetPedKeepTask(ped, true)
                else
                    -- Alive
                    TaskSetBlockingOfNonTemporaryEvents(ped, true)
                    ERS_SpawnConfiguredWeaponForPed(ped, calloutDataClient)
                    if IsPedInAnyVehicle(ped, false) then
                        TaskLeaveAnyVehicle(ped)
                        Wait(500)
                    end
                    TaskSetBlockingOfNonTemporaryEvents(ped, true)
                    SetPedKeepTask(ped, true)

                    ERS_ApplyBloodToPed(ped)

                    pedCoords = GetEntityCoords(ped)
                    local bool, safeCoords = GetSafeCoordForPed(pedCoords.x, pedCoords.y, pedCoords.z, true, 16)
                    if bool then
                        if Config.Debug then
                            print("Found safe coord for ped: "..safeCoords)
                        end
                        local xOffset= math.random(-2, 2)
                        local yOffset= math.random(-2, 2)

                        if Config.Debug then
                            print("Could not find safe coord for ped: "..safeCoords)
                        end
                    end
                    
                    Citizen.SetTimeout(10000, function() 
                        if DoesEntityExist(ped) then
                            if not IsPedDeadOrDying(ped, true) then
                                ERS_RequestNetControlForEntity(ped) 
                                
                                TaskSetBlockingOfNonTemporaryEvents(ped, true)

                                local scenario = ERS_SelectRandomWoundedPersonScenario()
                                TaskStartScenarioInPlace(ped, scenario, 0, true)

                                ERS_PerformTimedActionOnPed(calloutDataClient, pedList)

                                if Config.Debug then
                                    print("Blocking off non-temp events for ped at safe coords for ped: "..ped)
                                end
                            end
                        end
                    end)
                end
            end
        end

        for index, objNetId in pairs(objectList) do
            local obj = NetToObj(objNetId)
            if DoesEntityExist(obj) then
                ERS_RequestNetControlForEntity(obj) 
                PlaceObjectOnGroundProperly(obj)
            end
        end

        ERS_CreateTemporaryBlipForEntities(vehicleList, 15000)
        ERS_CreateTemporaryBlipForEntities(pedList, 15000)
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)
        local randomAmountOfVehicles = math.random(2,5)
        local randomAmountOfObjects = math.random(1,5)

        -- Build entities
        for i = 1, randomAmountOfVehicles do
            local diameter = 20
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)

            -- Build vehicle
            local vehModel = ERS_GetRandomModel(Config.randomVehicles)
            local vehType = "automobile"
            local vehCoords = vector3(coords.x, coords.y, coords.z)
            local vehHeading = math.random(360)
            local vehNetId = ERS_CreateVehicle(vehModel, vehType, vehCoords, vehHeading)
            local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
            table.insert(vehicleList, vehNetId)

            -- Build ped
            coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
            local pedModel = ERS_GetRandomModel(Config.randomPeds)
            local pedCoords = vector3(coords.x, coords.y, coords.z)
            local pedHeading = math.random(360)
            local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
            local ped = NetworkGetEntityFromNetworkId(pedNetId)
            SetPedIntoVehicle(ped, vehicle, -1)
            table.insert(pedList, pedNetId)

            -- Break vehicle
            SetVehicleBodyHealth(vehicle, (math.random(1000) + 0.0))
            for i = 0, 5 do
                local broken = math.random(0, 1)
                if broken == 1 then
                    SetVehicleDoorBroken(vehicle, i, false)
                end
                SetVehicleDirtLevel(vehicle, math.random(15) + 0.0)
            end

            -- Passengers
            for seatIndex = 0, 2 do -- seats (4 door vehicles) (front right, rear left, rear right), will leave passenger outside of vehicle if seat 0, 1 or 2 does not exist.
                if GetPedInVehicleSeat(vehicle, seatIndex) == 0 then
                    local chance = math.random(100)
                    if chance >= 67 then -- 1/3 chance.
                        coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
                        local passengerPedModel = ERS_GetRandomModel(Config.randomPeds)
                        local passengerPedCoords = vector3(coords.x, coords.y, coords.z)
                        local passengerPedHeading = math.random(360)
                        local passengerPedNetId = ERS_CreatePed(passengerPedModel, passengerPedCoords, passengerPedHeading)
                        local passengerPed = NetworkGetEntityFromNetworkId(pedNetId)
                        SetPedIntoVehicle(passengerPed, vehicle, seatIndex)
                        table.insert(pedList, passengerPedNetId)
                    end
                end
            end
        end

        -- Build objects
        for i = 1, randomAmountOfObjects do
            local diameter = 20
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)

            local objModel = ERS_GetRandomModel(Config.randomCollissionObjects)
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