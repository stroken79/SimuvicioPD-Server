Config.Callouts["armed_robbery"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Reports of an Armed Burglary",
    CalloutDescriptions = {
        "Respond to a report of an armed burglary; secure the area and apprehend the suspect.",
        "Alert: armed burglary in progress; deploy units to the location and ensure public safety.",
        "Units needed: report of a burglary involving a weapon; focus on securing the scene and detaining the suspect.",
        "Notice: armed burglary reported; act promptly to control the situation and prevent harm.",
        "Alert: report of an armed burglary; intervention needed to apprehend the suspect and ensure safety.",
        "Incident reported: armed burglary; take action to secure the premises and protect bystanders.",
        "Respond to a situation involving an armed burglary; prioritize public safety and coordinate with law enforcement.",
        "Situation alert: armed burglary in progress; secure the area and detain the suspect.",
        "Alert: report of a burglary with a weapon; respond swiftly to address the situation and ensure safety.",
        "Response needed: armed burglary; secure the area, apprehend the suspect, and restore order.",
    },                                
    CalloutUnitsRequired = {
        description = "Police, Ambulance.",
        policeRequired = true,
        ambulanceRequired = true,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(-462.7426, -1789.1514, 20.7425),
        [2] = vector3(-1349.7474, -978.6703, 8.3487),
        [3] = vector3(-1298.3502, -793.9792, 17.5649),
        [4] = vector3(-79.0676, -420.0754, 36.9070),
        [5] = vector3(269.7047, -454.0890, 45.1490),
        [6] = vector3(384.5264, -330.8739, 46.8860),
        [7] = vector3(-259.4929, -1608.9178, 31.8465),
        [8] = vector3(-179.2647, -1740.8966, 30.2026),
        [9] = vector3(19.5304, -1796.9473, 26.8921),
        [10] = vector3(182.0713, -1936.4159, 21.0075),
        [11] = vector3(483.6955, -1976.0867, 24.5434),
        [12] = vector3(558.0399, -1791.2672, 29.1919),
        [13] = vector3(791.4307, -2481.0999, 20.9120),
        [14] = vector3(365.3052, -2552.9727, 6.2214),
        [15] = vector3(-236.2226, -2470.8672, 6.0014),
        [16] = vector3(-607.5613, -2315.1016, 13.8226),
        [17] = vector3(-586.1891, -1164.0364, 22.1743),
        [18] = vector3(-707.7452, -923.6995, 19.0100),
        [19] = vector3(-710.3022, -866.9073, 23.3419),
        [20] = vector3(371.6894, 30.0890, 92.0128),
    },           
    PedChanceToFleeFromPlayer = 50,      -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 50,        -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 20,           -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 100,      -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 10000, -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 15000, -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "attack", -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_pistol",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)


        local plyGroupHash = GetPedRelationshipGroupHash(plyPed)
        local retval, suspectGroupHash = AddRelationshipGroup("SUSPECT_GROUP_HASH")
        local victim
        local suspectPedList = {}

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped)
                if index == 1 then
                    victim = ped
                    ERS_ClearPedTasksAndBlockEvents(ped)
                    Wait(100)
                    TaskHandsUp(ped, -1, 0, -1, true)
                else
                    SetPedRelationshipGroupHash(ped, suspectGroupHash)
                    SetEntityCanBeDamagedByRelationshipGroup(ped, false, suspectGroupHash)
                    SetRelationshipBetweenGroups(5, suspectGroupHash, plyGroupHash)
                    SetRelationshipBetweenGroups(5, plyGroupHash, suspectGroupHash)

                    ERS_ClearPedTasksAndBlockEvents(ped)
                    ERS_SpawnConfiguredWeaponForPed(ped, calloutDataClient)
                    Wait(100)
                    TaskAimGunAtEntity(ped, victim, -1, false)
                    table.insert(suspectPedList, pedNetId)
                end
            end
        end

        ERS_CreateTemporaryBlipForEntities(suspectPedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, suspectPedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        local diameter = 15

        -- Build victim
        local pedModel = ERS_GetRandomModel(Config.randomPeds)
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z+1.0)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        table.insert(pedList, pedNetId)

        -- Build peds
        local randomAmountOfSuspects = math.random(4)
        for i = 1, randomAmountOfSuspects do
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
            local pedModel = ERS_GetRandomModel(Config.randomPeds)
            local pedCoords = vector3(coords.x, coords.y, coords.z+1.0)
            local pedHeading = math.random(360)
            local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
            local ped = NetworkGetEntityFromNetworkId(pedNetId)
            table.insert(pedList, pedNetId)
        end

        return true
    end
}