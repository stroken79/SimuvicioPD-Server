Config.Callouts["stolen_boat"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Stolen boat",
    CalloutDescriptions = {
        "Respond to a stolen boat; immediate action required to apprehend suspects and secure the vessel.",
        "Emergency response needed for a stolen boat; deploy marine units to intercept and recover the vessel.",
        "Urgent call to respond to a stolen boat; mobilize resources to apprehend the perpetrators and return the vessel safely.",
        "Stolen boat reported; respond swiftly to prevent the vessel from being used for illicit activities.",
        "Incident alert: stolen boat; deploy law enforcement assets to pursue and recover the stolen vessel.",
        "Emergency response required for a stolen boat; prioritize apprehension of suspects and recovery of the vessel.",
        "Respond to the stolen boat incident; expedite efforts to apprehend suspects and secure the vessel.",
        "Stolen boat reported; activate emergency protocols and coordinate with maritime units to intercept the vessel.",
        "Immediate response needed for a stolen boat; prioritize public safety and prevent further criminal activity.",
        "Urgent callout: stolen boat; respond promptly to apprehend suspects and safeguard maritime security.",
    },                                                               
    CalloutUnitsRequired = {
        description = "Police.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(320.3609, 3864.7258, 31.8404),
        [2] = vector3(-720.7589, -1345.0660, 0.1235),
        [3] = vector3(-922.4822, -1456.1830, 0.0786),
        [4] = vector3(-969.0080, -1370.0115, 0.0762),
        [5] = vector3(-968.2100, -1757.9313, 0.4642),
        [6] = vector3(-1233.5177, -1928.0292, 0.6897),
        [7] = vector3(-1556.8328, -1318.2015, 0.7824),
        [8] = vector3(-1822.8844, -1007.8162, 1.9738),
        [9] = vector3(-2903.9915, -71.5243, 0.3220),
        [10] = vector3(-3163.2051, 200.5076, 0.4951),
        [11] = vector3(-3276.3652, 826.4033, -0.1878),
        [12] = vector3(-3259.8818, 1342.3621, 0.3533),
        [13] = vector3(-2861.9382, 2314.9438, 0.0152),
        [14] = vector3(-64.3367, 3825.8274, 30.6813),
        [15] = vector3(1303.2426, 3718.4692, 30.0989),
        [16] = vector3(2338.5203, 4292.5669, 29.8632),
        [17] = vector3(1344.1510, 4246.4478, 30.7815),
        [18] = vector3(-834.3231, 6160.4565, 0.2792),
        [19] = vector3(-289.6857, 6687.8032, -1.2348),
        [20] = vector3(1191.1776, 6624.9277, 1.3072),
    },                      
    PedChanceToFleeFromPlayer = 100,    -- Value between 0 and 100 -> Lower is less chance.
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

            end
        end
        
        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                ERS_SetPedToFleeFromPlayer(ped)
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

        -- Build suspect
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