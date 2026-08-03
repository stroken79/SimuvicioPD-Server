Config.Callouts["fire_dumpster"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Garbage bin on fire",
    CalloutDescriptions = {
        "Un contenedor de basura se incendio y requirio atencion inmediata de los bomberos.",
        "Se necesitan servicios de emergencia para extinguir un incendio en un contenedor de basura.",
        "Los informes indican que un contenedor de basura esta en llamas, lo que requiere una intervencion urgente de los bomberos.",
        "Se ha identificado un incendio en un contenedor de basura y se necesita personal de bomberos adicional para contenerlo y extinguirlo.",
        "Se ha solicitado a los servicios de emergencia que respondan al incendio de un contenedor de basura.",
        "Las autoridades que se ocupan del incendio de un contenedor de basura han solicitado asistencia.",
        "Se requieren unidades adicionales para apoyar al personal de bomberos en la gestion de un incendio en un contenedor de basura.",
        "Se requiere respaldo de emergencia para ayudar a las autoridades de bomberos a manejar un incendio en un contenedor de basura.",
        "Los socorristas que se enfrentan a un incendio en un contenedor de basura han emitido un llamado de ayuda.",
        "Los informes sugieren una situacion en la que la intervencion inmediata de los bomberos es crucial para gestionar y abordar un incendio en un contenedor de basura.",
    },                    
    CalloutUnitsRequired = {
        description = "Fire",
        policeRequired = false,
        ambulanceRequired = false,
        fireRequired = true,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(2454.83, 4054.92, 38.95),            
        [2] = vector3(1975.17, 3787.58, 32.97),           
        [3] = vector3(1926.45, 3745.37, 33.41),           
        [4] = vector3(1899.79, 3780.52, 33.30),         
        [5] = vector3(1825.76, 3746.67, 34.08),         
        [6] = vector3(1626.28, 3801.31, 35.26),           
        [7] = vector3(1558.18, 3805.05, 35.13),            
        [8] = vector3(1288.35, 3621.54, 33.74),            
        [9] = vector3(1401.00, 3632.42, 35.83),
        [10] = vector3(1432.34, 3621.90, 35.70),
        [11] = vector3(1700.85, 3696.76, 35.17),
        [12] = vector3(1685.64, 4805.29, 42.50),
        [13] = vector3(-72.80, 6505.27, 33.04),
        [14] = vector3(-5.64, 6480.96, 32.36),
        [15] = vector3(32.90, 6545.49, 32.29),
        [16] = vector3(179.28, 6444.78, 32.15),
        [17] = vector3(-54.29, 6284.64, 32.23),
        [18] = vector3(-127.22, 6230.84, 32.26),
        [19] = vector3(-202.53, 6243.81, 32.35),
        [20] = vector3(-349.31, 6242.84, 32.10),
        [21] = vector3(-434.26, 6162.51, 32.18),
        [22] = vector3(71.04, -209.51, 55.35),
        [23] = vector3(-18.18, -195.51, 53.23),
        [24] = vector3(-600.36, -981.30, 23.24),
        [25] = vector3(-624.94, -1789.60, 24.77),  
        [26] = vector3(-352.35, -1552.93, 25.95),
        [27] = vector3(-140.25, -1361.66, 30.23),
        [28] = vector3(2.35, -1350.34, 30.25),
        [29] = vector3(105.51, -1316.19, 30.15),
        [30] = vector3(120.27, -1541.17, 30.29),
        [31] = vector3(139.94, -1578.74, 30.19),
        [32] = vector3(155.78, -1655.72, 30.68),
        [33] = vector3(197.40, -1759.03, 30.11),
        [34] = vector3(130.42, -1887.35, 24.40),
        [35] = vector3(248.93, -1963.99, 23.27),
        [36] = vector3(267.02, -2056.23, 19.07),  
        [37] = vector3(287.49, -2091.68, 18.21),
        [38] = vector3(480.20, -1959.01, 25.64),
        [39] = vector3(454.12, -1908.81, 25.79),  
        [40] = vector3(467.88, -1586.12, 30.72),  
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

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                TaskSetBlockingOfNonTemporaryEvents(ped, true)
                Wait(100)
                TaskTurnPedToFaceCoord(ped, calloutDataClient.Coordinates.x, calloutDataClient.Coordinates.y, calloutDataClient.Coordinates.z, -1)
                Wait(2000)
                local scenario = ERS_SelectStandingByFireScenario()
                TaskStartScenarioInPlace(ped, scenario, 0, true)
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        local diameter = 6

        if UsingSmartFiresV2 or UsingSmartFires then
            local fireSize = Config.RandomSmallFireOrSmokeSize[math.random(#Config.RandomSmallFireOrSmokeSize)]
            local fireType = Config.NormalFireTypes[math.random(#Config.NormalFireTypes)]
            fireList[#fireList + 1] = ERS_AddCalloutFire(vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z-0.5), fireType, fireSize)
        elseif UsingSmartFiresLite then
            -- SmartFiresLite only supports "normal" as the fire type. The full
            -- version exposes the Config.*FireTypes presets used above.
            local fireSize = Config.RandomSmallFireOrSmokeSize[math.random(#Config.RandomSmallFireOrSmokeSize)]
            fireList[#fireList + 1] = ERS_AddCalloutFire(vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z-0.5), "normal", fireSize)
        end

        -- Build bystander(s)
        local randomAmountOfBystanders = math.random(3)
        for i = 1, randomAmountOfBystanders do
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