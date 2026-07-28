Config.Callouts["capsized_vehicle"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Capsized heavy vehicle",
    CalloutDescriptions = {
        "Responder a un incidente que involucre un vehiculo pesado volcado; Se requieren acciones inmediatas para asegurar el area.",
        "Llamada de emergencia: un vehiculo pesado ha volcado; enviar unidades para ayudar y gestionar la situacion.",
        "Se necesita respuesta urgente para un vehiculo pesado volcado; garantizar la seguridad y coordinar las operaciones de recuperacion.",
        "Incidente critico: vehiculo pesado volcado; responder rapidamente para brindar asistencia y controlar el trafico.",
        "Alerta: reportan vehiculo pesado volcado; desplegar recursos para estabilizar el vehiculo y prevenir peligros.",
        "Vehiculo pesado volcado; Se requiere intervencion inmediata para ayudar al conductor y gestionar la escena.",
        "Manejar una emergencia que involucre un vehiculo pesado volcado; priorizar la seguridad y coordinar con los equipos de recuperacion.",
        "Respuesta de emergencia: vehiculo pesado volco; asegurese de que el area sea segura y ayude con la recuperacion del vehiculo.",
        "Aviso urgente: vehiculo pesado volcado; responder rapidamente para gestionar la escena y evitar mas incidentes.",
        "Situacion critica: vehiculo pesado volcado; Se necesita una respuesta inmediata para ayudar con la recuperacion y garantizar la seguridad.",
    },                        
    CalloutUnitsRequired = {
        description = "Police, Ambulance, Tow.",
        policeRequired = true,
        ambulanceRequired = true,
        fireRequired = false,
        towRequired = true,
    },
    CalloutLocations = {
        [1] = vector3(816.4828, -679.9893, 41.9445),
        [2] = vector3(-1384.9823, -570.5046, 30.2422),
        [3] = vector3(-891.2759, -2575.0945, 13.8305),
        [4] = vector3(-556.4310, -2203.9673, 6.0330),
        [5] = vector3(-225.3320, -2168.1885, 13.9838),
        [6] = vector3(259.5528, -2228.2637, 6.9489),
        [7] = vector3(582.2025, -2092.6011, 14.7787),
        [8] = vector3(754.3458, -2073.8147, 29.2641),
        [9] = vector3(1039.4996, -1884.3270, 29.0919),
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
                SetEntityHealth(ped, 0)
            end
        end

        ERS_CreateTemporaryBlipForEntities(vehicleList, 15000)
        ERS_CreateTemporaryBlipForEntities(pedList, 15000)
        ERS_CreateTemporaryBlipForEntities(objectList, 15000)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)


        local diameter = 20
        
        -- Build vehicle
        local vehModel = ERS_GetRandomModel(Config.randomHeavyVehicles)
        local vehType = "automobile"
        local vehCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local vehHeading = math.random(360)
        local vehNetId = ERS_CreateVehicle(vehModel, vehType, vehCoords, vehHeading)
        local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
        table.insert(vehicleList, vehNetId)

        -- Build ped
        local pedModel = ERS_GetRandomModel(Config.randomPeds)
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        SetPedIntoVehicle(ped, vehicle, -1)
        table.insert(pedList, pedNetId)

        -- Build objects
        local randomAmountOfObjects = math.random(5,12)
        for i = 1, randomAmountOfObjects do
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)

            local objModel = ERS_GetRandomModel(Config.RandomHeavyVehicleObjects)
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

        return true
    end
}