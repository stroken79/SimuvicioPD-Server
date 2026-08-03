Config.Callouts["inj_suffocation"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Suffocation",
    CalloutDescriptions = {
        "Emergency: investigate reports of a potential suffocation incident; secure the area and administer first aid.",
        "Urgent alert: dispatch units to respond to reports of suffocation; provide immediate medical assistance.",
        "Critical response required: attend to reports of a suffocation case; perform necessary life-saving actions.",
        "Notice: check reports of suffocation; ensure quick medical intervention and safety measures.",
        "Alert: respond promptly to reports of suffocation; prioritize victim's safety and administer oxygen if needed.",
        "Incident reported: investigate reports of suffocation to prevent fatal outcomes; coordinate with medical teams.",
        "Immediate action: address reports of a person suffocating; implement rescue operations and ensure safety.",
        "Situation alert: attend to suffocation reports; secure the area and provide life-saving support.",
        "Emergency response: handle reports of suffocation and follow medical protocols to ensure survival.",
        "Response needed: investigate suffocation reports urgently; take appropriate actions to save lives and prevent harm.",
    },                      
    CalloutUnitsRequired = {
        description = "Ambulance",
        policeRequired = false,
        ambulanceRequired = true,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(-1417.2120, -1615.8606, 0.1448),
        [2] = vector3(251.6226, -1503.1725, 29.1405),
        [3] = vector3(-153.3584, -1352.1089, 29.8504),
        [4] = vector3(-400.0376, -1445.8768, 29.3115),
        [5] = vector3(-866.9430, -861.7206, 18.4204),
        [6] = vector3(-1217.7489, -505.0577, 30.9675),
        [7] = vector3(-1090.9929, 80.6599, 54.5098),
        [8] = vector3(-41.2845, 228.3184, 107.9620),
        [9] = vector3(1091.1876, -698.9880, 57.4586),
        [10] = vector3(391.5157, -1442.1150, 29.4271),
        [11] = vector3(-616.9894, -629.8798, 32.1431),
        [12] = vector3(-667.2766, -230.0070, 37.1263),
        [13] = vector3(-676.4556, -169.8028, 37.5968),
        [14] = vector3(617.5099, 273.6443, 102.9611),
        [15] = vector3(599.5178, 2728.1765, 41.9364),
        [16] = vector3(1823.3440, 3742.6594, 33.3723),
        [17] = vector3(1980.1499, 3814.6687, 32.1411),
        [18] = vector3(2008.8790, 4989.6445, 41.3342),
        [19] = vector3(236.8464, 2590.3799, 45.1829),
        [20] = vector3(-1226.6552, -1493.0027, 4.3844),
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
    
        local deadPed = 0
        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                if index == 1 then
                    deadPed = ped
                    SetEntityHealth(ped, 0)
                    TaskSetBlockingOfNonTemporaryEvents(ped, true)
                else
                    TaskGoToEntity(ped, deadPed, -1, 3.0, 10.0, 1073741824.0, 0)
                    Wait(math.random(5000))
                    TaskTurnPedToFaceEntity(ped, deadPed, 2000)
                    Wait(1000)
                    local scenario = ERS_SelectRandomBystanderScenario()
                    TaskStartScenarioInPlace(ped, scenario, 0, true)
                end
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)

    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        -- Build victim
        local pedModel = ERS_GetRandomModel(Config.randomPeds)
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        table.insert(pedList, pedNetId)

        -- Build bystanders
        local randomAmountOfBystanders = math.random(4)
        for i = 1, randomAmountOfBystanders do
            local diameter = 6
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
            
            local bystanderPedModel = ERS_GetRandomModel(Config.randomPeds)
            local bystanderPedCoords = vector3(coords.x, coords.y, coords.z)
            local bystanderPedHeading = math.random(360)
            local bystanderPedNetId = ERS_CreatePed(bystanderPedModel, bystanderPedCoords, bystanderPedHeading)
            local bystanderPed = NetworkGetEntityFromNetworkId(pedNetId)
            table.insert(pedList, bystanderPedNetId)
        end

        return true
    end
}