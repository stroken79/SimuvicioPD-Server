Config.Callouts["climate_protest"] = {
    
    Enabled = true,
    Priority = 1,
    CalloutName = "Climate change protest",
    CalloutDescriptions = {
        "Se ha informado de una protesta por el cambio climatico que requiere una respuesta policial inmediata.",
        "Se necesita asistencia de emergencia para gestionar y abordar una protesta por el cambio climatico.",
        "Los informes indican una protesta por el cambio climatico, que requiere una intervencion policial urgente.",
        "Se ha informado de una protesta por el cambio climatico y se necesita apoyo para mantener el orden y garantizar la seguridad.",
        "Se ha solicitado a los servicios de emergencia que atiendan una protesta por el cambio climatico.",
        "Los agentes que respondieron a una protesta por el cambio climatico hicieron una solicitud de asistencia.",
        "Se requieren unidades adicionales para apoyar a los oficiales que gestionan una protesta por el cambio climatico.",
        "Se requiere respaldo de emergencia para ayudar a los oficiales a manejar una protesta por el cambio climatico.",
        "Los agentes que se ocupan de una protesta por el cambio climatico han emitido un llamado de ayuda.",
        "Los informes sugieren una situacion en la que la asistencia policial inmediata es crucial para gestionar y abordar una protesta por el cambio climatico.",
    },                                     
    CalloutUnitsRequired = {
        description = "Police.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(197.27, -935.14, 30.69),         -- Legion Square
        [2] = vector3(-921.31, -724.34, 19.91),        -- Park Downtown
        [3] = vector3(292.90, 179.39, 104.24),         -- Vinewood Commerce Street
        [4] = vector3(885.13, -43.29, 78.76),          -- Casino Parkinglot
        [5] = vector3(1867.51, 2586.37, 45.67),        -- Bolingbroke PI
        [6] = vector3(1718.59, 3766.62, 34.26),        -- Sandy City Hall
        [7] = vector3(-278.57, 6054.73, 31.5152),      -- Paleto Parkinglot
        [8] = vector3(-617.1911, -539.0128, 25.1484),  -- Del Perro Fwy
    },                                         
    PedChanceToFleeFromPlayer = 10,     -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 25,       -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 10,          -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 25,      -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 1000, -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 5000, -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "none",  -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_poolcue",
        "weapon_golfclub",
        "weapon_crowbar",
        "weapon_bat",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)
        
        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                local scenario = ERS_SelectRandomProtesterScenario()
                TaskStartScenarioInPlace(ped, scenario, 0, true)
            end
        end

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)

    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        -- Build protesters
        local suspects = math.random(20)
        local diameter = 25
        for i = 1, suspects do
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
            local pedModel = ERS_GetRandomModel(Config.randomPeds)
            local pedCoords = vector3(coords.x, coords.y, coords.z)
            local pedHeading = math.random(360)
            local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
            local ped = NetworkGetEntityFromNetworkId(pedNetId)
            table.insert(pedList, pedNetId)
        end
    
        return true
    end
}