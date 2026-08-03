Config.Callouts["arson"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Reports of arson",
    CalloutDescriptions = {
        "Incidents of suspected arson have been reported, necessitating immediate attention and intervention from law enforcement and fire services.",
        "Emergency services are urgently needed to address incidents of suspected arson, ensuring the safety of the community and property.",
        "Reports indicate multiple instances of suspected arson, requiring swift action from authorities to prevent further damage and danger.",
        "Suspected cases of arson have been identified, prompting the mobilization of additional resources to investigate and mitigate the situation.",
        "Emergency services have been alerted to incidents of suspected arson, necessitating coordinated efforts to identify and apprehend perpetrators.",
        "Authorities have requested assistance in addressing suspected cases of arson, emphasizing the need for vigilance and cooperation from the public.",
        "Additional units are required to support law enforcement and fire personnel in responding to incidents of suspected arson.",
        "Emergency backup is necessary to assist authorities in managing and containing incidents of suspected arson, ensuring public safety.",
        "A call for assistance has been issued by responders dealing with suspected cases of arson, highlighting the urgency of the situation.",
        "Reports suggest a situation where immediate intervention is crucial to manage and address incidents of suspected arson, safeguarding lives and property.",
    },                        
    CalloutUnitsRequired = {
        description = "Police, Fire",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = true,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(-1656.60, -150.07, 58.33),
        [2] = vector3(-964.03, -184.61, 37.80),
        [3] = vector3(-628.39, -234.97, 38.05),
        [4] = vector3(-586.74, -293.28, 35.07),
        [5] = vector3(-42.90, -419.81, 39.64),
        [6] = vector3(23.17, -434.85, 45.50),
        [7] = vector3(371.64, -363.52, 46.75),
        [8] = vector3(802.94, -828.72, 27.32),
        [9] = vector3(827.70, -1072.18, 29.00),
        [10] = vector3(1001.18, -1538.05, 30.83),
        [11] = vector3(954.11, -1679.79, 30.05),
        [12] = vector3(39.68, -2684.49, 6.17),
        [13] = vector3(-420.11, -2790.76, 6.01),
        [14] = vector3(-1142.01, -1969.37, 13.16),
        [15] = vector3(-1175.60, -1800.86, 3.90),
        [16] = vector3(-1998.75, 553.35, 112.60),
        [17] = vector3(-748.51, 5593.33, 41.65),
        [18] = vector3(-377.63, 6075.06, 31.50),
        [19] = vector3(-159.16, 6290.67, 31.50),
        [20] = vector3(-69.88, 6250.36, 31.08),
        [21] = vector3(1919.24, 4831.56, 46.02),
        [22] = vector3(2542.07, 4648.52, 34.07),
        [23] = vector3(2508.43, 4212.37, 40.15),
        [24] = vector3(1882.91, 3806.63, 32.76),
        [25] = vector3(1710.45, 3689.69, 34.82),            
        -- Add up to 40
    },                                                                        
    PedChanceToFleeFromPlayer = 50,      -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 50,        -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 10,           -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 60,       -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 5000,  -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 10000, -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "flee",   -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_knife",
        "weapon_hammer",
        "weapon_crowbar",
        "weapon_bottle",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)


        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                TaskSetBlockingOfNonTemporaryEvents(ped, true)
                Wait(100)
                ERS_SetPedToFleeFromPlayer(ped)
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)


        local diameter = 2
        
        if UsingSmartFiresV2 or UsingSmartFires then
            local fireSize = Config.RandomSmallFireOrSmokeSize[math.random(#Config.RandomSmallFireOrSmokeSize)]
            local fireType = Config.NormalFireTypes[math.random(#Config.NormalFireTypes)]
            fireList[#fireList + 1] = ERS_AddCalloutFire(vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z-0.5), fireType, fireSize)
        elseif UsingSmartFiresLite then
            local fireSize = Config.RandomSmallFireOrSmokeSize[math.random(#Config.RandomSmallFireOrSmokeSize)]
            fireList[#fireList + 1] = ERS_AddCalloutFire(vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z-0.5), "normal", fireSize)
        end

        -- Build suspect peds
        local randomAmountOfSuspects = math.random(3)
        for i = 1, randomAmountOfSuspects do
            local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
            
            local suspectPedModel = ERS_GetRandomModel(Config.randomPeds)
            local suspectPedCoords = vector3(coords.x, coords.y, coords.z)
            local suspectPedHeading = math.random(360)
            local suspectPedNetId = ERS_CreatePed(suspectPedModel, suspectPedCoords, suspectPedHeading)
            local suspectPed = NetworkGetEntityFromNetworkId(suspectPedNetId)
            table.insert(pedList, suspectPedNetId)
        end
    
        return true
    end
}