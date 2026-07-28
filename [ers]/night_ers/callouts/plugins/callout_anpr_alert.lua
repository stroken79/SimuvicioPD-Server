Config.Callouts["anpr_alert"] = {
    
    Enabled = true,
    Priority = 1,
    CalloutName = "ANPR Alert",
    CalloutDescriptions = {
        "Se informo una alerta de la ANPR que requiere una respuesta policial inmediata.",
        "Se necesita asistencia de emergencia para gestionar y abordar una alerta ANPR.",
        "Los informes indican una alerta de la ANPR, que requiere una intervencion policial urgente.",
        "Se ha informado una alerta ANPR y se necesitan refuerzos para mantener el orden y garantizar la seguridad.",
        "Se ha solicitado a los servicios de emergencia que atiendan una alerta ANPR.",
        "Los agentes que respondieron a una alerta de la ANPR realizaron una solicitud de asistencia.",
        "Se requieren unidades adicionales para apoyar a los oficiales que gestionan una alerta ANPR.",
        "Se requiere respaldo de emergencia para ayudar a los oficiales a manejar una alerta ANPR.",
        "Los agentes que se ocupan de una alerta ANPR han emitido una llamada de asistencia.",
        "Los informes sugieren una situacion en la que la asistencia policial inmediata es crucial para gestionar y abordar una alerta ANPR.",
    },                         
    CalloutUnitsRequired = {
        description = "Police.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(252.45, -991.78, 29.15),
        [2] = vector3(442.52, -544.01, 28.28),
        [3] = vector3(676.55, -219.48, 44.30),
        [4] = vector3(365.68, -108.07, 66.25),
        [5] = vector3(-817.47, -126.34, 37.52),
        [6] = vector3(-309.89, -15.74, 48.35),
        [7] = vector3(-2354.87, -285.41, 14.13),
        [8] = vector3(-1000.02, -602.68, 18.39),
        [9] = vector3(199.27, 6574.46, 31.80),
        [10] = vector3(1391.85, 6500.05, 19.76),
        [11] = vector3(1723.97, 6387.80, 34.03),
        [12] = vector3(2553.27, 5194.82, 50.78),
        [13] = vector3(-136.89, 6224.72, 31.34),
        [14] = vector3(2600.13, 5119.80, 44.78),
        [15] = vector3(2446.42, 4009.14, 37.06),
        [16] = vector3(1831.28, 3258.06, 44.10),
        [17] = vector3(1977.05, 3081.72, 47.07),
        [18] = vector3(2558.44, 2702.69, 41.77),
        [19] = vector3(2854.36, 2819.08, 53.09),
        [20] = vector3(254.91, 2848.28, 43.59),
        [21] = vector3(85.82, 3595.74, 39.75),
        [22] = vector3(-821.40, 5761.81, 5.54),
        [23] = vector3(-300.05, 6057.30, 31.35),
        [24] = vector3(1244.97, -383.18, 69.11),
        [25] = vector3(-862.40, -656.93, 27.53),
        [26] = vector3(-866.07, -939.28, 15.85),
        [27] = vector3(-188.73, -891.99, 29.34),
        [28] = vector3(-707.01, -1611.40, 22.79),
        [29] = vector3(738.92, -2466.61, 20.22),
        [30] = vector3(1240.60, -2054.46, 44.35),
        [31] = vector3(1969.42, -921.52, 79.16),
        [32] = vector3(2454.87, 977.85, 86.22),
        [33] = vector3(2207.62, 2999.60, 45.54),
        [34] = vector3(1696.63, 3510.35, 36.47),
        [35] = vector3(226.92, 2973.63, 42.71),
        [36] = vector3(-1254.90, 2537.62, 18.12),
        [37] = vector3(-1785.69, 4736.50, 57.01),
        [38] = vector3(-303.03, 6231.18, 31.45),
        [39] = vector3(-54.87, 6311.50, 31.33),
        [40] = vector3(1940.65, 6254.72, 43.52),
    },                                                     
    PedChanceToFleeFromPlayer = 75,     -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 25,       -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 10,          -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 25,      -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 10000, -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 30000, -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "flee",  -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_poolcue",
        "weapon_golfclub",
        "weapon_crowbar",
        "weapon_bat",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)
        
        local vehicle

        for index, vehNetId in pairs(vehicleList) do
            local veh = NetToVeh(vehNetId)
            if DoesEntityExist(veh) then
                vehicle = veh
                ERS_RequestNetControlForEntity(vehicle) 
            else
                if Config.Debug then
                    print("Could not find vehicle entity.")
                end
            end
            Wait(500)
        end

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                TaskSetBlockingOfNonTemporaryEvents(ped, true)
                if not IsPedInAnyVehicle(ped, true) then
                    TaskEnterVehicle(ped, vehicle, 5000, -1, 2.0, 1, 0)
                    Wait(2000)
                    ERS_SetPedToFleeFromPlayer(ped)
                else
                    ERS_SetPedToFleeFromPlayer(ped)
                end
            end
        end

        ERS_CreateTemporaryBlipForEntities(vehicleList, 15000)
        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)

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

        -- Build ped
        local pedModel = ERS_GetRandomModel(Config.randomPeds)
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z + 3.0)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        SetPedIntoVehicle(ped, vehicle, -1)
        table.insert(pedList, pedNetId)

        return true
    end
}