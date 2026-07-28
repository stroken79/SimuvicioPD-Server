Config.Callouts["gas_smell"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Reports of the smell of gas",
    CalloutDescriptions = {
        "Investigar informes de una fuga de gas; asegurar el area y garantizar la seguridad publica.",
        "Alerta: enviar unidades para responder a informes de una posible fuga de gas; prevenir cualquier peligro potencial.",
        "Unidades requeridas: responder a reportes de fuga de gas y tomar las acciones necesarias para contenerla.",
        "Aviso: consulte los informes de fuga de gas; implementar medidas de seguridad para proteger al publico.",
        "Alerta: responda con prontitud a los informes de una fuga de gas; priorizar la seguridad y prevenir danos.",
        "Incidente reportado: investigue los informes de fuga de gas para prevenir situaciones peligrosas.",
        "Investigar informes de una fuga de gas; coordinar con las autoridades pertinentes para abordar la situacion.",
        "Alerta de situacion: atender informes de fuga de gas; Asegurese de que el area este evacuada y asegurada.",
        "Alerta: maneje los informes de una fuga de gas y siga los protocolos para garantizar la seguridad de todos.",
        "Se necesita respuesta: investigar los informes de una fuga de gas y tomar las medidas adecuadas para evitar danos.",
    },        
    CalloutUnitsRequired = {
        description = "Fire",
        policeRequired = false,
        ambulanceRequired = false,
        fireRequired = true,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(320.3299, -2028.6627, 20.7297),
        [2] = vector3(2734.6477, 2792.8330, 34.4528),
        [3] = vector3(2713.7800, 1708.7676, 24.5957),
        [4] = vector3(997.8574, -1399.0852, 31.3591),
        [5] = vector3(452.5323, -1510.2538, 29.2950),
        [6] = vector3(1121.3575, -2448.8159, 31.1848),
        [7] = vector3(1101.7811, -2215.8853, 30.7006),
        [8] = vector3(1068.6343, -2029.6871, 30.9942),
        [9] = vector3(892.8798, -1834.2726, 30.6321),
        [10] = vector3(-162.9202, -1087.0149, 18.6834),
        [11] = vector3(-152.9407, -1098.5862, 13.1170),
        [12] = vector3(-94.6749, -979.1372, 21.2769),
        [13] = vector3(79.4206, -425.8600, 37.5528),
        [14] = vector3(76.8570, -346.6708, 42.6144),
        [15] = vector3(208.1455, -1879.8135, 24.5918),
        [16] = vector3(-508.5347, -1444.9080, 13.5982),
        [17] = vector3(-553.1423, -1659.5178, 19.2136),
        [18] = vector3(-423.6055, -1683.0629, 19.0715),
        [19] = vector3(-341.0407, -1350.1746, 31.3082),
        [20] = vector3(388.1617, -348.0286, 46.8153),
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


        local diameter = 20
        local coords = calloutDataClient.Coordinates 
        local particleDict = "scr_weap_bombs"
        local particleName = "scr_bomb_gas"
        local particleSize = 5.0
        local particleAmount = math.random(1,5)
        local timeoutInMs = math.random(15000, 45000)   -- Timeout to remove the particles.
        local chanceToExplode = 33                      -- Will the particles explode at the end? Compared to a random of 100 (%) 

        --ERS_SpawnParticlesWithinRange(coords, diameter, particleDict, particleName, particleSize, particleAmount, timeout, chanceToExplode)  
        local data = {
            diameter = diameter,
            coords = coords, 
            particleDict = particleDict,
            particleName = particleName,
            particleSize = particleSize,
            particleAmount = particleAmount,
            timeoutInMs = timeoutInMs,
            chanceToExplode = chanceToExplode
        }
        TriggerServerEvent(Config.EventPrefix..':ERS_SpawnParticlesWithinRange', data)

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                ERS_SetMovementAnimClipSetToPed(ped, "move_m@injured")
                local randomChance = math.random(100)
                if randomChance < 75 then
                    SetEntityHealth(ped, 0) 
                else
                    TaskReactAndFleePed(ped, plyPed)
                end
            end
        end
        
        ERS_CreateTemporaryBlipForEntities(pedList, 30000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)


        local diameter = 10

        -- Build victims
        local victims = math.random(5)
        for i = 1, victims do
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
            local pedModel = ERS_GetRandomModel(Config.randomPeds)
            local pedCoords = vector3(coords.x, coords.y, coords.z + 3.0)
            local pedHeading = math.random(360)
            local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
            local ped = NetworkGetEntityFromNetworkId(pedNetId)
            table.insert(pedList, pedNetId)
        end
    
        return true
    end
}