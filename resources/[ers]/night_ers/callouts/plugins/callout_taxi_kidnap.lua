Config.Callouts["taxi_kidnap"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Taxi driver has kidnapped a person",
    CalloutDescriptions = {
        "Emergencia: responder a denuncias de taxista secuestrando a una persona; garantizar medidas de seguridad inmediatas y detener al sospechoso.",
        "Alerta urgente: enviar unidades al lugar del reporte del secuestro del taxista; evitar que el sospechoso escape y garantizar la seguridad de la victima.",
        "Se requiere respuesta critica: atender denuncias de persona secuestrada por taxista; coordinar con las autoridades para detener al perpetrador.",
        "Aviso: consultar reportes de taxista involucrado en secuestro; tomar medidas inmediatas para asegurar el area y rescatar a la victima.",
        "Alerta: responder con prontitud a las denuncias de secuestro de un taxista; priorizar la seguridad de la victima y detener al sospechoso.",
        "Incidente reportado: investigan a taxista acusado de secuestro; Trabajar con las autoridades para resolver la situacion de forma segura.",
        "Accion inmediata: atender denuncias de secuestro de taxista; implementar protocolos para garantizar la seguridad de la victima y detener al sospechoso.",
        "Alerta de situacion: ayudar a gestionar el secuestro de un taxista denunciado; asegurar el area y brindar el apoyo necesario a las fuerzas del orden.",
        "Respuesta a emergencias: atender denuncias de taxista involucrado en secuestro; Siga los procedimientos para rescatar a la victima y detener al sospechoso de manera segura.",
        "Se necesita respuesta: investigar con urgencia las denuncias de secuestro de un taxista; tomar las acciones apropiadas para rescatar a la victima y garantizar la seguridad publica.",
    },                                                                   
    CalloutUnitsRequired = {
        description = "Police.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(1332.1410, 3583.2266, 34.8965),
        [2] = vector3(-697.0299, 5776.0215, 17.3310),
        [3] = vector3(-206.0954, 6540.2759, 11.0971),
        [4] = vector3(454.1506, 6624.8638, 23.0635),
        [5] = vector3(1607.6415, 6481.7622, 21.8166),
        [6] = vector3(1755.2949, 6392.8755, 36.5205),
        [7] = vector3(2435.6018, 5135.6597, 46.8859),
        [8] = vector3(2008.6410, 4633.4839, 41.1880),
        [9] = vector3(2341.9792, 3785.3757, 37.2855),
        [10] = vector3(2100.4690, 3326.6724, 45.1793),
        [11] = vector3(1970.9108, 3079.3357, 46.9376),
        [12] = vector3(1575.0837, 1307.2762, 92.1799),
        [13] = vector3(1104.1776, 589.7816, 102.4962),
        [14] = vector3(717.8885, 195.3734, 87.8088),
        [15] = vector3(89.7476, 164.2194, 104.5954),
        [16] = vector3(-1016.2654, -173.1175, 37.7538),
        [17] = vector3(-1085.8276, -907.6064, 3.5490),
        [18] = vector3(-1105.2926, -1374.6267, 5.2202),
        [19] = vector3(-649.9991, -1202.9358, 11.4201),
        [20] = vector3(-362.4801, -1791.1382, 22.9878),
    },               
    PedChanceToFleeFromPlayer = 0,      -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 0,        -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 0,           -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 0,       -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 0,    -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 1000, -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "none",  -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_unarmed"
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
                if index == 1 then
                    ERS_SetPedToFleeFromPlayer(ped)
                else
                    TaskSetBlockingOfNonTemporaryEvents(ped, true)
                end
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000)
        ERS_CreateTemporaryBlipForEntities(vehicleList, 15000)
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        -- Build vehicle
        local vehModel = "taxi"
        local vehType = "automobile"
        local vehCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local vehHeading = math.random(360)
        local vehNetId = ERS_CreateVehicle(vehModel, vehType, vehCoords, vehHeading)
        local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
        table.insert(vehicleList, vehNetId)

        -- Build driver / passenger
        local seatIndex = -1
        local backSeatIndex = 1 -- or 2
        for i = 1, 2 do
            local pedModel = ERS_GetRandomModel(Config.randomPeds)
            local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z + 2.0)
            local pedHeading = math.random(360)
            local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
            local ped = NetworkGetEntityFromNetworkId(pedNetId)
            table.insert(pedList, pedNetId)
            if i == 1 then
                SetPedIntoVehicle(ped, vehicle, seatIndex)
            else
                SetPedIntoVehicle(ped, vehicle, backSeatIndex)
            end
        end
    
        return true
    end
}