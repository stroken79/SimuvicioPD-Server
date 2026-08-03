Config.Callouts["animal_dog_attack"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Person Attacked by a dog",
    CalloutDescriptions = {
        "Responder inmediatamente a un informe de una persona siendo atacada por un perro; asegurar el area y brindar asistencia medica.",
        "Alerta de emergencia: persona atacada por un perro; desplegar unidades para gestionar la situacion y garantizar la seguridad de la victima.",
        "Se requiere respuesta urgente: individuo atacado por un perro; centrarse en brindar ayuda y controlar al animal.",
        "Situacion critica: ataque de perro a una persona; actuar rapidamente para ayudar a la victima y contener al perro.",
        "Alerta: informe de un perro atacando a una persona; Se necesita intervencion inmediata para garantizar la seguridad y proporcionar ayuda.",
        "Incidente de ataque de perro: se requiere accion urgente para asegurar la zona y asistir al herido.",
        "Manejar una emergencia que involucre el ataque de un perro a una persona; priorizar la seguridad de la victima y coordinar con el control de animales.",
        "Situacion de emergencia: persona atacada por un perro; garantizar que el area sea segura y brindar la asistencia necesaria.",
        "Alerta urgente: individuo atacado por un perro; Responda rapidamente para gestionar la escena y ayudar a la victima.",
        "Se necesita una respuesta critica: ataque de un perro a una persona; asegurar el area, asistir a los heridos y controlar al animal.",
    },        
    CalloutUnitsRequired = {
        description = "Police, Ambulance.",
        policeRequired = true,
        ambulanceRequired = true,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(-1016.5710, -1280.4180, 6.1974),
        [2] = vector3(-101.3984, -446.6597, 35.9044),
        [3] = vector3(-137.1873, -433.7953, 34.1178),
        [4] = vector3(-353.7449, -992.6283, 29.2972),
        [5] = vector3(1141.6670, -643.3297, 56.7655),
        [6] = vector3(627.6739, -103.4051, 73.4221),
        [7] = vector3(428.5690, 6507.1108, 28.0105),
        [8] = vector3(-556.6186, 6240.6646, 8.9844),
        [9] = vector3(-1007.1041, 5032.3906, 179.1540),
        [10] = vector3(-1678.2893, 4244.0859, 78.9253),
        [11] = vector3(-1438.6696, 828.6215, 184.3856),
        [12] = vector3(-526.8943, 285.0213, 83.0205),
        [13] = vector3(-603.4233, -1307.2855, 12.2781),
        [14] = vector3(252.2129, -1993.1140, 20.3490),
        [15] = vector3(170.6650, -1825.4866, 28.1628),
        [16] = vector3(376.8596, -1836.3699, 28.3408),
        [17] = vector3(830.2681, -795.4789, 26.2482),
        [18] = vector3(707.4484, -863.0705, 23.8887),
        [19] = vector3(349.2947, -1140.6333, 29.3828),
        [20] = vector3(182.8992, -1222.9861, 29.3061),
    },
    PedChanceToFleeFromPlayer = 0,      -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 100,      -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 0,           -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 0,       -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 10000,-- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 15000,-- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "attack",-- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_unarmed",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)

        local dogPedList = {}
        local targetPed
        local dogPed

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                TaskSetBlockingOfNonTemporaryEvents(ped, true)

                if ERS_IsPedAnAnimalPed(ped) then
                    dogPed = ped
                    table.insert(dogPedList, PedToNet(dogPed))
                else
                    targetPed = ped
                    ERS_ApplyBloodToPed(ped)
                end
            end
        end

        if DoesEntityExist(dogPed) and DoesEntityExist(targetPed) then
            TaskCombatPed(dogPed, targetPed, 0, 16)

            local chance = math.random(100)
            if chance > 50 then
                -- Ped fights back
                TaskCombatPed(targetPed, dogPed, 0, 16)
            else
                -- Ped flees
                ERS_ClearPedTasksAndBlockEvents(targetPed)
                TaskReactAndFleePed(targetPed, dogPed)
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, dogPedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        local diameter = 5

        -- Build ped
        local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
        local pedModel = ERS_GetRandomModel(Config.randomPeds)
        local pedCoords = vector3(coords.x, coords.y, coords.z+1.0)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        table.insert(pedList, pedNetId)

        -- Build dog
        coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
        local pedModel = ERS_GetRandomModel(Config.randomDogs)
        local pedCoords = vector3(coords.x, coords.y, coords.z+1.0)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        table.insert(pedList, pedNetId)

        return true
    end
}
