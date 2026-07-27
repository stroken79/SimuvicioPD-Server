Config.Callouts["sr_wounded_hiker"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Wounded hiker on a mountain",
    CalloutDescriptions = {
        "Emergency responders have located a wounded hiker on a mountain and are providing assistance.",
        "Authorities report that a wounded hiker has been found on a mountain, requiring immediate medical attention.",
        "A wounded hiker has been located on a mountain, necessitating urgent action to ensure their safety.",
        "Critical situation with a wounded hiker located on a mountain; medical personnel are needed for support.",
        "Immediate response needed to provide medical assistance to the wounded hiker on the mountain.",
        "A wounded hiker has been found on a mountain, posing a severe threat to their health; medical reinforcements are necessary.",
        "Emergency crews are requesting medical backup to assist in providing care to the wounded hiker on the mountain.",
        "An urgent call for help has been issued to handle a wounded hiker on a mountain and ensure their well-being.",
        "Responders are on the scene with a wounded hiker on a mountain and need extra support to provide necessary care.",
        "A serious emergency involving a wounded hiker on a mountain demands swift action to provide medical attention and ensure their recovery.",
    },                                       
    CalloutUnitsRequired = {
        description = "Police, Ambulance, Fire.",
        policeRequired = true,
        ambulanceRequired = true,
        fireRequired = true,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(1636.79, 316.93, 257.37),
        [2] = vector3(971.07, 1035.19, 255.01),
        [3] = vector3(492.52, 1430.20, 348.07),
        [4] = vector3(-477.16, 1506.49, 387.38),
        [5] = vector3(-2458.71, 2106.71, 128.77),
        [6] = vector3(-1359.00, 3033.32, 108.77),
        [7] = vector3(-931.42, 3231.37, 165.68),
        [8] = vector3(-701.86, 3417.53, 175.38),
        [9] = vector3(-382.24, 3443.27, 174.59),
        [10] = vector3(-607.16, 4130.06, 174.42),
        [11] = vector3(-1138.60, 3841.83, 473.76),
        [12] = vector3(-1006.31, 4513.29, 159.06),
        [13] = vector3(-729.99, 4692.80, 214.97),
        [14] = vector3(-665.98, 4743.13, 242.80),
        [15] = vector3(-953.59, 4825.62, 307.56),
        [16] = vector3(-181.78, 4899.77, 333.31),
        [17] = vector3(-56.61, 5240.92, 372.42),
        [18] = vector3(94.51, 5681.98, 494.71),
        [19] = vector3(352.54, 5665.37, 686.56),
        [20] = vector3(478.62, 5654.97, 750.77),
        [21] = vector3(543.72, 5643.06, 772.24),
        [22] = vector3(680.14, 5266.46, 532.61),
        [23] = vector3(1861.35, 5396.27, 224.39),
        [24] = vector3(2325.34, 6191.57, 173.38),
        [25] = vector3(2190.97, 6310.20, 187.08),
        [26] = vector3(2589.27, 6119.09, 179.64),
        [27] = vector3(2755.07, 6128.20, 265.87),
        [28] = vector3(2837.06, 5964.97, 351.38),
        [29] = vector3(2912.71, 5659.78, 235.56),
        [30] = vector3(2937.77, 5203.86, 142.13),
        [31] = vector3(3209.33, 4747.44, 192.55),
        [32] = vector3(3442.59, 4250.45, 230.11),
        [33] = vector3(3289.66, 3136.04, 252.29),
        [34] = vector3(2952.92, 2504.37, 164.71),
        [35] = vector3(1939.98, 1078.99, 251.30),
        [36] = vector3(2148.21, 747.11, 260.15),
        [37] = vector3(1996.37, -184.50, 271.41),
        [38] = vector3(2028.24, -1771.37, 134.18),
        [39] = vector3(1895.74, -2156.22, 154.96),
        [40] = vector3(-2551.98, 457.35, 209.33),
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
                TaskSetBlockingOfNonTemporaryEvents(ped, true)
                ERS_ApplyBloodToPed(ped)
                local scenario = ERS_SelectRandomWoundedPersonScenario()
                TaskStartScenarioInPlace(ped, scenario, 0, true)
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 5000) -- short, to make it harder to find. :)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        -- Build ped
        local pedModel = ERS_GetRandomModel(Config.randomPeds)
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        table.insert(pedList, pedNetId)

        return true
    end
}