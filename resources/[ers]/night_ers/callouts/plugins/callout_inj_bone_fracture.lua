Config.Callouts["inj_bone_fracture"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Bone fracture with severe loss off blood",
    CalloutDescriptions = {
        "Asistir a un paciente con una fractura osea grave; Se necesita atencion medica urgente para controlar la lesion.",
        "Llamada de emergencia: individuo con un hueso fracturado; enviar equipo medico para apoyo inmediato.",
        "Situacion critica: la persona ha sufrido una fractura osea; Se requiere una respuesta rapida para mitigar el dolor y estabilizarlo.",
        "Alerta: se reporta fractura osea significativa; enviar personal medico para brindar atencion urgente.",
        "La persona con una fractura osea necesita ayuda; Asegurar una rapida intervencion medica para tratar la lesion.",
        "Se necesita ayuda inmediata en caso de un incidente de fractura osea; priorizar la atencion al paciente y el manejo del dolor.",
        "Responder a una llamada por una fractura de hueso; Proporcionar asistencia medica y apoyo esenciales a la persona lesionada.",
        "Respuesta de emergencia: fractura osea grave; desplegar unidades medicas para manejar la situacion de manera efectiva.",
        "Se requiere atencion medica urgente por una fractura de hueso; centrarse en estabilizar y tratar al paciente.",
        "Incidente critico que involucra una fractura osea; Se necesita una pronta respuesta medica para ayudar al individuo afectado.",
    },             
    CalloutUnitsRequired = {
        description = "Ambulance.",
        policeRequired = false,
        ambulanceRequired = true,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(792.9553, -240.9984, 66.1143),
        [2] = vector3(842.8905, -260.9836, 67.9002),
        [3] = vector3(1757.4556, 3327.4480, 41.3261),
        [4] = vector3(1852.7067, 3849.6326, 33.0655),
        [5] = vector3(1428.0652, 3667.6677, 39.7284),
        [6] = vector3(585.1674, 2726.8047, 42.0601),
        [7] = vector3(205.2145, 2441.6804, 59.2908),
        [8] = vector3(826.9429, 1868.5367, 120.0712),
        [9] = vector3(1417.9462, 1154.7434, 114.6737),
        [10] = vector3(481.1850, 53.5993, 94.1020),
        [11] = vector3(327.7636, -195.2430, 54.2264),
        [12] = vector3(236.0775, -874.6152, 30.4921),
        [13] = vector3(773.8135, -295.2217, 59.9715),
        [14] = vector3(-320.6177, -1532.3145, 27.5748),
        [15] = vector3(227.9964, -2978.5430, 7.4518),
        [16] = vector3(782.0969, -3192.1824, 5.9008),
        [17] = vector3(453.3673, -3081.0610, 6.0701),
        [18] = vector3(949.4739, -3087.8894, 5.9008),
        [19] = vector3(1536.4180, -2115.9968, 76.8700),
        [20] = vector3(2597.9036, -268.9229, 92.8858),
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
                ERS_SetMovementAnimClipSetToPed(ped, "move_m@injured")
                ERS_RequestNetControlForEntity(ped)
                ERS_ApplyBloodToPed(ped)

                local scenario = ERS_SelectRandomWoundedPersonScenario()
                TaskStartScenarioInPlace(ped, scenario, 0, true)
            end

            Citizen.SetTimeout(math.random(20000), function() 
                if DoesEntityExist(ped) then
                    if not IsPedDeadOrDying(ped, true) then
                        ERS_RequestNetControlForEntity(ped) 
                        ERS_SetPedToPassout(ped)
                    end
                end
            end)
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        --ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        local pedModel = ERS_GetRandomModel(Config.randomPeds)
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        table.insert(pedList, pedNetId)

        return true
    end
}