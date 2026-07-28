Config.Callouts["protest_haybales"] = {
    Enabled = true,
    Priority = 1,
    CalloutName = "Protest with hay bales on fire",
    CalloutDescriptions = {
        "Los manifestantes prendieron fuego a fardos de heno, lo que requirio la intervencion inmediata de los bomberos.",
        "Se necesitan equipos de emergencia para controlar un incendio iniciado por manifestantes que quemaban fardos de heno.",
        "Las autoridades informan que se incendiaron fardos de heno durante una protesta, lo que requiere una accion urgente.",
        "Se ha intensificado una protesta con fardos de heno en llamas y se necesitan unidades de extincion de incendios adicionales para contenerla.",
        "Se requiere una respuesta inmediata a un incendio de protesta que involucra fardos de heno y que pone en peligro las areas circundantes.",
        "Los manifestantes han encendido fardos de heno y se necesitan refuerzos para ayudar a los servicios de bomberos locales.",
        "Los equipos de bomberos solicitan refuerzos para controlar un grave incendio iniciado por manifestantes que quemaban fardos de heno.",
        "Se ha hecho un llamamiento urgente de ayuda para hacer frente a los fardos de heno quemados durante una protesta.",
        "Los socorristas se encuentran en el lugar de una protesta donde se queman fardos de heno y requieren apoyo adicional para evitar danos mayores.",
        "Un incendio importante en una protesta con fardos de heno exige una intervencion inmediata para proteger vidas y propiedades.",
    },                                     
    CalloutUnitsRequired = {
        description = "Police, Fire.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = true,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(903.23, 161.76, 74.04), 
        [2] = vector3(1113.25, 417.18, 83.67),        
        [3] = vector3(1543.74, 892.82, 77.47),    
        [4] = vector3(1614.32, 1105.89, 82.08), 
        [5] = vector3(2052.10, 2595.61, 53.69),
        [6] = vector3(2236.29, 2788.25, 44.15), 
        [7] = vector3(2853.91, 3515.08, 54.34), 
        [8] = vector3(2859.30, 3601.57, 52.95), 
        [9] = vector3(2878.75, 4194.57, 50.14), 
        [10] = vector3(2775.87, 4404.12, 48.96), 
        [11] = vector3(2649.70, 5079.81, 44.83), 
        [12] = vector3(2114.19, 6027.16, 50.92), 
        [13] = vector3(1528.76, 6442.59, 23.29), 
        [14] = vector3(8900.44, 6471.33, 31.35), 
        [15] = vector3(-176.06, 6199.81, 31.19), 
        [16] = vector3(-477.35, 5862.80, 33.60),
        [17] = vector3(-1189.78, 5261.50, 52.16), 
        [18] = vector3(-2015.21, 4496.73, 57.07), 
        [19] = vector3(-2241.45, 4260.30, 45.70),     
        [20] = vector3(-2474.10, 3637.44, 13.92),   
        [21] = vector3(-2631.86, 2855.54, 16.70),   
        [22] = vector3(-2707.72, 2295.90, 18.40),   
        [23] = vector3(-3096.80, 1315.54, 20.22),   
        [24] = vector3(-2988.84, 374.60, 14.79),   
        [25] = vector3(-2553.09, -164.87, 20.33),   
        [26] = vector3(-2164.92, -343.06, 13.19),   
        [27] = vector3(-1821.37, -608.59, 11.26),   
        [28] = vector3(-926.08, -564.75, 18.87),   
        [29] = vector3(-887.70, -512.39, 21.50),  
        [30] = vector3(-471.13, -528.49, 25.33),  
        [31] = vector3(-146.59, -492.57, 29.13),  
        [32] = vector3(290.05, -522.58, 34.08),  
        [33] = vector3(763.41, -606.53, 37.10),  
        -- Add more to 40
    },        
    PedChanceToFleeFromPlayer = 50,     -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 50,       -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 20,          -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 50,      -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 15000, -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 20000, -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "attack",  -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_knife",
        "weapon_hatchet",
        "weapon_crowbar",
    },
    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)

        for index, objNetId in pairs(objectList) do
            local obj = NetToObj(objNetId)
            if DoesEntityExist(obj) then
                ERS_RequestNetControlForEntity(obj) 
                PlaceObjectOnGroundProperly(obj)
            end
        end

        for index, vehNetId in pairs(vehicleList) do
            local veh = NetToVeh(vehNetId)
            if DoesEntityExist(veh) then
                ERS_RequestNetControlForEntity(veh)
                -- Add something here to alter the vehicle behaviour.
            end
        end

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                local scenario = ERS_SelectRandomProtesterScenario()
                TaskStartScenarioInPlace(ped, scenario, 0, true)
            end
        end

        ERS_CreateTemporaryBlipForEntities(vehicleList, 15000)
        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        local diameter = 20

        -- Build vehicle
        local vehModel = "tractor2"
        local vehType = "automobile"
        local vehCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local vehHeading = math.random(360)
        local vehNetId = ERS_CreateVehicle(vehModel, vehType, vehCoords, vehHeading)
        local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
        table.insert(vehicleList, vehNetId)

        -- Build objects
        local randomAmountOfObjects = math.random(7)
        for i = 1, randomAmountOfObjects do
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
            if UsingSmartFiresV2 or UsingSmartFires then
                local fireSize = Config.RandomLargeFireOrSmokeSize[math.random(#Config.RandomLargeFireOrSmokeSize)]
                local fireType = Config.NormalFireTypes[math.random(#Config.NormalFireTypes)]
                fireList[#fireList + 1] = ERS_AddCalloutFire(vector3(coords.x, coords.y, coords.z+0.6), fireType, fireSize)
            elseif UsingSmartFiresLite then
                local fireSize = Config.RandomLargeFireOrSmokeSize[math.random(#Config.RandomLargeFireOrSmokeSize)]
                fireList[#fireList + 1] = ERS_AddCalloutFire(vector3(coords.x, coords.y, coords.z+0.6), "normal", fireSize)
            end

            local objModel = "prop_haybale_02"
            local objCoords = vector3(coords.x, coords.y, coords.z) -- Haybales float apparently.
            local objHeading = math.random(360)
            local objNetId = ERS_CreateObject(objModel, objCoords, objHeading)
            if objNetId then    
                local obj = NetworkGetEntityFromNetworkId(objNetId)
                table.insert(objectList, objNetId)
            else
                DebugPrint("^1ERROR ^7Could not create object: "..objModel)
            end
        end

        -- Build smoke
        if UsingSmartFiresV2 or UsingSmartFires then
            local smokeSize = Config.RandomMediumFireOrSmokeSize[math.random(#Config.RandomMediumFireOrSmokeSize)]
            local smokeType = Config.AllSmokeTypes[math.random(#Config.AllSmokeTypes)]
            smokeList[#smokeList + 1] = ERS_AddCalloutSmoke(vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z-0.5), smokeType, smokeSize)
        elseif UsingSmartFiresLite then
            local smokeSize = Config.RandomMediumFireOrSmokeSize[math.random(#Config.RandomMediumFireOrSmokeSize)]
            smokeList[#smokeList + 1] = ERS_AddCalloutSmoke(vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z-0.5), "normal", smokeSize)
        end

        -- Build protesters
        local suspects = math.random(10)
        for i = 1, suspects do
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
            local pedModel = ERS_GetRandomModel(Config.randomPeds)
            local pedCoords = vector3(coords.x, coords.y, coords.z)
            local pedHeading = math.random(360)
            local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
            local ped = NetworkGetEntityFromNetworkId(pedNetId)
            table.insert(pedList, pedNetId)
        end

        return true
    end
}