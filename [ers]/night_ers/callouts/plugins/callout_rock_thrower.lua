Config.Callouts["rock_thrower"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Reports of a rockthrower at a highway bridge",
    CalloutDescriptions = {
        "Investigar reportes de una persona arrojando piedras en la carretera; asegurar el area y garantizar la seguridad.",
        "Alerta: enviar unidades para responder a informes de un lanzador de piedras en la carretera; prevenir posibles accidentes.",
        "Unidades requeridas: responder a reportes de persona arrojando piedras en la carretera y tomar las acciones necesarias.",
        "Aviso: consultar reportes de un lanzador de piedras en la carretera; implementar medidas de seguridad para proteger a los automovilistas.",
        "Alerta: responda con prontitud a los informes de un lanzador de piedras en la carretera; priorizar la seguridad y prevenir danos.",
        "Incidente reportado: consultar reportes de una persona arrojando piedras en la carretera para evitar accidentes.",
        "Investigar informes de un lanzador de piedras en la carretera; coordinar con las autoridades pertinentes para abordar la situacion.",
        "Alerta de situacion: atender reportes de persona arrojando piedras en la via; asegurese de que el area este despejada.",
        "Alerta: atienda los informes de un lanzador de piedras en la carretera y siga los protocolos para garantizar la seguridad de todos.",
        "Se necesita respuesta: investigar los informes de una persona que arroja piedras en la carretera y tomar las medidas adecuadas para evitar danos.",
    },
    CalloutUnitsRequired = {
        description = "Police",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(1090.6511, -1724.6661, 35.6686),
        [2] = vector3(149.6323, -499.0016, 43.3375),
        [3] = vector3(304.4368, -518.3337, 43.2498),
        [4] = vector3(-82.0214, -537.6570, 40.1383),
        [5] = vector3(-223.2275, -505.3830, 34.7831),
        [6] = vector3(-652.4840, -506.2829, 34.7621),
        [7] = vector3(-914.4279, -557.6136, 33.8698),
        [8] = vector3(-2985.9165, 416.2830, 24.6855),
        [9] = vector3(-3078.3875, 767.0917, 31.3687),
        [10] = vector3(2671.0034, 4822.2881, 44.5706),
    },               
    PedChanceToFleeFromPlayer = 50,       -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 0,          -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 20,            -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 50,        -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 5000,   -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 10000,  -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "flee",    -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_crowbar",
        "weapon_bottle",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)

        for index, objNetId in pairs(objectList) do
            local obj = NetToObj(objNetId)
            if DoesEntityExist(obj) then
                ERS_RequestNetControlForEntity(obj) 
                PlaceObjectOnGroundProperly(obj)
            end
        end

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                local pos = GetEntityCoords(ped)
                local randomChance = math.random(100)
                if randomChance < 50 then
                    ERS_SetPedAsDrunkPed(ped) 
                end
                TaskTurnPedToFaceEntity(ped, plyPed, 5000)
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 30000)
        ERS_CreateTemporaryBlipForEntities(objectList, 30000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        local diameter = 20

        local pedModel = ERS_GetRandomModel(Config.randomPeds)
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        table.insert(pedList, pedNetId)

        local randomAmountOfObjects = math.random(5)
        for i = 1, randomAmountOfObjects do
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
            local objModel = ERS_GetRandomModel(Config.randomRockObjects)
            local objCoords = vector3(coords.x, coords.y, coords.z)
            local objHeading = math.random(360)
            local objNetId = ERS_CreateObject(objModel, objCoords, objHeading)
            if objNetId then    
                local obj = NetworkGetEntityFromNetworkId(objNetId)
                table.insert(objectList, objNetId)
            else
                DebugPrint("^1ERROR ^7Could not create object: "..objModel)
            end
        end
    
        return true
    end
}