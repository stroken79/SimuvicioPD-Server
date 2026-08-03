Config.Callouts["shop_robbery"] = {
    Enabled = true,
    Priority = 1,
    CalloutName = "Shop Robbery",
    CalloutDescriptions = {
        "Los informes indican que se esta produciendo un atrevido robo en una tienda local. Los sospechosos posiblemente armados se acercan con precaucion.",
        "Los servicios de emergencia han sido alertados de un descarado robo en una tienda cercana. Se solicitan unidades adicionales.",
        "El dueno de una tienda ha informado de que se esta produciendo un robo violento. Evalue la escena en busca de peligros potenciales.",
        "Los testigos informan de un robo en una tienda y los sospechosos huyeron del lugar. Priorizar la respuesta ante la aprehension.",
        "Se ha activado una alarma en la tienda, lo que indica un posible robo en curso. Se requiere una investigacion inmediata.",
        "Una persona angustiada que llama informa de un presunto secuestro tras un robo en su tienda. Coordinar los esfuerzos de busqueda de inmediato.",
        "Los informes sugieren que se esta produciendo un robo relacionado con drogas en una tienda local. Evalue los riesgos potenciales antes de participar.",
        "Un comerciante ha resultado herido durante un intento de robo. Acerquese al lugar con precaucion y priorice la asistencia medica.",
        "Los testigos informan de un atropello y fuga tras un robo en una tienda. Los sospechosos pueden estar armados y ser peligrosos. Acercate con extrema precaucion.",
        "Los informes indican actividad fraudulenta en una tienda. Coordinar con las autoridades para la investigacion y aprehension de sospechosos.",
    },               
    CalloutUnitsRequired = {
        description = "Police.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(1734.71, 6420.61, 35.04),      -- Mount Chilliad, Senora Fwy
        [2] = vector3(1959.34, 3748.75, 32.34),      -- Sandy Shores, Niland Ave
        [3] = vector3(1168.99, 2717.88, 37.16),      -- Grand Senora Desert, Route 68
        [4] = vector3(614.70, 2764.62, 42.09),       -- Suburban, Harmony, Route 68
        [5] = vector3(378.13, 333.19, 103.57),       -- Downtown Vinewood, Clinton Ave
        [6] = vector3(-165.61, -304.13, 39.73),      -- Burton, Las Lagunas Blvd
        [7] = vector3(-1171.97, -1571.98, 4.66),     -- Vespucci Beach, Goma St
        [8] = vector3(-3047.61, 585.73, 7.91),       -- Banham Canyon, Ineseno Road
        [9] = vector3(2555.99, 386.47, 108.62),      -- Palomino Fwy
        [10] = vector3(-828.11, -1073.62, 11.33),    -- South Rockford Dr.
    },        
    PedChanceToFleeFromPlayer = 50,     -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 50,       -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 25,          -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 25,      -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 10000,-- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 15000,-- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "flee",  -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_knife",
        "weapon_bat",
        "weapon_hammer",
        "weapon_wrench",
        "weapon_pistol",
    },
    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)
        local shopkeeperPed = nil
        local robberPedsList = {}

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 

                local foundShopkeeperPed = false
                for k, v in pairs(Config.shopKeeperPeds) do
                    if GetEntityModel(ped) == GetHashKey(v) then 
                        shopkeeperPed = ped
                        foundShopkeeperPed = true
                        if Config.Debug then
                            print("Shopkeeper ped: "..ped)
                        end
                        break
                    end
                end
                if not foundShopkeeperPed then
                    table.insert(robberPedsList, pedNetId)
                    if Config.Debug then
                        print("Robber ped: "..ped)
                    end
                end
            end
        end

        local chance = math.random(100)
        if chance >= 50 then
            -- Shocked shopkeeper
            ClearPedTasks(shopkeeperPed)
            TaskSetBlockingOfNonTemporaryEvents(shopkeeperPed, true)

            Wait(100)

            TaskHandsUp(shopkeeperPed, -1, plyPed, -1, true)
            SetPedKeepTask(shopkeeperPed, true) 

            if Config.Debug then
                print("Shopkeeper is tasked to put their hands up.")
            end
        else
            -- Rogue shopkeeper
            ClearPedTasks(shopkeeperPed)
            TaskSetBlockingOfNonTemporaryEvents(shopkeeperPed, true)

            ERS_SpawnConfiguredWeaponForPed(shopkeeperPed, calloutDataClient)

            Wait(100)

            local targetPed = NetToPed(robberPedsList[math.random(#robberPedsList)])
            TaskCombatPed(shopkeeperPed, targetPed, 0, 16)
            
            if Config.Debug then
                print("Shopkeeper is tasked to attack the robbers")
            end
        end

        for i, robberPedNetId in pairs(robberPedsList) do
            local robberPed = NetToPed(robberPedNetId)
            local fleeChance = 50
            if fleeChance > math.random(1,100) then
                ERS_SpawnConfiguredWeaponForPed(robberPed, calloutDataClient)

                TaskCombatPed(robberPed, shopkeeperPed, 0, 16)

                if Config.Debug then
                    print("Robber ped "..robberPed.." is attacking shopkeeper ped "..shopkeeperPed)
                end
            else
                TaskReactAndFleePed(ped, shopkeeperPed)

                if Config.Debug then
                    print("Robber ped "..robberPed.." is fleeing from shopkeeper ped "..shopkeeperPed)
                end
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000) -- You could choose to adjust this to only mark robbers. Up to you.

        ERS_PerformTimedActionOnPed(calloutDataClient, robberPedsList)
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)
        -- Build shopkeeper ped
        local pedModel = ERS_GetRandomModel(Config.shopKeeperPeds)
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        table.insert(pedList, pedNetId)

        -- Build robber ped(s)
        local robberCount = math.random(3)
        for i = 1, robberCount do            
            local robberPedModel = ERS_GetRandomModel(Config.randomPeds)
            local robberPedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
            local robberPedHeading = math.random(360)
            local robberPedNetId = ERS_CreatePed(robberPedModel, robberPedCoords, robberPedHeading)
            local robberPed = NetworkGetEntityFromNetworkId(robberPedNetId)
            table.insert(pedList, robberPedNetId)
        end

        return true
    end
}