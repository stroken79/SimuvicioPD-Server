Config.Callouts["road_rubble"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Rubble on the road",
    CalloutDescriptions = {
        "Emergencia: responder a reportes de escombros en la via; Asegurese de que el area este despejada para evitar accidentes.",
        "Alerta urgente: envio de unidades para atender escombros en la via; Retire los escombros para garantizar el paso seguro de los vehiculos.",
        "Se requiere una respuesta critica: atender los informes sobre escombros en las carreteras; asegurar la zona y evitar nuevos incidentes.",
        "Aviso: consultar reportes de escombros en la via; tomar medidas inmediatas para limpiar los escombros y restablecer la seguridad vial.",
        "Alerta: responder con prontitud a los informes de escombros en la carretera; priorizar la seguridad de los automovilistas y despejar la obstruccion.",
        "Incidente reportado: investigar reportes de escombros en la via; Coordinar con las autoridades locales para gestionar la situacion.",
        "Accion inmediata: abordar los informes de escombros en las carreteras; Utilice metodos adecuados para despejar el area y garantizar la seguridad.",
        "Alerta de situacion: ayudar a retirar los escombros de la carretera; garantizar que el area sea segura para el trafico y los peatones.",
        "Respuesta a emergencias: manejar reportes de escombros viales y seguir protocolos para retirar escombros y garantizar la seguridad vial.",
        "Se necesita respuesta: investigar urgentemente los informes sobre escombros en la carretera; tomar las medidas adecuadas para prevenir accidentes y garantizar el paso libre.",
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
        [2] = vector3(323.1100, 6571.5659, 29.0666),
        [3] = vector3(-619.8828, 5612.6821, 39.0517),
        [4] = vector3(-895.5853, 5425.6592, 36.1425),
        [5] = vector3(2.1686, 4527.1665, 107.7096),
        [6] = vector3(1918.0905, 4591.0244, 38.3464),
        [7] = vector3(2448.5151, 4276.7529, 36.8721),
        [8] = vector3(1788.3530, 3563.3096, 35.7547),
        [9] = vector3(2119.9487, 3043.8943, 45.5342),
        [10] = vector3(1755.7428, 1931.1074, 72.3967),
        [11] = vector3(385.7047, -98.7011, 66.6472),
        [12] = vector3(242.6648, -633.6824, 40.3116),
        [13] = vector3(38.8675, -1131.0657, 29.3294),
        [14] = vector3(-596.7621, -1888.5531, 29.1868),
        [15] = vector3(-1008.5099, -809.5873, 16.2181),
        [16] = vector3(-696.3465, -60.0736, 37.6844),
        [17] = vector3(663.1342, -404.3603, 41.7616),
        [18] = vector3(838.3165, -1611.0994, 31.9497),
        [19] = vector3(520.7114, -1693.2850, 29.2939),
        [20] = vector3(387.5263, -1559.6461, 29.3324),
    },               
    PedChanceToFleeFromPlayer = 0,      -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 0,        -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 0,           -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 0,       -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 0,    -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 1000, -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "none",  -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_unarmed",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)

        for index, objNetId in pairs(objectList) do
            local obj = NetToObj(objNetId)
            if DoesEntityExist(obj) then
                ERS_RequestNetControlForEntity(obj) 
                PlaceObjectOnGroundProperly(obj)
            end
        end

        ERS_CreateTemporaryBlipForEntities(objectList, 30000)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        local diameter = 20

        -- Build objects
        local randomAmountOfObjects = math.random(10)
        for i = 1, randomAmountOfObjects do
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
            local objModel = ERS_GetRandomModel(Config.randomDebris)
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

        return true
    end
}