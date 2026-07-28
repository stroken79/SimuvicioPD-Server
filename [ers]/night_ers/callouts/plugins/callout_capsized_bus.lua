Config.Callouts["capsized_bus"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Capsized passenger bus",
    CalloutDescriptions = {
        "Atender una emergencia en la que un autobus de pasajeros se haya volcado; asegure la zona inmediatamente.",
        "Alerta: un autobus de pasajeros ha volcado; enviar unidades para manejar la situacion y ayudar a los involucrados.",
        "Se requiere accion inmediata para un autobus que se ha volcado; centrarse en la seguridad y coordinar los esfuerzos de recuperacion.",
        "Emergencia critica: un autobus de pasajeros volco; prestar asistencia con prontitud y regular el trafico.",
        "Advertencia: se detecta autobus de pasajeros volcado; enviar recursos para estabilizar el autobus y mitigar riesgos.",
        "Accidente de autobus de pasajeros: autobus volcado; Se necesita ayuda urgente para asistir a los pasajeros y controlar la escena.",
        "Manejar una situacion que involucre un autobus volcado; priorizar la seguridad y colaborar con el personal de recuperacion.",
        "Responder a un vuelco de un autobus de pasajeros; asegurese de que el area sea segura y ayude con la recuperacion del vehiculo.",
        "Se requiere una respuesta urgente: el autobus de pasajeros se volco; Maneje la escena para evitar mayores complicaciones.",
        "Alerta critica: autobus volcado; Se necesita intervencion inmediata para ayudar en los esfuerzos de recuperacion y garantizar la seguridad.",
    },                         
    CalloutUnitsRequired = {
        description = "Police, Ambulance, Tow.",
        policeRequired = true,
        ambulanceRequired = true,
        fireRequired = false,
        towRequired = true,
    },
    CalloutLocations = {
        [1] = vector3(-1072.4072, -1289.6188, 5.9038),
        [2] = vector3(2537.8545, 1776.8958, 24.4214),
        [3] = vector3(2324.2249, 1188.5785, 65.1486),
        [4] = vector3(2381.6067, 893.6487, 111.0333),
        [5] = vector3(1784.8096, 433.7240, 172.6540),
        [6] = vector3(1134.1582, 750.4255, 146.8967),
        [7] = vector3(541.8043, 1033.2881, 219.0286),
        [8] = vector3(506.1575, 1312.2441, 284.1587),
        [9] = vector3(159.6427, 1480.7738, 239.4097),
        [10] = vector3(-152.2372, 1556.9006, 307.3201),
        [11] = vector3(-363.4066, 1451.2218, 288.9186),
        [12] = vector3(-501.1940, 1201.6180, 323.9875),
        [13] = vector3(-766.0131, 1636.6566, 205.8681),
        [14] = vector3(-1065.2036, 2193.1619, 88.9680),
        [15] = vector3(-932.9423, -2720.0906, 13.8070),
        [16] = vector3(-862.6539, -2496.4246, 13.8369),
        [17] = vector3(-693.9046, -1483.1071, 10.9885),
        [18] = vector3(-417.6440, -1573.9742, 25.7328),
        [19] = vector3(-277.1655, -1420.7927, 31.2840),
        [20] = vector3(142.5911, -1160.8898, 36.5171),
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
                ERS_ApplyBloodToPed(ped)
                if index == 1 then 
                    SetEntityHealth(ped, 0)
                else
                    local chanceToSurvive = math.random(0, 1)     
                    if chanceToSurvive > 0 then
                        Citizen.Wait(2500)
                        local scenario = ERS_SelectRandomWoundedPersonScenario()
                        TaskStartScenarioInPlace(ped, scenario, 0, true)
                    else
                        SetEntityHealth(ped, 0)
                    end
                end
            end
        end

        ERS_CreateTemporaryBlipForEntities(vehicleList, 15000)
        ERS_CreateTemporaryBlipForEntities(pedList, 15000)
        ERS_CreateTemporaryBlipForEntities(objectList, 15000)

        -- ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)


        local diameter = 20
        
        -- Build vehicle
        local vehModel = ERS_GetRandomModel(Config.randomBuses)
        local vehType = "automobile"
        local vehCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local vehHeading = math.random(360)
        local vehNetId = ERS_CreateVehicle(vehModel, vehType, vehCoords, vehHeading)
        local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
        table.insert(vehicleList, vehNetId)

        -- Build ped
        local pedModel = "a_m_y_busicas_01"
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        SetPedIntoVehicle(ped, vehicle, -1)
        table.insert(pedList, pedNetId)

        -- Build objects
        local randomAmountOfObjects = math.random(8)
        for i = 1, randomAmountOfObjects do
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)

            local objModel = ERS_GetRandomModel(Config.RandomBagObjects)
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

        local randomAmountOfPassengers = math.random(20)
        -- Build passengers
        for i = 1, randomAmountOfPassengers do -- seats
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
            local passengerPedModel = ERS_GetRandomModel(Config.randomPeds)
            local passengerPedCoords = vector3(coords.x, coords.y, coords.z)
            local passengerPedHeading = math.random(360)
            local passengerPedNetId = ERS_CreatePed(passengerPedModel, passengerPedCoords, passengerPedHeading)
            local passengerPed = NetworkGetEntityFromNetworkId(pedNetId)
            table.insert(pedList, passengerPedNetId)
        end

        return true
    end
}