Config.Callouts["unidentified_object"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Unidentified object reported",
    CalloutDescriptions = {
        "Responder a informes de un objeto no identificado; asegurar el area y evaluar las amenazas potenciales.",
        "Alerta: despliegue unidades para investigar informes de un objeto no identificado y garantizar la seguridad publica.",
        "Unidades requeridas: evaluar informes de un objeto no identificado en busca de peligros o peligros potenciales.",
        "Aviso: investigue los informes de un objeto no identificado y tome las precauciones necesarias.",
        "Alerta: responder a informes de un objeto no identificado; priorizar la seguridad y la investigacion exhaustiva.",
        "Incidente reportado: investigar informes de un objeto no identificado para determinar su naturaleza.",
        "Responder a informes de un objeto sospechoso; coordinar con expertos en desactivacion de bombas y asegurar el area.",
        "Alerta de situacion: tome medidas inmediatas ante informes de un objeto no identificado y coordine con las autoridades.",
        "Alerta: responda con cautela a los informes de un objeto no identificado y siga el protocolo para posibles amenazas.",
        "Respuesta necesaria: investigar los informes de un objeto no identificado y tomar las medidas adecuadas para garantizar la seguridad publica.",
    },
    CalloutUnitsRequired = {
        description = "Police, Fire.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = true,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(4.7873, -1519.3046, 29.4797),
        [2] = vector3(-357.4233, 6248.2720, 31.4930),
        [3] = vector3(-278.0290, 6331.2485, 32.4218),
        [4] = vector3(-112.2073, 6460.9526, 31.4685),
        [5] = vector3(1706.3806, 3778.7673, 34.7586),
        [6] = vector3(230.2121, 214.2268, 105.5514),
        [7] = vector3(67.2231, 112.0352, 79.0892),
        [8] = vector3(-166.2632, -1425.4434, 31.1112),
        [9] = vector3(45.1339, -1748.2421, 29.5469),
        [10] = vector3(-278.8082, -1925.3947, 29.9460),
        [11] = vector3(-832.1346, -2092.6909, 8.9603),
        [12] = vector3(-1037.4767, -2737.1309, 0.7991),
        [13] = vector3(-157.7649, -1694.3339, 31.4686),
        [14] = vector3(192.4545, -931.2686, 30.6037),
        [15] = vector3(308.4785, -728.3778, 29.3168),
        [16] = vector3(292.3311, -780.2249, 29.3219),
        [17] = vector3(355.9457, -1029.9708, 29.3312),
        [18] = vector3(-939.5764, -280.3421, 39.2679),
        [19] = vector3(-804.2067, -224.7950, 37.2235),
        [20] = vector3(-798.2543, -98.7246, 37.6296),
    },               
    PedChanceToFleeFromPlayer = 0,       -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 0,         -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 0,            -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 0,        -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 0,     -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 1000,  -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "none",   -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_unarmed",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)

        local object
        for index, objNetId in pairs(objectList) do
            local obj = NetToObj(objNetId)
            if DoesEntityExist(obj) then
                object = obj
                ERS_RequestNetControlForEntity(obj) 
                PlaceObjectOnGroundProperly(obj)
            end
        end

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                ERS_ClearPedTasksAndBlockEvents(ped)

                Wait(100)

                TaskTurnPedToFaceEntity(ped, object, 1000)

                Wait(1000)

                local scenario = ERS_SelectRandomBystanderScenario()
                TaskStartScenarioInPlace(ped, scenario, 0, true)
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000)
        ERS_CreateTemporaryBlipForEntities(objectList, 30000)

        if math.random(100) < 50 then
            Citizen.SetTimeout(math.random(30000), function()
                if DoesEntityExist(object) then
                    ERS_RequestNetControlForEntity(object)
                    local pos = GetEntityCoords(object)
                    AddExplosion(pos.x, pos.y, pos.z, 5, 5.0, true, false, 5.0)

                    Wait(1000)

                    for index, pedNetId in pairs(pedList) do
                        local ped = NetToPed(pedNetId)
                        if DoesEntityExist(ped) then
                            local scenario = ERS_SelectRandomWoundedPersonScenario()
                            TaskStartScenarioInPlace(ped, scenario, 0, true)
                            ERS_ApplyBloodToPed(ped)
                        end
                    end
                end
            end)
        end

    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        local objModel = ERS_GetRandomModel(Config.RandomBombObjectModels)
        local objCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local objHeading = math.random(360)
        local objNetId = ERS_CreateObject(objModel, objCoords, objHeading)
        if objNetId then    
            local obj = NetworkGetEntityFromNetworkId(objNetId)
            table.insert(objectList, objNetId)
        else
            DebugPrint("^1ERROR ^7Could not create object: "..objModel)
        end

        -- Build bystanders
        local randomAmountOfBystanders = math.random(4)
        for i = 1, randomAmountOfBystanders do
            local diameter = 15
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
            
            local bystanderPedModel = ERS_GetRandomModel(Config.randomPeds)
            local bystanderPedCoords = vector3(coords.x, coords.y, coords.z)
            local bystanderPedHeading = math.random(360)
            local bystanderPedNetId = ERS_CreatePed(bystanderPedModel, bystanderPedCoords, bystanderPedHeading)
            local bystanderPed = NetworkGetEntityFromNetworkId(bystanderPedNetId)
            table.insert(pedList, bystanderPedNetId)
        end

        Citizen.SetTimeout(math.random(30000), function()
            local fireToObjChance = math.random(100)
            if fireToObjChance < 50 then
                -- Build fire
                if UsingSmartFiresV2 or UsingSmartFires then
                    local fireSize = Config.RandomSmallFireOrSmokeSize[math.random(#Config.RandomSmallFireOrSmokeSize)]
                    local fireType = Config.NormalFireTypes[math.random(#Config.NormalFireTypes)]
                    fireList[#fireList + 1] = ERS_AddCalloutFire(vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z-0.5), fireType, fireSize)
                elseif UsingSmartFiresLite then
                    local fireSize = Config.RandomSmallFireOrSmokeSize[math.random(#Config.RandomSmallFireOrSmokeSize)]
                    fireList[#fireList + 1] = ERS_AddCalloutFire(vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z-0.5), "normal", fireSize)
                end
            end
        end)
    
        return true
    end
}