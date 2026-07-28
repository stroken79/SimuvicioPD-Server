Config.Callouts["valet_theft"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Valet stole vehicle",
    CalloutDescriptions = {
        "Responder inmediatamente a un informe de un valet robando un vehiculo; Asegure el area y localice el auto robado.",
        "Alerta de emergencia: robo de vehiculo por parte de un valet; desplegar unidades para localizar y recuperar el vehiculo robado.",
        "Se necesita una respuesta urgente: un aparcacoches se ha marchado con el coche de un cliente; Asegurese de que el vehiculo sea recuperado y el sospechoso detenido.",
        "Situacion critica: robo de un vehiculo por parte de un valet; actuar con rapidez para localizar el coche y controlar la escena.",
        "Alerta: valet robo un vehiculo; Se necesita intervencion inmediata para recuperar el vehiculo y mantener la seguridad.",
        "Incidente de robo de vehiculo: valet involucrado; Se requieren medidas urgentes para asegurar la zona y recuperar el coche robado.",
        "Manejar una situacion en la que un valet roba un vehiculo; priorizar la recuperacion y la coordinacion con las autoridades.",
        "Situacion de emergencia: vehiculo robado por el valet; asegurese de que el area sea segura y ayude a recuperar el vehiculo robado.",
        "Alerta urgente: vehiculo robado por valet; Responda rapidamente para gestionar la escena y recuperar el coche.",
        "Se necesita una respuesta critica: el valet robo un vehiculo; Asegure el area, recupere el automovil y detenga al sospechoso.",
    },           
    CalloutUnitsRequired = {
        description = "Police.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(-690.5018, -2291.0522, 13.0379),
        [2] = vector3(-568.6872, -449.3962, 33.9551),
        [3] = vector3(-669.8828, -221.6496, 37.1944),
        [4] = vector3(-884.0535, -346.2314, 34.5298),
        [5] = vector3(-1036.0609, -474.1400, 36.8752),
        [6] = vector3(-1363.8979, -711.5773, 24.6793),
        [7] = vector3(-1332.7385, -1034.8738, 7.5625),
        [8] = vector3(-1591.2513, -898.1854, 9.5285),
        [9] = vector3(-1734.3279, -721.0918, 10.3650),
        [10] = vector3(-1865.0079, -353.5096, 49.0548),
        [11] = vector3(-949.8361, -1278.8688, 5.0537),
        [12] = vector3(-852.7844, -1212.0709, 6.1981),
        [13] = vector3(-695.9883, -1109.3223, 14.5092),
        [14] = vector3(253.6740, -1641.1349, 29.1255),
        [15] = vector3(309.0320, -1096.0039, 29.2574),
        [16] = vector3(382.4882, -751.6982, 29.2883),
        [17] = vector3(-36.3656, 201.6859, 101.9738),
        [18] = vector3(-137.4618, 205.8481, 92.1274),
        [19] = vector3(-418.0433, 1209.1710, 325.6375),
        [20] = vector3(213.3478, 1225.9126, 225.4462),
    },                      
    PedChanceToFleeFromPlayer = 100,    -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 0,        -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 50,          -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 0,       -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 10000, -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 15000, -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "flee",  -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_unarmed",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)
        for index, vehNetId in pairs(vehicleList) do
            local veh = NetToVeh(vehNetId)
            if DoesEntityExist(veh) then
                ERS_RequestNetControlForEntity(veh)
            end
        end
        
        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped)
                ERS_SetPedToFleeFromPlayer(ped)
            end
        end

        ERS_CreateTemporaryBlipForEntities(vehicleList, 30000)
        ERS_CreateTemporaryBlipForEntities(pedList, 30000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        local vehModel = ERS_GetRandomModel(Config.randomLuxuryVehicles)
        local vehType = "automobile"
        local vehCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local vehHeading = math.random(360)
        local vehNetId = ERS_CreateVehicle(vehModel, vehType, vehCoords, vehHeading)
        local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
        table.insert(vehicleList, vehNetId)

        -- Build valet
        local pedModel = "s_m_y_valet_01"
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z+1.5)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        SetPedIntoVehicle(ped, vehicle, -1)
        table.insert(pedList, pedNetId)

        return true
    end
}