Config.Callouts["unknown_smoke"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Unknown source of smoke",
    CalloutDescriptions = {
        "Se requiere que los servicios de emergencia investiguen la fuente del humo.",
        "Las autoridades informan sobre una fuente desconocida de humo y exigen una investigacion inmediata para garantizar la seguridad.",
        "Se ha informado de humo procedente de una fuente desconocida, lo que requiere medidas urgentes para identificar y abordar la causa.",
        "Situacion critica con humo desconocido; Se necesitan unidades adicionales para apoyo.",
        "Se necesita una respuesta inmediata para abordar una fuente desconocida de humo que representa un peligro potencial.",
        "Se ha detectado una fuente desconocida de humo que representa una posible amenaza; Se necesitan refuerzos para investigar y contener cualquier peligro.",
        "Los equipos de emergencia solicitan refuerzos para ayudar en la investigacion y el manejo de una fuente desconocida de humo.",
        "Se ha emitido un llamado urgente de ayuda para manejar una fuente desconocida de humo y garantizar la seguridad.",
        "Los socorristas se encuentran en la escena de una fuente de humo desconocida y necesitan apoyo adicional para estabilizar la situacion.",
        "Una emergencia grave que involucra una fuente desconocida de humo exige una accion rapida para evitar un posible resultado catastrofico.",
    },                   
    CalloutUnitsRequired = {
        description = "Police, Fire.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = true,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(0.2095, -1733.7487, 31.6350), 
        -- [2] = vector3(2278.6301, 2969.2185, 46.5811), 
        -- [3] = vector3(2840.2234, 1553.8225, 24.5741), 
        -- [4] = vector3(2821.8545, 1511.8513, 24.7242), 
        -- [5] = vector3(2458.3921, 1457.0712, 36.2040), 
        -- [6] = vector3(1127.5670, -2489.8242, 33.3611), 
        -- [7] = vector3(233.3477, 6399.8403, 31.6335), 
        -- [8] = vector3(1346.0159, 6383.4556, 33.4101), 
        -- [9] = vector3(2050.1416, 3683.3496, 34.5879), 
        -- [10] = vector3(683.1802, 120.5065, 80.7545), 

        -- Add more to 40
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

        -- No other actions required clientside.
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        -- Build smoke
        if UsingSmartFiresV2 or UsingSmartFires then
            local smokeSize = Config.RandomLargeFireOrSmokeSize[math.random(#Config.RandomLargeFireOrSmokeSize)]
            local smokeType = Config.AllSmokeTypes[math.random(#Config.AllSmokeTypes)]
            smokeList[#smokeList + 1] = ERS_AddCalloutSmoke(vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z-0.5), smokeType, smokeSize)
        elseif UsingSmartFiresLite then
            local smokeSize = Config.RandomLargeFireOrSmokeSize[math.random(#Config.RandomLargeFireOrSmokeSize)]
            smokeList[#smokeList + 1] = ERS_AddCalloutSmoke(vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z-0.5), "normal", smokeSize)
        end

        return true
    end
}