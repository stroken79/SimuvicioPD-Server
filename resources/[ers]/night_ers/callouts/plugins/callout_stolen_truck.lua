Config.Callouts["stolen_truck"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Stolen truck",
    CalloutDescriptions = {
        "Responder a un camion robado; Se requiere accion inmediata para detener a los sospechosos y recuperar el vehiculo.",
        "Se necesita respuesta de emergencia para un camion robado; desplegar unidades para interceptar y recuperar el vehiculo.",
        "Llamado urgente para atender camion robado; Movilizar recursos para detener a los perpetradores y devolver el vehiculo de manera segura.",
        "Reportan camioneta robada; responder rapidamente para evitar que el vehiculo sea utilizado para actividades delictivas.",
        "Alerta de incidente: camion robado; desplegar recursos policiales para perseguir y recuperar el vehiculo robado.",
        "Se requiere respuesta de emergencia para un camion robado; priorizar la detencion de sospechosos y la recuperacion del vehiculo.",
        "Responder al incidente del camion robado; acelerar los esfuerzos para detener a los sospechosos y asegurar el vehiculo.",
        "Reportan camioneta robada; activar protocolos de emergencia y coordinar con unidades para interceptar el vehiculo.",
        "Se necesita una respuesta inmediata para un camion robado; priorizar la seguridad publica y prevenir futuras actividades delictivas.",
        "Aviso urgente: camion robado; responder con prontitud para detener a los sospechosos y salvaguardar la seguridad de la comunidad.",
    },
    CalloutUnitsRequired = {
        description = "Police.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(-66.8283, 2832.2595, 53.7482),
        [2] = vector3(-950.1295, -2582.0771, 13.8310),
        [3] = vector3(-326.1115, -2165.7007, 10.3181),
        [4] = vector3(32.2191, -1716.7432, 29.2860),
        [5] = vector3(307.5628, -1098.0363, 29.3472),
        [6] = vector3(209.0576, -817.9829, 30.6324),
        [7] = vector3(898.6524, -3187.9153, 5.8967),
        [8] = vector3(614.1050, -2702.2434, 5.9083),
        [9] = vector3(116.4583, -2069.7996, 17.6480),
        [10] = vector3(406.9794, -638.5778, 28.5001),
        [11] = vector3(612.8627, 104.1877, 92.8750),
        [12] = vector3(971.8981, 150.0137, 80.8799),
        [13] = vector3(2552.4385, 2636.7893, 37.9819),
        [14] = vector3(2507.8540, 1593.2323, 31.6219),
        [15] = vector3(2411.8125, 972.2469, 86.6440),
        [16] = vector3(2663.4463, 3116.9456, 49.9681),
        [17] = vector3(2662.5396, 3524.7676, 52.4791),
        [18] = vector3(2841.4377, 3701.9082, 48.9755),
        [19] = vector3(3282.6230, 5149.8555, 18.7254),
        [20] = vector3(1689.0770, 4940.0337, 42.1513),
        [21] = vector3(1317.9303, 4472.5825, 62.5055),
    },                      
    PedChanceToFleeFromPlayer = 100,    -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 0,        -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 0,           -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 50,      -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 0,    -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 1000, -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "none",  -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_poolcue",
        "weapon_bottle",
        "weapon_crowbar",
        "weapon_bat",
        "weapon_pistol",
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
                ERS_SetPedToFleeFromPlayer(ped)
            end
        end

        ERS_CreateTemporaryBlipForEntities(vehicleList, 15000)
        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        -- Build truck
        local vehModel = ERS_GetRandomModel(Config.randomTrucks)
        local vehType = "automobile"
        local vehCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local vehHeading = math.random(360)
        local vehNetId = ERS_CreateVehicle(vehModel, vehType, vehCoords, vehHeading)
        local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
        table.insert(vehicleList, vehNetId)

        -- Build suspect
        local pedModel = ERS_GetRandomModel(Config.randomPeds)
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        SetPedIntoVehicle(ped, vehicle, -1)
        table.insert(pedList, pedNetId)

        return true
    end
}