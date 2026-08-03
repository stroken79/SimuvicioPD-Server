Config.Callouts["airport_fire"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Fire at an airport",
    CalloutDescriptions = {
        "A fire has broken out at the airport, requiring immediate intervention from fire services.",
        "Emergency teams are needed to extinguish a fire at the airport.",
        "Authorities report an airport fire threatening nearby structures, necessitating urgent action.",
        "A large fire has erupted at the airport, and additional firefighting units are needed to contain it.",
        "Immediate response required to an airport fire endangering surrounding areas.",
        "A fire at the airport is escalating, and reinforcements are needed to assist local fire services.",
        "Fire crews are requesting backup to control a severe fire at the airport.",
        "An urgent call for assistance has been made to deal with an airport fire spreading towards nearby properties.",
        "Responders are on the scene of an airport fire and require additional support to prevent further damage.",
        "A significant fire at the airport demands immediate intervention to protect lives and property.",
    },                               
    CalloutUnitsRequired = {
        description = "Fire.",
        policeRequired = false,
        ambulanceRequired = false,
        fireRequired = true,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(1740.46, 3327.01, 41.22), 
        [2] = vector3(1746.42, 3306.86, 41.22), 
        [3] = vector3(1725.30, 3294.12, 41.22), 
        [4] = vector3(1722.81, 3320.40, 41.22), 
        [5] = vector3(1697.10, 3289.78, 41.15), 
        [6] = vector3(1693.23, 3293.00, 41.15), 
        [7] = vector3(2143.53, 4785.09, 40.97), 
        [8] = vector3(2139.51, 4772.66, 41.00), 
        [9] = vector3(2132.91, 4771.54, 40.97), 
        [10] = vector3(-1482.70, -3253.20, 13.95), 
        [11] = vector3(-1348.19, -3286.84, 13.94), 
        [12] = vector3(-1282.99, -3333.97, 14.14), 
        [13] = vector3(-1265.18, -3424.46, 14.14), 
        [14] = vector3(-1119.58, -3487.74, 14.14), 
        [15] = vector3(-1136.13, -3520.39, 14.14), 
        [16] = vector3(-1916.21, -2994.46, 13.94), 
        [17] = vector3(-1785.29, -2761.26, 13.94), 
        [18] = vector3(-948.39, -2930.32, 13.94), 
        [19] = vector3(-925.56, -3041.93, 13.95), 
        [20] = vector3(-938.65, -2800.90, 13.97),      
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


        local vehicle
        for index, vehNetId in pairs(vehicleList) do
            local veh = NetToVeh(vehNetId)
            if DoesEntityExist(veh) then
                vehicle = veh
                ERS_RequestNetControlForEntity(vehicle) 
                ERS_SetRandomDamageToVehicle(vehicle)
                SetVehicleBodyHealth(vehicle, 0)
                SetVehicleEngineHealth(vehicle, 0)
            end
        end

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                TaskSetBlockingOfNonTemporaryEvents(ped, true)
                TaskTurnPedToFaceEntity(ped, vehicle, -1)
                Wait(1000)
                local scenario = ERS_SelectRandomBystanderScenario()
                TaskStartScenarioInPlace(ped, scenario, 0, true)
            end
        end

        ERS_CreateTemporaryBlipForEntities(vehicleList, 15000)
        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        local diameter = 20

        if UsingSmartFiresV2 or UsingSmartFires then
            local fireSize = Config.RandomLargeFireOrSmokeSize[math.random(#Config.RandomLargeFireOrSmokeSize)]
            local fireType = Config.AllFireTypes[math.random(#Config.AllFireTypes)]
            fireList[#fireList + 1] = ERS_AddCalloutFire(vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z-0.5), fireType, fireSize)
        elseif UsingSmartFiresLite then
            local fireSize = Config.RandomLargeFireOrSmokeSize[math.random(#Config.RandomLargeFireOrSmokeSize)]
            fireList[#fireList + 1] = ERS_AddCalloutFire(vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z-0.5), "normal", fireSize)
        end

        -- Build vehicle
        local vehModel = ERS_GetRandomModel(Config.randomAirportVehicles)
        local vehType = "automobile"
        local vehCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local vehHeading = math.random(360)
        local vehNetId = ERS_CreateVehicle(vehModel, vehType, vehCoords, vehHeading)
        local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
        table.insert(vehicleList, vehNetId)


        -- Build bystander(s)
        local randomAmountOfBystanders = math.random(3)
        for i = 1, randomAmountOfBystanders do
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)

            local pedModel = ERS_GetRandomModel(Config.randomAirportPeds)
            local pedCoords = vector3(coords.x, coords.y, coords.z)
            local pedHeading = math.random(360)
            local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
            local ped = NetworkGetEntityFromNetworkId(pedNetId)
            table.insert(pedList, pedNetId)
        end

        return true
    end
}