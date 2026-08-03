Config.Callouts["unidentified_body"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Unidentified body found",
    CalloutDescriptions = {
        "Se ha descubierto un cuerpo no identificado que requiere una respuesta policial inmediata.",
        "Se necesita asistencia de emergencia para investigar y asegurar el area donde se descubrio un cuerpo no identificado.",
        "Los informes indican el descubrimiento de un cuerpo no identificado, lo que requiere una intervencion policial urgente.",
        "Se ha reportado un cuerpo no identificado y se necesitan refuerzos para asegurar la escena y realizar una investigacion.",
        "Los servicios de emergencia han sido enviados para atender el hallazgo de un cuerpo no identificado.",
        "Los agentes que respondieron al descubrimiento de un cuerpo no identificado hicieron una solicitud de asistencia.",
        "Se requieren unidades adicionales para apoyar a los oficiales que responden al descubrimiento de un cuerpo no identificado.",
        "Se requiere respaldo de emergencia para ayudar a los oficiales a realizar una investigacion sobre el descubrimiento de un cuerpo no identificado.",
        "Los agentes que se ocupan del descubrimiento de un cuerpo no identificado han emitido un llamado de asistencia.",
        "Los informes sugieren una situacion en la que la asistencia policial inmediata es crucial para investigar y gestionar el descubrimiento de un cuerpo no identificado.",
    },                 
    CalloutUnitsRequired = {
        description = "Police, ambulance, coroner.",
        policeRequired = true,
        ambulanceRequired = true,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(208.47, -3316.17, 5.79),           -- King Road
        [2] = vector3(-132.51, -1678.17, 34.91),         -- Strawberry Ave, Chamberlin hills
        [3] = vector3(-4964.33, -1410.93, 7.68),         -- Tug St, La Puerta
        [4] = vector3(-2005.94, -319.00, 48.10),         -- The Jetty, Vespucci beach
        [5] = vector3(-872.19, 830.25, 202.88),          -- North Sheldon Rd, Vinewood Hills
        [6] = vector3(-448.68, 1598.16, 358.63),         -- East Galileo Ave, Vinewood Hills
        [7] = vector3(-31.04, 1952.23, 190.19),          -- Baytree Canyon Rd, GSD
        [8] = vector3(407.70, 2575.28, 43.52),           -- Senora Rd, Harmony
        [9] = vector3(2076.18, 3932.20, 31.06),          -- Algonquin Blvd, Sandy Shores
        [10] = vector3(3819.60, 4491.61, 4.19),          -- Catfish view, San Chainski Mountain
        [11] = vector3(1184.28, 3267.64, 39.20),
        [12] = vector3(1693.80, 3461.85, 37.02),
        [13] = vector3(1820.61, 3507.98, 38.32),
        [14] = vector3(2271.27, 3757.01, 38.42),
        [15] = vector3(2453.31, 3854.30, 38.94),
        [16] = vector3(2632.89, 2946.15, 40.42),
        [17] = vector3(2663.66, 3928.24, 42.34),
        [18] = vector3(2700.45, 3083.12, 42.76),
        [19] = vector3(2851.14, 3440.11, 50.92),
        [20] = vector3(-3040.17, 3745.06, 70.20),
        [21] = vector3(-4050.71, 5335.75, 83.14),
        [22] = vector3(-4043.33, 5599.94, 68.38),
        [23] = vector3(2874.65, 4868.66, 62.60),
        [24] = vector3(3000.50, 4099.68, 57.18),
        [25] = vector3(-92.55, 6150.44, 31.80),
        [26] = vector3(769.43, 203.60, 83.65),
        [27] = vector3(95.80, -219.33, 54.48),
        [28] = vector3(-160.23, -756.60, 41.92),
        [29] = vector3(-270.76, -980.51, 31.21),
        [30] = vector3(181.82, -936.06, 30.09),
        [31] = vector3(231.81, -751.09, 30.82),
        [32] = vector3(237.88, -888.73, 30.49),
        [33] = vector3(1305.96, -587.50, 71.80),
        [34] = vector3(2525.68, 2612.09, 37.94),
        [35] = vector3(2692.64, 2785.85, 36.03),
        [36] = vector3(445.14, 3524.84, 33.53),
        [37] = vector3(737.51, 3534.92, 34.08),
        [38] = vector3(1345.39, 3643.31, 33.62),
        [39] = vector3(1491.65, 3771.76, 33.51),
        [40] = vector3(1812.97, 3836.61, 33.56),
        [41] = vector3(2415.94, 4813.70, 35.91),
    },                                 
    PedChanceToFleeFromPlayer = 75,     -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 25,       -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 25,          -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 10,      -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 1000, -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 5000, -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "flee",  -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_pistol",
        "weapon_knife",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)
        
        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                if index == 1 then
                    ERS_ApplyBloodToPed(ped)
                    SetEntityHealth(ped, 0)
                    TaskSetBlockingOfNonTemporaryEvents(ped, true)
                end
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)

    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)
        

        -- Build victim
        local pedModel = ERS_GetRandomModel(Config.randomPeds)
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        table.insert(pedList, pedNetId)

        -- Build potential suspect
        local randomChance = math.random(100)
        if randomChance > 50 then
            local diameter = 10
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
            local suspectPedModel = ERS_GetRandomModel(Config.randomPeds)
            local suspectPedCoords = vector3(coords.x, coords.y, coords.z)
            local suspectPedHeading = math.random(360)
            local suspectPedNetId = ERS_CreatePed(suspectPedModel, suspectPedCoords, suspectPedHeading)
            local suspectPed = NetworkGetEntityFromNetworkId(suspectPedNetId)
            table.insert(pedList, suspectPedNetId)
        end
    
        return true
    end
}