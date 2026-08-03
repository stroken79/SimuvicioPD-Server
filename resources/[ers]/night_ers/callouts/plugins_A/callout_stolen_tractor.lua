Config.Callouts["stolen_tractor"] = {
    Enabled = true,
    Priority = 1,
    CalloutName = "Theft of a tractor",
    CalloutDescriptions = {
        "Reports of theft of a tractor, details pending",
        "Suspected theft of a tractor reported, further information needed",
        "Incident involving stolen tractor, assess situation for safety",
        "Theft of a tractor reported, prioritize response for recovery",
        "Vehicle reported missing, coordinate search and recovery efforts",
        "Suspected theft of vehicle, approach investigation with caution",
        "Reports of theft of a tractor, prioritize response for recovery",
        "Theft of a tractor incident reported, coordinate with authorities",
    },            
    CalloutUnitsRequired = {
        description = "Police.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(2580.3032, 4350.1309, 40.6124),
        [2] = vector3(2115.0203, 4938.2480, 40.7989),
        [3] = vector3(2339.8333, 4944.9595, 41.9972),
        [4] = vector3(2518.6138, 5010.1162, 44.0731),
        [5] = vector3(2710.1873, 4156.1001, 43.0990),
        [6] = vector3(1631.6482, 3870.9463, 33.8225),
        [7] = vector3(304.6279, 6515.4443, 29.3935),
        [8] = vector3(-458.2026, -1713.3237, 18.6376),
        [9] = vector3(1494.8003, -1941.1366, 70.7175),
        [10] = vector3(1440.6566, 1034.6569, 114.2230),
    },
    PedChanceToFleeFromPlayer = 90,     -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 10,       -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 10,          -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 25,      -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 10000,-- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 15000,-- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "flee",  -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_knife",
        "weapon_pistol",
    },
    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)
        local vehicle

        for index, vehNetId in pairs(vehicleList) do
            local veh = NetToVeh(vehNetId)
            if DoesEntityExist(veh) then
                vehicle = veh
                ERS_RequestNetControlForEntity(vehicle) 
            end
        end

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                if not IsPedOnAnyBike(ped) then
                    SmashVehicleWindow(vehicle, 0) -- break driver window for example
                end
                if not IsPedInAnyVehicle(ped, true) then
                    TaskEnterVehicle(ped, vehicle, 5000, -1, 2.0, 1, 0)
                    Wait(5000)
                    ERS_SetPedToFleeFromPlayer(ped)
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
        -- Build vehicle
        local vehModel = "tractor2"
        local vehType = "automobile"
        local vehCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local vehHeading = math.random(360)
        local vehNetId = ERS_CreateVehicle(vehModel, vehType, vehCoords, vehHeading)
        local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
        table.insert(vehicleList, vehNetId)

        -- Build ped
        local pedModel = ERS_GetRandomModel(Config.randomPeds)
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z +1.0)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        SetPedIntoVehicle(ped, vehicle, -1)
        table.insert(pedList, pedNetId)

        return true
    end
}
