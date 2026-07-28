Config.Callouts["domestic_dispute"] = {
    Enabled = true,
    Priority = 1,
    CalloutName = "Domestic Dispute",
    CalloutDescriptions = {
        "Se recibio una llamada de socorro informando de un disturbio domestico. Mas detalles pendientes.",
        "Los informes indican una acalorada discusion que se convirtio en un incidente de violencia domestica. Se necesita informacion adicional.",
        "Los servicios de emergencia han sido alertados de una situacion interna volatil. Evalue la escena por seguridad.",
        "Los vecinos han informado de un disturbio que sugiere un incidente de violencia domestica. Priorizar la respuesta para la intervencion.",
        "Un ciudadano preocupado ha informado de ruidos de un altercado domestico cercano. Se requiere una investigacion inmediata.",
        "Se ha recibido una llamada frenetica que indica una posible situacion de violencia domestica. Coordinar los esfuerzos de respuesta.",
        "Los testigos han observado un comportamiento sospechoso que indica una disputa domestica. Evalue los riesgos potenciales antes de continuar.",
        "Los servicios de emergencia han sido enviados a una residencia tras informes de un incidente domestico. Acercate con precaucion.",
        "Los informes de ciudadanos preocupados sugieren que se trata de un disturbio interno que requiere atencion inmediata. Priorizar la respuesta para la intervencion.",
        "Los servicios de emergencia han sido notificados de una posible situacion de violencia domestica. Coordinar con las autoridades para la investigacion.",
    },
    CalloutUnitsRequired = {
        description = "Police.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(-218.79, -1671.06, 34.46),     -- Davis
        [2] = vector3(204.20, -1706.48, 29.30),      -- Davis
        [3] = vector3(72.79, -1971.16, 20.81),       -- Grv Str. Davis
        [4] = vector3(-11.37, -1433.59, 31.12),      -- Forum Dr. Strawberry
        [5] = vector3(-684.74, 311.88, 83.08),       -- Terras, West Vinewood
        [6] = vector3(-802.68, -173.13, 72.84),      -- Rockford Hills, Michaels House
        [7] = vector3(-1269.22, 502.25, 97.11),      -- Montana House, Vinewood Hills
        [8] = vector3(-37.97, 2865.60, 59.18),       -- Grand Senora Desert, Route 68 Appr.
        [9] = vector3(1393.42, 3603.21, 38.94),      -- Algonquin Blvd, Sandy Shores 
        [10] = vector3(1651.51, 3805.67, 34.98),     -- Cholla Springs Ave, Sandy Shores
        [11] = vector3(1717.82, 4676.85, 43.66),     -- Grapeseed Main street
        [12] = vector3(-221.87, 6457.18, 31.20),     -- Procopio Dr. Paleto Bay
        [13] = vector3(152.46, -67.65, 75.59),
        [14] = vector3(123.23, -124.85, 54.83),
        [15] = vector3(-83.17, -399.36, 37.02),
        [16] = vector3(-580.11, -450.97, 34.25),
        [17] = vector3(-585.01, -778.63, 25.02),
        [18] = vector3(-768.56, -1026.56, 14.13),
        [19] = vector3(-962.78, -1336.89, 5.86),
        [20] = vector3(-1091.03, -1598.80, 4.54),
        [21] = vector3(-1099.65, -1491.92, 4.94),
        [22] = vector3(-1340.53, -1085.94, 6.93),
        [23] = vector3(-1694.72, -159.24, 57.53),
        [24] = vector3(-1475.38, -69.34, 54.64),
        [25] = vector3(870.97, -602.44, 58.22),
        [26] = vector3(1250.40, -698.28, 64.77),
        [27] = vector3(1056.11, -2434.86, 30.30),
        [28] = vector3(-1099.53, -1636.62, 4.41),
        [29] = vector3(-1268.18, -1300.48, 8.29),
        [30] = vector3(-1100.09, -1009.88, 2.15),
        [31] = vector3(-773.32, -1262.42, 5.70),
        [32] = vector3(-704.79, -1035.82, 16.11),
        [33] = vector3(-551.47, -810.51, 30.75),
        [34] = vector3(266.59, -637.23, 42.02),
        [35] = vector3(44.35, -902.36, 29.98),
        [36] = vector3(-281.74, -800.32, 33.00),
        [37] = vector3(-780.90, -193.10, 37.28),
        [38] = vector3(-876.24, 42.46, 48.76),
        [39] = vector3(-951.93, 192.81, 67.39),
        [40] = vector3(-1009.26, 455.48, 79.36),
    },         
    PedChanceToFleeFromPlayer = 50,     -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 20,       -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 0,           -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 25,      -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 10000,-- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 20000,-- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "flee",  -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_knife",
        "weapon_bat",
        "weapon_hammer",
        "weapon_wrench",
        "weapon_pistol",
    },
    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)
        local ped1
        local ped2

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                if ped1 == nil then
                    ped1 = ped
                end
                if ped1 ~= nil and ped1 ~= ped then
                    ped2 = ped
                end
                ClearPedTasks(ped)
                TaskSetBlockingOfNonTemporaryEvents(ped, true)
                Wait(100)
                ERS_SpawnConfiguredWeaponForPed(ped, calloutDataClient)
            end
        end

        -- Intial actions
        local randomPercentageChance = math.random(1, 100)
        if randomPercentageChance > 0 and randomPercentageChance < 50 then
            TaskCombatPed(ped1, ped2, 0, 16)
            TaskCombatPed(ped2, ped1, 0, 16)

            if Config.Debug then
                print("Attacking eachother.")
            end

        elseif randomPercentageChance >= 50 and randomPercentageChance <= 75 then
            TaskCombatPed(ped1, ped2, 0, 16)
            TaskReactAndFleePed(ped2, ped1)

            if Config.Debug then
                print("Attacking and other fleeing.")
            end

        elseif randomPercentageChance > 75 and randomPercentageChance <= 100 then
            TaskCombatPed(ped1, plyPed, 0, 16)
            TaskReactAndFleePed(ped2, ped1)

            if Config.Debug then
                print("Attacking player and other fleeing from ped.")
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)
        for i = 1, 2 do
            -- Build 2 peds
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