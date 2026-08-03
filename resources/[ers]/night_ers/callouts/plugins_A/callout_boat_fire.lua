Config.Callouts["boat_fire"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Boat on fire",
    CalloutDescriptions = {
        "Emergency responders are required to extinguish flames engulfing a boat.",
        "Authorities report a boat ablaze, demanding immediate intervention to ensure safety.",
        "A boat fire has been reported, necessitating urgent action to prevent further damage.",
        "Critical situation with a boat on fire; additional units are needed for support.",
        "Immediate response needed to tackle a boat engulfed in flames.",
        "A boat is burning, posing a severe threat; reinforcements are necessary to contain the fire.",
        "Emergency crews are requesting backup to assist in managing a boat fire and prevent its spread.",
        "An urgent call for help has been issued to handle a boat engulfed in flames and ensure safety.",
        "Responders are on the scene of a boat fire and need extra support to control the blaze.",
        "A serious emergency involving a boat on fire demands swift action to prevent escalation.",
    },                             
    CalloutUnitsRequired = {
        description = "Police, Ambulance, Fire.",
        policeRequired = true,
        ambulanceRequired = true,
        fireRequired = true,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(-2029.22, -797.05, 2.16),
        [2] = vector3(-2661.27, -236.46, 2.16),
        [3] = vector3(-3174.36, 665.70, 2.16),
        [4] = vector3(-3239.07, 1421.02, 2.16),
        [5] = vector3(-3118.33, 1943.30, 2.16),
        [6] = vector3(-2517.58, 2573.30, 2.16),
        [7] = vector3(-2987.53, 3180.48, 2.16),
        [8] = vector3(-2656.73, 3659.40, 2.16),
        [9] = vector3(-1798.92, 4985.75, 2.16),
        [10] = vector3(-1568.89, 5229.72, 2.16),
        [11] = vector3(-968.35, 5672.23, 2.16),
        [12] = vector3(-310.43, 6615.29, 2.16),
        [13] = vector3(197.87, 7120.72, 2.16),
        [14] = vector3(1255.58, 6652.24, 2.16),
        [15] = vector3(2518.04, 6642.32, 2.16),
        [16] = vector3(3332.51, 6162.08, 2.16),
        [17] = vector3(3402.76, 5224.96, 2.16),
        [18] = vector3(3862.89, 4493.04, 2.16),
        [19] = vector3(3801.36, 3823.51, 2.16),
        [20] = vector3(3418.12, 2693.48, 2.16),
        [21] = vector3(3067.49, 1866.37, 2.16),
        [22] = vector3(2957.35, 801.10, 2.16),
        [23] = vector3(2900.93, 198.23, 2.16),
        [24] = vector3(2863.76, -619.72, 2.16),
        [25] = vector3(2536.89, -1505.16, 2.16),
        [26] = vector3(2204.72, -2297.75, 2.16),
        [27] = vector3(1842.65, -2711.85, 2.16),
        [28] = vector3(1497.10, -2793.84, 2.16),
        [29] = vector3(797.41, -2807.87, 2.16),
        [30] = vector3(524.35, -3208.54, 2.16),
        [31] = vector3(417.24, -2760.60, 2.16),
        [32] = vector3(145.56, -2691.64, 2.16),
        [33] = vector3(-275.30, -2742.84, 2.16),
        [34] = vector3(-485.02, -2321.13, 2.16),
        [35] = vector3(-822.42, -1458.82, 2.16),
        [36] = vector3(-983.20, -1376.05, 2.16),
        [37] = vector3(-1010.13, -1060.06, 2.16),
        [38] = vector3(-1606.03, -1271.05, 2.16),
        [39] = vector3(-1848.64, -1829.78, 2.16),
        [40] = vector3(-1821.09, -2573.49, 2.16),
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
                StartEntityFire(veh) -- Unsure if this native actually works...
                --AddExplosion(pos.x, pos.y, pos.z-2.0, 0, 1.0, true, false, 1.0) -- Optionally...
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


        -- Build boat
        local vehModel = ERS_GetRandomModel(Config.randomBoats)
        local vehType = "boat"
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

        -- Build passengers
        for seatIndex = 0, 1 do -- seats boats
            if GetPedInVehicleSeat(vehicle, seatIndex) == 0 then
                local passengerPedModel = ERS_GetRandomModel(Config.randomPeds)
                local passengerPedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
                local passengerPedHeading = math.random(360)
                local passengerPedNetId = ERS_CreatePed(passengerPedModel, passengerPedCoords, passengerPedHeading)
                local passengerPed = NetworkGetEntityFromNetworkId(pedNetId)
                SetPedIntoVehicle(passengerPed, vehicle, seatIndex)
                table.insert(pedList, passengerPedNetId)
            end
        end

        return true
    end
}