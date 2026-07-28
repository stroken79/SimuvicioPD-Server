Config.Callouts["animals_escaped"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Escaped farm animals",
    CalloutDescriptions = {
        "Emergencia: responder a informes de animales de granja escapados; velar por la seguridad de las personas y animales de la zona.",
        "Alerta urgente: enviar unidades para acorralar animales de granja escapados; evitar que causen accidentes o danos.",
        "Se requiere una respuesta critica: atender los informes de animales de granja que se escaparon; Asegure el area y evite que sigan deambulando.",
        "Aviso: consulte los informes de animales de granja escapados; implementar medidas para devolverlos de manera segura a su recinto.",
        "Alerta: responda con prontitud a los informes de animales de granja que se escaparon; priorizar la seguridad tanto de los animales de granja como del publico.",
        "Incidente reportado: investigar avistamientos de animales de granja escapados; coordinar con las autoridades locales y los agricultores para gestionar la situacion.",
        "Accion inmediata: abordar los informes de animales de granja que se escaparon; utilizar metodos adecuados para acorralarlos y garantizar su seguridad.",
        "Alerta de situacion: ayude a acorralar a los animales de granja que se escaparon; asegurese de que el area sea segura y que los animales de la granja esten ilesos.",
        "Respuesta de emergencia: manejar informes de animales de granja escapados y seguir protocolos para capturarlos y devolverlos de manera segura.",
        "Se necesita respuesta: investigar urgentemente los informes sobre animales de granja escapados; tomar las medidas adecuadas para prevenir danos y proteger a los animales.",
    },                                   
    CalloutUnitsRequired = {
        description = "Police, Animal Rescue.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(-156.5135, 1941.9556, 195.2362),
        [2] = vector3(1466.7488, 992.6075, 114.9633),
        [3] = vector3(1499.7604, 1483.1517, 105.4204),
        [4] = vector3(1517.8981, 1748.6394, 109.8674),
        [5] = vector3(235.0015, 2621.3835, 46.2649),
        [6] = vector3(2559.9636, 4217.8853, 41.0057),
        [7] = vector3(2681.3750, 4837.1987, 33.4963),
        [8] = vector3(2231.8330, 5172.8379, 59.2566),
        [9] = vector3(-458.1834, 5884.9546, 32.9752),
        [10] = vector3(1484.6155, 4508.0635, 52.6044),
        [11] = vector3(2527.8472, 4688.5127, 33.6504),
        [12] = vector3(2695.5269, 4217.3936, 43.5792),
        [13] = vector3(641.7357, 1772.3513, 194.4283),
        [14] = vector3(-62.1715, 1856.3737, 200.6837),
        [15] = vector3(-2177.8003, -385.5692, 13.2969),
        [16] = vector3(1981.4440, 4971.6411, 42.1647),
        [17] = vector3(2244.5688, 5189.4077, 60.3518),
        [18] = vector3(2838.7747, 4742.7949, 47.9336),
        [19] = vector3(2986.2134, 4558.3813, 51.6006),
        [20] = vector3(895.3198, 294.8879, 87.3205),
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

        local coords = calloutDataClient.Coordinates 

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                ClearPedTasks(ped)
                TaskWanderInArea(ped, coords.x, coords.y, coords.z, 20.0, 5000, 10000)
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 30000)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        local diameter = 20

        local randomAmountOfAnimals = math.random(1, 8)
        local randomAnimalPedModel = ERS_GetRandomModel(Config.cattleAnimals)
        for i = 1, randomAmountOfAnimals do
            -- Build animals of the same type.
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
            local animalPedCoords = vector3(coords.x, coords.y, coords.z)
            local animalPedHeading = math.random(360)
            local animalPedNetId = ERS_CreatePed(randomAnimalPedModel, animalPedCoords, animalPedHeading)
            local animalPed = NetworkGetEntityFromNetworkId(animalPedNetId)
            table.insert(pedList, animalPedNetId)
        end
    
        return true
    end
}