Config.Callouts["emergency_heli_land"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Emergency Landing (Helicopter)",
    CalloutDescriptions = {
        "Responder inmediatamente a un informe de un helicoptero realizando un aterrizaje de emergencia; asegurar el area y ayudar a la tripulacion.",
        "Alerta de emergencia: helicoptero realizando un aterrizaje de emergencia; desplegar unidades para gestionar la situacion y garantizar la seguridad.",
        "Se requiere respuesta urgente: helicoptero en peligro; centrarse en asegurar la zona de aterrizaje y proporcionar ayuda a la tripulacion.",
        "Situacion critica: aterrizaje de emergencia de helicoptero; actuar rapidamente para ayudar a la tripulacion y controlar la escena.",
        "Alerta: informe de un helicoptero realizando un aterrizaje de emergencia; Se necesita intervencion inmediata para garantizar la seguridad y proporcionar ayuda.",
        "Incidente de helicoptero: se requieren acciones urgentes para asegurar la zona y ayudar a la tripulacion y a los pasajeros.",
        "Manejar una emergencia que involucre el aterrizaje de un helicoptero; priorizar la seguridad y coordinar con los equipos de rescate.",
        "Situacion de emergencia: helicoptero realizando un aterrizaje de emergencia; garantizar que el area sea segura y brindar la asistencia necesaria.",
        "Alerta urgente: helicoptero en peligro; Responder rapidamente para gestionar el aterrizaje y ayudar a la tripulacion.",
        "Se necesita una respuesta critica: aterrizaje de emergencia de helicopteros; asegurar el area, ayudar a la tripulacion y garantizar la seguridad de todos los involucrados.",
    },             
    CalloutUnitsRequired = {
        description = "Police, Ambulance.",
        policeRequired = true,
        ambulanceRequired = true,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(-1429.2676, -1289.7368, 4.3511),
        [2] = vector3(-1653.2723, -870.3990, 9.0263),
        [3] = vector3(-1455.4275, -1152.7502, 2.4831),
        [4] = vector3(-747.0457, -1485.9590, 5.0007),
        [5] = vector3(-454.8493, -1426.9784, 29.3621),
        [6] = vector3(25.1825, -1721.3936, 29.2899),
        [7] = vector3(325.5524, -1511.4641, 29.3379),
        [8] = vector3(225.6287, -1045.0038, 29.3698),
        [9] = vector3(125.6850, -514.5389, 43.1679),
        [10] = vector3(361.6500, 140.9549, 103.0987),
        [11] = vector3(1453.7101, 1106.9681, 114.3338),
        [12] = vector3(1314.7112, 1861.2794, 90.4019),
        [13] = vector3(-75.2154, 1854.2852, 199.9619),
        [14] = vector3(-600.4490, 2159.9644, 131.3303),
        [15] = vector3(-1343.5653, 2450.3135, 26.8504),
        [16] = vector3(-2514.7119, 3724.3655, 13.2465),
        [17] = vector3(-1593.7363, 4768.4336, 50.9807),
        [18] = vector3(-759.7006, 5534.2915, 33.4762),
        [19] = vector3(-291.4177, 6123.8335, 31.5306),
        [20] = vector3(-231.0190, 6260.1074, 31.4410),
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


        local heli
        for index, vehNetId in pairs(vehicleList) do
            local veh = NetToVeh(vehNetId)
            if DoesEntityExist(veh) then
                ERS_RequestNetControlForEntity(veh)
                ERS_SetRandomDamageToVehicle(veh)
                SetVehicleEngineOn(veh, true, true, false)
                SetHeliBladesSpeed(veh, 0.5)
                heli = veh
            end
        end
        
        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                TaskSetBlockingOfNonTemporaryEvents(ped, true)
                
                if index == 1 then -- Pilot
                    local pos = GetEntityCoords(heli, false)
                    local foundGround, groundZ = GetGroundZFor_3dCoord(pos.x, pos.y, pos.z, false)
                    
                    if foundGround then
                        local destinationX = pos.x
                        local destinationY = pos.y
                        local destinationZ = groundZ
                        local missionFlag = 4
                        local maxSpeed = 20.0
                        local landingRadius = 10.0
                        local targetHeading = 0.0
                        local unk1 = -1.0
                        local unk2 = -1.0
                        local unk3 = 5.0
                        local landingFlags = 32

                        ERS_ClearPedTasksAndBlockEvents(ped)

                        while not IsPedInAnyHeli(ped) do
                            ERS_RequestNetControlForEntity(ped) 
                            ERS_RequestNetControlForEntity(heli) 
                            SetPedIntoVehicle(ped, heli, -1)
                            Wait(500)
                        end

                        TaskHeliMission(ped, heli, 0, 0, destinationX, destinationY, destinationZ, missionFlag, maxSpeed, landingRadius, targetHeading, unk1, unk2, unk3, landingFlags)
                    end
                else -- Passengers
                    local chance = math.random(100)
                    if chance > 50 then
                        -- Ped is injured
                        ERS_ApplyBloodToPed(ped)
                        SetEntityHealth(ped, 0)
                    end
                end
            end
        end

        ERS_CreateTemporaryBlipForEntities(vehicleList, 15000)
        ERS_CreateTemporaryBlipForEntities(pedList, 15000)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)


        local diameter = 20

        -- Build vehicle
        local vehModel = ERS_GetRandomModel(Config.randomHelicopters)
        local vehType = "heli"
        local vehCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z+150.0)
        local vehHeading = math.random(360)
        local vehNetId = ERS_CreateVehicle(vehModel, vehType, vehCoords, vehHeading)
        local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
        table.insert(vehicleList, vehNetId)

        -- Build pilot & passengers
        local seatIndex = -1
        local randomAmountOfPassengers = math.random(4)
        for i = 1, randomAmountOfPassengers do
            local pedModel = ERS_GetRandomModel(Config.randomPeds)
            if i == 1 then
                pedModel = "s_m_m_pilot_01"
            end
            local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z+3.0)
            local pedHeading = math.random(360)
            local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
            local ped = NetworkGetEntityFromNetworkId(pedNetId)
            SetPedIntoVehicle(ped, vehicle, seatIndex)
            seatIndex = seatIndex + 1
            table.insert(pedList, pedNetId)
        end
    
        return true
    end
}