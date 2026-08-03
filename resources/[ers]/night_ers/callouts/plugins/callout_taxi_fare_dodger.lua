Config.Callouts["taxi_fare_dodger"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Fare dodger",
    CalloutDescriptions = {
        "Alerta: responder a informes de un evasor de tarifas; garantizar la seguridad del conductor y abordar la situacion con prontitud.",
        "Alerta urgente: enviar unidades a la ubicacion de un evasor de tarifas denunciado; evitar que el sospechoso huya y resolver el problema.",
        "Se requiere accion inmediata: atender los informes de un evasor de tarifas; ayudar al conductor a recuperar el billete impago.",
        "Aviso: verifique los informes de un evasor de tarifas; tomar las acciones necesarias para identificar y manejar al sospechoso.",
        "Alerta: responder con prontitud a los informes de un evasor de tarifas; priorizar la seguridad de todas las partes involucradas y abordar el problema.",
        "Incidente reportado: investigue a un evasor de tarifas; Trabajar con las autoridades locales para gestionar la situacion de forma eficaz.",
        "Respuesta inmediata: abordar los informes de un evasor de tarifas; implementar protocolos para asegurar la compensacion al conductor y prevenir futuros incidentes.",
        "Alerta de situacion: ayudar en el manejo de un informe de evasion de tarifas; asegurese de que el area sea segura y ayude al conductor a resolver el problema.",
        "Respuesta de emergencia: manejar informes de evasores de tarifas; seguir los procedimientos para identificar al sospechoso y recuperar la tarifa impaga.",
        "Se necesita respuesta: investigar urgentemente los informes sobre un evasor de tarifas; tomar las acciones apropiadas para resolver la situacion y apoyar al conductor.",
    },                                                                        
    CalloutUnitsRequired = {
        description = "Police.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(-531.02, -1280.64, 26.05),
        [2] = vector3(-823.61, -111.83, 27.96),
        [3] = vector3(-286.70, -332.71, 18.29),
        [4] = vector3(-1368.22, -527.83, 30.33),
        [5] = vector3(-491.25, -719.88, 23.90),
        [6] = vector3(-212.88, -1028.95, 30.14),
        [7] = vector3(131.76, -1739.58, 30.11),
        [8] = vector3(-1038.86, -2740.55, 13.35),
        [9] = vector3(2663.66, 3928.24, 42.34),
        [10] = vector3(2700.45, 3083.12, 42.76),
        [11] = vector3(2632.89, 2946.15, 40.42),
        [12] = vector3(2851.14, 3440.11, 50.92),
        [13] = vector3(2453.31, 3854.30, 38.94),
        [14] = vector3(2271.27, 3757.01, 38.42),
        [15] = vector3(1820.61, 3507.98, 38.32),
        [16] = vector3(1693.80, 3461.85, 37.02),
        [17] = vector3(1184.28, 3267.64, 39.20),
        [18] = vector3(-3040.17, 3745.06, 70.20),
        [19] = vector3(-4050.71, 5335.75, 83.14),
        [20] = vector3(-4043.33, 5599.94, 68.38),
        [21] = vector3(2874.65, 4868.66, 62.60),
        [22] = vector3(3000.50, 4099.68, 57.18),
        [23] = vector3(-92.55, 6150.44, 31.80)
    },                      
    PedChanceToFleeFromPlayer = 50,      -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 25,        -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 10,           -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 50,       -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 10000, -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 15000, -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "flee",   -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_knife",
        "weapon_bat",
        "weapon_hammer",
        "weapon_wrench",
        "weapon_pistol",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                TaskWanderStandard(ped, 10.0, 10)
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        -- Build suspect
        local pedModel = ERS_GetRandomModel(Config.randomPeds)
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        table.insert(pedList, pedNetId)

        return true
    end
}