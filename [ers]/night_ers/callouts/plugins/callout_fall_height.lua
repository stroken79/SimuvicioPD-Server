Config.Callouts["fall_height"] = {
    Enabled = true,
    Priority = 1,
    CalloutName = "Fall from a height",
    CalloutDescriptions = {
        "Una persona ha caido desde una altura considerable y requiere atencion medica inmediata.",
        "Se necesitan servicios de emergencia para ayudar a una victima de caida desde una altura.",
        "Los informes indican una caida desde una altura que requirio intervencion medica urgente.",
        "Una persona ha caido desde una altura y se necesita personal adicional para su rescate y tratamiento.",
        "Se ha solicitado a los servicios de emergencia que atiendan a una victima de caida desde altura.",
        "Los servicios de emergencia que atienden a una victima de una caida desde una altura han solicitado asistencia.",
        "Se requieren unidades adicionales para apoyar al personal de emergencia en el manejo de una victima de caida desde una altura.",
        "Se requiere respaldo de emergencia para ayudar al personal de emergencia a manejar a una victima de una caida desde una altura.",
        "Los socorristas que atienden a una victima de una caida desde una altura han emitido una llamada de asistencia.",
        "Los informes sugieren una situacion en la que la asistencia medica inmediata es crucial para gestionar y abordar una caida desde una altura.",
    },   
    CalloutUnitsRequired = {
        description = "Ambulance.",
        policeRequired = false,
        ambulanceRequired = true,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(312.62, -729.49, 29.31),           -- Strawberry Ave. Textile city
        [2] = vector3(778.43, -1260.22, 26.39),          -- Popular Str. La Mesa
        [3] = vector3(919.10, -2497.89, 35.96),          -- Rooftop Hanger Way, Cypress Flats
        [4] = vector3(-758.37, -2275.35, 13.06),         -- Opium Hotel, Greenwich Pkwy LSIA
        [5] = vector3(-651.30, -1074.34, 14.76),         -- Polomino Ave Little Seoul Appt.
        [6] = vector3(-921.44, -451.14, 39.59),          -- Movie Star Way, Rockford Hills
        [7] = vector3(-677.35, 231.68, 82.85),           -- West Eclipse Blvd, West Vinewood
        [8] = vector3(2441.10, 4990.92, 46.29),          -- Union Rd. Grapeseed
        [9] = vector3(-1247.26, -1289.18, 3.91),
        [10] = vector3(-830.33, -691.75, 27.85),
        [11] = vector3(-930.11, -393.31, 38.97),
        [12] = vector3(-189.31, -830.65, 30.72),
        [13] = vector3(105.66, -942.81, 29.69),
        [14] = vector3(1153.69, -340.26, 67.72),
        [15] = vector3(399.06, -694.78, 29.28),
        [16] = vector3(364.27, -789.78, 29.28),
        [17] = vector3(310.35, -736.36, 29.31),
        [18] = vector3(-14.66, -570.64, 37.75),
        [19] = vector3(-312.22, -439.72, 31.97),
        [20] = vector3(-588.00, -106.00, 42.94),
        [21] = vector3(-1536.15, -579.45, 33.70),
        [22] = vector3(-1342.74, -805.67, 18.89),
        [23] = vector3(-1306.35, -995.69, 4.85),
        [24] = vector3(-1589.59, -556.76, 34.94),
        [25] = vector3(-1225.44, -203.92, 39.18),  
        [26] = vector3(761.77, -676.47, 28.83),
        [27] = vector3(778.55, -158.17, 74.43),
        [28] = vector3(977.21, 5.70, 81.04),
        [29] = vector3(1255.52, -335.71, 69.08),
        [30] = vector3(777.82, 223.07, 85.41),
        [31] = vector3(321.26, 134.58, 103.47),
        [32] = vector3(-663.29, 241.58, 81.33),
        [33] = vector3(-1344.42, 457.41, 101.63),
        [34] = vector3(273.76, 2855.59, 43.64),
        [35] = vector3(224.76, 3217.02, 42.50),
        [36] = vector3(345.88, 3408.64, 36.65),  
        [37] = vector3(1415.46, 3612.75, 34.94),
        [38] = vector3(1524.32, 3567.52, 35.36),
        [39] = vector3(2339.08, 3852.54, 35.59),  
        [40] = vector3(2481.64, 4094.74, 38.07), 
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
        -- Build ped
        local pedModel = ERS_GetRandomModel(Config.randomPeds)
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z+50.0)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        table.insert(pedList, pedNetId)

        return true
    end
}