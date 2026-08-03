Config.Callouts["highway_pileup"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Pileup on the Highway",
    CalloutDescriptions = {
        "Respond immediately to a multi-vehicle pileup on the highway; secure the area and provide assistance to those involved.",
        "Emergency alert: major pileup on the highway; deploy units to manage the scene and ensure the safety of all motorists.",
        "Urgent response required: multiple vehicles involved in a highway pileup; focus on rescue operations and traffic control.",
        "Critical situation: highway pileup involving several vehicles; act swiftly to provide aid and prevent further incidents.",
        "Alert: major highway pileup reported; immediate intervention needed to assist the injured and clear the wreckage.",
        "Highway incident: multi-vehicle pileup; urgent action required to secure the scene and help the affected drivers.",
        "Handle a serious pileup on the highway; prioritize emergency response and coordinate with rescue teams.",
        "Emergency situation: multiple vehicle collision on the highway; ensure the area is safe and assist in rescue efforts.",
        "Urgent alert: significant pileup on the highway; respond quickly to manage the scene and provide necessary aid.",
        "Critical response needed: highway pileup involving numerous vehicles; secure the area, assist the injured, and restore traffic flow.",
    },               
    CalloutUnitsRequired = {
        description = "Police, Ambulance, Fire, Tow.",
        policeRequired = true,
        ambulanceRequired = true,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(-723.9343, -501.5836, 25.1885),
        [2] = vector3(1306.3455, 604.0614, 80.1776),
        [3] = vector3(1615.2841, 1112.5173, 82.3359),
        [4] = vector3(1814.2136, 2232.6438, 53.7744),
        [5] = vector3(2250.2102, 2768.9214, 44.1481),
        [6] = vector3(2906.5564, 4007.5483, 51.3679),
        [7] = vector3(2702.1899, 4758.9541, 44.4291),
        [8] = vector3(2501.0244, 5560.6606, 44.8073),
        [9] = vector3(1860.9811, 6321.2598, 40.6849),
        [10] = vector3(533.3502, 6550.3486, 27.4865),
        [11] = vector3(-103.8089, 6285.8931, 31.3435),
        [12] = vector3(-560.1664, 5687.4629, 37.6950),
        [13] = vector3(-918.4584, 5417.5034, 37.1486),
        [14] = vector3(-1270.9117, 5258.7598, 50.9792),
        [15] = vector3(-1962.1641, 4557.4907, 57.0737),
        [16] = vector3(-2259.5281, 4231.6406, 43.5575),
        [17] = vector3(-2540.3325, 3460.8416, 13.4633),
        [18] = vector3(-2693.2185, 2441.3757, 16.6942),
        [19] = vector3(-3094.0144, 1192.8280, 20.3403),
        [20] = vector3(-2317.9683, -303.7535, 13.8492),
        [21] = vector3(-1844.1833, -562.5378, 11.5654),
        [22] = vector3(-1376.2452, -766.1354, 11.0586),
        [23] = vector3(-905.1063, -531.1483, 20.2172),
        [24] = vector3(34.4561, -522.6520, 34.0809),
        [25] = vector3(859.5303, -711.8274, 42.6594),
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
                        TaskGoToCoordAnyMeans(ped, safeCoords.x + xOffset, safeCoords.y + yOffset, safeCoords.z, 10.0, 0, false, 786603, 0xbf800000)
                    else
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
        ERS_CreateTemporaryBlipForEntities(objectList, 15000)

        -- ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)


        local randomAmountOfVehicles = math.random(5,15)
        local randomAmountOfObjects = math.random(3,10)

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

            local fireToObjChance = math.random(100)
            if fireToObjChance > 75 then
                -- Build fire
                if UsingSmartFiresV2 or UsingSmartFires then
                    local fireSize = Config.RandomMediumFireOrSmokeSize[math.random(#Config.RandomMediumFireOrSmokeSize)]
                    local fireType = Config.NormalFireTypes[math.random(#Config.NormalFireTypes)]
                    fireList[#fireList + 1] = ERS_AddCalloutFire(vector3(coords.x, coords.y, coords.z-0.5), fireType, fireSize)
                elseif UsingSmartFiresLite then
                    local fireSize = Config.RandomMediumFireOrSmokeSize[math.random(#Config.RandomMediumFireOrSmokeSize)]
                    fireList[#fireList + 1] = ERS_AddCalloutFire(vector3(coords.x, coords.y, coords.z-0.5), "normal", fireSize)
                end
            end
        end

        return true
    end
}