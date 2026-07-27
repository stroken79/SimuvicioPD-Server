Config.Callouts["prisoner_escape_bus"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Prisoner transport bus escape",
    CalloutDescriptions = {
        "Respond immediately to an attempted escape from a prisoner transport bus; secure the area and prevent any escapes.",
        "Emergency alert: escape attempt from a prisoner transport bus in progress; deploy units to contain the situation.",
        "Urgent response required: prisoners attempting to flee from transport bus; ensure all prisoners are accounted for and secure the vicinity.",
        "Critical situation: attempted breakout from a prisoner transport bus; act swiftly to prevent any escapes and control the scene.",
        "Alert: prisoners trying to escape from transport bus; immediate intervention needed to apprehend escapees and maintain security.",
        "Prisoner transport bus incident: escape attempt underway; urgent action needed to secure the bus and surroundings.",
        "Handle an escape attempt from a prisoner transport bus; prioritize containment and coordination with law enforcement.",
        "Emergency situation: prisoners attempting to escape from bus; ensure area lockdown and assist in recapture efforts.",
        "Urgent alert: breakout attempt from prisoner transport bus; respond quickly to control the scene and prevent further incidents.",
        "Critical response needed: prisoner transport bus escape attempt; secure the area, assist in recapture, and restore order.",
    },
    CalloutUnitsRequired = {
        description = "Police.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(-430.1359, -1841.9290, 19.4628),
        [2] = vector3(225.9333, -1226.3806, 38.2550),
        [3] = vector3(778.6886, -1006.5396, 25.9907),
        [4] = vector3(778.5501, -851.2286, 43.3722),
        [5] = vector3(761.3960, -477.1339, 36.2214),
        [6] = vector3(582.0797, -75.4963, 70.7756),
        [7] = vector3(894.2089, 61.3250, 78.9686),
        [8] = vector3(422.2990, 296.2672, 103.0581),
        [9] = vector3(-146.1876, -87.6049, 55.1551),
        [10] = vector3(1407.4314, -1749.7058, 65.9185),
        [11] = vector3(1013.7170, -1435.1545, 35.6374),
        [12] = vector3(858.6818, -1072.3356, 39.1867),
        [13] = vector3(737.6019, -602.1349, 36.2894),
        [14] = vector3(666.0109, -247.3925, 43.8801),
        [15] = vector3(150.5485, 85.2522, 84.6272),
        [16] = vector3(-537.0259, 254.9205, 83.0729),
        [17] = vector3(-778.9194, 564.0609, 125.2098),
        [18] = vector3(-1052.4857, 1178.5732, 216.5182),
        [19] = vector3(-1431.6735, 1912.0579, 73.7801),
        [20] = vector3(-1305.9124, 2536.4126, 18.9174),
        [21] = vector3(-2350.6760, 3425.3782, 28.8471),
        [22] = vector3(-2314.3596, 4168.1719, 38.7900),
        [23] = vector3(-1917.4707, 4439.6279, 40.5788),
        [24] = vector3(-1560.4316, 4733.1812, 50.4538),
        [25] = vector3(-777.4516, 5262.8662, 89.9326),
        [26] = vector3(170.4841, 4417.7505, 75.2792),
        [27] = vector3(849.2275, 4230.1768, 50.8234),
        [28] = vector3(1735.9677, 4574.9873, 39.7539),
        [29] = vector3(2448.9150, 4597.9678, 36.9199),
        [30] = vector3(2713.1785, 3906.6541, 43.5291),
    },                      
    PedChanceToFleeFromPlayer = 75,     -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 20,       -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 50,          -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 20,      -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 10000, -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 15000, -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "flee",  -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_unarmed",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)

        for index, vehNetId in pairs(vehicleList) do
            local veh = NetToVeh(vehNetId)
            if DoesEntityExist(veh) then
                ERS_RequestNetControlForEntity(veh)
                SetEntityRotation(veh, 0, -90.01, 0, 2, true)
                ERS_SetRandomDamageToVehicle(veh)
                SetVehicleBodyHealth(veh, 0)
                SetVehicleEngineHealth(veh, 0)
            end
        end
        
        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped)
                ERS_ApplyBloodToPed(ped)
                if index == 1 then
                    ERS_SetPedToPassout(ped)
                else
                    ERS_SetPedToFleeFromPlayer(ped)
                end
            end
        end

        ERS_CreateTemporaryBlipForEntities(vehicleList, 15000)
        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        local diameter = 20
        
        -- Build vehicle
        local vehModel = "pbus"
        local vehType = "automobile"
        local vehCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z+1.0)
        local vehHeading = math.random(360)
        local vehNetId = ERS_CreateVehicle(vehModel, vehType, vehCoords, vehHeading)
        local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
        table.insert(vehicleList, vehNetId)

        -- Build ped
        local pedModel = "s_m_m_prisguard_01"
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        SetPedIntoVehicle(ped, vehicle, -1)
        table.insert(pedList, pedNetId)


        local randomAmountOfPassengers = math.random(10)
        -- Build passengers
        for i = 1, randomAmountOfPassengers do
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
            local passengerPedModel = ERS_GetRandomModel(Config.randomPrisonerPeds)
            local passengerPedCoords = vector3(coords.x, coords.y, coords.z+2.0)
            local passengerPedHeading = math.random(360)
            local passengerPedNetId = ERS_CreatePed(passengerPedModel, passengerPedCoords, passengerPedHeading)
            local passengerPed = NetworkGetEntityFromNetworkId(pedNetId)
            table.insert(pedList, passengerPedNetId)
        end

        return true
    end
}