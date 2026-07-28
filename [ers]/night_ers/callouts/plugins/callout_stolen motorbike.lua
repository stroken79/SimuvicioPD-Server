Config.Callouts["Stolen_motorbike"] = {
    Enabled = true,
    Priority = 1,
    CalloutName = "Stolen Motorbike",
    CalloutDescriptions = {
        "Denuncias de moto robada, mas detalles pendientes",
        "Se denuncia presunto robo de motocicleta; se necesita informacion adicional",
        "Incidente de motocicleta robada, evaluar situacion por seguridad",
        "Denuncian robo de motocicleta, priorizan respuesta para recuperacion",
        "Denuncia de robo de motocicleta; se requiere investigacion inmediata",
        "Moto reportada como desaparecida, coordinar esfuerzos de busqueda y recuperacion",
        "Denuncian motocicleta robada, evaluar riesgos potenciales",
        "Sospechoso de robo de motocicleta, acerquese a la investigacion con precaucion",
        "Denuncias por robo de motos, priorizan respuesta para recuperacion",
        "Reportan incidente de robo de moto, coordinar con autoridades",
    },
    CalloutUnitsRequired = {
        description = "Police.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(340.61, -1038.00, 29.27),          -- Mission Row
        [2] = vector3(54.32, -1312.17, 29.27),           -- Strawberry
        [3] = vector3(23.96, -1738.95, 29.27),           -- Mall Grove Street
        [4] = vector3(-1026.59, -2724.31, 13.77),        -- Airport
        [5] = vector3(-333.22, 6146.83, 31.49),          -- Church (Paleto)
        [6] = vector3(454.24, -765.57, 27.37),           -- China town MR (City)
        [7] = vector3(2002.19, 3798.70, 32.18),          -- Mechanic (Sandy)
        [8] = vector3(-946.74, -787.83, 15.92),          -- 8087 Skatepark (City)
        [9] = vector3(-166.79, 6271.88, 31.49),          -- 1026 (Paleto)
        [10] = vector3(-284.55, 6051.91, 31.51),         -- 1033 (Paleto)
        [11] = vector3(-17.17, 6264.73, 31.23),          -- 1023 (Paleto)
        [12] = vector3(200.57, 6630.61, 31.52),          -- 8087 (Paleto)
        [13] = vector3(1861.29, 3870.04, 33.07),         -- Random house (Sandy)
        [14] = vector3(1709.93, 3869.28, 34.78),         -- House Patriot (Sandy)
        [15] = vector3(1512.02, 4790.44, 33.51),         -- Boat house (Sandy)
        [16] = vector3(1091.11, -764.46, 57.28),         -- West mirror drive, Mirror park
        [17] = vector3(216.64, 648.34, 188.97),          -- Jessop Rd, Vinewood Hills
        [18] = vector3(-721.72, 593.73, 141.52),         -- Durham Rd, Vinewood hills
        [19] = vector3(-1609.13, 167.21, 59.33),         -- The White way, Richman
        [20] = vector3(-1619.83, -532.31, 34.06),        -- Hitchen Rd, Del Perro
        [21] = vector3(-1580.70, -1044.14, 12.64),       -- Longcroft rd, Del Perro pier
        [22] = vector3(-1174.80, -1513.21, 3.89),        -- Fieldcroft, Vespucci beach
        [23] = vector3(-625.06, -1187.81, 14.67),        -- Church St, La Puerta
        [24] = vector3(-471.76, -816.77, 30.13),         -- Grove Rd, Little Seoul
        [25] = vector3(-17.21, -1458.49, 30.14),         -- Kendale Rd, Strawberry
        [26] = vector3(199.27, 6574.46, 31.80),
        [27] = vector3(1391.85, 6500.05, 19.76),
        [28] = vector3(1723.97, 6387.80, 34.03),
        [29] = vector3(2553.27, 5194.82, 50.78),
        [30] = vector3(-136.89, 6224.72, 31.34),
        [31] = vector3(2600.13, 5119.80, 44.78),
        [32] = vector3(2446.42, 4009.14, 37.06),
        [33] = vector3(1831.28, 3258.06, 44.10),
        [34] = vector3(1977.05, 3081.72, 47.07),
        [35] = vector3(2558.44, 2702.69, 41.77),
        [36] = vector3(2854.36, 2819.08, 53.09),
        [37] = vector3(254.91, 2848.28, 43.59),
        [38] = vector3(85.82, 3595.74, 39.75),
        [39] = vector3(-821.40, 5761.81, 5.54),
        [40] = vector3(-300.05, 6057.30, 31.35),
    },       
    PedChanceToFleeFromPlayer = 90,     -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 10,       -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 10,          -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 25,      -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 0,    -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 2000, -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "flee",  -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_knife",
        "weapon_pistol",
    },
    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)
        local vehicle = nil
        local driver = nil

        for index, vehNetId in pairs(vehicleList) do
            local veh = NetToVeh(vehNetId)
            if DoesEntityExist(veh) then
                vehicle = veh
                ERS_RequestNetControlForEntity(vehicle) 
            end
        end

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                driver = ped
                ERS_RequestNetControlForEntity(driver) 
                if not IsPedOnAnyBike(driver) then
                    SmashVehicleWindow(vehicle, 0) -- break driver window
                end
                if not IsPedInAnyVehicle(driver, true) then
                    TaskEnterVehicle(driver, vehicle, 5000, -1, 2.0, 1, 0)
                    Wait(5000)
                    ERS_SetPedToFleeFromPlayer(driver)
                else
                    ERS_SetPedToFleeFromPlayer(driver)
                end             
            end
        end

        ERS_CreateTemporaryBlipForEntities(vehicleList, 15000)
        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)
        -- Build vehicle
        local vehModel = ERS_GetRandomModel(Config.randomMotorBikes)
        local vehType = "bike"
        local vehCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local vehHeading = math.random(360)
        local vehNetId = ERS_CreateVehicle(vehModel, vehType, vehCoords, vehHeading)
        local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
        table.insert(vehicleList, vehNetId)

        -- Build ped
        local pedModel = ERS_GetRandomModel(Config.randomPeds)
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z +1.0)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        SetPedIntoVehicle(ped, vehicle, -1)
        table.insert(pedList, pedNetId)

        return true
    end
}