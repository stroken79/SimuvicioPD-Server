Config.Callouts["illegal_party"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Illegal Party",
    CalloutDescriptions = {
        "Responder a una denuncia de una fiesta ilegal; gestionar la multitud y garantizar el cumplimiento de las leyes locales.",
        "Alerta: fiesta no autorizada en curso; enviar unidades para atender la situacion y mantener el orden publico.",
        "Unidades necesarias: informe de una reunion no aprobada; centrarse en dispersar a la multitud y restablecer el orden.",
        "Aviso: fiesta ilegal reportada; actuar con prontitud para controlar la escena y evitar posibles perturbaciones.",
        "Alerta: informe de una parte no autorizada; intervencion necesaria para garantizar la seguridad y el cumplimiento de las normas.",
        "Incidente reportado: fiesta ilegal; tomar medidas para gestionar la multitud y hacer cumplir las leyes locales.",
        "Responder a una situacion que involucre a una parte no autorizada; priorizar la seguridad publica y la coordinacion con las autoridades locales.",
        "Alerta de situacion: fiesta ilegal en curso; Asegure el area y administre la multitud.",
        "Alerta: informe de una reunion no aprobada; responder rapidamente para abordar la situacion y garantizar la seguridad publica.",
        "Respuesta necesaria: parte no autorizada; asegurar el area, gestionar a los asistentes y garantizar el cumplimiento de la normativa.",
    },                        
    CalloutUnitsRequired = {
        description = "Police.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(1180.83, -3242.74, 6.03),
        [2] = vector3(382.12, -1227.18, 32.38),     
        [3] = vector3(146.43, -1279.99, 29.04),   
        [4] = vector3(501.40, -2159.42, 5.91),    
        [5] = vector3(367.48, -2668.01, 6.00),   
        [6] = vector3(-443.82, -2445.16, 6.00),    
        [7] = vector3(-1217.72, -1804.72, 3.71),   
        [8] = vector3(-1621.59, -1060.65, 13.09),   
        [9] = vector3(326.59, -210.93, 54.08),   
        [10] = vector3(685.86, 577.65, 130.46),
        [11] = vector3(-459.34, -1713.22, 18.67),  
        [12] = vector3(-3081.01, 551.72, 2.34),   
        [13] = vector3(-2197.92, 4260.04, 48.04),
        [14] = vector3(928.27, -2616.08, 6.10),
        [15] = vector3(2828.00, -721.21, 1.94),
        [16] = vector3(607.89, -387.84, 24.80),
        [17] = vector3(-2230.76, -418.19, 3.73),
        [18] = vector3(-934.01, 6172.48, 4.58),
        [19] = vector3(178.33, 7044.23, 1.86),
        [20] = vector3(2125.20, 4794.25, 41.15),
        [21] = vector3(2041.08, 3177.06, 44.96),
        [22] = vector3(341.01, 3566.12, 33.46),
        [23] = vector3(-419.47, 1577.32, 355.83),
        [24] = vector3(-859.44, 853.35, 202.88),
        [25] = vector3(1542.65, 6625.82, 2.36),
    },           
    PedChanceToFleeFromPlayer = 50,     -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 0,        -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 10,          -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 0,       -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 10000,-- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 15000,-- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "flee",  -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_unarmed",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)

        local soundFolder = "generic-sounds"
        local soundFile = ERS_SelectRandomPartyMusic()
        local soundVolume = LimitSoundVolume(0.1)
        PlaySound(soundFolder, soundFile, soundVolume)

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                TaskSetBlockingOfNonTemporaryEvents(ped, true)

                local scenario = ERS_SelectRandomPartyScenario()
                TaskStartScenarioInPlace(ped, scenario, 0, true)
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)


        local diameter = 15

        -- Build peds
        local randomAmountOfSuspects = math.random(10)
        for i = 1, randomAmountOfSuspects do
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
            local pedModel = ERS_GetRandomModel(Config.randomPeds)
            local pedCoords = vector3(coords.x, coords.y, coords.z+1.0)
            local pedHeading = math.random(360)
            local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
            local ped = NetworkGetEntityFromNetworkId(pedNetId)
            table.insert(pedList, pedNetId)
        end

        local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
        local objModel = "prop_boombox_01"
        local objCoords = vector3(coords.x, coords.y, coords.z)
        local objHeading = math.random(360)
        local objNetId = ERS_CreateObject(objModel, objCoords, objHeading)
            if objNetId then    
                local obj = NetworkGetEntityFromNetworkId(objNetId)
                table.insert(objectList, objNetId)
            else
                DebugPrint("^1ERROR ^7Could not create object: "..objModel)
            end

        return true
    end
}