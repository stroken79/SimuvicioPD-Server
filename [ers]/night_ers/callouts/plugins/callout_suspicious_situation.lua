Config.Callouts["suspicious_situation"] = {
    
    Enabled = true,
    Priority = 1,
    CalloutName = "Suspicious situation",
    CalloutDescriptions = {
        "Se ha informado de una situacion sospechosa que requiere una investigacion inmediata.",
        "Se necesitan servicios de emergencia para abordar un incidente sospechoso.",
        "Los informes indican una situacion sospechosa que requiere una intervencion urgente.",
        "Se ha identificado una situacion sospechosa y se necesita personal adicional para su investigacion y resolucion.",
        "Se ha solicitado a los servicios de emergencia que respondan a un incidente sospechoso.",
        "Las autoridades que se ocupan de una situacion sospechosa han presentado una solicitud de asistencia.",
        "Se requieren unidades adicionales para apoyar al personal que gestiona una situacion sospechosa.",
        "Se requiere respaldo de emergencia para ayudar a las autoridades a manejar un incidente sospechoso.",
        "Los socorristas que se enfrentan a una situacion sospechosa han emitido una llamada de asistencia.",
        "Los informes sugieren una situacion en la que la intervencion inmediata es crucial para gestionar y abordar un incidente sospechoso.",
    },          
    CalloutUnitsRequired = {
        description = "Police.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(312.62, -729.49, 29.31),            -- Strawberry Ave. Textile city
        [2] = vector3(778.43, -1260.22, 26.39),           -- Popular Str. La Mesa
        [3] = vector3(919.1, -2497.89, 35.96),            -- Rooftop Hanger Way, Cypress Flats
        [4] = vector3(-758.37, -2275.35, 13.06),          -- Opium Hotel, Greenwich Pkwy LSIA
        [5] = vector3(-651.3, -1074.34, 14.76),           -- Polomino Ave Little Seoul Appt.
        [6] = vector3(-922.5, -449.48, 45.21),            -- Movie Star Way, Rockford Hills
        [7] = vector3(-677.35, 231.68, 82.85),            -- West Eclipse Blvd, West Vinewood
        [8] = vector3(2441.1, 4990.92, 46.29),            -- Union Rd. Grapeseed
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
        [20] = vector3(-587.996, -105.99, 42.94),
        [21] = vector3(-1536.15, -579.45, 33.70),
        [22] = vector3(-1342.74, -805.67, 18.89),
        [23] = vector3(-1306.35, -995.69, 4.85),
        [24] = vector3(-1589.59, -556.76, 34.94),
        [25] = vector3(-1225.44, -203.92, 39.18),  
        [26] = vector3(1028.15, 2659.62, 39.55),
        [27] = vector3(489.17, 2610.76, 43.10),
        [28] = vector3(368.19, 2637.59, 44.49),
        [29] = vector3(250.44, 2603.57, 45.00),
        [30] = vector3(610.31, 2731.38, 41.99),
        [31] = vector3(1379.04, 3597.18, 34.88),
        [32] = vector3(1520.36, 3761.85, 34.03),
        [33] = vector3(1724.26, 3719.18, 34.11),
        [34] = vector3(1989.30, 3767.38, 32.18),
        [35] = vector3(2434.24, 4020.73, 36.96),
        [36] = vector3(2500.49, 4081.92, 38.49),
        [37] = vector3(2646.71, 4254.73, 44.78),
        [38] = vector3(2104.67, 4768.53, 41.23),
        [39] = vector3(1702.87, 4803.73, 41.80),
        [40] = vector3(2527.26, 4211.30, 39.99),
    },                                                         
    PedChanceToFleeFromPlayer = 50,     -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 25,       -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 25,          -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 25,      -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 5000, -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 10000, -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "flee",  -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_poolcue",
        "weapon_golfclub",
        "weapon_crowbar",
        "weapon_bat",
        "weapon_pistol",
        "weapon_minismg",
        "weapon_smg",
        "weapon_assaultrifle",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)
        
        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped)
                if index == 1 then
                    TaskSetBlockingOfNonTemporaryEvents(ped, true)
                    TaskTurnPedToFaceEntity(ped, NetToPed(math.random(#pedList)), -1)
                    Wait(1000)
                    ClearPedTasks(ped)
                    Wait(500)
                    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_DRUG_DEALER", 0, true)
                else
                    TaskSetBlockingOfNonTemporaryEvents(ped, true)
                    TaskTurnPedToFaceEntity(ped, NetToPed(pedList[math.random(#pedList)]), -1)
                    Wait(1000)
                    ClearPedTasks(ped)
                    Wait(500)
                    TaskStartScenarioInPlace(ped, "WORLD_HUMAN_DRUG_DEALER_HARD", 0, true)
                end
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)

    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)
        
        local diameter = 10  

        -- Build suspect peds
        local suspects = math.random(2, 6)
        for i = 1, suspects do
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