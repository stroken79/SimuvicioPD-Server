Config.Callouts["fight"] = {
    
    Enabled = true,
    Priority = 1,
    CalloutName = "Fight",
    CalloutDescriptions = {
        "Ha estallado una pelea en las calles, con los combatientes intercambiando golpes en medio de una multitud reunida.",
        "Se ha llamado a los servicios de emergencia para que intervengan en una caotica pelea callejera que genera mucha tension.",
        "Los informes indican que se desarrollo un altercado violento en un area publica, con varias personas involucradas.",
        "La confrontacion se convirtio en un altercado fisico, lo que llevo a los transeuntes a buscar ayuda.",
        "Una acalorada discusion se ha convertido en una pelea en toda regla, y los espectadores exigen una intervencion inmediata.",
        "Se ha informado de un disturbio y los sonidos de una pelea resonaron en el vecindario. Responda con precaucion.",
        "Los testigos informan de un enfrentamiento entre multiples partes y la situacion se esta intensificando rapidamente. Acercate con extrema precaucion.",
        "Los servicios de emergencia han sido enviados a un lugar donde ha estallado una pelea, lo que representa una amenaza para la seguridad publica.",
        "Los informes sugieren un altercado violento que requiere atencion urgente. Movilizar recursos para una resolucion rapida.",
        "Los servicios de emergencia han sido alertados de un posible enfrentamiento. Coordinar con las autoridades para desescalar la situacion.",
    },            
    CalloutUnitsRequired = {
        description = "Police, ambulance.",
        policeRequired = true,
        ambulanceRequired = true,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(-218.79, -1671.06, 34.46),       -- Davis
        [2] = vector3(204.20, -1706.48, 29.30),        -- Davis
        [3] = vector3(72.79, -1971.16, 20.81),         -- Grv Str. Davis
        [4] = vector3(-11.37, -1433.59, 31.12),        -- Forum Dr. Strawberry
        [5] = vector3(-684.74, 311.88, 83.08),         -- Terras, West Vinewood
        [6] = vector3(-802.68, -173.13, 72.84),        -- Rockford Hills, Michaels House
        [7] = vector3(-1269.22, 502.25, 97.11),        -- Montana House, Vinewood Hills
        [8] = vector3(-37.97, 2865.61, 59.18),         -- Grand Senora Desert, Route 68 Appr.
        [9] = vector3(1393.42, 3603.21, 38.94),        -- Algonquin Blvd, Sandy Shores 
        [10] = vector3(1651.51, 3805.67, 34.98),       -- Cholla Springs Ave, Sandy Shores
        [11] = vector3(1717.82, 4676.85, 43.66),       -- Grapeseed Main Street
        [12] = vector3(-221.87, 6457.18, 31.20),       -- Procopio Dr. Paleto Bay
        [13] = vector3(1990.99, 3048.07, 47.22),       -- Yellow Jack (Sandy)
        [14] = vector3(-297.58, 6254.43, 31.48),       -- Hen House (Paleto)
        [15] = vector3(219.45, 300.67, 105.57),        -- 7088 Alta Str. (City)
        [16] = vector3(118.47, -1286.84, 28.27),       -- Vanilla Unicorn (City)
        [17] = vector3(-824.06, -1221.66, 7.37),       -- 8236 Hotel (City)
        [18] = vector3(-803.07, -932.42, 17.89),       -- Park (City)
        [19] = vector3(-946.74, -787.83, 15.92),       -- 8087 Skatepark (City)
        [20] = vector3(-987.96, -386.97, 45.36),       -- Bridge 7225 (City)
        [21] = vector3(-1199.08, 349.09, 71.14),       -- 7054 Vinewood (City)
        [22] = vector3(-720.96, 81.89, 55.86),         -- Kifflom 7151 (City)
        [23] = vector3(-497.94, 65.17, 56.50),         -- Garage Rooftop (City)
        [24] = vector3(-387.93, -67.28, 45.19),        -- Alleyway LS Customs (City)
        [25] = vector3(-377.88, 223.04, 84.22),        -- Nightclub (City)
        [26] = vector3(-422.30, 265.51, 83.20),        -- Nightclub (City)
        [27] = vector3(-555.78, 283.94, 82.18),        -- Bar (City)
        [28] = vector3(-52.26, -773.81, 32.89),        -- Weird Depot (City)
        [29] = vector3(244.11, -755.45, 30.83),        -- Garage Bottom Legion (City)
        [30] = vector3(361.15, -792.78, 29.29),        -- Alleyway Mission Row (City)
        [31] = vector3(426.23, -800.99, 29.49),        -- Binco's MR (City)
        [32] = vector3(456.47, -608.74, 28.50),        -- Dashound (City)
        [33] = vector3(454.24, -765.57, 27.37),        -- China Town MR (City)
        [34] = vector3(389.78, -356.29, 48.02),        -- 7195 (City)
        [35] = vector3(2002.19, 3798.70, 32.18),       -- Mechanic (Sandy)
        [36] = vector3(1861.29, 3870.04, 33.07),       -- Random House (Sandy)
        [37] = vector3(1709.93, 3869.28, 34.78),       -- House Patriot (Sandy)
        [38] = vector3(1512.02, 4790.44, 33.51),       -- Boat House (Sandy)
        [39] = vector3(-333.22, 6146.83, 31.49),       -- Church (Paleto)
        [40] = vector3(-315.97, 6293.39, 35.19),       -- Scaffold (Paleto)
        [41] = vector3(-109.52, 6465.71, 31.63),       -- Bank (Paleto)
        [42] = vector3(63.26, 6560.11, 29.33),         -- Construction Site (Paleto)
        [43] = vector3(1985.06, 3774.55, 32.18),       -- Additional Location (Sandy)
        [44] = vector3(2432.03, 4022.39, 36.88),       -- Additional Location (Sandy)
        [45] = vector3(2455.81, 4978.84, 46.81),       -- Additional Location (Sandy)
        [46] = vector3(3316.37, 5167.69, 18.41),       -- Additional Location (Sandy)
        [47] = vector3(446.51, 5572.15, 781.19),       -- Additional Location (Sandy)
    },        
    PedChanceToFleeFromPlayer = 20,     -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 20,       -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 20,          -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 25,      -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 10000,-- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 15000,-- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "flee",  -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_knife",
        "weapon_bat",
        "weapon_hammer",
        "weapon_wrench",
        "weapon_pistol",
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

        local randomBrawlers = math.random(2, 8)
        for i = 1, randomBrawlers do
            -- Build peds
            local pedModel = ERS_GetRandomModel(Config.randomPeds)
            local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
            local pedHeading = math.random(360)
            local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
            local ped = NetworkGetEntityFromNetworkId(pedNetId)
            table.insert(pedList, pedNetId)
        end
    
        return true
    end
}