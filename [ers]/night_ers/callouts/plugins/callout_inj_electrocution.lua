Config.Callouts["inj_electrocution"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "A person has been electrocuted",
    CalloutDescriptions = {
        "Emergencia: responder a informes de una persona electrocutada; garantizar la seguridad de los transeuntes y proporcionar asistencia medica inmediata.",
        "Alerta urgente: enviar unidades al lugar de una electrocucion; asegurar la zona y administrar medidas para salvar vidas.",
        "Se requiere respuesta critica: atender informes de electrocucion; coordinar con el personal medico para realizar las intervenciones necesarias.",
        "Aviso: consultar reportes de persona electrocutada; tomar medidas inmediatas para asegurar la zona y proporcionar asistencia medica.",
        "Alerta: responder con prontitud a un incidente de electrocucion; priorizar la atencion a las victimas y prevenir mayores peligros.",
        "Incidente reportado: investigan a persona electrocutada; Colaborar con los servicios de emergencia para estabilizar a la victima.",
        "Accion inmediata: abordar los informes de electrocucion; implementar protocolos para garantizar la seguridad y brindar atencion medica.",
        "Alerta de situacion: ayudar en la gestion de un incidente de electrocucion; garantizar que el area sea segura y brindar apoyo a los equipos medicos.",
        "Respuesta a emergencias: manejar reportes de una persona electrocutada; Siga los protocolos medicos para salvar vidas y mantener la seguridad.",
        "Se necesita respuesta: investigar con urgencia los informes de una persona electrocutada; tomar las medidas adecuadas para evitar mayores danos y proporcionar la ayuda necesaria.",
    },                                                              
    CalloutUnitsRequired = {
        description = "Police, Ambulance.",
        policeRequired = true,
        ambulanceRequired = true,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(1353.1198, 3602.6426, 34.8422),
        [2] = vector3(2647.1370, 553.8140, 95.7575),
        [3] = vector3(2094.0078, 2325.3831, 94.2853), 
        [4] = vector3(2278.6301, 2969.2185, 46.5811), 
        [5] = vector3(2840.2234, 1553.8225, 24.5741), 
        [6] = vector3(2821.8545, 1511.8513, 24.7242), 
        [7] = vector3(2458.3921, 1457.0712, 36.2040), 
        [8] = vector3(1127.5670, -2489.8242, 33.3611), 
        [9] = vector3(233.3477, 6399.8403, 31.6335), 
        [10] = vector3(1346.0159, 6383.4556, 33.4101), 
        [11] = vector3(2050.1416, 3683.3496, 34.5879), 
        [12] = vector3(683.1802, 120.5065, 80.7545), 
        [13] = vector3(2670.0710, 1395.4910, 24.5107),
        [14] = vector3(2836.6687, 1573.3999, 24.7241),
        [15] = vector3(2617.8452, 1690.0687, 27.5987),
        [16] = vector3(2560.6836, 2580.0842, 37.9533),
        [17] = vector3(2147.8455, 3386.1294, 45.4485),
        [18] = vector3(1686.9581, 3592.4873, 35.6091),
        [19] = vector3(1532.7958, 3795.6772, 33.5183),
        [20] = vector3(4-679.5399, 5790.6323, 17.3309),
    },               
    PedChanceToFleeFromPlayer = 0,      -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 0,        -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 0,           -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 0,       -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 0,    -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 1000, -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "none",  -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_unarmed"
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)


        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped)
                TaskSetBlockingOfNonTemporaryEvents(ped, true)
                ERS_ApplyBloodToPed(ped)

                local pedLoc = GetEntityCoords(ped)
                ShootSingleBulletBetweenCoordsPresetParams(pedLoc.x, pedLoc.y, pedLoc.z+1.0, pedLoc.x, pedLoc.y, pedLoc.z, 200.0, 100, GetHashKey("WEAPON_STUNGUN"), plyPed, false, true, 500.0)
                PlayPain(ped, 20, 1, 1)
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        -- Build victim
        local pedModel = ERS_GetRandomModel(Config.randomPeds)
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        table.insert(pedList, pedNetId)

        return true
    end
}