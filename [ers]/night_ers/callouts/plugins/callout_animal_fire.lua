Config.Callouts["animal_fire"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Animal on fire",
    CalloutDescriptions = {
        "Un animal se ha incendiado y es necesaria una intervencion inmediata para salvarlo.",
        "Se necesitan equipos de emergencia para extinguir las llamas de un animal en llamas.",
        "Las autoridades informan de un animal en llamas, lo que requiere medidas urgentes para evitar danos mayores.",
        "Una situacion critica con un animal en llamas; Se necesitan unidades adicionales para ayudar.",
        "Se requiere respuesta inmediata para rescatar a un animal envuelto en llamas.",
        "Un animal se esta quemando, lo que representa una grave amenaza; Se necesitan refuerzos para manejar la situacion.",
        "Los equipos de emergencia solicitan refuerzos para salvar a un animal en llamas y evitar que las llamas se propaguen.",
        "Se ha emitido un llamado urgente de ayuda para atender a un animal atrapado en un incendio.",
        "Los socorristas estan en la escena de un animal en llamas y necesitan apoyo adicional para controlar las llamas.",
        "Una emergencia grave que involucra un animal en llamas exige una accion rapida para proteger tanto al animal como a las areas cercanas.",
    },
    CalloutUnitsRequired = {
        description = "Police, Fire.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = true,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(1425.4738, -2374.1970, 67.0164), 
        -- [2] = vector3(2278.6301, 2969.2185, 46.5811), 
        -- [3] = vector3(2840.2234, 1553.8225, 24.5741), 
        -- [4] = vector3(2821.8545, 1511.8513, 24.7242), 
        -- [5] = vector3(2458.3921, 1457.0712, 36.2040), 
        -- [6] = vector3(1127.5670, -2489.8242, 33.3611), 
        -- [7] = vector3(233.3477, 6399.8403, 31.6335), 
        -- [8] = vector3(1346.0159, 6383.4556, 33.4101), 
        -- [9] = vector3(2050.1416, 3683.3496, 34.5879), 
        -- [10] = vector3(683.1802, 120.5065, 80.7545), 

        -- Add more to 40
    },        
    PedChanceToFleeFromPlayer = 70,     -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 0,        -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 10,          -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 0,       -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 1000, -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 5000, -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "flee",  -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_unarmed",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)


        local victim
        local suspectPedList = {}
        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                TaskSetBlockingOfNonTemporaryEvents(ped, true)
                if ERS_IsPedAnAnimalPed(ped) then
                    victim = ped
                    StartEntityFire(victim)
                    ERS_ApplyBloodToPed(victim)
                elseif index == 2 then
                    table.insert(suspectPedList, PedToNet(ped))
                    ERS_SetPedToFleeFromPlayer(ped)
                else
                    TaskTurnPedToFaceEntity(ped, victim, -1)
                    Wait(1000)
                    local scenario = ERS_SelectRandomBystanderScenario()
                    TaskStartScenarioInPlace(ped, scenario, 0, true)
                end
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, suspectPedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        local diameter = 10

        -- Build fire
        if UsingSmartFiresV2 or UsingSmartFires then
            local fireSize = Config.RandomSmallFireOrSmokeSize[math.random(#Config.RandomSmallFireOrSmokeSize)]
            local fireType = Config.NormalFireTypes[math.random(#Config.NormalFireTypes)]
            fireList[#fireList + 1] = ERS_AddCalloutFire(vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z-0.5), fireType, fireSize)
        elseif UsingSmartFiresLite then
            local fireSize = Config.RandomSmallFireOrSmokeSize[math.random(#Config.RandomSmallFireOrSmokeSize)]
            fireList[#fireList + 1] = ERS_AddCalloutFire(vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z-0.5), "normal", fireSize)
        end

        -- Build victim
        local pedModel = ERS_GetRandomModel(Config.calloutAnimals)
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        table.insert(pedList, pedNetId)

        -- Build suspect & bystander(s)
        local randomAmountOfBystanders = math.random(3)
        for i = 1, randomAmountOfBystanders do
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)

            local pedModel = ERS_GetRandomModel(Config.randomPeds)
            local pedCoords = vector3(coords.x, coords.y, coords.z)
            local pedHeading = math.random(360)
            local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
            local ped = NetworkGetEntityFromNetworkId(pedNetId)
            table.insert(pedList, pedNetId)
        end

        return true
    end
}