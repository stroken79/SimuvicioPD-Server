Config.Callouts["inj_cardiac_arrest"] = {
    Enabled = true,
    Priority = 1,
    CalloutName = "Cardiac arrest",
    CalloutDescriptions = {
        "A cardiac arrest has occurred, requiring immediate medical attention.",
        "Emergency medical assistance is needed to address a cardiac arrest situation.",
        "Reports indicate a cardiac arrest incident, necessitating urgent medical intervention.",
        "A cardiac arrest has been reported, and medical support is needed to stabilize the patient.",
        "Emergency services have been requested to address a cardiac arrest situation.",
        "A request for medical assistance has been made by personnel responding to a cardiac arrest.",
        "Additional medical units are required to support personnel responding to a cardiac arrest.",
        "Emergency backup is required to assist medical personnel in stabilizing a patient experiencing a cardiac arrest.",
        "A call for assistance has been issued by personnel dealing with a cardiac arrest.",
        "Reports suggest a cardiac arrest situation where immediate medical assistance is crucial to save a life.",
    },
    CalloutUnitsRequired = {
        description = "Ambulance.",
        policeRequired = false,
        ambulanceRequired = true,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(-802.40, 173.09, 72.84),          -- Michel's house, Vinewood
        [2] = vector3(-798.06, -101.23, 37.60),         -- Portola Dr, Rockford hills
        [3] = vector3(-252.35, -2040.25, 29.95),        -- Maze bank arena
        [4] = vector3(-1022.05, -2751.73, 1.01),        -- Ls International airport
        [5] = vector3(-10.97, -1433.83, 31.12),         -- Franklins aunts house, Strawberry
        [6] = vector3(2549.68, 382.84, 108.62),         -- Palomino Fwy, Tataviam mount
        [7] = vector3(1190.73, 2713.12, 38.22),         -- Route 68, Binko clothing
        [8] = vector3(-2193.41, 4293.39, 49.17),        -- Great Ocean Hw, Chumash
        [9] = vector3(15.75, 6499.83, 31.49),           -- Paleto Blvd, Paleto Bay
        [10] = vector3(61.15, 6940.83, 13.31),          -- Paleto Blvd, Paleto Bay, beach
        [11] = vector3(-1154.30, -1520.94, 10.63),
        [12] = vector3(-1204.87, -1561.01, 4.61),
        [13] = vector3(-1456.49, -240.12, 49.81),
        [14] = vector3(253.01, 220.31, 106.29),
        [15] = vector3(2663.66, 3928.24, 42.34),
        [16] = vector3(2700.45, 3083.12, 42.76),
        [17] = vector3(2632.89, 2946.15, 40.42),
        [18] = vector3(2851.14, 3440.11, 50.92),
        [19] = vector3(2453.31, 3854.3, 38.94),
        [20] = vector3(2271.27, 3757.01, 38.42),
        [21] = vector3(1820.61, 3507.98, 38.32),
        [22] = vector3(1693.8, 3461.85, 37.02),
        [23] = vector3(1184.28, 3267.64, 39.2),
        [24] = vector3(-3040.17, 3745.06, 70.2),
        [25] = vector3(-4050.71, 5335.75, 83.14),
        [26] = vector3(-4043.33, 5599.94, 68.38),
        [27] = vector3(2874.65, 4868.66, 62.6),
        [28] = vector3(3000.5, 4099.68, 57.18),
        [29] = vector3(-92.55, 6150.44, 31.8),
        [30] = vector3(-1832.48, 2686.74, 4.24),
        [31] = vector3(-1308.78, 2512.97, 21.74),
        [32] = vector3(445.14, 3524.84, 33.53),
        [33] = vector3(737.51, 3534.92, 34.08),
        [34] = vector3(1345.39, 3643.31, 33.62),
        [35] = vector3(1491.65, 3771.76, 33.51),
        [36] = vector3(1812.97, 3836.61, 33.56),
        [37] = vector3(2561.29, 4289.19, 41.60),
        [38] = vector3(2415.94, 4813.70, 35.91),
        [39] = vector3(2204.14, 5194.41, 60.96),
        [40] = vector3(2692.64, 2785.85, 36.03),
        [41] = vector3(2525.68, 2612.09, 37.94),
        [42] = vector3(769.43, 203.60, 83.65),
        [43] = vector3(95.80, -219.33, 54.48),
        [44] = vector3(-160.23, -756.60, 41.92),
        [45] = vector3(-270.76, -980.51, 31.21),
        [46] = vector3(181.82, -936.06, 30.09),
        [47] = vector3(237.88, -888.73, 30.49),
        [48] = vector3(231.81, -751.09, 30.82),
        [49] = vector3(1305.96, -587.50, 71.80),
    },                       
    PedChanceToFleeFromPlayer = 0,      -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 0,        -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 0,           -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 0,       -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 0,    -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 1000, -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "none", -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
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