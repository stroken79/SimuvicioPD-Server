Config.Callouts["overheated_transformer"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Overheated transformer station",
    CalloutDescriptions = {
        "A transformer station is experiencing critical overheating, needing immediate action to prevent a fire.",
        "Emergency crews are required to cool down an overheating transformer station to avoid power disruptions.",
        "Authorities report an urgent situation with a transformer station overheating, demanding prompt intervention.",
        "A transformer station has dangerously high temperatures; additional units are necessary to control the risk.",
        "Immediate response needed to address an overheating transformer station and mitigate potential hazards.",
        "An overheated transformer station poses a significant threat, calling for reinforcements to stabilize the situation.",
        "Critical overheating detected at a transformer station; emergency teams must act quickly to prevent escalation.",
        "An urgent alert for assistance due to a transformer station overheating and risking major power outages.",
        "Responders are battling an overheating transformer station and need extra support to ensure safety.",
        "A serious overheating issue at a transformer station requires swift action to protect nearby infrastructure and lives.",
    },                                               
    CalloutUnitsRequired = {
        description = "Police, Fire.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = true,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(2094.0078, 2325.3831, 94.2853), 
        [2] = vector3(2278.6301, 2969.2185, 46.5811), 
        [3] = vector3(2840.2234, 1553.8225, 24.5741), 
        [4] = vector3(2821.8545, 1511.8513, 24.7242), 
        [5] = vector3(2458.3921, 1457.0712, 36.2040), 
        [6] = vector3(1127.5670, -2489.8242, 33.3611), 
        [7] = vector3(233.3477, 6399.8403, 31.6335), 
        [8] = vector3(1346.0159, 6383.4556, 33.4101), 
        [9] = vector3(2050.1416, 3683.3496, 34.5879), 
        [10] = vector3(683.1802, 120.5065, 80.7545), 
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


        -- No other actions required clientside.
    
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        local diameter = 15
        local randomAmountOfFires = math.random(2,6)
        for i = 1, randomAmountOfFires do
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
            -- Build fires
            if UsingSmartFiresV2 or UsingSmartFires then
                local fireSize = Config.RandomHugeFireOrSmokeSize[math.random(#Config.RandomHugeFireOrSmokeSize)]
                fireList[#fireList + 1] = ERS_AddCalloutFire(vector3(coords.x, coords.y, coords.z-0.5), Config.ElectricalFire, fireSize)
            elseif UsingSmartFiresLite then
                local fireSize = Config.RandomHugeFireOrSmokeSize[math.random(#Config.RandomHugeFireOrSmokeSize)]
                fireList[#fireList + 1] = ERS_AddCalloutFire(vector3(coords.x, coords.y, coords.z-0.5), "normal", fireSize)
            end
        end

        return true
    end
}