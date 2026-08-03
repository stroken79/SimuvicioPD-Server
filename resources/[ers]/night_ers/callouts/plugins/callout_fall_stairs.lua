Config.Callouts["fall_stairs"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Person fell off a staircase/ladder",
    CalloutDescriptions = {
        "Responder a una emergencia que involucre a una persona que se haya caido de una escalera; Se requiere asistencia medica inmediata.",
        "Se necesita respuesta de emergencia para un incidente en el que una persona se cae de una escalera; enviar unidades para brindar ayuda.",
        "Llamada urgente para auxiliar a una persona que se ha caido de una escalera; movilizar recursos medicos al lugar.",
        "Persona lesionada tras caerse de una escalera; responder rapidamente para proporcionar la atencion medica necesaria y garantizar la seguridad.",
        "Alerta de incidente: persona caida de una escalera; desplegar unidades medicas para evaluar y tratar las lesiones.",
        "Se requiere respuesta de emergencia para una persona que se ha caido de una escalera; priorizar la intervencion medica inmediata.",
        "Responder al incidente de una persona que se cae de una escalera; acelerar los esfuerzos para brindar atencion y apoyo medicos.",
        "Persona caida de una escalera; activar protocolos de emergencia y coordinar con unidades para entregar ayuda oportuna.",
        "Se necesita una respuesta inmediata para una persona que se ha caido de una escalera; priorizar su seguridad y tratamiento medico.",
        "Llamado urgente: persona herida tras caer de una escalera; responder con prontitud para brindar asistencia medica y garantizar el bienestar.",
    },        
    CalloutUnitsRequired = {
        description = "Ambulance.",
        policeRequired = false,
        ambulanceRequired = true,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(351.4657, 271.0494, 103.0172),
        [2] = vector3(-652.7864, -766.0150, 25.5297),
        [3] = vector3(-474.7756, -910.9007, 29.4782),
        [4] = vector3(-920.7066, -1298.7263, 5.1850),
        [5] = vector3(-1170.1167, -1102.2087, 3.8880),
        [6] = vector3(-1298.2869, -1045.9518, 12.4772),
        [7] = vector3(-1125.2135, -451.0492, 35.8138),
        [8] = vector3(-1119.3269, -439.5915, 36.2330),
        [9] = vector3(-355.6841, -149.6584, 38.2469),
        [10] = vector3(-209.2857, -237.3621, 60.8542),
        [11] = vector3(338.8574, -1092.9243, 29.4042),
        [12] = vector3(327.6939, -1012.8282, 29.2898),
        [13] = vector3(318.7952, -622.8632, 29.2940),
        [14] = vector3(723.5764, -707.2311, 26.7198),
        [15] = vector3(216.0993, 115.9391, 106.0705),
        [16] = vector3(51.7044, 147.6956, 98.0485),
        [17] = vector3(-588.4545, -200.9341, 37.8006),
        [18] = vector3(563.5626, -2202.3018, 10.2138),
        [19] = vector3(727.1979, -2151.6619, 28.4359),
        [20] = vector3(983.2426, -1669.0815, 41.1710),
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

                local chanceToSurvive = math.random(0, 1)     
                if chanceToSurvive > 0 then
                    Citizen.Wait(2500)
                    local scenario = ERS_SelectRandomWoundedPersonScenario()
                    TaskStartScenarioInPlace(ped, scenario, 0, true)
                else
                    SetEntityHealth(ped, 0)
                end
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        local pedModel = ERS_GetRandomModel(Config.randomPeds)
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z + 10.0)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        table.insert(pedList, pedNetId)

        return true
    end
}