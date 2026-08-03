Config.Callouts["inj_drowning"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Reports of a Drowning",
    CalloutDescriptions = {
        "Respond to a report of a drowning; locate the individual and provide immediate assistance.",
        "Alert: possible drowning incident; deploy units to the location and ensure prompt rescue efforts.",
        "Units needed: report of a person drowning; focus on rescuing the individual and providing necessary medical aid.",
        "Notice: drowning incident reported; act promptly to rescue the person and prevent further danger.",
        "Alert: report of a drowning; intervention needed to save the individual and ensure safety.",
        "Incident reported: person drowning; take action to rescue and administer first aid.",
        "Respond to a situation involving a drowning; prioritize the rescue and coordinate with emergency services.",
        "Situation alert: drowning in progress; secure the area and provide immediate assistance to the individual.",
        "Alert: report of a drowning; respond swiftly to rescue the person and ensure their safety.",
        "Response needed: drowning incident; rescue the individual, provide medical aid, and ensure the area is safe.",
    },                          
    CalloutUnitsRequired = {
        description = "Ambulance.",
        policeRequired = false,
        ambulanceRequired = true,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(-1639.65, -2380.76, 1.29),
        [2] = vector3(-1534.27, -1315.52, 1.09),
        [3] = vector3(-1785.31, -1016.55, 0.74),
        [4] = vector3(-2132.12, -513.91, 1.85),
        [5] = vector3(1094.68, -2682.35, 2.24),
        [6] = vector3(2344.83, -2136.04, 1.30),
        [7] = vector3(-1616.36, -2312.97, 1.36),
        [8] = vector3(-3106.82, 107.83, 2.83),
        [9] = vector3(602.10, -1103.62, 10.13),
        [10] = vector3(1161.76, -119.16, 55.56),
        [11] = vector3(35.49, 769.50, 197.24),
        [12] = vector3(-1108.14, 135.07, 59.40),
        [13] = vector3(1911.35, 285.13, 161.66),
        [14] = vector3(-1175.26, -1016.70, 0.58),
        [15] = vector3(-1060.38, 704.26, 165.42),
        [16] = vector3(-56.61, 807.01, 226.98),
        [17] = vector3(-1773.77, 439.62, 127.34),
        [18] = vector3(-2997.52, 753.23, 26.69),
        [19] = vector3(-3114.40, 435.10, 1.64),
        [20] = vector3(14.85, 521.72, 170.22),
        [21] = vector3(-764.52, 2869.57, 14.38),
        [22] = vector3(-2783.95, 2714.57, 1.71),
        [23] = vector3(181.55, 3616.83, 30.99),
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


        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped)
                SetEntityHealth(ped, 0)
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