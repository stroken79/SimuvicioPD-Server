Config.Callouts["illegal_race"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Illegal Street Race",
    CalloutDescriptions = {
        "Responder inmediatamente a una carrera callejera ilegal; asegurar el area y evitar accidentes.",
        "Alerta de emergencia: carrera callejera ilegal en curso; desplegar unidades para gestionar la situacion y garantizar la seguridad publica.",
        "Se requiere una respuesta urgente: se detectan carreras callejeras de alta velocidad; garantizar la seguridad de los transeuntes y detener a los corredores.",
        "Situacion critica: carrera callejera no autorizada; actuar con rapidez para prevenir accidentes y controlar la escena.",
        "Alerta: se reporta carrera callejera ilegal; Se necesita una intervencion inmediata para detener la carrera y garantizar la seguridad vial.",
        "Incidente de carrera callejera: carreras ilegales en marcha; Se necesitan medidas urgentes para asegurar las calles y detener a los delincuentes.",
        "Manejar una carrera callejera ilegal; priorizar la seguridad publica y coordinar con las unidades de control de transito.",
        "Situacion de emergencia: carrera callejera en curso; asegurese de que el area sea segura y detenga a los corredores.",
        "Alerta urgente: carreras callejeras de alta velocidad; responder rapidamente para gestionar la escena y evitar mas incidentes.",
        "Se necesita una respuesta critica: se detecta carrera callejera ilegal; Asegure el area, garantice la seguridad y detenga a los participantes.",
    },    
    CalloutUnitsRequired = {
        description = "Police.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(-285.3925, -1832.0594, 26.7288),
        [2] = vector3(-87.1607, -113.6892, 57.7443),
        [3] = vector3(-165.5629, -377.4605, 33.3565),
        [4] = vector3(-530.7234, -367.9998, 35.2181),
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
    PedChanceToFleeFromPlayer = 100,    -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 0,        -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 50,          -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 0,       -- Value between 0 and 100 -> Lower is less chance.
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
            end
        end
        
        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped)
                Wait(2500)
                TaskReactAndFleePed(ped, plyPed)
            end
        end

        ERS_CreateTemporaryBlipForEntities(vehicleList, 30000)
        ERS_CreateTemporaryBlipForEntities(pedList, 30000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)


        local diameter = 20
        
        -- Build vehicles & drivers
        local amountOfStreetRacers = 2
        for i = 1, amountOfStreetRacers do
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
            local vehModel = ERS_GetRandomModel(Config.randomLuxuryVehicles)
            local vehType = "automobile"
            local vehCoords = vector3(coords.x, coords.y, coords.z+1.0)
            local vehHeading = math.random(360)
            local vehNetId = ERS_CreateVehicle(vehModel, vehType, vehCoords, vehHeading)
            local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
            table.insert(vehicleList, vehNetId)

            local pedModel = ERS_GetRandomModel(Config.randomPeds)
            local pedCoords = vector3(coords.x, coords.y, coords.z+2.0)
            local pedHeading = math.random(360)
            local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
            local ped = NetworkGetEntityFromNetworkId(pedNetId)
            SetPedIntoVehicle(ped, vehicle, -1)
            table.insert(pedList, pedNetId)
        end

        return true
    end
}