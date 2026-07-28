Config.Callouts["possible_murder"] = {
    
    Enabled = true,
    Priority = 1,
    CalloutName = "Possible Murder",
    CalloutDescriptions = {
        "La persona que llama informa de una muerte sospechosa; se necesita una investigacion inmediata.",
        "Llamada de emergencia: persona encontrada muerta en circunstancias misteriosas, se requiere respuesta policial urgente.",
        "¡Emergencia! Se informo de una muerte inexplicable, posible juego sucio involucrado.",
        "Se reporto una muerte sospechosa, se necesitan detectives de homicidios en la escena lo antes posible.",
        "Solicitan auxilio por posible asesinato, victima encontrada con heridas sospechosas.",
        "Urgente: posible homicidio, se necesita policia y equipo forense de inmediato.",
        "Los testigos informan que descubrieron un cuerpo, las senales sugieren un posible asesinato y se requieren servicios de emergencia.",
        "Se reporto escena de crimen grave, posible asesinato, todas las unidades responden.",
        "La persona que llama indica una muerte sospechosa, se necesita personal de emergencia para la investigacion.",
        "Informe de un posible asesinato, se requiere intervencion policial inmediata.",
    },                           
    CalloutUnitsRequired = {
        description = "Police",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        vector3(571.27, 116.67, 98.04),          -- Langlwey Hill, downtown Vinewood
        vector3(-1610.21, -992.59, 7.65),        -- Vespucci beach, Pier
        vector3(176.54, 1246.37, 223.77),        -- Eastman way, Vinewood hills
        vector3(-675.35, -631.46, 25.30),        -- Belford road, Little Souel
        vector3(-588.82, -1770.54, 22.68),       -- Dark Ln, La Puerta
        vector3(-27.91, -1203.60, 29.51),        -- Under M25, Strawberry
        vector3(1593.50, -1690.90, 88.09),       -- Witter Ave, Burro Heights
        vector3(2822.94, -746.96, 1.73),         -- Arksey Rd, Pacific Ocean
        vector3(1237.75, -413.37, 68.94),        -- Green gardens, MP
        vector3(2784.11, 1397.43, 24.65),        -- Power Plant
        vector3(1732.47, 3247.21, 41.36),        
        vector3(665.81, 3569.90, 33.21),         
        vector3(245.65, 3595.09, 34.20),         
        vector3(50.83, 3682.69, 39.74),          
        vector3(503.01, 5595.35, 795.77),        
    },                                                           
    PedChanceToFleeFromPlayer = 50,      -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 50,        -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 50,           -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 100,      -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 5000,  -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 10000, -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "attack", -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_knife",
        "weapon_dagger",
        "weapon_hatchet",
        "weapon_machete",
        "weapon_switchblade",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)

        local victim
        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                if index == 1 then
                    ERS_RequestNetControlForEntity(ped)
                    TaskSetBlockingOfNonTemporaryEvents(ped, true)
                    ERS_ApplyBloodToPed(ped)
                    SetEntityHealth(ped, 0)
                    victim = ped
                else
                    TaskTurnPedToFaceEntity(ped, victim, 2500)
                    local scenario = ERS_SelectMentalHealthPersonScenario()
                    TaskStartScenarioInPlace(ped, scenario, 0, true)
                end
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)
        

        local diameter = 6  

        -- Build victim
        local pedModel = ERS_GetRandomModel(Config.randomPeds)
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        table.insert(pedList, pedNetId)

        -- Build suspect
        local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)

        local suspectPedModel = ERS_GetRandomModel(Config.randomPeds)
        local suspectPedCoords = vector3(coords.x, coords.y, coords.z)
        local suspectPedHeading = math.random(360)
        local suspectPedNetId = ERS_CreatePed(suspectPedModel, suspectPedCoords, suspectPedHeading)
        local suspectPed = NetworkGetEntityFromNetworkId(suspectPedNetId)
        table.insert(pedList, suspectPedNetId)
    
        return true
    end
}