Config.Callouts["bicycle_accident"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Accident with a bicycle",
    CalloutDescriptions = {
        "La persona que llama informa de un accidente de bicicleta con heridos. Se necesita asistencia inmediata.",
        "Llamada de emergencia recibida: ciclista atropellado por un automovil, se requiere atencion medica urgente.",
        "¡Emergencia! Se informo de un accidente de bicicleta, con posibles lesiones graves involucradas.",
        "Se informo de una colision de bicicletas, se necesitan socorristas en la escena lo antes posible.",
        "Se solicita ayuda por accidente de bicicleta, la victima parece estar inconsciente.",
        "Urgente: accidente de bicicleta con posibles lesiones en la cabeza, enviar apoyo medico.",
        "Un testigo informa que un ciclista cayo despues del accidente; se necesitan servicios de emergencia inmediatos.",
        "Se informo de un grave accidente de bicicleta; se solicito inmediatamente a una ambulancia y a la policia.",
        "La persona que llama indica un accidente de bicicleta grave, se necesita personal de emergencia.",
        "Informe de accidente de bicicleta con heridos graves, requiere intervencion urgente.",
    },                      
    CalloutUnitsRequired = {
        description = "Police, Ambulance.",
        policeRequired = true,
        ambulanceRequired = true,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(1877.74, 1275.50, 153.27),  -- 7360 Postal
        [2] = vector3(1302.03, -284.86, 89.41),   -- 7347 Postal
        [3] = vector3(1576.03, -2259.40, 93.49),  -- 9375 Postal
        [4] = vector3(-1262.42, -1512.35, 4.32),  -- 8210 Postal
        [5] = vector3(-1612.53, -1041.78, 13.15), -- 8002 Postal
        [6] = vector3(-948.18, -218.03, 37.98),   -- 7179 Postal
        [7] = vector3(-100.81, -68.12, 57.73),    -- 7137 Postal
        [8] = vector3(423.21, -215.01, 59.39),    -- 7107 Postal
        [9] = vector3(459.24, -735.82, 27.36),    -- 8044 Postal
        [10] = vector3(-173.99, -1719.37, 30.74), -- 9086 Postal
        [11] = vector3(-263.66, -1564.95, 33.48), -- 9081 Postal
        [12] = vector3(-261.75, -776.90, 32.43),  -- 8065 Postal
        [13] = vector3(112.90, 796.34, 204.43),   -- 6072 Postal
        [14] = vector3(664.86, 1350.20, 330.22),  -- 5025 Postal
        [15] = vector3(807.24, 1844.48, 124.05),  -- 5023 Postal
        [16] = vector3(-1022.65, 2214.24, 48.69), -- 4004 Postal
        [17] = vector3(1635.72, 3683.47, 34.26),  -- 3020 Postal
        [18] = vector3(2066.44, 3944.21, 32.15),  -- 3011 Postal
        [19] = vector3(2023.18, 5325.93, 138.52), -- 2001 Postal
        [20] = vector3(-605.14, 4527.68, 84.05),  -- 1095 Postal
        [21] = vector3(2663.66, 3928.24, 42.34),
        [22] = vector3(2700.45, 3083.12, 42.76),
        [23] = vector3(2632.89, 2946.15, 40.42),
        [24] = vector3(2851.14, 3440.11, 50.92),
        [25] = vector3(2453.31, 3854.30, 38.94),
        [26] = vector3(2271.27, 3757.01, 38.42),
        [27] = vector3(1820.61, 3507.98, 38.32),
        [28] = vector3(1693.80, 3461.85, 37.02),
        [29] = vector3(1184.28, 3267.64, 39.20),
        [30] = vector3(-3040.17, 3745.06, 70.20),
        [31] = vector3(-4050.71, 5335.75, 83.14),
        [32] = vector3(-4043.33, 5599.94, 68.38),
        [33] = vector3(2874.65, 4868.66, 62.60),
        [34] = vector3(3000.50, 4099.68, 57.18),
        [35] = vector3(-92.55, 6150.44, 31.80),
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


        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped)
                TaskSetBlockingOfNonTemporaryEvents(ped, true)
                ERS_ApplyBloodToPed(ped)
                SetEntityHealth(ped, 0)
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
   
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        -- Build vehicle
        local vehModel = ERS_GetRandomModel(Config.randomBicycles)
        local vehType = "bike"
        local vehCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local vehHeading = math.random(360)
        local vehNetId = ERS_CreateVehicle(vehModel, vehType, vehCoords, vehHeading)
        local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
        table.insert(vehicleList, vehNetId)

        -- Build ped
        local pedModel = ERS_GetRandomModel(Config.randomPeds)
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        SetPedIntoVehicle(ped, vehicle, -1)
        table.insert(pedList, pedNetId)    
    
        return true
    end
}