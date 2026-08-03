Config.Callouts["tree_fire"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Tree on fire",
    CalloutDescriptions = {
        "Emergency responders are required to extinguish a tree fire.",
        "Authorities report a tree ablaze, demanding immediate intervention to ensure safety.",
        "A tree fire has been reported, necessitating urgent action to minimize further damage.",
        "Critical situation with a tree on fire; additional units are needed for support.",
        "Immediate response needed to address a tree fire posing imminent danger.",
        "A tree is on fire, posing a severe threat; reinforcements are necessary to contain the blaze.",
        "Emergency crews are requesting backup to assist in managing a tree fire and prevent its spread.",
        "An urgent call for help has been issued to handle a tree fire and ensure safety.",
        "Responders are on the scene of a tree fire and need extra support to stabilize the situation.",
        "A serious emergency involving a tree fire demands swift action to prevent a catastrophic outcome.",
    },               
    CalloutUnitsRequired = {
        description = "Police, Fire.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = true,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(404.1695, -2100.9302, 20.4752),
        [2] = vector3(-740.7983, -2037.9850, 9.0763),
        [3] = vector3(-784.0410, -1785.0958, 31.3617),
        [4] = vector3(-184.4082, -2134.9944, 24.5058),
        [5] = vector3(97.7032, -1838.3838, 25.6308),
        [6] = vector3(93.5803, -1143.7230, 29.3680),
        [7] = vector3(365.1689, -444.4351, 42.5076),
        [8] = vector3(1283.5366, -1626.8275, 54.2254),
        [9] = vector3(1751.8948, -2086.2515, 114.6973),
        [10] = vector3(2149.2805, -601.8230, 98.0530),
        [11] = vector3(2544.0249, 284.1833, 108.6631),
        [12] = vector3(2579.5286, 2690.2253, 44.7803),
        [13] = vector3(2942.6099, 4248.1655, 52.4890),
        [14] = vector3(2233.0967, 4749.2607, 39.8360),
        [15] = vector3(182.4587, 4399.9561, 74.3766),
        [16] = vector3(-1090.9008, 4585.7231, 128.1570),
        [17] = vector3(-1442.2822, 5421.2280, 23.0274),
        [18] = vector3(-316.3200, 6178.8647, 32.3698),
        [19] = vector3(198.4696, 6845.0181, 22.1809),
        [20] = vector3(2565.4204, 5587.5654, 47.4446),
    },        
    PedChanceToFleeFromPlayer = 70,      -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 40,        -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 20,           -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 40,       -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 5000,  -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 10000, -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "flee",   -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_knife",
        "weapon_hatchet",
        "weapon_hammer",
        "weapon_pistol",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                TaskSetBlockingOfNonTemporaryEvents(ped, true)
                local scenario = "WORLD_HUMAN_GARDENER_PLANT"
                TaskStartScenarioInPlace(ped, scenario, 0, true)
                Wait(1000)
                ERS_SetPedToFleeFromPlayer(ped)
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)


        local diameter = 10

        -- Build fire
        if UsingSmartFiresV2 or UsingSmartFires then
            local fireSize = Config.RandomMediumFireOrSmokeSize[math.random(#Config.RandomMediumFireOrSmokeSize)]
            local fireType = Config.NormalFireTypes[math.random(#Config.NormalFireTypes)]
            fireList[#fireList + 1] = ERS_AddCalloutFire(vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z-0.5), fireType, fireSize)
        elseif UsingSmartFiresLite then
            local fireSize = Config.RandomMediumFireOrSmokeSize[math.random(#Config.RandomMediumFireOrSmokeSize)]
            fireList[#fireList + 1] = ERS_AddCalloutFire(vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z-0.5), "normal", fireSize)
        end

        -- Build suspect
        local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
        local pedModel = ERS_GetRandomModel(Config.randomPeds)
        local pedCoords = vector3(coords.x, coords.y, coords.z)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        table.insert(pedList, pedNetId)

        return true
    end
}