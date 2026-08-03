Config.Callouts["riot"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Riot",
    CalloutDescriptions = {
        "Investigar informes de disturbios; asegurar el area y evaluar la situacion.",
        "Alerta: desplegar unidades para gestionar un motin; garantizar la seguridad publica y restablecer el orden.",
        "Unidades requeridas: responder a informes de disturbios y evaluar posibles amenazas a la comunidad.",
        "Aviso: verifique los informes de disturbios e implemente las medidas necesarias para controlar la situacion.",
        "Alerta: responder con prontitud a un disturbio; priorizar la seguridad y la evaluacion detallada del evento.",
        "Incidente reportado: consulte los informes de disturbios para comprender el alcance de los disturbios.",
        "Investigar informes de disturbios; coordinar con los equipos de control de multitudes y asegurar la vecindad.",
        "Alerta de situacion: abordar informes de disturbios; Trabajar con las autoridades pertinentes para gestionar la situacion.",
        "Alerta: maneje los informes de disturbios y cumpla con los protocolos para restablecer el orden y garantizar la seguridad.",
        "Se necesita respuesta: investigar informes de disturbios y tomar medidas para garantizar la seguridad de la comunidad.",
    },            
    CalloutUnitsRequired = {
        description = "Police, Fire, Tow.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = true,
        towRequired = true,
    },
    CalloutLocations = {
        [1] = vector3(831.1976, -3137.5559, 5.9008),
        [2] = vector3(-1557.1982, 2761.8516, 17.7053),
        [3] = vector3(1710.1578, 3771.4617, 34.4025),
        [4] = vector3(1743.8546, 3272.0657, 41.1703),
        [5] = vector3(1858.9907, 2540.5154, 45.6719),
        [6] = vector3(235.6954, -878.0937, 30.4921),
        [7] = vector3(-191.3728, -1964.3601, 27.6204),
        [8] = vector3(-620.6758, -2123.2578, 5.9923),
        [9] = vector3(-1619.6090, -903.4967, 8.9739),
        [10] = vector3(-2457.9941, 3656.7156, 13.9443),
        [11] = vector3(-282.2079, 6052.3569, 31.5152),
        [12] = vector3(146.9176, 6602.6260, 31.8042),
        [13] = vector3(1571.6101, 6441.9468, 24.4484),
        [14] = vector3(2043.6166, 4986.9048, 40.6116),
        [15] = vector3(2412.2124, 4142.8066, 35.5256),
        [16] = vector3(2105.3550, 2864.5730, 47.6522),
        [17] = vector3(2722.0613, 1381.5297, 24.5540),
        [18] = vector3(963.9542, 154.3185, 80.8222),
        [19] = vector3(520.3144, 50.4172, 95.0597),
        [20] = vector3(158.9241, -413.5882, 41.1308),
    },               
    PedChanceToFleeFromPlayer = 25,       -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 25,         -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 10,            -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 50,        -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 10000,  -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 15000,  -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "none",    -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_bat",
        "weapon_hammer",
        "weapon_wrench",
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
                ERS_SetRandomDamageToVehicle(veh)
                local vehClass = GetVehicleClass(veh)
                if vehClass == 18 then -- Break all emergency vehicles.
                    SetVehicleBodyHealth(veh, 0)
                    SetVehicleEngineHealth(veh, 0)
                end
            end
        end

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                ERS_SpawnConfiguredWeaponForPed(ped, calloutDataClient)
                local targetIndex = math.random(#pedList)
                local targetPed = NetToPed(pedList[targetIndex])
                if targetPed ~= ped then
                    TaskCombatPed(ped, targetPed, 0, 16)
                else
                    TaskReactAndFleePed(ped, plyPed)
                end
            end
        end

        local diameter = 20
        local randomAmountOfFlares = math.random(1,10)
        for i = 1, randomAmountOfFlares do
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutDataClient.Coordinates, diameter)
            ERS_CreateFlareAtCoordinate(coords)
        end

        ERS_CreateTemporaryBlipForEntities(vehicleList, 15000)
        ERS_CreateTemporaryBlipForEntities(pedList, 15000)
        ERS_CreateTemporaryBlipForEntities(objectList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)


        local diameter = 20

        -- Build vehicle
        local randomAmountOfVehicles = math.random(5)
        for i = 1, randomAmountOfVehicles do
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
            local vehModel = ERS_GetRandomModel(Config.randomRiotVehicles)
            local vehType = "automobile"
            local vehCoords = vector3(coords.x, coords.y, coords.z+1.0)
            local vehHeading = math.random(360)
            local vehNetId = ERS_CreateVehicle(vehModel, vehType, vehCoords, vehHeading)
            local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
            table.insert(vehicleList, vehNetId)
        end

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

            local objModel = ERS_GetRandomModel(Config.randomRiotObjects)
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

        -- Build smoke
        if UsingSmartFiresV2 or UsingSmartFires then
            local smokeSize = Config.RandomMediumFireOrSmokeSize[math.random(#Config.RandomMediumFireOrSmokeSize)]
            local smokeType = Config.AllSmokeTypes[math.random(#Config.AllSmokeTypes)]
            smokeList[#smokeList + 1] = ERS_AddCalloutSmoke(vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z-0.5), smokeType, smokeSize)
        elseif UsingSmartFiresLite then
            local smokeSize = Config.RandomMediumFireOrSmokeSize[math.random(#Config.RandomMediumFireOrSmokeSize)]
            smokeList[#smokeList + 1] = ERS_AddCalloutSmoke(vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z-0.5), "normal", smokeSize)
        end

        -- Build rioters
        local suspects = math.random(7, 15)
        for i = 1, suspects do
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
            local pedModel = ERS_GetRandomModel(Config.randomPeds)
            local pedCoords = vector3(coords.x, coords.y, coords.z+2.0)
            local pedHeading = math.random(360)
            local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
            local ped = NetworkGetEntityFromNetworkId(pedNetId)
            table.insert(pedList, pedNetId)
        end
    
        return true
    end
}