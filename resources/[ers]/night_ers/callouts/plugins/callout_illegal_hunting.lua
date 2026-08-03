Config.Callouts["illegal_hunting"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Illegal hunting activity reported",
    CalloutDescriptions = {
        "Emergencia: responder inmediatamente a informes de actividad de caza ilegal; garantizar la seguridad de la vida silvestre y detener a los perpetradores.",
        "Alerta urgente: enviar unidades al lugar donde se haya reportado caza ilegal; prevenir mayores danos a la vida silvestre y hacer cumplir las regulaciones.",
        "Respuesta critica: atender denuncias de caza ilegal; priorizar la captura de los cazadores y la preservacion del habitat natural.",
        "Accion inmediata: investigar informes de cazadores ilegales; asegurar el area y proteger las especies en peligro de extincion.",
        "Alerta: responder a una situacion de caza ilegal; tomar las medidas necesarias para hacer cumplir las leyes de proteccion de la vida silvestre.",
        "Incidente reportado: manejar reportes de actividad de caza ilegal; coordinar con las autoridades ambientales para gestionar la situacion.",
        "Alerta de situacion: ayudar a detener la caza ilegal; garantizar la seguridad de la vida silvestre y prevenir futuras actividades ilegales.",
        "Respuesta de emergencia: hacer frente a las denuncias de caza ilegal; seguir protocolos para detener a los infractores y proteger la vida silvestre.",
        "Intervencion inmediata: responder a incidentes de caza ilegal; priorizar los esfuerzos de conservacion y hacer cumplir las consecuencias legales.",
        "Se necesita respuesta: investigar urgentemente los informes de caza ilegal; tomar acciones apropiadas para salvaguardar la vida silvestre y hacer cumplir las regulaciones.",
    },                                                                        
    CalloutUnitsRequired = {
        description = "Police.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(304.4698, 4341.0410, 49.3768),
        [2] = vector3(504.2131, 763.4841, 204.5995),
        [3] = vector3(1207.5034, 1962.9425, 68.4958),
        [4] = vector3(761.4645, 2819.7319, 63.7832),
        [5] = vector3(-291.2993, 3406.9119, 143.1390),
        [6] = vector3(-388.7302, 4298.3594, 53.2579),
        [7] = vector3(-1408.7485, 4553.0562, 59.9540),
        [8] = vector3(-693.2683, 5127.5913, 125.8998),
        [9] = vector3(-478.4487, 5664.6099, 59.8453),
        [10] = vector3(1537.3450, 6494.9561, 22.3388),
        [11] = vector3(1864.3669, 6475.7451, 86.6147),
        [12] = vector3(3315.1624, 5023.2134, 24.5438),
        [13] = vector3(3695.4143, 4492.2827, 21.6310),
        [14] = vector3(3665.2588, 3772.9104, 21.7392),
        [15] = vector3(2260.9492, 1897.1869, 120.5797),
        [16] = vector3(1889.6501, 288.3779, 163.9660),
        [17] = vector3(2272.6648, -580.2591, 103.8383),
        [18] = vector3(-2053.5574, 1446.3859, 274.9150),
        [19] = vector3(27.9638, 2623.7949, 85.9685),
        [20] = vector3(103.2002, 3011.1301, 48.4709),
    },                      
    PedChanceToFleeFromPlayer = 25,      -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 50,        -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 10,           -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 100,      -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 25000, -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 40000, -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "flee",   -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_marksmanrifle",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)

        local wildAnimal
        local hunter
        local hunterPedsList = {}
        local coords = calloutDataClient.Coordinates

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                if index == 1 then
                    wildAnimal = ped
                    TaskWanderInArea(wildAnimal, coords.x, coords.y, coords.z, 40.0, 5000, 10000)
                    SetEntityHealth(wildAnimal, 200)
                    SetPedArmour(wildAnimal, 200)
                else
                    hunter = ped
                    ERS_SpawnConfiguredWeaponForPed(hunter, calloutDataClient)
                    SetEntityHealth(hunter, 200)
                    SetPedArmour(hunter, 200)
                    SetPedAccuracy(hunter, 10)
                    TaskCombatPed(hunter, wildAnimal, 0, 16)
                    table.insert(hunterPedsList, pedNetId)
                end
            end
        end
    
        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, hunterPedsList)

    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        -- 1 hunter, bad accuracy, deer. etc..

        local diameter = 30

        -- Build hunted wild animal
        local randomWildAnimalPedModel = ERS_GetRandomModel(Config.huntedAnimals)
        local wildAnimalPedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local wildAnimalPedHeading = math.random(360)
        local wildAnimalPedNetId = ERS_CreatePed(randomWildAnimalPedModel, wildAnimalPedCoords, wildAnimalPedHeading)
        local wildAnimalPed = NetworkGetEntityFromNetworkId(wildAnimalPedNetId)
        table.insert(pedList, wildAnimalPedNetId)

        -- Build suspect
        local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
        local pedModel = ERS_GetRandomModel(Config.randomHunterPeds)
        local pedCoords = vector3(coords.x, coords.y, coords.z+3.0)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        table.insert(pedList, pedNetId)
    
        return true
    end
}