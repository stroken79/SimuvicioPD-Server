Config.Callouts["moneytruck_incident"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Incident with a Money Truck",
    CalloutDescriptions = {
        "Respond immediately to a report involving a money truck; secure the area and ensure the safety of personnel and assets.",
        "Emergency alert: incident with a money truck; deploy units to manage the situation and protect the cargo.",
        "Urgent response required: money truck involved in an incident; focus on securing the vehicle and safeguarding the valuables.",
        "Critical situation: money truck emergency; act swiftly to provide assistance and control the scene.",
        "Alert: money truck incident reported; immediate intervention needed to ensure the security of the truck and its contents.",
        "Money truck incident: urgent action required to secure the area and assist the personnel involved.",
        "Handle an emergency involving a money truck; prioritize the security of the assets and coordinate with law enforcement.",
        "Emergency situation: money truck in trouble; ensure the area is safe and assist in securing the cargo.",
        "Urgent alert: money truck incident; respond quickly to manage the scene and protect the valuables.",
        "Critical response needed: incident with a money truck; secure the area, assist the personnel, and ensure the safety of the assets.",
    },
    CalloutUnitsRequired = {
        description = "Police, Ambulance, Fire, Tow.",
        policeRequired = true,
        ambulanceRequired = true,
        fireRequired = true,
        towRequired = true,
    },
    CalloutLocations = {
        [1] = vector3(875.4945, -688.0707, 43.0357),
        [2] = vector3(1719.8188, 4609.8384, 42.2503),
        [3] = vector3(2537.9226, 5092.7334, 44.0742),
        [4] = vector3(2771.3525, 4398.0645, 49.0240),
        [5] = vector3(2362.5691, 2962.7026, 48.9666),
        [6] = vector3(1707.8932, 1505.2977, 84.7929),
        [7] = vector3(356.2293, -264.4918, 53.9432),
        [8] = vector3(-393.4785, -2.1186, 46.9674),
        [9] = vector3(-1027.6091, -187.3826, 37.7828),
        [10] = vector3(-1714.3776, -541.1097, 37.4315),
        [11] = vector3(-2877.8933, 59.8339, 14.1071),
        [12] = vector3(-3159.2134, 916.8397, 14.3760),
        [13] = vector3(-2718.2336, 2273.2571, 19.6467),
        [14] = vector3(-1705.6680, 4793.6533, 59.4235),
        [15] = vector3(-765.0125, 5497.1079, 34.9195),
        [16] = vector3(-580.3328, 6125.1748, 7.4043),
        [17] = vector3(-23.4844, 6507.6704, 31.3663),
        [18] = vector3(-105.1847, 6443.0786, 31.2827),
        [19] = vector3(-900.0214, -829.4100, 17.4409),
        [20] = vector3(-349.2408, -1639.5975, 19.1104),
        [21] = vector3(735.6824, -2816.4446, 6.2865),
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
                local pos = GetEntityCoords(veh, false)
                local foundGround, groundZ = GetGroundZFor_3dCoord(pos.x, pos.y, pos.z, false)
                
                if foundGround then
                    SetEntityCoords(veh, pos.x, pos.y, groundZ, false, false, false, false)
                end
                
                SetEntityRotation(veh, 0, -90.01, 0, 2, true)
                ERS_SetRandomDamageToVehicle(veh)
                SetVehicleBodyHealth(veh, 0)
                SetVehicleEngineHealth(veh, 0)
            end
        end

        for index, objNetId in pairs(objectList) do
            local obj = NetToObj(objNetId)
            if DoesEntityExist(obj) then
                ERS_RequestNetControlForEntity(obj) 
                PlaceObjectOnGroundProperly(obj)
            end
        end
        
        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                TaskSetBlockingOfNonTemporaryEvents(ped, true)
                local chance = math.random(100)
                if chance > 50 then
                    local scenario = ERS_SelectRandomWoundedPersonScenario()
                    TaskStartScenarioInPlace(ped, scenario, 0, true)
                else
                    SetEntityHealth(ped, 0)
                end
                ERS_ApplyBloodToPed(ped)
            end
        end

        ERS_CreateTemporaryBlipForEntities(vehicleList, 15000)
        ERS_CreateTemporaryBlipForEntities(pedList, 15000)
        ERS_CreateTemporaryBlipForEntities(objectList, 15000)

        -- ERS_PerformTimedActionOnPed(calloutDataClient, pedList)

    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        local diameter = 20

        -- Build vehicle
        local vehModel = "stockade"
        local vehType = "automobile"
        local vehCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local vehHeading = math.random(360)
        local vehNetId = ERS_CreateVehicle(vehModel, vehType, vehCoords, vehHeading)
        local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
        table.insert(vehicleList, vehNetId)

        -- Build ped
        local seatIndex = -1
        for i = 1, 2 do
            local pedModel = ERS_GetRandomModel(Config.randomMoneyTransportPeds)
            local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z+3.0)
            local pedHeading = math.random(360)
            local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
            local ped = NetworkGetEntityFromNetworkId(pedNetId)
            SetPedIntoVehicle(ped, vehicle, seatIndex)
            seatIndex = seatIndex + 1
            table.insert(pedList, pedNetId)
        end

         -- Build objects
         local randomAmountOfObjects = math.random(3,10)
         for i = 1, randomAmountOfObjects do
            local diameter = 20
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)

            local objModel = ERS_GetRandomModel(Config.randomMoneyObjects)
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
                    local fireSize = Config.RandomSmallFireOrSmokeSize[math.random(#Config.RandomSmallFireOrSmokeSize)]
                    local fireType = Config.NormalFireTypes[math.random(#Config.NormalFireTypes)]
                    fireList[#fireList + 1] = ERS_AddCalloutFire(vector3(coords.x, coords.y, coords.z-0.5), fireType, fireSize)
                elseif UsingSmartFiresLite then
                    local fireSize = Config.RandomSmallFireOrSmokeSize[math.random(#Config.RandomSmallFireOrSmokeSize)]
                    fireList[#fireList + 1] = ERS_AddCalloutFire(vector3(coords.x, coords.y, coords.z-0.5), "normal", fireSize)
                end
            end
        end

        return true
    end
}