Config.Callouts["moneytruck_raid"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Active raid on money truck",
    CalloutDescriptions = {
        "Responder a una redada activa en un camion de dinero; Se requieren acciones inmediatas para neutralizar a los sospechosos y asegurar los fondos.",
        "Se necesita respuesta de emergencia para una redada en curso contra un camion de dinero; desplegar unidades para intervenir y proteger la valiosa carga.",
        "Llamado urgente para responder a allanamiento activo a camion de dinero; movilizar recursos para frustrar a los perpetradores y salvaguardar los fondos.",
        "Camion de dinero bajo ataque; responder rapidamente para prevenir el robo de activos valiosos y garantizar la seguridad publica.",
        "Alerta de incidente: asalto a un camion de dinero; desplegar unidades especializadas para contrarrestar la amenaza y asegurar los fondos.",
        "Se requiere respuesta de emergencia para una redada activa en un camion de dinero; priorizar la proteccion de los bienes y la captura de los agresores.",
        "Responder a la redada en curso contra un camion de dinero; acelerar los esfuerzos para neutralizar la amenaza y salvaguardar la valiosa carga.",
        "Camion de dinero bajo asedio; activar protocolos de emergencia y coordinar con unidades para reprimir el allanamiento y proteger los fondos.",
        "Se necesita una respuesta inmediata para una redada activa en un camion de dinero; priorizar la seguridad de los civiles y la seguridad de los activos.",
        "Aviso urgente: asalto a un camion de dinero; responder con prontitud para neutralizar la amenaza y garantizar la integridad de la operacion.",
    },
    CalloutUnitsRequired = {
        description = "Police.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(204.0068, 197.2750, 105.5652),
        [2] = vector3(1288.0315, 3541.9167, 35.1836),
        [3] = vector3(2314.9722, 3859.9841, 34.8134),
        [4] = vector3(353.8910, -520.1240, 34.1515),
        [5] = vector3(736.7793, -1174.7837, 44.8672),
        [6] = vector3(-268.7205, -1124.7623, 23.0979),
        [7] = vector3(29.2399, -273.9065, 47.7049),
        [8] = vector3(24.6531, 258.0385, 109.5969),
        [9] = vector3(-1621.2246, -272.0746, 52.8909),
        [10] = vector3(-1768.3605, 63.5210, 68.3115),
        [11] = vector3(236.9416, 6563.9238, 31.0833),
        [12] = vector3(123.5326, 6604.4155, 31.4928),
        [13] = vector3(-122.8901, 6455.9414, 31.4685),
        [14] = vector3(-2706.8562, 2302.3909, 18.0392),
        [15] = vector3(-2048.6133, 1928.3405, 187.5260),
        [16] = vector3(217.2915, 3131.1104, 42.3544),
        [17] = vector3(1599.0537, 3669.8826, 34.5075),
        [18] = vector3(790.1103, 156.8885, 81.2086),
        [19] = vector3(29.8005, -770.7616, 44.2360),
        [20] = vector3(-640.6522, -655.5369, 31.7352),
    },                      
    PedChanceToFleeFromPlayer = 0,      -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 0,        -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 0,           -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 100,     -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 5000, -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 10000,-- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "none",  -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_pistol",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)


        local moneyTruckPedsList = {}
        local moneyTruck
        local suspectPedList = {}
        local suspectVehicle
        local plyGroupHash = GetPedRelationshipGroupHash(plyPed)
        local retval, suspectGroupHash = AddRelationshipGroup("SUSPECT_GROUP_HASH")

        SetRelationshipBetweenGroups(5, suspectGroupHash, plyGroupHash)
        SetRelationshipBetweenGroups(4, plyGroupHash, suspectGroupHash)

        for index, vehNetId in pairs(vehicleList) do
            local veh = NetToVeh(vehNetId)
            if DoesEntityExist(veh) then
                ERS_RequestNetControlForEntity(veh)

                local vehModel = GetEntityModel(veh)
                if vehModel == GetHashKey("stockade") then
                    moneyTruck = veh
                else
                    suspectVehicle = veh
                end
            end
        end
        
        -- Set ped into teams
        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                if IsPedInVehicle(ped, moneyTruck, true) then
                    SetPedRelationshipGroupHash(ped, plyGroupHash)
                    SetEntityCanBeDamagedByRelationshipGroup(ped, false, plyGroupHash)
                    table.insert(moneyTruckPedsList, PedToNet(ped))
                else
                    SetPedRelationshipGroupHash(ped, suspectGroupHash)
                    SetEntityCanBeDamagedByRelationshipGroup(ped, false, suspectGroupHash)
                    table.insert(suspectPedList, PedToNet(ped))
                end
            end
        end

        for index, pedNetId in pairs(moneyTruckPedsList) do
            
            local driverEntity = GetPedInVehicleSeat(moneyTruck, -1)
            local ped = NetToPed(pedNetId)
            ERS_RequestNetControlForEntity(ped) 
            if ped == driverEntity then
                ERS_RequestNetControlForEntity(moneyTruck) 
                SetVehicleDoorsLocked(moneyTruck, 4) -- Lock peds inside.
                ERS_RequestNetControlForEntity(ped) 
                local suspectPed = NetToPed(suspectPedList[1])
                TaskReactAndFleePed(ped, suspectPed)
            else
                TaskSetBlockingOfNonTemporaryEvents(ped, true)
            end
        end

        for index, pedNetId in pairs(suspectPedList) do
            local driverEntity = GetPedInVehicleSeat(suspectVehicle, -1)
            local ped = NetToPed(pedNetId)
            ERS_RequestNetControlForEntity(ped) 
            if ped == driverEntity then
                ERS_RequestNetControlForEntity(ped) 
                TaskSetBlockingOfNonTemporaryEvents(ped, true)
                Wait(50)
                TaskVehicleEscort(ped, suspectVehicle, moneyTruck, -1, 50.0, 1082917029, 7.5, 0, -1)
                SetPedKeepTask(ped, true)
            else
                TaskSetBlockingOfNonTemporaryEvents(ped, true)

                SetCanPedEquipAllWeapons(ped, true)
                --SetPedCanSwitchWeapon(ped, true)
                SetPedCombatAttributes(ped, 2, true)  -- Can shoot from vehicle
                SetPedCombatAttributes(ped, 54, true)  -- Always equip best weapon.

                ERS_SpawnConfiguredWeaponForPed(ped, calloutDataClient)

                Citizen.SetTimeout(5000, function() 
                    if DoesEntityExist(ped) then
                        if not IsPedDeadOrDying(ped, true) then
                            ERS_RequestNetControlForEntity(ped) 
                            -- Make the ped shoot at the target entity indefinitely
                            local targetPed = NetToPed(moneyTruckPedsList[math.random(#moneyTruckPedsList)])
                            TaskCombatPed(ped, targetPed, 0, 16)
                            SetPedKeepTask(ped, true)
                            --TaskShootAtEntity(ped, targetPed, -1, GetHashKey("FIRING_PATTERN_FULL_AUTO"))
                            -- print("tasking to shoot for ped "..ped)
                        end
                    end
                end)
                
            end
        end

        ERS_CreateTemporaryBlipForEntities(moneyTruckPedsList, 15000)

        --ERS_PerformTimedActionOnPed(calloutDataClient, suspectPedList)

    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        local diameter = 25
        
        -- Build vehicle
        local vehModel = "stockade"
        local vehType = "automobile"
        local vehCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local vehHeading = math.random(360)
        local vehNetId = ERS_CreateVehicle(vehModel, vehType, vehCoords, vehHeading)
        local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
        table.insert(vehicleList, vehNetId)

        -- Build stockade drivers
        local seatIndex = -1
        for i = 1, 2 do
            local pedModel = ERS_GetRandomModel(Config.randomMoneyTransportPeds)
            local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z + 2.0)
            local pedHeading = math.random(360)
            local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
            local ped = NetworkGetEntityFromNetworkId(pedNetId)
            SetPedIntoVehicle(ped, vehicle, seatIndex)
            seatIndex = seatIndex + 1
            table.insert(pedList, pedNetId)
        end

        -- Build suspect vehicle
        local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
        local suspectVehModel = ERS_GetRandomModel(Config.randomFourDoorVehiclesSpecific)
        local suspectVehType = "automobile"
        local suspectVehCoords = vector3(coords.x, coords.y, coords.z)
        local suspectVehHeading = math.random(360)
        local suspectVehNetId = ERS_CreateVehicle(suspectVehModel, suspectVehType, suspectVehCoords, suspectVehHeading)
        local suspectVehicle = NetworkGetEntityFromNetworkId(suspectVehNetId)
        table.insert(vehicleList, suspectVehNetId)

        -- Build suspect peds
        local randomAmountOfSuspects = math.random(3,4)
        seatIndex = -1
        for i = 1, randomAmountOfSuspects do
            local pedModel = ERS_GetRandomModel(Config.randomPeds)
            local pedCoords = vector3(coords.x, coords.y, coords.z+2.0)
            local pedHeading = math.random(360)
            local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
            local ped = NetworkGetEntityFromNetworkId(pedNetId)
            SetPedIntoVehicle(ped, suspectVehicle, seatIndex)
            seatIndex = seatIndex + 1
            table.insert(pedList, pedNetId)
        end

        return true
    end
}