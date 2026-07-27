Config.Callouts["illegal_mining"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Illegal mining activity",
    CalloutDescriptions = {
        "Respond to reports of illegal mining activity in the area; immediate intervention needed to halt operations and enforce regulations.",
        "Emergency call: illegal mining operation detected; deploy units to investigate and prevent further environmental damage.",
        "Urgent response required for suspected illegal mining activity; mobilize enforcement teams to enforce laws and protect natural resources.",
        "Critical situation: unauthorized mining activity reported; respond swiftly to preserve the integrity of the environment and enforce regulations.",
        "Alert: illegal mining operation underway; coordinate efforts to shut down operations and hold perpetrators accountable.",
        "Suspected illegal mining activity reported; immediate action needed to safeguard the environment and prevent exploitation.",
        "Handle an emergency involving illegal mining operations; prioritize environmental protection and enforcement of mining laws.",
        "Emergency response: detected illegal mining activity; ensure compliance with regulations and mitigate environmental impact.",
        "Urgent callout: illegal mining operation in progress; deploy resources to stop the activity and safeguard natural resources.",
        "Critical situation: unauthorized mining activity detected; immediate intervention necessary to uphold legal standards and protect the environment.",
    },                                
    CalloutUnitsRequired = {
        description = "Police, Ambulance.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(2947.2610, 2801.1228, 41.2169),
        [2] = vector3(2694.3813, 2909.6035, 36.3845),
        [3] = vector3(3013.2708, 2925.5684, 63.9230),
        [4] = vector3(2618.2444, 2176.4280, 18.0428),
    },                      
    PedChanceToFleeFromPlayer = 80,     -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 20,       -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 50,          -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 20,      -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 10000, -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 15000, -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "flee",  -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_battleaxe",
        "weapon_stone_hatchet",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                TaskSetBlockingOfNonTemporaryEvents(ped, true)
                local scenario = "WORLD_HUMAN_CONST_DRILL"
                TaskStartScenarioInPlace(ped, scenario, 0, true)
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        local diameter = 20

        -- Build suspect peds
        local randomAmountOfSuspects = math.random(5)
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