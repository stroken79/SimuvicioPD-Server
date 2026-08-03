Config.Callouts["abandoned_vehicle"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Abandoned vehicle",
    CalloutDescriptions = {
        "Investigar un vehiculo abandonado en una zona desierta; Verifique si hay ocupantes angustiados o articulos sospechosos.",
        "Alerta: coche abandonado encontrado cerca de una obra en construccion; asegurese de que no obstruya ninguna operacion ni represente un peligro.",
        "Unidades requeridas: automovil descubierto con las puertas abiertas y sin nadie alrededor; Examine la escena en busca de signos de juego sucio.",
        "Aviso: vehiculo estacionado en un lugar inusual durante un periodo prolongado; verificar que no sea un auto robado o abandonado.",
        "Alerta: reporte de vehiculo abandonado en zona escolar; determinar si representa algun peligro para los ninos y el personal.",
        "Incidente reportado: vehiculo encontrado con el motor en marcha pero sin conductor a la vista; asegurese de que sea seguro e investigue.",
        "Responder a una situacion que involucra un automovil abandonado en las vias del tren; Coordinar con las autoridades de transporte para prevenir accidentes.",
        "Alerta de situacion: vehiculo descubierto con senales de advertencia de materiales peligrosos; priorizar la seguridad y coordinar con los equipos de materiales peligrosos.",
        "Alerta: coche abandonado en zona propensa a inundaciones; evaluar el riesgo de que sea arrastrado y cause danos.",
        "Se necesita respuesta: vehiculo sospechoso encontrado cerca de una instalacion de alta seguridad; compruebe si hay posibles amenazas o violaciones de seguridad.",
    },
    CalloutUnitsRequired = {
        description = "Tow",
        policeRequired = false,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = true,
    },
    CalloutLocations = {
        [1] = vector3(482.5813, -902.2799, 35.9722),
        [2] = vector3(-498.6677, 6267.7412, 11.3615),
        [3] = vector3(-742.7029, 5812.6357, 17.4803),
        [4] = vector3(-767.0907, 5543.6484, 33.4922),
        [5] = vector3(-916.5244, 5250.4307, 83.9764),
        [6] = vector3(-525.5445, 4948.1494, 147.3998),
        [7] = vector3(151.7183, 4416.7876, 75.6445),
        [8] = vector3(1466.3269, 4531.2056, 52.0130),
        [9] = vector3(1504.0210, 3749.1111, 34.0672),
        [10] = vector3(1547.0118, 3635.0022, 34.4262),
        [11] = vector3(1986.4946, 3661.6140, 33.5053),
        [12] = vector3(2458.8081, 3812.0923, 40.1474),
        [13] = vector3(2672.1116, 3534.7649, 51.9782),
        [14] = vector3(2568.6899, 2890.6724, 39.7117),
        [15] = vector3(1522.8920, 787.9393, 77.4461),
        [16] = vector3(1123.0111, 258.1617, 80.8556),
        [17] = vector3(1019.5189, -698.3103, 56.8416),
        [18] = vector3(1167.9501, -1548.5294, 34.6922),
        [19] = vector3(1112.2905, -2524.5283, 32.4943),
        [20] = vector3(599.6377, -2757.5508, 6.0598),
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

        for index, vehNetId in pairs(vehicleList) do
            local veh = NetToVeh(vehNetId)
            if DoesEntityExist(veh) then
                ERS_RequestNetControlForEntity(veh) 
                ERS_SetRandomDamageToVehicle(veh)
                
                for i = 0, 7 do -- Tire indices range from 0 to 7
                    if math.random(100) < 75 then
                        SetVehicleTyreBurst(veh, i, true, 1000.0)
                    end
                end
        
                local numDoors = GetNumberOfVehicleDoors(veh)
                for i = 0, numDoors - 1 do
                    if math.random(100) < 50 then
                        SetVehicleDoorOpen(veh, i, false, false)
                    end
                end

                local randomDirtLevel = math.random(0, 15)
                SetVehicleDirtLevel(veh, randomDirtLevel+.0)
            end
        end

        ERS_CreateTemporaryBlipForEntities(vehicleList, 15000)
   
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        -- Build vehicle
        local vehModel = ERS_GetRandomModel(Config.randomVehicles)
        local vehType = "automobile"
        local vehCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local vehHeading = math.random(360)
        local vehNetId = ERS_CreateVehicle(vehModel, vehType, vehCoords, vehHeading)
        local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
        table.insert(vehicleList, vehNetId)
   
        return true
    end
}