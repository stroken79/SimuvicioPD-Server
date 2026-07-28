Config.Callouts["motorist_trouble"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "A Motorcyclist in Trouble",
    CalloutDescriptions = {
        "Responder a un informe de un motociclista en peligro; proporcionar asistencia inmediata y garantizar su seguridad.",
        "Alerta: motociclista en problemas; desplegar unidades al lugar y evaluar la situacion.",
        "Unidades necesarias: llamada de emergencia para motociclista en apuros; centrarse en garantizar la seguridad del ciclista y proporcionar la ayuda necesaria.",
        "Aviso: incidente de motociclista reportado; actuar con prontitud para controlar la situacion y ofrecer asistencia.",
        "Alerta: reporte de motociclista en peligro; Intervencion necesaria para asegurar el lugar y ayudar al ciclista.",
        "Incidente reportado: motociclista en problemas; tomar medidas para brindar atencion y apoyo urgentes.",
        "Responder a una situacion que involucre a un motociclista en apuros; priorizar su seguridad y coordinar con los servicios de emergencia.",
        "Alerta de situacion: motociclista en peligro; proporcionar asistencia inmediata y garantizar que la escena sea segura.",
        "Alerta: reporte de incidente de motociclista; responder rapidamente para abordar la emergencia y ofrecer el apoyo necesario.",
        "Se necesita respuesta: motociclista en problemas; garantizar la seguridad del ciclista, proporcionar ayuda y asegurar el area.",
    },                                        
    CalloutUnitsRequired = {
        description = "Police, Ambulance.",
        policeRequired = true,
        ambulanceRequired = true,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(363.8318, 131.8475, 103.0946),
        [2] = vector3(165.3648, 6576.9131, 31.8289),
        [3] = vector3(1182.2383, 6480.1406, 21.0092),
        [4] = vector3(2442.9731, 5646.5942, 45.0481),
        [5] = vector3(2481.4070, 4492.7974, 34.8779),
        [6] = vector3(2248.0789, 3233.3501, 48.1212),
        [7] = vector3(2494.7690, 1328.7114, 45.6007),
        [8] = vector3(2618.0596, 603.9803, 95.0671),
        [9] = vector3(1799.6150, -1188.7709, 83.4309),
        [10] = vector3(1424.8677, -1864.6902, 71.3417),
        [11] = vector3(-60.1252, -2061.7119, 21.6247),
        [12] = vector3(-203.0126, -1791.1558, 29.8386),
        [13] = vector3(-749.8683, -1720.9191, 39.7212),
        [14] = vector3(-827.5394, -995.8917, 13.5648),
        [15] = vector3(-1296.6694, -499.8325, 33.1732),
        [16] = vector3(-1562.0688, -166.4641, 55.4659),
        [17] = vector3(-1583.1840, 489.7940, 114.9331),
        [18] = vector3(-328.1876, 976.7682, 233.2896),
        [19] = vector3(256.1261, 1219.5848, 229.5003),
        [20] = vector3(-280.2731, 1473.8699, 288.9326),
    },           
    PedChanceToFleeFromPlayer = 0,      -- Value between 0 and 100 -> Lower is less chance.
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
                if not IsPedInAnyVehicle(driver, true) then
                    TaskEnterVehicle(driver, vehicle, 5000, -1, 2.0, 1, 0)
                    Wait(5000)
                    TaskReactAndFleePed(driver, plyPed)
                else
                    TaskReactAndFleePed(driver, plyPed)
                end             
            end
        end

        Citizen.SetTimeout(math.random(7500,15000), function() 
            ERS_RequestNetControlForEntity(driver) 
            if DoesEntityExist(driver) then
                if not IsPedDeadOrDying(driver, true) then
                    ERS_RequestNetControlForEntity(driver) 
                    SetEntityHealth(driver, 0)
                end
            end
        end)

        ERS_CreateTemporaryBlipForEntities(vehicleList, 15000)
        ERS_CreateTemporaryBlipForEntities(pedList, 15000)
    
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        -- Build vehicle
        local vehModel = ERS_GetRandomModel(Config.randomMotorBikes)
        local vehType = "bike"
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
    
        return true
    end
}