Config.Callouts["stuck_roof"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Person stuck on a roof",
    CalloutDescriptions = {
        "Responder a un reporte de una persona atrapada en un techo; proporcionar asistencia inmediata y garantizar su descenso seguro.",
        "Alerta: persona varada en un techo; desplegar unidades al lugar y evaluar la situacion.",
        "Unidades necesarias: llamada de emergencia para una persona atrapada en un techo; centrarse en garantizar su seguridad y proporcionar la ayuda necesaria.",
        "Aviso: reportan persona varada en un techo; actuar con prontitud para controlar la situacion y ofrecer asistencia.",
        "Alerta: reporte de persona atrapada en un techo; Se necesita intervencion para asegurar el lugar y ayudarles a bajar de forma segura.",
        "Incidente reportado: persona atrapada en un techo; tomar medidas para brindar atencion y apoyo urgentes.",
        "Responder a una situacion que involucre a una persona atrapada en un techo; priorizar su seguridad y coordinar con los servicios de rescate.",
        "Alerta de situacion: persona atrapada en un tejado; proporcionar asistencia inmediata y garantizar que la escena sea segura.",
        "Alerta: reporte de persona varada en techo; responder rapidamente para abordar la emergencia y ofrecer el apoyo necesario.",
        "Se necesita respuesta: persona atrapada en un tejado; garantizar su seguridad, proporcionar ayuda y asegurar la zona.",
    },                                             
    CalloutUnitsRequired = {
        description = "Police, Ambulance, Fire.",
        policeRequired = true,
        ambulanceRequired = true,
        fireRequired = true,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(294.60, -1278.10, 33.80),
        [2] = vector3(108.80, -1089.97, 55.29),
        [3] = vector3(147.44, -1045.87, 49.22),
        [4] = vector3(-702.66, -677.43, 44.96),
        [5] = vector3(-1273.67, -590.35, 42.07),
        [6] = vector3(-950.18, -291.80, 83.12),
        [7] = vector3(-408.71, -189.23, 69.27),
        [8] = vector3(-87.21, -295.60, 63.07),
        [9] = vector3(217.83, -393.84, 59.66),
        [10] = vector3(461.11, 33.42, 110.89),
        [11] = vector3(294.16, 310.53, 132.09),
        [12] = vector3(214.79, 1191.13, 240.26),
        [13] = vector3(1153.12, 2384.42, 68.36),
        [14] = vector3(418.17, -1513.96, 40.92),
        [15] = vector3(112.17, -1523.72, 36.35),
        [16] = vector3(57.56, -1739.80, 47.70),
        [17] = vector3(-96.32, -1787.92, 40.60),
        [18] = vector3(-185.91, -1711.78, 37.68),
        [19] = vector3(98.72, -1500.22, 36.34),
        [20] = vector3(81.95, -1389.92, 34.83),
        [21] = vector3(149.77, -1346.10, 37.44),
        [22] = vector3(35.06, -1296.72, 34.80),
        [23] = vector3(-243.15, -1322.39, 48.41),
        [24] = vector3(416.72, -878.00, 44.56),
        [25] = vector3(-527.91, -692.21, 44.03),
        [26] = vector3(-1204.88, -837.79, 29.41),
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

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                TaskSetBlockingOfNonTemporaryEvents(ped, true)
                
                local scenario = ERS_SelectMentalHealthPersonScenario()
                TaskStartScenarioInPlace(ped, scenario, 0, true)
            end
        end

    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        -- Build ped
        local pedModel = ERS_GetRandomModel(Config.randomPeds)
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)

        table.insert(pedList, pedNetId)

        return true
    end
}