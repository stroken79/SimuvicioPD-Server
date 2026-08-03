Config.Callouts["vehicle_fire"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Vehicle on fire",
    CalloutDescriptions = {
        "Emergency responders are required to extinguish flames engulfing a vehicle.",
        "Authorities report a vehicle ablaze, requiring immediate intervention to ensure safety.",
        "A vehicle fire has been reported, prompting urgent action to prevent further damage.",
        "Critical situation with a vehicle on fire; additional units are needed for support.",
        "Immediate response needed to tackle a vehicle engulfed in flames.",
        "A vehicle is burning, posing a severe threat; reinforcements are necessary to contain the fire.",
        "Emergency crews are requesting backup to extinguish a vehicle fire and prevent its spread.",
        "An urgent call for help has been issued to deal with a vehicle engulfed in flames.",
        "Responders are on the scene of a vehicle fire and need extra support to control the blaze.",
        "A serious emergency involving a vehicle on fire demands swift action to prevent escalation.",
    },        
    CalloutUnitsRequired = {
        description = "Police, Ambulance, Fire.",
        policeRequired = true,
        ambulanceRequired = true,
        fireRequired = true,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(1221.65, -1950.32, 40.40),
        [2] = vector3(-161.30, -164.19, 43.62),
        [3] = vector3(101.98, -349.36, 42.34),
        [4] = vector3(-134.71, -982.66, 27.27),
        [5] = vector3(641.63, -432.34, 24.74),
        [6] = vector3(-58.80, -1212.65, 28.59),
        [7] = vector3(362.10, -1702.46, 32.53),
        [8] = vector3(-526.54, -1689.42, 19.20),
        [9] = vector3(-2961.83, 59.35, 11.60),
        [10] = vector3(-2308.16, 261.28, 169.60),
        [11] = vector3(-1678.73, 488.84, 128.87),
        [12] = vector3(-1498.19, 1504.78, 115.61),
        [13] = vector3(-1134.82, 2692.60, 18.80),
        [14] = vector3(-414.71, 2964.71, 24.94),
        [15] = vector3(527.80, 3093.14, 40.46)            

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
                ERS_SetRandomDamageToVehicle(veh)
                SetVehicleBodyHealth(veh, 0)
                SetVehicleEngineHealth(veh, 0)
                StartEntityFire(veh)
                --AddExplosion(pos.x, pos.y, pos.z, 0, 1.0, true, false, 1.0)
            end
        end
        
        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                TaskSetBlockingOfNonTemporaryEvents(ped, true)
                SetEntityHealth(ped, 0)
                StartEntityFire(ped)
                ERS_ApplyBloodToPed(ped)
            end
        end

        ERS_CreateTemporaryBlipForEntities(vehicleList, 15000)
        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)


        -- Build vehicle
        local vehModel = ERS_GetRandomModel(Config.randomVehicles)
        local vehType = "automobile"
        local vehCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local vehHeading = math.random(360)
        local vehNetId = ERS_CreateVehicle(vehModel, vehType, vehCoords, vehHeading)
        local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
        table.insert(vehicleList, vehNetId)

        -- Build victim
        local pedModel = ERS_GetRandomModel(Config.randomPeds)
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        SetPedIntoVehicle(ped, vehicle, -1)
        table.insert(pedList, pedNetId)

        return true
    end
}