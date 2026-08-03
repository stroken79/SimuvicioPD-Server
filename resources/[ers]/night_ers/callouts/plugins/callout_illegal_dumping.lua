Config.Callouts["illegal_dumping"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Illegal Waste Dump",
    CalloutDescriptions = {
        "Responder a una denuncia de vertido ilegal de residuos; Investigar la escena y tomar las acciones necesarias.",
        "Alerta: eliminacion no autorizada de residuos en curso; desplegar unidades para abordar la situacion y garantizar la seguridad ambiental.",
        "Unidades necesarias: informe de vertimiento ilegal; centrarse en identificar a los infractores y mitigar el impacto ambiental.",
        "Aviso: denuncian vertedero ilegal de residuos; actuar con prontitud para controlar la escena y evitar una mayor contaminacion.",
        "Alerta: informe de eliminacion no autorizada de residuos; Es necesaria una intervencion para detener el vertido y asegurar la zona.",
        "Incidente reportado: vertedero ilegal de residuos; tomar medidas para investigar y hacer cumplir las regulaciones ambientales.",
        "Responder a una situacion que implique la eliminacion no autorizada de residuos; priorizar la proteccion ambiental y la coordinacion con las autoridades locales.",
        "Alerta de situacion: vertidos ilegales en curso; Asegure el area e investigue el incidente.",
        "Alerta: informe de eliminacion de residuos no autorizada; responder rapidamente para abordar la situacion y garantizar el cumplimiento de las regulaciones.",
        "Se necesita respuesta: vertedero ilegal de residuos; asegurar el area, investigar a los infractores y garantizar el cumplimiento de las leyes ambientales.",
    },               
    CalloutUnitsRequired = {
        description = "Police, Fire.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = true,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(-660.74, 984.44, 238.79),
        [2] = vector3(-1316.92, -1258.45, 4.58),     
        [3] = vector3(-1207.55, -2045.67, 14.37),   
        [4] = vector3(-680.96, -2477.55, 13.83),    
        [5] = vector3(1444.21, -2604.68, 48.29),   
        [6] = vector3(576.81, -2324.42, 5.91),    
        [7] = vector3(639.60, -1840.57, 9.32),   
        [8] = vector3(-459.00, -1720.25, 18.62),   
        [9] = vector3(1369.84, -748.74, 67.10),   
        [10] = vector3(689.30, -981.94, 23.51),
        [11] = vector3(503.83, -582.16, 24.76),  
        [12] = vector3(-240.22, -1667.63, 33.49),   
        [13] = vector3(-632.16, 410.67, 101.04),
        [14] = vector3(584.70, 126.32, 98.04),
        [15] = vector3(850.27, 1276.24, 359.66),
        [16] = vector3(2396.01, 3113.06, 48.15),
        [17] = vector3(1433.38, 2793.44, 52.40),
        [18] = vector3(202.73, 2793.21, 45.66),
        [19] = vector3(2414.30, 3742.92, 41.78),
        [20] = vector3(2921.07, 4634.95, 48.55),
        [21] = vector3(2145.48, 3891.38, 33.18),
        [22] = vector3(341.01, 3566.12, 33.46),
        [23] = vector3(1412.42, 3752.11, 32.31),
        [24] = vector3(360.36, 4445.27, 62.92),
        [25] = vector3(3794.42, 4461.90, 5.42),
        [26] = vector3(1384.47, 6582.36, 13.08),
        [27] = vector3(-202.06, 6541.56, 11.10),
        [28] = vector3(-735.59, 5814.26, 17.42),
        [29] = vector3(-229.14, 6258.89, 31.49),
        [30] = vector3(80.08, 6326.47, 31.23),
        [31] = vector3(437.61, 6539.34, 27.99),
        [32] = vector3(-1634.07, 4736.70, 53.25),
        [33] = vector3(-1577.25, 5157.76, 19.91),
        [34] = vector3(-942.45, 5427.65, 38.09),
        [35] = vector3(1474.00, 6359.01, 23.66),
    },               
    PedChanceToFleeFromPlayer = 100,    -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 0,        -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 0,           -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 0,       -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 10000,-- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 15000,-- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "flee",  -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
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
            end
        end

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped)
                if index == 1 then
                    ERS_SetPedToFleeFromPlayer(ped)
                end

            end
        end

        ERS_CreateTemporaryBlipForEntities(vehicleList, 15000)
        ERS_CreateTemporaryBlipForEntities(pedList, 15000)
        ERS_CreateTemporaryBlipForEntities(objectList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)


        local diameter = 20

         -- Build objects
         local randomAmountOfObjects = math.random(3,10)
         for i = 1, randomAmountOfObjects do
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
            local objModel = ERS_GetRandomModel(Config.randomWasteDumpObjects)
            local objCoords = vector3(coords.x, coords.y, coords.z+2.0)
            local objHeading = math.random(360)
            local objNetId = ERS_CreateObject(objModel, objCoords, objHeading)
            if objNetId then    
                local obj = NetworkGetEntityFromNetworkId(objNetId)
                table.insert(objectList, objNetId)
            else
                DebugPrint("^1ERROR ^7Could not create object: "..objModel)
            end

            local fireToObjChance = math.random(100)
            if fireToObjChance > 75 then
                -- Build fire
                if UsingSmartFiresV2 or UsingSmartFires then
                    local fireSize = Config.RandomSmallFireOrSmokeSize[math.random(#Config.RandomSmallFireOrSmokeSize)]
                    local fireType = Config.NormalFireTypes[math.random(#Config.NormalFireTypes)]
                    fireList[#fireList + 1] = ERS_AddCalloutFire(vector3(coords.x, coords.y, coords.z-0.5), fireType, fireSize)
                elseif UsingSmartFiresLite then
                    local fireSize = Config.RandomSmallFireOrSmokeSize[math.random(#Config.RandomSmallFireOrSmokeSize)]
                    fireList[#fireList + 1] = ERS_AddCalloutFire(vector3(coords.x, coords.y, coords.z-0.5), "normal", fireSize)
                end
            end
        end

        -- Build vehicle
        local vehModel = ERS_GetRandomModel(Config.randomVans)
        local vehType = "automobile"
        local vehCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local vehHeading = math.random(360)
        local vehNetId = ERS_CreateVehicle(vehModel, vehType, vehCoords, vehHeading)
        local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
        table.insert(vehicleList, vehNetId)

        -- Build ped
        local seatIndex = -1
        for i = 1, 2 do
            local pedModel = ERS_GetRandomModel(Config.randomGangPeds)
            local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z+3.0)
            local pedHeading = math.random(360)
            local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
            local ped = NetworkGetEntityFromNetworkId(pedNetId)
            ERS_SetPedIntoVehicle(ped, vehicle, seatIndex)
            seatIndex = seatIndex + 1
            table.insert(pedList, pedNetId)
        end

        return true
    end
}