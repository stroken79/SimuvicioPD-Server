Config.Callouts["overheated_transformer"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Overheated transformer station",
    CalloutDescriptions = {
        "Una estacion transformadora esta experimentando un sobrecalentamiento critico y necesita accion inmediata para evitar un incendio.",
        "Se requieren equipos de emergencia para enfriar una estacion transformadora sobrecalentada para evitar interrupciones en el suministro electrico.",
        "Las autoridades informan de una situacion urgente de sobrecalentamiento de una estacion transformadora y exigen una pronta intervencion.",
        "Una estacion transformadora tiene temperaturas peligrosamente altas; Se necesitan unidades adicionales para controlar el riesgo.",
        "Se necesita una respuesta inmediata para abordar una estacion transformadora sobrecalentada y mitigar los peligros potenciales.",
        "Una estacion transformadora sobrecalentada representa una amenaza importante y requiere refuerzos para estabilizar la situacion.",
        "Detectado sobrecalentamiento critico en una estacion transformadora; Los equipos de emergencia deben actuar rapidamente para evitar una escalada.",
        "Una alerta urgente de asistencia debido al sobrecalentamiento de una estacion transformadora que corre el riesgo de sufrir cortes de energia importantes.",
        "Los socorristas estan luchando contra una estacion transformadora sobrecalentada y necesitan apoyo adicional para garantizar la seguridad.",
        "Un grave problema de sobrecalentamiento en una estacion transformadora requiere una accion rapida para proteger la infraestructura y las vidas cercanas.",
    },                                               
    CalloutUnitsRequired = {
        description = "Police, Fire.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = true,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(2094.0078, 2325.3831, 94.2853), 
        [2] = vector3(2278.6301, 2969.2185, 46.5811), 
        [3] = vector3(2840.2234, 1553.8225, 24.5741), 
        [4] = vector3(2821.8545, 1511.8513, 24.7242), 
        [5] = vector3(2458.3921, 1457.0712, 36.2040), 
        [6] = vector3(1127.5670, -2489.8242, 33.3611), 
        [7] = vector3(233.3477, 6399.8403, 31.6335), 
        [8] = vector3(1346.0159, 6383.4556, 33.4101), 
        [9] = vector3(2050.1416, 3683.3496, 34.5879), 
        [10] = vector3(683.1802, 120.5065, 80.7545), 
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

        local diameter = 15
        local randomAmountOfFires = math.random(2,6)
        for i = 1, randomAmountOfFires do
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
            -- Build fires
            if UsingSmartFiresV2 or UsingSmartFires then
                local fireSize = Config.RandomHugeFireOrSmokeSize[math.random(#Config.RandomHugeFireOrSmokeSize)]
                fireList[#fireList + 1] = ERS_AddCalloutFire(vector3(coords.x, coords.y, coords.z-0.5), Config.ElectricalFire, fireSize)
            elseif UsingSmartFiresLite then
                local fireSize = Config.RandomHugeFireOrSmokeSize[math.random(#Config.RandomHugeFireOrSmokeSize)]
                fireList[#fireList + 1] = ERS_AddCalloutFire(vector3(coords.x, coords.y, coords.z-0.5), "normal", fireSize)
            end
        end

        return true
    end
}