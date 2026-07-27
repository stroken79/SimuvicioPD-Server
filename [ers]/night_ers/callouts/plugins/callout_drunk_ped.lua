Config.Callouts["drunk_ped"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Drunk and disorderly",
    CalloutDescriptions = {
        "Respond to a report of an individual behaving erratically due to intoxication; ensure public safety.",
        "Emergency call: intoxicated person causing a disturbance; dispatch units to handle the situation.",
        "Urgent assistance needed for a drunk and disorderly individual; maintain order and provide necessary support.",
        "Critical incident: individual under the influence is causing a public disturbance; respond immediately.",
        "Alert: drunk and disorderly person reported; deploy officers to manage the situation and restore peace.",
        "Person behaving aggressively due to alcohol consumption; immediate response required to ensure safety.",
        "Handle an incident involving an intoxicated individual causing a scene; prioritize public order and safety.",
        "Emergency response: drunk and disorderly behavior reported; coordinate efforts to de-escalate and resolve the issue.",
        "Urgent callout: individual under the influence causing trouble; respond quickly to address the disorderly conduct.",
        "Critical situation: intoxicated person disrupting public order; immediate intervention needed to prevent escalation.",
    },                   
    CalloutUnitsRequired = {
        description = "Police.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(414.9027, -606.7913, 28.7064),
        [2] = vector3(1985.8014, 3051.5066, 47.2152),
        [3] = vector3(2002.7778, 3050.8342, 47.2134),
        [4] = vector3(1979.8967, 3059.4202, 47.1777),
        [5] = vector3(1969.7324, 3032.3501, 47.0564),
        [6] = vector3(1567.9878, 3575.3203, 33.0887),
        [7] = vector3(1661.0940, 3813.2605, 34.8567),
        [8] = vector3(1974.0117, 3818.5132, 33.4363),
        [9] = vector3(1691.9283, 4783.4653, 41.9215),
        [10] = vector3(1658.3806, 4874.2173, 42.0714),
        [11] = vector3(727.2822, 4187.3271, 40.7092),
        [12] = vector3(192.4504, 3092.5593, 43.0729),
        [13] = vector3(235.8815, 2568.2986, 46.4725),
        [14] = vector3(-1914.7069, 2051.5798, 140.7368),
        [15] = vector3(-3065.0869, 559.6572, 2.3003),
        [16] = vector3(-3044.6960, 33.3533, 10.1182),
        [17] = vector3(-1817.5731, -1183.0045, 14.3061),
        [18] = vector3(119.1438, -1287.0010, 28.2693),
        [19] = vector3(430.7794, -627.6445, 28.7117),
        [20] = vector3(456.3588, -738.9048, 27.3576),
        [21] = vector3(113.8742, 246.7692, 107.8513),
        [22] = vector3(298.0912, 185.1022, 104.1350),
        [23] = vector3(-1390.5596, -583.9694, 30.2245),
    },                      
    PedChanceToFleeFromPlayer = 25,      -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 50,        -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 0,            -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 25,       -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 10000,  -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 15000, -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "none",   -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_knife",
        "weapon_bottle",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped)
                ERS_SetPedAsDrunkPed(ped)
                TaskWanderStandard(ped, 10.0, 10)
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        local diameter = 10 

        -- Build suspect peds
        local randomAmountOfSuspects = math.random(3)
        for i = 1, randomAmountOfSuspects do
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
            local pedModel = ERS_GetRandomModel(Config.randomPeds)
            local pedCoords = vector3(coords.x, coords.y, coords.z)
            local pedHeading = math.random(360)
            local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
            local ped = NetworkGetEntityFromNetworkId(pedNetId)
            table.insert(pedList, pedNetId)
        end
    
        return true
    end
}