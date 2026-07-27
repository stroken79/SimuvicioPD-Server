Config.Callouts["construction_incident"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Construction site incident",
    CalloutDescriptions = {
        "Emergency: respond immediately to a construction site incident; ensure the safety of all workers and secure the area.",
        "Urgent alert: dispatch units to the scene of a construction accident; provide immediate assistance and medical support.",
        "Critical response: attend to a construction site emergency; prioritize rescuing injured individuals and managing the situation.",
        "Immediate action: investigate reports of an incident at a construction site; take necessary measures to stabilize the area.",
        "Alert: respond promptly to a construction site accident; ensure the safety of workers and address any hazards.",
        "Incident reported: handle a construction site emergency; coordinate with relevant authorities to manage the situation effectively.",
        "Situation alert: assist in responding to a construction accident; secure the site and provide necessary support to emergency services.",
        "Emergency response: deal with an incident at a construction site; follow safety protocols to protect workers and contain the area.",
        "Immediate intervention: respond to reports of a construction site accident; prioritize the safety of all individuals and mitigate risks.",
        "Response needed: investigate an incident at a construction site urgently; take appropriate actions to ensure safety and prevent further harm.",
    },                                                                            
    CalloutUnitsRequired = {
        description = "Police, ambulance.",
        policeRequired = true,
        ambulanceRequired = true,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(44.8051, -332.5600, 43.6708),
        [2] = vector3(-459.1893, -1055.8129, 29.1281),
        [3] = vector3(-452.7524, -1011.5723, 22.4238),
        [4] = vector3(-448.3265, -944.9791, 29.3928),
        [5] = vector3(-451.2589, -893.2188, 47.9797),
        [6] = vector3(-466.1203, -896.0312, 43.3733),
        [7] = vector3(-471.4753, -923.3779, 43.7068),
        [8] = vector3(-503.3624, -974.1968, 23.5567),
        [9] = vector3(34.9236, -429.9841, 44.6752),
        [10] = vector3(43.1620, -405.4659, 45.5525),
        [11] = vector3(58.3875, -397.1533, 42.2667),
        [12] = vector3(34.9210, -350.7701, 42.4556),
        [13] = vector3(35.5786, -395.5785, 55.2863),
        [14] = vector3(40.7332, -407.7932, 73.9167),
        [15] = vector3(127.8936, -349.3301, 42.9060),
        [16] = vector3(46.5655, -459.1139, 42.9473),
        [17] = vector3(85.5404, -435.6951, 35.9977),
        [18] = vector3(83.5077, -420.9894, 37.5525),
        [19] = vector3(19.7530, -362.7425, 39.3051),
        [20] = vector3(135.2936, -386.8390, 43.3106),
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


        local victim

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
                if index == 1 then
                    victim = ped
                    SetEntityHealth(victim, 0)
                else
                    -- Bystanders
                    TaskTurnPedToFaceEntity(ped, victim, 2000)
                    Wait(2000)
                    local scenario = ERS_SelectRandomBystanderScenario()
                    TaskStartScenarioInPlace(ped, scenario, 0, true)
                end
            end
        end
    
        ERS_CreateTemporaryBlipForEntities(pedList, 15000)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)


        -- Build victim
        local pedModel = ERS_GetRandomModel(Config.randomConstructionSitePeds)
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        table.insert(pedList, pedNetId)

        -- Build heavy vehicle
        local vehModel = ERS_GetRandomModel(Config.randomHeavyVehicles)
        local vehType = "automobile"
        local vehCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z+2.0)
        local vehHeading = math.random(360)
        local vehNetId = ERS_CreateVehicle(vehModel, vehType, vehCoords, vehHeading)
        local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
        table.insert(vehicleList, vehNetId)

        -- Build bystanders
        local randomAmountOfBystanders = math.random(4)
        for i = 1, randomAmountOfBystanders do
            local diameter = 20
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
            
            local bystanderPedModel = ERS_GetRandomModel(Config.randomConstructionSitePeds)
            local bystanderPedCoords = vector3(coords.x, coords.y, coords.z+1.0)
            local bystanderPedHeading = math.random(360)
            local bystanderPedNetId = ERS_CreatePed(bystanderPedModel, bystanderPedCoords, bystanderPedHeading)
            local bystanderPed = NetworkGetEntityFromNetworkId(pedNetId)
            table.insert(pedList, bystanderPedNetId)
        end
    
        return true
    end
}