Config.Callouts["repeated_hotline"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Person continously calling the emergency hotline",
    CalloutDescriptions = {
        "Investigate repeated emergency calls from an individual; ensure their safety and address any urgent needs.",
        "Alert: deploy units to assess and assist an individual making repeated emergency calls.",
        "Units required: investigate multiple emergency calls from the same location for potential emergencies.",
        "Notice: verify the nature of persistent emergency calls and provide necessary support.",
        "Alert: respond to ongoing emergency calls from a residential area; assess for genuine emergencies.",
        "Incident reported: investigate continuous emergency calls to determine the caller's needs.",
        "Respond to an individual repeatedly dialing the emergency hotline; prioritize mental health and provide support.",
        "Situation alert: coordinate with professionals to assist an individual making repeated emergency calls.",
        "Alert: respond empathetically to persistent emergency calls and provide appropriate assistance.",
        "Response needed: investigate and address continuous emergency calls to ensure safety and support.",
    },
    CalloutUnitsRequired = {
        description = "Police",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(299.9856, -873.1115, 29.1976),
        [2] = vector3(265.3121, -2841.4810, 6.0074),
        [3] = vector3(80.3296, -2722.0681, 5.9887),
        [4] = vector3(-661.8322, -2187.9426, 6.0002),
        [5] = vector3(-1012.8489, -1607.4501, 5.0882),
        [6] = vector3(-1254.8690, -1366.3451, 4.0205),
        [7] = vector3(-1191.7335, -1044.5894, 2.1412),
        [8] = vector3(-961.3003, -727.1707, 19.8872),
        [9] = vector3(-727.7034, -411.9380, 35.0770),
        [10] = vector3(-384.7127, -42.9089, 49.0244),
        [11] = vector3(-14.7561, 308.0486, 113.0616),
        [12] = vector3(307.0553, 64.7258, 99.8901),
        [13] = vector3(604.6143, -428.4446, 24.7441),
        [14] = vector3(695.1581, -1109.6603, 22.4602),
        [15] = vector3(322.6585, -1750.1853, 29.2482),
        [16] = vector3(-12.8548, -1504.0767, 30.1095),
        [17] = vector3(2698.3960, 1376.3064, 24.5163),
        [18] = vector3(2516.6223, 4186.7397, 39.7938),
        [19] = vector3(2513.5872, 4787.5181, 34.5690),
        [20] = vector3(-268.1085, 6214.6250, 31.5452),
    },               
    PedChanceToFleeFromPlayer = 25,      -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 25,        -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 0,            -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 25,       -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 5000,  -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 15000, -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "flee",   -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_knife",
        "weapon_pistol",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                ERS_ClearPedTasksAndBlockEvents(ped)

                Wait(100)

                local scenario = "WORLD_HUMAN_STAND_MOBILE"
                TaskStartScenarioInPlace(ped, scenario, 0, true)
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        -- Build ped
        local pedModel = ERS_GetRandomModel(Config.randomPeds)
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z+1.0)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        table.insert(pedList, pedNetId)

        return true
    end
}