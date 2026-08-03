Config.Callouts["animal_on_tracks"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Animal on the train tracks",
    CalloutDescriptions = {
        "Investigar informes de un animal en las vias del tren; asegurar el area y garantizar la seguridad.",
        "Alerta: enviar unidades para retirar un animal de las vias del tren; prevenir posibles accidentes.",
        "Unidades requeridas: responder a reportes de un animal en las vias del tren y tomar las acciones necesarias.",
        "Aviso: consulte los informes de un animal obstruyendo las vias del tren; implementar medidas de seguridad.",
        "Alerta: responda con prontitud a los informes de un animal en las vias del tren; priorizar la seguridad y despejar las vias.",
        "Incidente reportado: investigue los informes de un animal en las vias del tren para evitar interrupciones.",
        "Investigar informes de un animal en las vias del tren; coordinar con las autoridades pertinentes para su remocion.",
        "Alerta de situacion: atender informes de un animal obstruyendo las vias del tren; asegurese de que el area este despejada.",
        "Alerta: atender reportes de animal en las vias del tren y seguir protocolos para garantizar la seguridad.",
        "Se necesita respuesta: investigar los informes de un animal en las vias del tren y tomar las medidas adecuadas para eliminarlo.",
    },
    CalloutUnitsRequired = {
        description = "Police",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(153.18, -2083.33, 17.14),          
        [2] = vector3(272.54, -1867.12, 26.86),           
        [3] = vector3(664.85, -1103.13, 23.69),           
        [4] = vector3(669.08, -1097.25, 23.48),         
        [5] = vector3(669.67, -735.04, 24.08),         
        [6] = vector3(735.63, -524.24, 27.11),           
        [7] = vector3(738.73, -512.96, 27.39),            
        [8] = vector3(1431.49, -967.60, 61.45),            
        [9] = vector3(1573.22, -941.38, 70.74),
        [10] = vector3(1757.88, -819.74, 88.22),
        [11] = vector3(1826.75, -767.81, 94.47),
        [12] = vector3(2079.20, -692.69, 96.97),
        [13] = vector3(2237.53, -559.26, 96.02),
        [14] = vector3(2645.90, 130.26, 93.94),
        [15] = vector3(2672.17, 459.43, 94.66),
        [16] = vector3(2163.94, 1410.07, 79.75),
        [17] = vector3(1913.86, 2183.46, 61.62),
        [18] = vector3(2476.13, 2765.11, 37.96),
        [19] = vector3(2615.23, 2934.57, 39.95),
        [20] = vector3(2854.46, 3427.33, 46.75),
        [21] = vector3(2837.95, 3821.68, 44.12),
        [22] = vector3(2064.51, 3656.00, 38.55),
        [23] = vector3(1742.14, 3470.76, 38.84),
        [24] = vector3(711.45, 3177.26, 42.10),
        [25] = vector3(-85.88, 3497.44, 53.25),  
        [26] = vector3(-392.81, 3885.08, 76.91),
        [27] = vector3(-505.23, 5186.76, 89.23),
        [28] = vector3(-358.47, 5913.59, 45.39),
        [29] = vector3(-180.77, 6101.54, 31.60),
        [30] = vector3(99.54, 6310.35, 31.64),
        [31] = vector3(465.13, 6437.98, 31.85),
        [32] = vector3(877.99, 6437.00, 32.14),
        [33] = vector3(1233.69, 6432.33, 31.81),
        [34] = vector3(1666.08, 6345.36, 43.10), 
        [35] = vector3(2401.34, 5879.92, 60.57), 
        [36] = vector3(2623.79, 5468.85, 62.03),  
        [37] = vector3(2692.14, 5276.94, 62.17),
        [38] = vector3(2894.65, 4847.27, 63.09),
        [39] = vector3(3011.50, 4143.03, 58.34),  
        [40] = vector3(2957.92, 3709.76, 54.91),  
        [41] = vector3(2480.69, 2363.09, 36.98),
        [42] = vector3(2610.93, 1603.51, 28.46),
        [43] = vector3(669.48, -1056.83, 22.44),
        [44] = vector3(769.45, -1525.64, 20.49),
        [45] = vector3(537.58, -2617.92, 12.90), 
        [46] = vector3(217.48, -2524.09, 6.44), 
        [47] = vector3(217.23, -2199.28, 13.34),  
        [48] = vector3(68.30, -2589.99, 6.00),
        [49] = vector3(221.95, -2728.21, 6.13),
        [50] = vector3(217.77, -2624.48, 6.37),   
    },                      
    PedChanceToFleeFromPlayer = 0,        -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 0,          -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 0,             -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 0,         -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 0,      -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 1000,   -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "none",    -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_unarmed",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                local pos = GetEntityCoords(ped)
                local randomChance = math.random(100)
                if randomChance < 50 then
                    SetEntityHealth(ped, 0)
                else
                    TaskWanderInArea(ped, pos.x, pos.y, pos.z, 10.0, 10000, 10000)
                end
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        local pedModel = ERS_GetRandomModel(Config.allAnimals)
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        table.insert(pedList, pedNetId)
    
        return true
    end
}