Config.Callouts["smoking_weed"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Reports of a person smoking weed",
    CalloutDescriptions = {
        "Investigate reports of a person smoking weed; locate the individual and assess the situation.",
        "Alert: dispatch units to check on reports of marijuana use in a public area; ensure compliance with laws.",
        "Units required: respond to reports of someone smoking weed and evaluate the circumstances.",
        "Notice: check reports of a person using marijuana; take necessary actions to maintain public order.",
        "Alert: respond promptly to reports of marijuana use; prioritize community safety and proper assessment.",
        "Incident reported: look into reports of a person smoking weed to understand the context and legality.",
        "Investigate reports of marijuana use; coordinate with local authorities to address the situation.",
        "Situation alert: address reports of a person smoking weed; work with relevant authorities if needed.",
        "Alert: handle reports of marijuana use and adhere to protocols for ensuring public safety and compliance.",
        "Response needed: investigate reports of a person smoking weed and take steps to ensure community standards are upheld.",
    },  
    CalloutUnitsRequired = {
        description = "Police",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(558.51, -2590.25, 6.19),          
        [2] = vector3(314.44, -997.08, 29.18),           
        [3] = vector3(195.41, -948.04, 30.09),           
        [4] = vector3(171.31, -1077.74, 29.19),         
        [5] = vector3(34.17, -1025.83, 29.47),         
        [6] = vector3(-137.15, -1180.85, 25.25),           
        [7] = vector3(-306.71, -1167.35, 23.26),            
        [8] = vector3(-318.98, -1334.59, 31.34),            
        [9] = vector3(-356.58, -1483.50, 30.16),
        [10] = vector3(-342.61, -1566.72, 25.22),
        [11] = vector3(-429.75, -1721.61, 19.05),
        [12] = vector3(-575.62, -1793.78, 22.73),
        [13] = vector3(-249.28, -1939.75, 29.95),
        [14] = vector3(-331.26, -2171.95, 10.32),
        [15] = vector3(-809.27, -2328.58, 14.57),
        [16] = vector3(-1148.01, -1984.79, 13.16),
        [17] = vector3(-1247.68, -1711.14, 4.47),
        [18] = vector3(-1216.14, -1525.44, 4.26),
        [19] = vector3(-1285.50, -1408.50, 4.45),
        [20] = vector3(-1493.06, -1369.73, 2.15),
        [21] = vector3(-1817.37, -1240.33, 13.02),
        [22] = vector3(-1654.58, -362.49, 49.48),
        [23] = vector3(-1318.32, -152.82, 46.39),
        [24] = vector3(-516.12, -446.37, 34.19),
        [25] = vector3(-302.33, -262.08, 32.42),  
        [26] = vector3(-188.07, -88.38, 52.18),
        [27] = vector3(-43.71, -12.89, 69.87),
        [28] = vector3(83.45, 33.97, 73.51),
        [29] = vector3(243.14, 117.53, 102.62),
        [30] = vector3(323.57, 174.77, 103.61),
        [31] = vector3(193.88, 296.12, 105.62),
        [32] = vector3(173.28, 387.58, 109.38),
        [33] = vector3(206.88, 777.59, 205.56),
        [34] = vector3(1221.91, 2722.65, 38.00), 
        [35] = vector3(1771.69, 3306.27, 41.17), 
        [36] = vector3(1633.14, 3559.25, 35.15),  
        [37] = vector3(1646.57, 3725.12, 34.34),
        [38] = vector3(1767.44, 3754.12, 33.83),
        [39] = vector3(1978.10, 3759.90, 32.18),  
        [40] = vector3(2461.98, 4063.67, 38.06),  
        [41] = vector3(2108.17, 4767.26, 41.17),
        [42] = vector3(1695.52, 4784.01, 42.01),
        [43] = vector3(1669.93, 4768.75, 41.85),
        [44] = vector3(1429.15, 4384.90, 44.18),
        [45] = vector3(1684.00, 6422.10, 32.27), 
        [46] = vector3(131.79, 6636.05, 31.81), 
        [47] = vector3(76.80, 6347.70, 31.37),  
        [48] = vector3(-18.15, 6392.06, 31.44),
        [49] = vector3(-104.94, 6256.18, 31.35),
        [50] = vector3(-252.48, 6213.64, 31.49),  
        [51] = vector3(-329.01, 6222.01, 31.48),  
    },        
    PedChanceToFleeFromPlayer = 25,       -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 25,         -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 10,            -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 10,        -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 10000,  -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 15000,  -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "flee",    -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_bat",
        "weapon_hammer",
        "weapon_wrench",
        "weapon_pistol",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                local scenario = ERS_SelectRandomSmokeScenario()
                TaskStartScenarioInPlace(ped, scenario, 0, true)
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        local diameter = 10

        -- Build suspects
        local suspects = math.random(1, 3)
        for i = 1, suspects do
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
            local pedModel = ERS_GetRandomModel(Config.randomGangPeds)
            local pedCoords = vector3(coords.x, coords.y, coords.z+1.0)
            local pedHeading = math.random(360)
            local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
            local ped = NetworkGetEntityFromNetworkId(pedNetId)
            table.insert(pedList, pedNetId)
        end

        return true
    end
}