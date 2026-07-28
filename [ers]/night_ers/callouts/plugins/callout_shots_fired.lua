Config.Callouts["shots_fired"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Shots Fired",
    CalloutDescriptions = {
        "Responder inmediatamente a una denuncia de disparos; asegurar el area y garantizar la seguridad publica.",
        "Alerta de emergencia: disparos en las inmediaciones; desplegar unidades para gestionar la situacion y proteger a los civiles.",
        "Se requiere una respuesta urgente: situacion de tirador activo; centrarse en neutralizar la amenaza y ayudar a los heridos.",
        "Situacion critica: disparos; actuar con rapidez para controlar el lugar y prestar ayuda a los afectados.",
        "Alerta: reporte de disparos; Se necesita una intervencion inmediata para detener la violencia y garantizar la seguridad.",
        "Incidente de tiroteo: se requieren acciones urgentes para asegurar el area y proteger a los transeuntes.",
        "Manejar una situacion que involucre disparos; priorizar la seguridad publica y coordinar con las autoridades.",
        "Situacion de emergencia: disparos; Asegurese de que el area sea segura y ayude a controlar la escena.",
        "Alerta urgente: se reporta tirador activo; responder rapidamente para gestionar la situacion y proteger al publico.",
        "Se necesita una respuesta critica: disparos; asegurar la zona, ayudar a los heridos y restablecer el orden.",
    },                   
    CalloutUnitsRequired = {
        description = "Police, Ambulance.",
        policeRequired = true,
        ambulanceRequired = true,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(-889.4525, -853.4730, 20.5661),
        [2] = vector3(-231.0190, 6260.1074, 31.4391),
        [3] = vector3(-237.1503, 6439.3364, 31.0982),
        [4] = vector3(-77.6606, 6549.7329, 31.4881),
        [5] = vector3(469.6108, 6448.6230, 30.1986),
        [6] = vector3(1697.6783, 4802.4580, 41.8141),
        [7] = vector3(2633.9438, 4596.7261, 36.1075),
        [8] = vector3(1633.8063, 3795.7200, 34.8466),
        [9] = vector3(1393.9348, 3606.6814, 39.2701),
        [10] = vector3(1545.7815, 3561.8938, 35.3486),
        [11] = vector3(1589.5295, 2891.2266, 57.1263),
        [12] = vector3(2272.5593, 1102.3688, 65.0331),
        [13] = vector3(2572.4104, 388.7282, 108.4568),
        [14] = vector3(1668.3339, -1631.9216, 112.2200),
        [15] = vector3(1381.5989, -2063.7688, 51.9946),
        [16] = vector3(1121.3654, -2602.6497, 16.8344),
        [17] = vector3(276.8874, -2505.6790, 6.4400),
        [18] = vector3(-79.5865, -1749.0245, 29.4207),
        [19] = vector3(120.0385, -1940.8367, 20.7270),
        [20] = vector3(266.9131, -1787.1008, 27.1102),
        [21] = vector3(36.7397, -1586.4495, 29.3206),
        [22] = vector3(850.5896, -2291.6616, 30.3330),
        [23] = vector3(1071.6823, -1826.0753, 37.2903),
        [24] = vector3(752.7496, -1193.8081, 24.2690),
        [25] = vector3(816.7231, -261.8644, 65.8427),
        [26] = vector3(-380.1862, 291.0942, 84.9367),
        [27] = vector3(-567.3224, 324.2887, 84.4385),
        [28] = vector3(-1858.3063, -618.8312, 11.1323),
        [29] = vector3(-1522.5084, -926.1440, 10.1185),
        [30] = vector3(-742.9850, -1042.8475, 12.3789),
    },
    PedChanceToFleeFromPlayer = 30,     -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 20,       -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 10,          -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 100,     -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 10000,-- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 15000,-- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "flee",  -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_pistol",
        "weapon_microsmg",
        "weapon_smg",
        "weapon_assaultrifle",
        "weapon_mg",
        "weapon_pumpshotgun",
        "weapon_sawnoffshotgun",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)


        local team1 = {}
        local team2 = {}
    
        local totalPeds = #pedList
        local pedsPerTeam = math.floor(totalPeds / 2)
    
        local team1Count = 0
        local team2Count = 0
    
        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                local chance = math.random(0,1)
                if chance > 0 then
                    ERS_SetPedAsDrunkPed(ped)
                end
    
                local random = math.random(100)
                if (team1Count < pedsPerTeam) or (team2Count >= pedsPerTeam and random >= 50) then
                    table.insert(team1, ped)
                    team1Count = team1Count + 1
                else
                    table.insert(team2, ped)
                    team2Count = team2Count + 1
                end
    
                TaskSetBlockingOfNonTemporaryEvents(ped, true)
    
                Wait(100)
    
                ERS_SpawnConfiguredWeaponForPed(ped, calloutDataClient)
            end
        end
    
        if #team1 > 0 and #team2 > 0 then
            for i, ped in pairs(team1) do
                local randomTarget = team2[math.random(#team2)]
                TaskCombatPed(ped, randomTarget, 0, 16)
                if Config.Debug then
                    print("Team 1 Ped "..ped.." is attacking ped "..randomTarget)
                end
            end

            for i, ped in pairs(team2) do
                local randomTarget = team1[math.random(#team1)]
                TaskCombatPed(ped, randomTarget, 0, 16)
                if Config.Debug then
                    print("Team 2 Ped "..ped.." is attacking ped "..randomTarget)
                end
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)


        local diameter = 20

        -- Build peds
        local randomAmountOfSuspects = math.random(4,12)
        for i = 1, randomAmountOfSuspects do
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
            local pedModel = ERS_GetRandomModel(Config.randomGangPeds)
            local pedCoords = vector3(coords.x, coords.y, coords.z+1.0)
            local pedHeading = math.random(360)
            local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
            local ped = NetworkGetEntityFromNetworkId(pedNetId)
            table.insert(pedList, pedNetId)
        end
    
        return true
    end
}