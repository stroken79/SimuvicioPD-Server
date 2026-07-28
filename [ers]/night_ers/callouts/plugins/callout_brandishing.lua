Config.Callouts["brandishing"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Person brandishing an offensive weapon",
    CalloutDescriptions = {
        "La persona que llama informa que alguien blande un arma en publico. Se necesita una intervencion policial inmediata.",
        "Llamada de emergencia: se ve a un individuo agitando un arma, se requiere respuesta policial urgente.",
        "¡Emergencia! Persona con un arma amenazando a la gente, la policia necesita lo antes posible.",
        "Persona identificada con un arma, solicitaron agentes adicionales que acudieran al lugar de inmediato.",
        "Se necesita ayuda: individuo blandiendo un arma, representando un peligro para el publico.",
        "Urgente: persona con un arma vista en una zona concurrida, envie apoyo policial ahora.",
        "Un testigo informa que un individuo blandia un arma y se requiere respaldo policial inmediato.",
        "Incidente grave: persona con arma amenazando a otros, respuesta policial urgente.",
        "La persona que llama indica que una persona agita un arma y se requiere intervencion policial de emergencia.",
        "Denuncia de persona blandiendo arma, se necesita inmediata y fuerte presencia policial.",
    },                          
    CalloutUnitsRequired = {
        description = "Police",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(312.02, 173.49, 103.73),             -- Vinewood Blvd, Downtown Vinewood
        [2] = vector3(-1358.83, -616.33, 28.53),           -- Red Desert Ave, Del Perro
        [3] = vector3(-1634.62, -1046.74, 13.15),          -- Red Desert Ave, Del Perro Beach
        [4] = vector3(-670.87, -1726.81, 25.18),           -- La Puerta Fwy, La Puerta
        [5] = vector3(39.09, -1823.58, 24.51),             -- Grove St, Davis
        [6] = vector3(525.56, -1762.27, 28.49),            -- Jamestown St, Rancho
        [7] = vector3(1347.26, -1548.74, 53.67),           -- Fudge Ln, El Burro Heights
        [8] = vector3(904.59, -1059.49, 32.83),            -- Supply St, La Mesa
        [9] = vector3(1127.62, -647.69, 56.73),            -- West Mirror Drive, Mirror Park
        [10] = vector3(597.18, 772.05, 202.79),            -- Marlow Dr, Vinewood Hills
        [11] = vector3(2504.24, 4099.16, 38.38),           -- East Joshua Rd, Grapeseed
        [12] = vector3(1564.05, 3589.36, 35.36),           -- Algonquin Blvd, Sandy Shores
        [13] = vector3(642.97, 2735.41, 41.88),            -- Route 68, Harmony
        [14] = vector3(-1131.19, 2696.14, 18.80),          -- Route 68, Great Chaparrel
        [15] = vector3(-2169.96, 4279.30, 48.98),          -- Great Ocean Hwy, North Chumash
        [16] = vector3(-1435.55, 4312.66, 2.30),           -- Cassidy Trail, Cassidy Creek
        [17] = vector3(-102.90, 6369.40, 31.48),           -- Paleto Blvd, Paleto Bay
        [18] = vector3(-1702.35, 6438.63, 32.71),          -- Senora Fwy, Mount chillad
        [19] = vector3(-55.37, 6545.97, 31.49),
        [20] = vector3(-121.01, 6455.89, 31.43),
        [21] = vector3(-141.32, 6353.57, 31.49),
        [22] = vector3(-198.16, 6220.51, 31.49),
        [23] = vector3(-341.15, 6146.56, 31.49),
        [24] = vector3(-362.37, 6071.18, 31.50),
        [25] = vector3(-253.74, 6053.39, 32.18),
        [26] = vector3(-352.09, 6080.49, 31.43),
        [27] = vector3(-293.39, 6123.37, 31.51),
        [28] = vector3(-152.95, 6194.23, 31.28),
        [29] = vector3(97.98, 6379.73, 31.23),
        [30] = vector3(-115.51, 6571.54, 29.52),
        [31] = vector3(280.69, 5.25, 79.06),
        [32] = vector3(86.86, -212.80, 54.49),
        [33] = vector3(-53.24, -190.05, 52.16),
        [34] = vector3(144.43, -1068.91, 29.19),
        [35] = vector3(-24.62, -1018.18, 28.87),
        [36] = vector3(-223.76, -1164.73, 23.00),
        [37] = vector3(-21.12, -1845.02, 25.19),
        [38] = vector3(253.31, -1956.31, 22.95),
        [39] = vector3(905.81, -1735.93, 30.56),
        [40] = vector3(1199.30, -1371.50, 35.23),
        -- Add more
    },                                                             
    PedChanceToFleeFromPlayer = 25,     -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 50,       -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 10,          -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 90,      -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 10000, -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 15000, -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "flee",  -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_poolcue",
        "weapon_golfclub",
        "weapon_crowbar",
        "weapon_bat",
        "weapon_pistol",
        "weapon_combatpistol",
        "weapon_appistol",
        "weapon_stungun",
        "weapon_microsmg",
        "weapon_smg",
        "weapon_assaultsmg",
        "weapon_assaultrifle",
        "weapon_carbinerifle",
        "weapon_advancedrifle",
        "weapon_mg",
        "weapon_combatmg",
        "weapon_pumpshotgun",
        "weapon_sawnoffshotgun",
        "weapon_assaultshotgun",
        "weapon_bullpupshotgun",
        "weapon_stungun",
        "weapon_flaregun",
        "weapon_nightstick",
        "weapon_knife",
        "weapon_hammer",
        "weapon_bat",
        "weapon_golfclub",
        "weapon_crowbar",
        "weapon_bottle",
        "weapon_dagger",
        "weapon_hatchet",
        "weapon_knuckle",
        "weapon_machete",
        "weapon_switchblade",
        "weapon_wrench",
        "weapon_battleaxe",
        "weapon_poolcue",
        "weapon_stone_hatchet",
        "weapon_pistol50",
        "weapon_smg_mk2",
        "weapon_combatpdw",
        "weapon_revolver",
        "weapon_revolver_mk2",
        "weapon_doubleaction",
    },        

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped)
                TaskSetBlockingOfNonTemporaryEvents(ped, true)

                ERS_SpawnConfiguredWeaponForPed(ped, calloutDataClient)

                local chance = 50
                if chance > math.random(100) then
                    SetEntityHealth(ped, 200)
                    SetPedArmour(ped, 200)
                    ERS_SetPedToAttackPlayer(ped)
                else
                    local scenario = ERS_SelectMentalHealthPersonScenario()
                    TaskStartScenarioInPlace(ped, scenario, 0, true)
                end
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    

    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)
        
        local diameter = 10  

        -- Build suspect peds
        local randomAmountOfSuspects = math.random(3)
        for i = 1, randomAmountOfSuspects do
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