Config.Callouts["prisoner_escape"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Escaped Prisoner Located",
    CalloutDescriptions = {
        "Emergencia: responder a informes de un prisionero fugitivo localizado; asegurese de que el area sea segura y detenga al individuo.",
        "Alerta urgente: enviar unidades al lugar del prisionero fugado; impedir su fuga y garantizar la seguridad publica.",
        "Se requiere una respuesta critica: atender los informes de un prisionero fugado; coordinar con las autoridades para capturar al fugitivo.",
        "Aviso: consulte los informes sobre el avistamiento de un prisionero fugado; tomar medidas inmediatas para asegurar el area y detener al sospechoso.",
        "Alerta: responder con prontitud a la ubicacion de un prisionero fugitivo; priorizar la seguridad y seguir los protocolos de arresto.",
        "Incidente reportado: investigar avistamientos de un prisionero fugitivo; trabajar con las autoridades locales para detener al individuo.",
        "Accion inmediata: abordar los informes de un prisionero fugado; utilizar la fuerza necesaria para asegurar el area y detener al sospechoso.",
        "Alerta de situacion: ayudar a localizar y detener a un prisionero fugado; velar por la seguridad del publico y de los funcionarios.",
        "Respuesta de emergencia: manejar informes de un prisionero fugado; Siga los procedimientos para capturar al fugitivo de forma segura.",
        "Se necesita respuesta: investigar los informes sobre la localizacion urgente de un prisionero fugado; tomar las medidas adecuadas para evitar que sigan huyendo y garantizar la seguridad publica.",
    },                                                   
    CalloutUnitsRequired = {
        description = "Police.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(214.6095, 3189.8245, 42.5928),
        [2] = vector3(293.1284, -1478.5221, 29.3080),
        [3] = vector3(103.3432, -1377.3875, 29.3154),
        [4] = vector3(485.6794, 6.2798, 87.1719),
        [5] = vector3(-5.2814, 381.2972, 112.3464),
        [6] = vector3(-2035.8617, -166.5863, 26.5854),
        [7] = vector3(482.3028, -1037.2313, 34.8134),
        [8] = vector3(380.8480, -757.6916, 29.2935),
        [9] = vector3(571.4741, -572.0841, 35.7990),
        [10] = vector3(772.4194, -828.8688, 26.2540),
        [11] = vector3(833.7119, -1555.7354, 29.8211),
        [12] = vector3(492.0949, -1751.8782, 28.5538),
        [13] = vector3(228.7512, -1807.6431, 27.6827),
        [14] = vector3(-520.3109, -1346.6263, 29.3196),
        [15] = vector3(-858.3890, -922.1454, 15.5615),
        [16] = vector3(-2436.8098, 2833.2585, 3.6499),
        [17] = vector3(-1920.5099, 2369.5808, 34.1331),
        [18] = vector3(-1223.8616, 2780.9143, 14.2682),
        [19] = vector3(14.8522, 4456.5659, 59.9622),
        [20] = vector3(2212.9841, 5604.5820, 53.8604),
    },               
    PedChanceToFleeFromPlayer = 50,      -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 50,        -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 10,           -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 50,       -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 10000,    -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 15000, -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "flee",  -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_bottle",
        "weapon_knife"
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)

        local vehicle
        local driver

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
                driver = ped
                ERS_RequestNetControlForEntity(driver) 
                TaskSetBlockingOfNonTemporaryEvents(driver, true)
                if not IsPedOnAnyBike(driver) then
                    SmashVehicleWindow(vehicle, 0) -- break driver window
                end
                if not IsPedInAnyVehicle(driver, true) then
                    TaskEnterVehicle(driver, vehicle, 5000, -1, 2.0, 1, 0)
                    Wait(5000)
                    ERS_SetPedToFleeFromPlayer(driver)
                else
                    ERS_SetPedToFleeFromPlayer(driver)
                end             
            end
        end

        ERS_CreateTemporaryBlipForEntities(vehicleList, 15000)
        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)
    
        -- Build vehicle
        local vehModel = ERS_GetRandomModel(Config.randomVehicles)
        local vehType = "automobile"
        local vehCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local vehHeading = math.random(360)
        local vehNetId = ERS_CreateVehicle(vehModel, vehType, vehCoords, vehHeading)
        local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
        table.insert(vehicleList, vehNetId)

        -- Build ped
        local pedModel = ERS_GetRandomModel(Config.randomPrisonerPeds)
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z +1.0)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        SetPedIntoVehicle(ped, vehicle, -1)
        table.insert(pedList, pedNetId)

        return true
    end
}