Config.Callouts["wildfire"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Wildfire",
    CalloutDescriptions = {
        "A major wildfire has broken out, requiring immediate attention from fire services.",
        "Emergency teams are needed to combat a rapidly spreading wildfire in the area.",
        "Authorities report a wildfire threatening homes and wildlife, necessitating urgent action.",
        "A large-scale fire has been detected, and additional firefighting units are needed to contain it.",
        "Immediate response required to a wildfire endangering a residential neighborhood.",
        "A wildfire has been reported, and reinforcements are needed to assist local fire services.",
        "Fire crews are requesting backup to control a severe wildfire in a densely forested region.",
        "An urgent call for assistance has been made to deal with a wildfire spreading towards populated areas.",
        "Responders are on the scene of a wildfire and require additional support to prevent further damage.",
        "A significant wildfire situation demands immediate intervention to protect lives and property.",
    },                    
    CalloutUnitsRequired = {
        description = "Fire.",
        policeRequired = false,
        ambulanceRequired = false,
        fireRequired = true,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(1649.18, -1300.25, 85.43),
        [2] = vector3(1841.42, -1568.56, 126.55),
        [3] = vector3(2719.96, 512.47, 92.76),
        [4] = vector3(2659.38, 1258.56, 29.26),
        [5] = vector3(2629.16, 2683.31, 56.89),
        [6] = vector3(997.11, 6347.87, 38.72),
        [7] = vector3(78.02, 6822.26, 17.92),
        [8] = vector3(-566.53, 5847.58, 31.20),
        [9] = vector3(-852.40, 5574.69, 27.42),
        [10] = vector3(-534.42, 5483.81, 66.69),
        [11] = vector3(-2744.51, 2175.46, 25.07),
        [12] = vector3(-2023.58, -217.21, 29.74),
        [13] = vector3(2030.26, 3371.11, 45.18),
        [14] = vector3(1524.29, 4464.20, 49.12),
        [15] = vector3(496.92, 5583.54, 793.80),
        [16] = vector3(-1159.60, 62.91, 56.31),
        [17] = vector3(-1658.64, 2642.03, 2.95),            
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

        -- No other actions required clientside, add if you desire
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        if UsingSmartFiresV2 or UsingSmartFires then
            local fireSize = Config.RandomLargeFireOrSmokeSize[math.random(#Config.RandomLargeFireOrSmokeSize)]
            fireList[#fireList + 1] = ERS_AddCalloutFire(vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z-0.5), Config.BonFire, fireSize)
        elseif UsingSmartFiresLite then
            local fireSize = Config.RandomHugeFireOrSmokeSize[math.random(#Config.RandomHugeFireOrSmokeSize)]
            fireList[#fireList + 1] = ERS_AddCalloutFire(vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z-0.5), "normal", fireSize)
        end

        return true
    end
}