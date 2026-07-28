Config.Callouts["inj_stroke"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Reports of a person having a stroke",
    CalloutDescriptions = {
        "Responder a un informe de un derrame cerebral; proporcionar asistencia medica inmediata y transporte al hospital.",
        "Alerta: sospecha de accidente cerebrovascular; desplegar unidades medicas en el lugar y administrar tratamientos que salven vidas.",
        "Unidades necesarias: llamada de emergencia por accidente cerebrovascular; centrarse en estabilizar al paciente y garantizar un transporte rapido.",
        "Aviso: accidente cerebrovascular reportado; actuar con prontitud para brindar atencion y apoyo criticos.",
        "Alerta: informe de un derrame cerebral; intervencion necesaria para salvar la vida del paciente y garantizar su ingreso hospitalario oportuno.",
        "Incidente reportado: accidente cerebrovascular; tomar medidas para brindar atencion medica urgente y monitorear la condicion del paciente.",
        "Responder a una situacion que implique un derrame cerebral; priorizar la estabilizacion del paciente y prepararse para el transporte.",
        "Alerta de situacion: ictus en curso; proporcionar intervencion medica inmediata y garantizar un traslado seguro a centros medicos.",
        "Alerta: informe de un accidente cerebrovascular grave; responder rapidamente para abordar la emergencia medica y administrar la atencion necesaria.",
        "Respuesta necesaria: accidente cerebrovascular; proporcionar soporte vital avanzado para accidentes cerebrovasculares, estabilizar al paciente y transportarlo al hospital.",
    },                                      
    CalloutUnitsRequired = {
        description = "Ambulance.",
        policeRequired = false,
        ambulanceRequired = true,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(473.6247, -37.2914, 79.5529),
        [2] = vector3(432.7529, 32.2285, 90.8419),
        [3] = vector3(-1217.9330, -1719.4886, 4.4694),
        [4] = vector3(-1373.3690, -1591.1857, 2.4133),
        [5] = vector3(-1374.0642, -1121.7670, 4.5113),
        [6] = vector3(-1425.6643, -715.1627, 23.5732),
        [7] = vector3(-603.4052, -37.7887, 42.6923),
        [8] = vector3(-101.1286, 213.4689, 94.9700),
        [9] = vector3(950.3441, -470.7156, 61.1370),
        [10] = vector3(1264.8539, -495.4488, 69.0965),
        [11] = vector3(1366.7874, -600.0669, 74.3363),
        [12] = vector3(292.1092, -1141.3961, 29.3440),
        [13] = vector3(-104.8924, -1594.4504, 31.5167),
        [14] = vector3(-244.0072, -2048.8423, 27.7512),
        [15] = vector3(-683.5329, -2275.6919, 13.0480),
        [16] = vector3(-1024.1530, -2697.4939, 13.7004),
        [17] = vector3(-1122.9849, -1997.5364, 13.1377),
        [18] = vector3(-3098.3879, 243.1394, 12.3798),
        [19] = vector3(-195.9645, 6320.5688, 31.5073),
        [20] = vector3(163.7554, 6592.9429, 31.8462),
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
                SetEntityHealth(ped, 0)
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        local pedModel = ERS_GetRandomModel(Config.randomPeds)
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z+1.0)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        table.insert(pedList, pedNetId)

        return true
    end
}