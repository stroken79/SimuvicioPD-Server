Config.Callouts["fire_petrol"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Petrol station on fire",
    CalloutDescriptions = {
        "Una gasolinera esta en llamas y requiere la intervencion inmediata de los bomberos.",
        "Se necesitan equipos de emergencia para extinguir un incendio en una gasolinera local.",
        "Las autoridades informan de un incendio en una gasolinera que amenaza las estructuras cercanas y requiere una accion urgente.",
        "Se ha producido un gran incendio en una gasolinera y se necesitan unidades de extincion adicionales para contenerlo.",
        "Se requiere respuesta inmediata ante un incendio en una gasolinera que pone en peligro las zonas circundantes.",
        "Una gasolinera esta en llamas y se necesitan refuerzos para ayudar a los bomberos locales.",
        "Los bomberos solicitan refuerzos para controlar un grave incendio en una gasolinera.",
        "Se ha hecho un llamado urgente de ayuda para hacer frente al incendio de una gasolinera que se esta extendiendo hacia propiedades cercanas.",
        "Los socorristas se encuentran en el lugar del incendio de una gasolinera y necesitan apoyo adicional para evitar danos mayores.",
        "Un importante incendio en una gasolinera exige una intervencion inmediata para proteger vidas y propiedades.",
    },                         
    CalloutUnitsRequired = {
        description = "Fire.",
        policeRequired = false,
        ambulanceRequired = false,
        fireRequired = true,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(170.22, -1563.05, 29.27),
        [2] = vector3(-70.88, -1764.10, 29.35),
        [3] = vector3(-321.58, -1467.19, 30.72),
        [4] = vector3(-521.46, -1208.76, 18.32),
        [5] = vector3(-733.16, -932.26, 19.21),
        [6] = vector3(-358.36, -1537.80, 28.71),
        [7] = vector3(621.74, 263.99, 103.08),
        [8] = vector3(2581.73, 359.16, 108.64),
        [9] = vector3(1785.78, 3330.22, 41.39),
        [10] = vector3(2006.81, 3774.46, 32.40),
        [11] = vector3(1208.14, 2658.84, 37.89),
        [12] = vector3(1690.48, 4927.02, 42.23),
        [13] = vector3(1701.65, 6417.42, 32.64),
        [14] = vector3(179.09, 6604.82, 32.04),
        [15] = vector3(-91.53, 6421.69, 31.63),
        [16] = vector3(-2558.62, 2333.26, 33.22),
        [17] = vector3(-2096.23, -320.18, 13.16),
        [18] = vector3(-974.32, -2859.85, 13.94),
        [19] = vector3(2003.77, 3773.46, 32.40),
        [20] = vector3(50.36, 2778.62, 58.04),
        [21] = vector3(264.98, 2607.24, 44.98),
        [22] = vector3(179.61, 6605.00, 32.04),
        [23] = vector3(-97.05, 6416.73, 31.63),
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

        -- No other actions required clientside, add if you desire.
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)


        if UsingSmartFiresV2 or UsingSmartFires then
            local fireSize = Config.RandomLargeFireOrSmokeSize[math.random(#Config.RandomLargeFireOrSmokeSize)]
            fireList[#fireList + 1] = ERS_AddCalloutFire(vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z-0.5), Config.ChemicalFire, fireSize)
        elseif UsingSmartFiresLite then
            local fireSize = Config.RandomLargeFireOrSmokeSize[math.random(#Config.RandomLargeFireOrSmokeSize)]
            fireList[#fireList + 1] = ERS_AddCalloutFire(vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z-0.5), "normal", fireSize)
        end

        return true
    end
}