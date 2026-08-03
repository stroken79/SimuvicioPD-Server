Config.Callouts["suspect_identified"] = {
    Enabled = true,
    Priority = 1,
    CalloutName = "Suspect Identified",
    CalloutDescriptions = {
        "Se ha identificado a un sospechoso en relacion con un robo denunciado. Mas detalles pendientes.",
        "Un sospechoso ha sido visto cerca del lugar de un presunto robo. Se necesita informacion adicional.",
        "Un sospechoso ha sido identificado en un incidente que involucra un asalto reportado. Evalue la situacion por seguridad.",
        "Se ha identificado a un sospechoso, al parecer tras cometer un acto de vandalismo. Priorizar la respuesta ante la aprehension.",
        "Se ha identificado a un sospechoso que presuntamente robaba un vehiculo. Se requiere una investigacion inmediata.",
        "Se ha identificado a un sospechoso, presuntamente desaparecido tras un secuestro denunciado. Coordinar los esfuerzos de busqueda.",
        "Se ha identificado a un sospechoso que, segun se informa, cometio un delito relacionado con drogas. Evaluar riesgos potenciales.",
        "Se ha identificado a un sospechoso en relacion con un asesinato denunciado. Acerquese a la investigacion con precaucion.",
        "Se ha identificado a un sospechoso que, segun se informa, cometio un atropello y fuga. Priorizar la respuesta ante la aprehension.",
        "Se ha identificado a un sospechoso que, segun se informa, cometio un fraude. Coordinar con las autoridades para la investigacion.",
    },            
    CalloutUnitsRequired = {
        description = "Police.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(755.62, -1337.14, 26.23),     -- La Mesa
        [2] = vector3(963.10, -1586.05, 30.45),     -- Factory
        [3] = vector3(219.15, -3002.62, 5.83),      -- Elysian Island
        [4] = vector3(-1036.90, -2736.79, 20.17),   -- LSIA
        [5] = vector3(-1259.30, -1480.23, 4.34),    -- Beach
        [6] = vector3(-1667.05, -503.34, 37.29),    -- Hotel Cougar Ave
        [7] = vector3(-512.53, -1214.96, 18.48),    -- Innocence Blvd petrol
        [8] = vector3(184.97, -1872.13, 24.49),
        [9] = vector3(241.20, -2042.94, 18.01),
        [10] = vector3(107.01, -2070.90, 17.65),
        [11] = vector3(-763.91, -2096.24, 9.02),
        [12] = vector3(-400.56, -1869.80, 20.63),
        [13] = vector3(-420.47, -1708.59, 19.37),
        [14] = vector3(285.36, -1268.65, 29.27),
        [15] = vector3(272.32, -1143.68, 29.60),
        [16] = vector3(238.33, -792.10, 30.50),
        [17] = vector3(-154.03, -612.85, 48.25),
        [18] = vector3(244.73, -392.47, 46.30),
        [19] = vector3(171.54, -249.56, 64.62),
        [20] = vector3(139.72, -123.28, 54.76),
        [21] = vector3(-48.47, 66.23, 72.48),
        [22] = vector3(-29.69, 206.49, 106.54),
        [23] = vector3(-821.16, 396.62, 91.21),
        [24] = vector3(-1090.35, 599.96, 103.06),
        [25] = vector3(-1638.11, 71.14, 62.81),
        [26] = vector3(-1814.13, 782.42, 137.55),
        [27] = vector3(-1093.47, 2703.74, 19.04),
        [28] = vector3(180.55, 3120.47, 42.36),
        [29] = vector3(592.60, 2731.74, 42.04),
        [30] = vector3(981.21, 2663.35, 43.09),
        [31] = vector3(1612.62, 3779.56, 34.73),
        [32] = vector3(2930.88, 4628.00, 48.55),
        [33] = vector3(2237.87, 4905.76, 40.65),
        [34] = vector3(1688.74, 4887.84, 42.14),
        [35] = vector3(-532.96, 4187.62, 192.65),
        [36] = vector3(-94.59, 6329.54, 33.40),
        [37] = vector3(-221.75, 6431.83, 31.20),
        [38] = vector3(-1859.28, 2071.85, 141.00),
        [39] = vector3(-362.35, 508.65, 118.90),
        [40] = vector3(323.41, 174.33, 103.64),
    },
    PedChanceToFleeFromPlayer = 75,     -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 25,       -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 25,          -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 25,      -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 5000, -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 10000,-- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "flee",  -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_knife",
        "weapon_pistol",
    },
    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)
        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                ClearPedTasks(ped)
                TaskSetBlockingOfNonTemporaryEvents(ped, true)
                Wait(100)
                ERS_SpawnConfiguredWeaponForPed(ped, calloutDataClient)
                ERS_SetPedToFleeFromPlayer(ped)
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)
        -- Build ped
        local pedModel = ERS_GetRandomModel(Config.randomPeds)
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        table.insert(pedList, pedNetId)

        return true
    end
}