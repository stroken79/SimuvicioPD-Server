Config.Callouts["aircraft_hard_landing"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Potential hard landing (Aircraft)",
    CalloutDescriptions = {
        "Se requiere que los servicios de emergencia mitiguen las consecuencias de un posible accidente aereo.",
        "Las autoridades informan de una aeronave en peligro y exigen una intervencion inmediata para garantizar la seguridad.",
        "Se informo de una emergencia de la aeronave que requiere medidas urgentes para minimizar danos mayores.",
        "Situacion critica con una aeronave en problemas; Se necesitan unidades adicionales para apoyo.",
        "Se necesita una respuesta inmediata para abordar una aeronave que enfrenta un peligro inminente.",
        "Una aeronave esta en peligro y representa una grave amenaza; Se necesitan refuerzos para evitar el desastre.",
        "Los equipos de emergencia solicitan apoyo para ayudar a gestionar una emergencia de aeronave y evitar que empeore.",
        "Se ha emitido una llamada urgente de ayuda para gestionar una emergencia aerea y garantizar la seguridad.",
        "Los socorristas se encuentran en el lugar de una emergencia aerea y necesitan apoyo adicional para estabilizar la situacion.",
        "Una emergencia grave que afecte a una aeronave exige una accion rapida para evitar un resultado catastrofico.",
    },           
    CalloutUnitsRequired = {
        description = "Police, Ambulance, Fire.",
        policeRequired = true,
        ambulanceRequired = true,
        fireRequired = true,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(776.0710, -2065.0103, 29.3829), 
        -- [2] = vector3(2278.6301, 2969.2185, 46.5811), 
        -- [3] = vector3(2840.2234, 1553.8225, 24.5741), 
        -- [4] = vector3(2821.8545, 1511.8513, 24.7242), 
        -- [5] = vector3(2458.3921, 1457.0712, 36.2040), 
        -- [6] = vector3(1127.5670, -2489.8242, 33.3611), 
        -- [7] = vector3(233.3477, 6399.8403, 31.6335), 
        -- [8] = vector3(1346.0159, 6383.4556, 33.4101), 
        -- [9] = vector3(2050.1416, 3683.3496, 34.5879), 
        -- [10] = vector3(683.1802, 120.5065, 80.7545), 

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


        local aircraft

        for index, vehNetId in pairs(vehicleList) do
            local veh = NetToVeh(vehNetId)
            if DoesEntityExist(veh) then
                ERS_RequestNetControlForEntity(veh)
                aircraft = veh
                SetVehicleEngineOn(aircraft, true, true, false)
            end
        end
        
        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 

                if index == 1 then
                    ERS_ApplyBloodToPed(ped)

                    -- Specify the destination coordinates
                    local destinationX = calloutDataClient.Coordinates.x
                    local destinationY = calloutDataClient.Coordinates.y
                    local destinationZ = calloutDataClient.Coordinates.z
                    
                    -- Set other parameters for the plane mission
                    local missionFlag = 17 -- This can vary based on your requirements
                    local angularDrag = 0.0 -- Adjust as needed
                    local unk = 0 -- Unknown parameter, usually set to 0
                    local targetHeading = 0.0 -- Heading angle to face when reaching the destination
                    local maxZ = 250.0 -- Maximum altitude
                    local minZ = 0.0 -- Minimum altitude

                    TaskPlaneMission(ped, aircraft, 0, 0, destinationX, destinationY, destinationZ, missionFlag, angularDrag, unk, targetHeading, maxZ, minZ)
                else
                    ERS_ApplyBloodToPed(ped)

                    local chance = math.random(100)
                    if chance > 50 then
                        TaskLeaveAnyVehicle(ped)
                        TaskSetBlockingOfNonTemporaryEvents(ped, true)
                    else
                        TaskSetBlockingOfNonTemporaryEvents(ped, true)
                    end
                end
            end
        end

        ERS_CreateTemporaryBlipForEntities(vehicleList, 15000)
        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        -- Build vehicle
        local vehModel = ERS_GetRandomModel(Config.randomPlanes)
        local vehType = "plane"
        local vehCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z+150)
        local vehHeading = math.random(360)
        local vehNetId = ERS_CreateVehicle(vehModel, vehType, vehCoords, vehHeading)
        local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
        table.insert(vehicleList, vehNetId)

        -- Build pilot
        local pedModel = "s_m_m_pilot_01"
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z+150)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        SetPedIntoVehicle(ped, vehicle, -1)
        table.insert(pedList, pedNetId)

        -- Build passengers
        for seatIndex = 0, 5 do -- seats planes
            if GetPedInVehicleSeat(vehicle, seatIndex) == 0 then
                local passengerPedModel = ERS_GetRandomModel(Config.randomPeds)
                local passengerPedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z+150)
                local passengerPedHeading = math.random(360)
                local passengerPedNetId = ERS_CreatePed(passengerPedModel, passengerPedCoords, passengerPedHeading)
                local passengerPed = NetworkGetEntityFromNetworkId(pedNetId)
                SetPedIntoVehicle(passengerPed, vehicle, seatIndex)
                table.insert(pedList, passengerPedNetId)
            end
        end

        return true
    end
}