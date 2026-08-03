Config.Callouts["drunk_entering_vehicle"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Drunk person entering a vehicle",
    CalloutDescriptions = {
        "Responder a un informe de una persona ebria que intenta entrar a un vehiculo; garantizar su seguridad y prevenir posibles peligros.",
        "Alerta: individuo en estado de ebriedad tratando de subir a un vehiculo; desplegar unidades para prevenir la conduccion en estado de ebriedad.",
        "Unidades necesarias: llamada de emergencia por persona en estado de ebriedad que ingresa a un vehiculo; centrarse en proteger al individuo y al vehiculo.",
        "Aviso: persona en estado de ebriedad reporto ingreso a vehiculo; actuar con prontitud para controlar la situacion y ofrecer asistencia.",
        "Alerta: informe de una persona ebria que intenta conducir; Intervencion necesaria para asegurar el lugar y evitar incidentes.",
        "Incidente reportado: persona ebria intentando ingresar a un vehiculo; tomar medidas para brindar atencion y apoyo urgentes.",
        "Responder a una situacion que involucre a un individuo ebrio que intenta ingresar a un vehiculo; priorizar la seguridad y coordinar con la policia.",
        "Alerta de situacion: persona ebria intentando conducir; proporcione asistencia inmediata y asegurese de que la persona no opere el vehiculo.",
        "Alerta: reporte de persona en estado de ebriedad ingresando a un vehiculo; responder rapidamente para abordar la emergencia y ofrecer el apoyo necesario.",
        "Se necesita respuesta: persona ebria que intenta conducir; garantizar su seguridad, proporcionar ayuda y asegurar la zona.",
    },                                                   
    CalloutUnitsRequired = {
        description = "Police",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(74.8666, -1436.6072, 29.3117),
        [2] = vector3(-76.5555, 1989.0193, 180.9692),
        [3] = vector3(220.4436, 2495.6790, 54.5016),
        [4] = vector3(409.2810, 2600.5032, 43.5221),
        [5] = vector3(614.2072, 2725.5054, 41.8296),
        [6] = vector3(1480.2856, 3734.7014, 33.7487),
        [7] = vector3(2487.2310, 4118.1738, 38.0647),
        [8] = vector3(1690.8002, 4768.3066, 41.9215),
        [9] = vector3(2548.6125, 4683.3149, 33.7332),
        [10] = vector3(2985.6746, 3496.2029, 71.3819),
        [11] = vector3(2557.5903, 2632.6567, 37.9575),
        [12] = vector3(-88.9214, -2026.9102, 18.0164),
        [13] = vector3(-219.9697, -1695.0724, 33.9713),
        [14] = vector3(-216.2287, 78.5081, 67.7878),
        [15] = vector3(-1397.6736, 66.2449, 53.4266),
        [16] = vector3(-1331.1656, 263.2677, 62.4902),
        [17] = vector3(-885.8245, 413.9728, 86.3693),
        [18] = vector3(-568.9772, 323.9600, 84.4676),
        [19] = vector3(-333.6727, 294.5822, 85.8672),
        [20] = vector3(-73.0234, 896.5555, 235.5506),
    },               
    PedChanceToFleeFromPlayer = 100,      -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 0,        -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 0,           -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 0,       -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 0,    -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 1000, -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "none",-- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_unarmed",
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
                ERS_SetPedAsDrunkPed(driver) 
                TaskVehicleDriveWander(driver, vehicle, 10.0, 786603)
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
        local pedModel = ERS_GetRandomModel(Config.randomPeds)
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z+1.0)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        SetPedIntoVehicle(ped, vehicle, -1)
        table.insert(pedList, pedNetId)

        return true
    end
}