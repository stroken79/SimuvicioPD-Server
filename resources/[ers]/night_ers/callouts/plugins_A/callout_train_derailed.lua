Config.Callouts["train_derailed"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Derailed train",
    CalloutDescriptions = {
        "A train has derailed, requiring immediate intervention from emergency services.",
        "Emergency teams are needed to assist with a derailed train incident.",
        "Authorities report a train derailment, necessitating urgent action to secure the area.",
        "A train has gone off the tracks, and additional units are needed to manage the situation.",
        "Immediate response required to a train derailment endangering surrounding areas.",
        "A derailed train is blocking the tracks, and reinforcements are needed to assist local authorities.",
        "Emergency crews are requesting backup to handle the aftermath of a train derailment.",
        "An urgent call for assistance has been made to deal with a train that has derailed.",
        "Responders are on the scene of a train derailment and require additional support to prevent further damage.",
        "A significant train derailment demands immediate intervention to protect lives and restore order.",
    },                                          
    CalloutUnitsRequired = {
        description = "Police, Ambulance, Fire.",
        policeRequired = true,
        ambulanceRequired = true,
        fireRequired = true,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(2442.1746, 2550.7461, 42.1325), 
        -- Add more to 40
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
                
                FreezeEntityPosition(veh, false)
                SetEntityCollision(veh, true, true)
                SetRenderTrainAsDerailed(veh, true)
                SetEntityRotation(veh, 0, math.random(0, 360)-0.01, 0, 2, true)
                ERS_SetRandomDamageToVehicle(veh)
                SetVehicleBodyHealth(veh, 0)
                SetVehicleEngineHealth(veh, 0)
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

        for index, objNetId in pairs(objectList) do
            local obj = NetToObj(objNetId)
            if DoesEntityExist(obj) then
                ERS_RequestNetControlForEntity(obj) 
                PlaceObjectOnGroundProperly(obj)
            end
        end

        ERS_CreateTemporaryBlipForEntities(vehicleList, 30000)
        ERS_CreateTemporaryBlipForEntities(pedList, 30000)
        ERS_CreateTemporaryBlipForEntities(objectList, 30000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        local diameter = 50
        local randomAmountOfTrainCarriages = math.random(2,5)

        -- Build vehicle
        local vehModel = "freight"
        local vehType = "train"
        local vehCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local vehHeading = math.random(360)
        local vehNetId = ERS_CreateVehicle(vehModel, vehType, vehCoords, vehHeading)
        local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
        table.insert(vehicleList, vehNetId)

        for i = 1, randomAmountOfTrainCarriages do
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
            local vehModel = ERS_GetRandomModel(Config.randomTrainCarriages)
            local vehType = "train"
            local vehCoords = vector3(coords.x, coords.y, coords.z)
            local vehHeading = math.random(360)
            local vehNetId = ERS_CreateVehicle(vehModel, vehType, vehCoords, vehHeading)
            local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
            table.insert(vehicleList, vehNetId)

            -- Build smoke
            if UsingSmartFiresV2 or UsingSmartFires then
                local smokeSize = Config.RandomMediumFireOrSmokeSize[math.random(#Config.RandomMediumFireOrSmokeSize)]
                local smokeType = Config.AllSmokeTypes[math.random(#Config.AllSmokeTypes)]
                smokeList[#smokeList + 1] = ERS_AddCalloutSmoke(vector3(coords.x, coords.y, coords.z-0.5), smokeType, smokeSize)
            elseif UsingSmartFiresLite then
                local smokeSize = Config.RandomMediumFireOrSmokeSize[math.random(#Config.RandomMediumFireOrSmokeSize)]
                smokeList[#smokeList + 1] = ERS_AddCalloutSmoke(vector3(coords.x, coords.y, coords.z-0.5), "normal", smokeSize)
            end
        end

        local randomAmountOfFires = math.random(2,6)
        for i = 1, randomAmountOfFires do
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
            -- Build fires
            if UsingSmartFiresV2 or UsingSmartFires then
                local fireSize = Config.RandomMediumFireOrSmokeSize[math.random(#Config.RandomMediumFireOrSmokeSize)]
                local fireType = Config.NormalFireTypes[math.random(#Config.NormalFireTypes)]
                fireList[#fireList + 1] = ERS_AddCalloutFire(vector3(coords.x, coords.y, coords.z-0.5), fireType, fireSize)
            elseif UsingSmartFiresLite then
                local fireSize = Config.RandomLargeFireOrSmokeSize[math.random(#Config.RandomLargeFireOrSmokeSize)]
                fireList[#fireList + 1] = ERS_AddCalloutFire(vector3(coords.x, coords.y, coords.z-0.5), "normal", fireSize)
            end
        end

        -- Build objects
        local randomAmountOfObjects = math.random(7)
        for i = 1, randomAmountOfObjects do
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
            local objModel = ERS_GetRandomModel(Config.randomDirtObjects)
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

        -- Build victims
        local victims = math.random(20)
        for i = 1, victims do
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
            local pedModel = ERS_GetRandomModel(Config.randomPeds)
            local pedCoords = vector3(coords.x, coords.y, coords.z + 3.0)
            local pedHeading = math.random(360)
            local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
            local ped = NetworkGetEntityFromNetworkId(pedNetId)
            table.insert(pedList, pedNetId)
        end    
    
        return true
    end
}