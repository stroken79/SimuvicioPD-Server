Config.Callouts["missing_found"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Missing person located",
    CalloutDescriptions = {
        "Emergency responders have located a missing person and are providing assistance.",
        "Authorities report that a missing person has been found, requiring immediate medical attention.",
        "A missing person has been located, necessitating urgent action to ensure their safety.",
        "Critical situation with a missing person located; medical personnel are needed for support.",
        "Immediate response needed to provide medical assistance to the located missing person.",
        "A missing person has been found, posing a severe threat to their health; medical reinforcements are necessary.",
        "Emergency crews are requesting medical backup to assist in providing care to the located missing person.",
        "An urgent call for help has been issued to handle a located missing person and ensure their well-being.",
        "Responders are on the scene with a located missing person and need extra support to provide necessary care.",
        "A serious emergency involving a missing person demands swift action to provide medical attention and ensure their recovery.",
    },                                  
    CalloutUnitsRequired = {
        description = "Police.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(1837.21, 193.28, 171.54),
        [2] = vector3(-1599.52, -1043.22, 13.02),
        [3] = vector3(-1639.43, 4734.02, 53.52),
        [4] = vector3(2337.29, 4931.56, 42.05),
        [5] = vector3(-1580.69, 2094.19, 69.17),
        -- Add more to 40
    },                 
    PedChanceToFleeFromPlayer = 50,     -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 0,        -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 0,           -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 50,      -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 1000, -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 10000, -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "flee",  -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_hammer",
        "weapon_stone_hatchet",
        "weapon_wrench",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                TaskSetBlockingOfNonTemporaryEvents(ped, true)
                ERS_ApplyBloodToPed(ped)
                local animClipSet = ERS_SelectRandomMovementClipSet()
                ERS_SetMovementAnimClipSetToPed(ped, animClipSet)
                TaskWanderStandard(ped, 10.0, 10)
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        local diameter = 10

        -- Build ped
        local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
        local pedModel = ERS_GetRandomModel(Config.randomPeds)
        local pedCoords = vector3(coords.x, coords.y, coords.z)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        table.insert(pedList, pedNetId)
    
        return true
    end
}