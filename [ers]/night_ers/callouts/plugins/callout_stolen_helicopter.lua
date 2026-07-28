Config.Callouts["stolen_helicopter"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Reports of theft of a helicopter",
    CalloutDescriptions = {
        "Emergencia: responder inmediatamente a informes de robo de helicoptero; asegurar el espacio aereo y evitar despegues no autorizados.",
        "Alerta urgente: enviar unidades al lugar del robo del helicoptero denunciado; coordinar con las autoridades de aviacion para rastrear y recuperar la aeronave.",
        "Respuesta critica: atender denuncia de helicoptero robado; priorizar la seguridad de los pasajeros y el personal de tierra al detener al sospechoso.",
        "Accion inmediata: investigar informes sobre el robo de un helicoptero; asegurar el aeropuerto y garantizar que la aeronave permanezca en tierra.",
        "Alerta: responder con prontitud a un incidente de robo de helicoptero; tomar las medidas necesarias para interceptar la aeronave antes de que abandone la zona.",
        "Incidente reportado: manejar una situacion que involucra un helicoptero robado; Trabajar con el control del trafico aereo para monitorear y gestionar la amenaza.",
        "Alerta de situacion: ayudar a rastrear un helicoptero robado; garantizar la seguridad de todas las personas involucradas y recuperar la aeronave.",
        "Respuesta de emergencia: abordar un incidente de robo de helicoptero; Siga los protocolos de seguridad de la aviacion para evitar que el helicoptero despegue.",
        "Intervencion inmediata: responder a denuncias de robo de helicoptero; priorizar la inmovilizacion de la aeronave y la captura del sospechoso.",
        "Se necesita respuesta: investigar urgentemente las denuncias sobre un helicoptero robado; tomar las acciones apropiadas para recuperar la aeronave y garantizar la seguridad del espacio aereo.",
    },                                                                                           
    CalloutUnitsRequired = {
        description = "Police.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(-1044.4764, -2992.8120, 13.9476), -- Make sure there is enough space for the helicopter to take off.
        [2] = vector3(1746.6627, 3240.6746, 41.7872),
        [3] = vector3(1627.9459, 3254.4121, 41.0430),
        [4] = vector3(-1582.3992, -569.0988, 116.3279),
        [5] = vector3(-913.2054, -378.4743, 137.9057),
        [6] = vector3(-752.0067, -1471.4247, 4.9620),
        [7] = vector3(313.4475, -1464.9767, 46.5095),
        [8] = vector3(478.4208, -3369.8223, 6.0699),
        [9] = vector3(-1606.8187, -3103.1138, 13.9442),
        [10] = vector3(-1188.5243, -3342.3813, 13.9440),
        [11] = vector3(-1094.5204, -2889.7732, 13.9446),
        [12] = vector3(-1204.9742, -2844.7400, 13.9449),
        [13] = vector3(-1181.7083, -2627.5745, 13.9449),
        [14] = vector3(-1197.5691, -2394.7705, 13.9449),
        [15] = vector3(-1268.3094, -2132.3171, 13.9407),
    },                      
    PedChanceToFleeFromPlayer = 100,    -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 0,        -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 0,           -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 0,       -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 10000,-- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 15000,-- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "flee",  -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_unarmed",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)

    
        local heli
        for index, vehNetId in pairs(vehicleList) do
            local veh = NetToVeh(vehNetId)
            if DoesEntityExist(veh) then
                ERS_RequestNetControlForEntity(veh)
                SetVehicleEngineOn(veh, true, true, false)
                --SetHeliBladesSpeed(veh, 0.5)
                heli = veh
            end
        end
        
        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                TaskSetBlockingOfNonTemporaryEvents(ped, true)
                
                if index == 1 then -- Pilot
                    ERS_ClearPedTasksAndBlockEvents(ped)

                    while not IsPedInAnyHeli(ped) do
                        ERS_RequestNetControlForEntity(ped) 
                        ERS_RequestNetControlForEntity(heli) 
                        SetPedIntoVehicle(ped, heli, -1)
                        Wait(500)
                    end

                    local destinationX, destinationY, destinationZ = 2170.03, 3783.03, 33.09 -- Random, this case Sandy shores.
                    TaskHeliMission(ped, heli, 0, 0, destinationX, destinationY, destinationZ, 4, 1.0, -1.0, -1.0, 10, 10, 5.0, 0);
                    
                else -- Passengers
                    TaskSetBlockingOfNonTemporaryEvents(ped, true)
                end
            end
        end

        ERS_CreateTemporaryBlipForEntities(vehicleList, 60000)
        ERS_CreateTemporaryBlipForEntities(pedList, 60000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)

    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        -- Build helicopter
        local vehModel = ERS_GetRandomModel(Config.randomHelicopters)
        local vehType = "heli"
        local vehCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local vehHeading = math.random(360)
        local vehNetId = ERS_CreateVehicle(vehModel, vehType, vehCoords, vehHeading)
        local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
        table.insert(vehicleList, vehNetId)

        -- Build pilot & passengers
        local seatIndex = -1
        local randomAmountOfPassengers = math.random(4)
        for i = 1, randomAmountOfPassengers do
            local pedModel = ERS_GetRandomModel(Config.randomPeds)
            local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y + math.random(5)+.0, calloutData.Coordinates.z)
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