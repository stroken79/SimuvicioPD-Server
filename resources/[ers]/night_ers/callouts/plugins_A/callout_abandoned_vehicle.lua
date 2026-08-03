Config.Callouts["abandoned_vehicle"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Abandoned vehicle",
    CalloutDescriptions = {
        "Investigate a vehicle left in a deserted area; check for any distressed occupants or suspicious items.",
        "Alert: abandoned car found near a construction site; ensure it is not obstructing any operations or posing a hazard.",
        "Units required: car discovered with doors open and no one around; examine the scene for any signs of foul play.",
        "Notice: vehicle parked in an unusual spot for an extended period; verify it is not a stolen or abandoned car.",
        "Alert: report of a vehicle left in a school zone; determine if it poses any danger to children and staff.",
        "Incident reported: vehicle found with the engine running but no driver in sight; ensure it is secure and investigate.",
        "Respond to a situation involving a car left on train tracks; coordinate with transportation authorities to prevent accidents.",
        "Situation alert: vehicle discovered with hazardous materials warning signs; prioritize safety and coordinate with hazmat teams.",
        "Alert: car abandoned in a flood-prone area; assess the risk of it being swept away and causing damage.",
        "Response needed: suspicious vehicle found near a high-security facility; check for any potential threats or security breaches.",
    },
    CalloutUnitsRequired = {
        description = "Tow",
        policeRequired = false,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = true,
    },
    CalloutLocations = {
        [1] = vector3(482.5813, -902.2799, 35.9722),
        [2] = vector3(-498.6677, 6267.7412, 11.3615),
        [3] = vector3(-742.7029, 5812.6357, 17.4803),
        [4] = vector3(-767.0907, 5543.6484, 33.4922),
        [5] = vector3(-916.5244, 5250.4307, 83.9764),
        [6] = vector3(-525.5445, 4948.1494, 147.3998),
        [7] = vector3(151.7183, 4416.7876, 75.6445),
        [8] = vector3(1466.3269, 4531.2056, 52.0130),
        [9] = vector3(1504.0210, 3749.1111, 34.0672),
        [10] = vector3(1547.0118, 3635.0022, 34.4262),
        [11] = vector3(1986.4946, 3661.6140, 33.5053),
        [12] = vector3(2458.8081, 3812.0923, 40.1474),
        [13] = vector3(2672.1116, 3534.7649, 51.9782),
        [14] = vector3(2568.6899, 2890.6724, 39.7117),
        [15] = vector3(1522.8920, 787.9393, 77.4461),
        [16] = vector3(1123.0111, 258.1617, 80.8556),
        [17] = vector3(1019.5189, -698.3103, 56.8416),
        [18] = vector3(1167.9501, -1548.5294, 34.6922),
        [19] = vector3(1112.2905, -2524.5283, 32.4943),
        [20] = vector3(599.6377, -2757.5508, 6.0598),
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
                
                for i = 0, 7 do -- Tire indices range from 0 to 7
                    if math.random(100) < 75 then
                        SetVehicleTyreBurst(veh, i, true, 1000.0)
                    end
                end
        
                local numDoors = GetNumberOfVehicleDoors(veh)
                for i = 0, numDoors - 1 do
                    if math.random(100) < 50 then
                        SetVehicleDoorOpen(veh, i, false, false)
                    end
                end

                local randomDirtLevel = math.random(0, 15)
                SetVehicleDirtLevel(veh, randomDirtLevel+.0)
            end
        end

        ERS_CreateTemporaryBlipForEntities(vehicleList, 15000)
   
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
   
        return true
    end
}