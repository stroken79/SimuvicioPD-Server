Config.Callouts["tunnel_smoke"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Smoke in a tunnel",
    CalloutDescriptions = {
        "Se requiere que los servicios de emergencia investiguen la fuente del humo en el tunel.",
        "Las autoridades reportan humo en un tunel y exigen una investigacion inmediata para garantizar la seguridad.",
        "Se ha informado de humo en un tunel, lo que requiere medidas urgentes para identificar y abordar la causa.",
        "Situacion critica con humo en un tunel; Se necesitan unidades adicionales para apoyo.",
        "Se necesita una respuesta inmediata para abordar el humo en un tunel que representa un peligro potencial.",
        "Se ha detectado humo en un tunel, lo que supone una posible amenaza; Se necesitan refuerzos para investigar y contener cualquier peligro.",
        "Los equipos de emergencia solicitan refuerzos para ayudar en la investigacion y gestion del humo en un tunel.",
        "Se ha emitido un llamado urgente de ayuda para controlar el humo en un tunel y garantizar la seguridad.",
        "Los socorristas se encuentran en el lugar del humo en un tunel y necesitan apoyo adicional para estabilizar la situacion.",
        "Una emergencia grave relacionada con el humo en un tunel exige una accion rapida para evitar un posible resultado catastrofico.",
    },                        
    CalloutUnitsRequired = {
        description = "Police, Fire.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = true,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(2155.49, 5998.66, 51.29),
        [2] = vector3(2264.53, 5901.12, 49.06),
        [3] = vector3(2355.03, 5793.62, 46.35),
        [4] = vector3(-2598.79, 3052.06, 15.96),
        [5] = vector3(-2578.00, 3294.84, 13.38),
        [6] = vector3(-1511.02, -766.17, 11.29),
        [7] = vector3(-1196.56, -688.77, 11.07),
        [8] = vector3(189.47, -595.13, 29.62),
        [9] = vector3(271.97, -1857.47, 18.60),
        [10] = vector3(-586.55, -581.31, 25.30),
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
            smokeList[#smokeList + 1] = ERS_AddCalloutSmoke(vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z-0.5), Config.FoggySmoke, smokeSize)
        elseif UsingSmartFiresLite then
            local smokeSize = Config.RandomLargeFireOrSmokeSize[math.random(#Config.RandomLargeFireOrSmokeSize)]
            smokeList[#smokeList + 1] = ERS_AddCalloutSmoke(vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z-0.5), "normal", smokeSize)
        end

        return true
    end
}