Config.Callouts["wildfire"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Wildfire",
    CalloutDescriptions = {
        "Se ha producido un gran incendio forestal que requiere atencion inmediata por parte de los servicios de bomberos.",
        "Se necesitan equipos de emergencia para combatir un incendio forestal que se propaga rapidamente en la zona.",
        "Las autoridades informan de un incendio forestal que amenaza hogares y vida silvestre, lo que requiere una accion urgente.",
        "Se ha detectado un incendio de gran magnitud y se necesitan unidades de extincion adicionales para contenerlo.",
        "Se requiere respuesta inmediata a un incendio forestal que pone en peligro un vecindario residencial.",
        "Se ha informado de un incendio forestal y se necesitan refuerzos para ayudar a los servicios de bomberos locales.",
        "Los equipos de bomberos solicitan apoyo para controlar un grave incendio forestal en una region densamente boscosa.",
        "Se ha hecho un llamamiento urgente de asistencia para hacer frente a un incendio forestal que se esta extendiendo hacia zonas pobladas.",
        "Los socorristas se encuentran en la escena de un incendio forestal y necesitan apoyo adicional para evitar danos mayores.",
        "Una situacion importante de incendio forestal exige una intervencion inmediata para proteger vidas y propiedades.",
    },                    
    CalloutUnitsRequired = {
        description = "Fire.",
        policeRequired = false,
        ambulanceRequired = false,
        fireRequired = true,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(1649.18, -1300.25, 85.43),
        [2] = vector3(1841.42, -1568.56, 126.55),
        [3] = vector3(2719.96, 512.47, 92.76),
        [4] = vector3(2659.38, 1258.56, 29.26),
        [5] = vector3(2629.16, 2683.31, 56.89),
        [6] = vector3(997.11, 6347.87, 38.72),
        [7] = vector3(78.02, 6822.26, 17.92),
        [8] = vector3(-566.53, 5847.58, 31.20),
        [9] = vector3(-852.40, 5574.69, 27.42),
        [10] = vector3(-534.42, 5483.81, 66.69),
        [11] = vector3(-2744.51, 2175.46, 25.07),
        [12] = vector3(-2023.58, -217.21, 29.74),
        [13] = vector3(2030.26, 3371.11, 45.18),
        [14] = vector3(1524.29, 4464.20, 49.12),
        [15] = vector3(496.92, 5583.54, 793.80),
        [16] = vector3(-1159.60, 62.91, 56.31),
        [17] = vector3(-1658.64, 2642.03, 2.95),            
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

        -- No other actions required clientside, add if you desire
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        if UsingSmartFiresV2 or UsingSmartFires then
            local fireSize = Config.RandomLargeFireOrSmokeSize[math.random(#Config.RandomLargeFireOrSmokeSize)]
            fireList[#fireList + 1] = ERS_AddCalloutFire(vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z-0.5), Config.BonFire, fireSize)
        elseif UsingSmartFiresLite then
            local fireSize = Config.RandomHugeFireOrSmokeSize[math.random(#Config.RandomHugeFireOrSmokeSize)]
            fireList[#fireList + 1] = ERS_AddCalloutFire(vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z-0.5), "normal", fireSize)
        end

        return true
    end
}