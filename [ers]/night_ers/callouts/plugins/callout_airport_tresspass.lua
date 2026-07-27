Config.Callouts["airport_tresspass"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Trespassing at the airport",
    CalloutDescriptions = {
        "Respond to a report of trespassing at the airport; locate and apprehend the individual.",
        "Alert: unauthorized person on airport property; deploy units to secure the area and ensure safety.",
        "Units needed: report of trespassing at the airport; focus on locating the trespasser and assessing any potential threats.",
        "Notice: trespassing incident at the airport reported; act promptly to control the situation and prevent disruptions.",
        "Alert: report of unauthorized entry at the airport; intervention needed to ensure safety and remove the trespasser.",
        "Incident reported: trespassing at the airport; take action to investigate and enforce security protocols.",
        "Respond to a situation involving unauthorized entry at the airport; prioritize security and coordinate with airport authorities.",
        "Situation alert: trespassing in progress at the airport; secure the area and apprehend the individual.",
        "Alert: report of unauthorized presence at the airport; respond swiftly to address the situation and ensure safety.",
        "Response needed: trespassing at the airport; secure the area, locate the individual, and enforce security measures.",
    },                     
    CalloutUnitsRequired = {
        description = "Police.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(-1360.23, -2220.66, 13.94),
        [2] = vector3(-1760.41, -2858.64, 15.13),
        [3] = vector3(-1427.77, -3142.13, 13.93),
        [4] = vector3(-909.73, -3190.05, 13.94),
        [5] = vector3(-1097.16, -2911.45, 13.94),
        [6] = vector3(-1261.79, -2780.29, 13.94),
        [7] = vector3(-1193.88, -2543.16, 13.94),
        [8] = vector3(-989.01, -2375.95, 13.94),
        [9] = vector3(-1157.98, -2742.06, 13.95),
        [10] = vector3(1701.78, 3266.63, 41.14),
        [11] = vector3(1054.73, 3072.05, 41.51),
        [12] = vector3(1425.41, 3088.31, 40.88),
    },           
    PedChanceToFleeFromPlayer = 100,    -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 0,        -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 0,           -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 0,       -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 10000,-- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 15000,-- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "flee",  -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_unarmed",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped)
                ERS_SetPedToFleeFromPlayer(ped)
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)

    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        local diameter = 15

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