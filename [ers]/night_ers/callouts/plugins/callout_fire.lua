Config.Callouts["fire"] = {
        Enabled = true,
        Priority = 1,
        CalloutName = "Reports of a fire",
        CalloutDescriptions = {
            "Se ha informado de un incendio que requiere atencion inmediata de los servicios de bomberos.",
            "Se necesitan servicios de emergencia para extinguir un incendio reportado.",
            "Los informes indican que se ha producido un incendio que requiere una intervencion urgente de los bomberos.",
            "Se ha identificado un incendio y se necesita personal de bomberos adicional para su contencion y extincion.",
            "Se ha solicitado a los servicios de emergencia que respondan a un incendio.",
            "Las autoridades que se ocupan del incendio han solicitado ayuda.",
            "Se requieren unidades adicionales para apoyar al personal de bomberos en la gestion de un incendio reportado.",
            "Se requiere respaldo de emergencia para ayudar a las autoridades de bomberos a manejar un incendio.",
            "Los socorristas que se ocupan de un incendio han emitido una llamada de ayuda.",
            "Los informes sugieren una situacion en la que la intervencion inmediata de los bomberos es crucial para gestionar y abordar un incendio.",
        },                           
        CalloutUnitsRequired = {
            description = "Fire",
            policeRequired = false,
            ambulanceRequired = false,
            fireRequired = true,
            towRequired = false,
        },
        CalloutLocations = {
            [1] = vector3(510.78, -970.06, 27.54),
            [2] = vector3(857.04, -946.39, 26.54),
            [3] = vector3(1124.11, -798.91, 57.63),
            [4] = vector3(1317.05, -1671.16, 51.24),
            [5] = vector3(1452.03, -1935.34, 72.47),
            [6] = vector3(1372.55, -2086.71, 53.11),
            [7] = vector3(822.35, -2974.13, 6.02),
            [8] = vector3(1104.56, -3249.35, 7.02),
            [9] = vector3(761.42, -3219.93, 7.34),
            [10] = vector3(445.66, -3037.47, 7.50),
            [11] = vector3(493.50, -2828.83, 2.77),
            [12] = vector3(150.72, -2650.57, 6.41),
            [13] = vector3(-390.61, -2188.21, 9.98),
            [14] = vector3(-674.53, -2460.26, 13.94),
            [15] = vector3(-1177.89, -2902.84, 15.95),
            [16] = vector3(-1122.50, -2830.59, 32.86),
            [17] = vector3(-1239.08, -2737.25, 14.36),
            [18] = vector3(-1146.44, -2326.89, 13.98),
            [19] = vector3(-1067.93, -2374.29, 20.52),
            [20] = vector3(-1077.42, -2074.45, 13.29),
            [21] = vector3(-14.69, -1436.00, 31.12),
            [22] = vector3(-269.54, -2103.16, 27.90),
            [23] = vector3(-13.95, -2167.43, 12.05),
            [24] = vector3(435.17, -655.06, 28.74),
            [25] = vector3(445.07, -564.27, 29.09),
            [26] = vector3(22.63, -391.70, 39.65),
            [27] = vector3(117.23, -353.09, 42.61),
            [28] = vector3(131.32, 71.40, 80.11),
            [29] = vector3(-152.12, 294.39, 98.82),
            [30] = vector3(-702.57, 89.93, 55.86),            
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
        
        if UsingSmartFiresV2 or UsingSmartFires then
            local fireSize = Config.RandomMediumFireOrSmokeSize[math.random(#Config.RandomMediumFireOrSmokeSize)]
            local fireType = Config.NormalFireTypes[math.random(#Config.NormalFireTypes)]
            fireList[#fireList + 1] = ERS_AddCalloutFire(vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z-0.5), fireType, fireSize)
        elseif UsingSmartFiresLite then
            local fireSize = Config.RandomSmallFireOrSmokeSize[math.random(#Config.RandomSmallFireOrSmokeSize)]
            fireList[#fireList + 1] = ERS_AddCalloutFire(vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z-0.5), "normal", fireSize)
        end

        return true
    end
}