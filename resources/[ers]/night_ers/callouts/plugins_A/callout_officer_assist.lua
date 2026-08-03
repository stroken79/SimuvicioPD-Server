Config.Callouts["officer_assist"] = {
    
    Enabled = true,
    Priority = 1,
    CalloutName = "Officer in need of assistance",
    CalloutDescriptions = {
        "A situation has arisen requiring immediate backup support for an officer.",
        "Emergency assistance is needed to address a law enforcement issue.",
        "Reports indicate an urgent situation where additional support is required for an officer.",
        "An incident has occurred requiring backup for an officer, ensuring their safety.",
        "Emergency services have been summoned to assist an officer in a critical situation.",
        "A request for assistance has been made by an officer in a potentially hazardous situation.",
        "Additional resources are needed to support an officer facing an escalating situation.",
        "Emergency backup is required to assist an officer dealing with an unforeseen circumstance.",
        "A call for assistance has been issued by an officer requiring immediate backup.",
        "Reports suggest a situation where an officer requires urgent assistance to maintain control.",
    },
    CalloutUnitsRequired = {
        description = "Police, ambulance.",
        policeRequired = true,
        ambulanceRequired = true,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(2710.43, 3309.19, 55.82),       -- Senora Freeway NB
        [2] = vector3(2533.19, 4205.98, 40.20),       -- East Joshua Rd.
        [3] = vector3(1692.66, 4571.54, 41.49),       -- North Calafia Way
        [4] = vector3(-2529.98, 2334.12, 33.06),      -- Route 68
        [5] = vector3(-1501.20, 4971.76, 63.12),      -- Great Ocean Hway (N)
        [6] = vector3(-724.18, 5809.86, 17.40),       -- Procopio Promenade
        [7] = vector3(44.24, 6375.56, 31.23),         -- Paleto Blvd.
        [8] = vector3(-3034.95, 117.41, 11.61),       -- Great Ocean Hway (S)
        [9] = vector3(-1857.44, -616.55, 11.18),      -- Vespucci beach
        [10] = vector3(-573.80, -1122.40, 22.18),     -- Calais Avenue
        [11] = vector3(116.18, -1070.91, 29.19),      -- Vespucci Blvd.
        [12] = vector3(1016.14, -895.78, 30.59),      --  8199 Postal
        [13] = vector3(1209.71, -2001.96, 43.57),     --  9368 Postal
        [14] = vector3(-316.17, -2399.95, 61.40),     --  10049 Postal
        [15] = vector3(-418.30, -1572.27, 39.05),     --  9028 Postal
        [16] = vector3(251.83, -1182.54, 38.24),      --  8175 Postal
        [17] = vector3(-352.41, -528.24, 25.33),      --  8021 Postal
        [18] = vector3(797.83, 20.93, 64.44),         --  7285 Postal
        [19] = vector3(-1121.12, -630.79, 13.17),     --  7263 Postal
        [20] = vector3(-1781.14, 74.81, 69.48),       --  7039 Postal
        [21] = vector3(-848.97, -2583.63, 13.80),     --  10009 Postal
        [22] = vector3(840.20, -1636.99, 30.56),      --  9236 Postal
        [23] = vector3(-1057.96, -746.88, 19.22),     --  8089 Postal
        [24] = vector3(-1066.86, 267.73, 63.93),      --  6203 Postal
        [25] = vector3(-2723.19, 2276.86, 19.60),     --  5011 Postal
        [26] = vector3(224.64, 2971.53, 42.70),       --  4013 Postal
        [27] = vector3(-1066.86, 267.73, 63.93),      --  6203 Postal
        [28] = vector3(1384.65, 3573.27, 34.89),      --  3026 Postal
        [29] = vector3(2461.99, 4321.02, 36.62),      --  2046 Postal
        [30] = vector3(1333.30, 6508.02, 19.77),      --  1003 Postal
        [31] = vector3(-191.31, 6440.66, 31.17),      --  1053 Postal
        [32] = vector3(-698.73, 1751.18, 204.39),     
        [33] = vector3(-1366.02, 2151.64, 51.84),     
        [34] = vector3(-2510.62, 3595.04, 14.49),     
        [35] = vector3(-2354.16, 4094.42, 33.47),     
        [36] = vector3(-767.83, 5543.92, 33.49),      
        [37] = vector3(-443.84, 6110.14, 31.10),      
        [38] = vector3(153.96, 6426.62, 31.30),       
        [39] = vector3(136.65, 6626.83, 31.65),       
        [40] = vector3(-2078.89, 3295.33, 32.81),     
    },        
    PedChanceToFleeFromPlayer = 25,     -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 75,       -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 10,          -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 70,      -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 10000, -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 15000, -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "attack", -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_pistol",
        "weapon_minismg",
        "weapon_smg",
        "weapon_assaultrifle",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)

        local copTeamPeds = {}
        local suspectPeds = {}
        local plyGroupHash = GetPedRelationshipGroupHash(plyPed)
        local copPedModels = Config.randomCops
        local retval, suspectGroupHash = AddRelationshipGroup("SUSPECT_GROUP_HASH")

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                ClearPedTasks(ped)
    
                local foundAsCop = false
                for k, v in pairs(copPedModels) do
                    local targetHash = GetHashKey(v)
                    local modelHash = GetEntityModel(ped)
                    --print("Comparing target hash "..targetHash.." to model hash "..modelHash)
                    if targetHash == modelHash then
                        table.insert(copTeamPeds, pedNetId)
                        if Config.Debug then
                            print("Inserted ped "..ped.." as part of team cops.")
                        end
                        ERS_PedEquipWeapon(ped, "weapon_combatpistol", 150)
                        SetPedRelationshipGroupHash(ped, plyGroupHash)
                        SetPedAsCop(ped, true)
                        foundAsCop = true
                        break
                    end
                end



                if not foundAsCop then
                    table.insert(suspectPeds, pedNetId)
                    SetPedRelationshipGroupHash(ped, suspectGroupHash)
                    SetEntityCanBeDamagedByRelationshipGroup(ped, false, suspectGroupHash)
                    SetRelationshipBetweenGroups(5, suspectGroupHash, plyGroupHash)
                    SetRelationshipBetweenGroups(5, plyGroupHash, suspectGroupHash)

                    ERS_SpawnConfiguredWeaponForPed(ped, calloutDataClient)
                end
    
                TaskSetBlockingOfNonTemporaryEvents(ped, true)
    
                Wait(100)
            end
        end

        if #copTeamPeds > 0 and #suspectPeds > 0 then
            for index, pedNetId in pairs(copTeamPeds) do
                local ped = NetToPed(pedNetId)
                local targetPed = NetToPed(suspectPeds[math.random(#suspectPeds)])
                SetPedRelationshipGroupHash(ped, plyGroupHash)
                TaskCombatPed(ped, targetPed, 0, 16)
            end
            for index, pedNetId in pairs(suspectPeds) do
                local ped = NetToPed(pedNetId)
                local targetPed = NetToPed(copTeamPeds[math.random(#copTeamPeds)])
                SetPedRelationshipGroupHash(ped, suspectGroupHash)
                TaskCombatPed(ped, targetPed, 0, 16)
            end
        else
            CancelCallout()
            return
        end

        ERS_CreateTemporaryBlipForEntities(vehicleList, 15000)
        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, suspectPeds) -- test this netid adjustment.

    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)
        local diameter = 20
        local coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)

        -- Build cop vehicle
        local vehModel = ERS_GetRandomModel(Config.randomPoliceVehicles)
        local vehType = "automobile"
        local vehCoords = vector3(coords.x, coords.y, coords.z)
        local vehHeading = math.random(360)
        local vehNetId = ERS_CreateVehicle(vehModel, vehType, vehCoords, vehHeading)
        local vehicle = NetworkGetEntityFromNetworkId(vehNetId)
        table.insert(vehicleList, vehNetId)

        -- Build cop peds of different types
        local randomCops = math.random(2)
        local seatIndex = -1
        for i = 1, randomCops do
            local pedModel = ERS_GetRandomModel(Config.randomCops)
            local pedCoords = vector3(coords.x, coords.y, coords.z)
            local pedHeading = math.random(360)
            local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
            local ped = NetworkGetEntityFromNetworkId(pedNetId)
            SetPedIntoVehicle(ped, vehicle, seatIndex)
            seatIndex = seatIndex + 1
            table.insert(pedList, pedNetId)
        end

        -- Build suspect vehicle
        coords = ERS_GetRandomCoordinateWithinRangeOfCoordinate(calloutData.Coordinates, diameter)
        local suspectVehModel = ERS_GetRandomModel(Config.randomVehicles)
        local suspectVehType = "automobile"
        local suspectVehCoords = vector3(coords.x, coords.y, coords.z)
        local suspectVehHeading = math.random(360)
        local suspectVehNetId = ERS_CreateVehicle(suspectVehModel, suspectVehType, suspectVehCoords, suspectVehHeading)
        local suspectVehicle = NetworkGetEntityFromNetworkId(suspectVehNetId)
        table.insert(vehicleList, suspectVehNetId)

        -- Build suspect ped(s)
        seatIndex = -1
        local randomAmountOfSuspects = math.random(4)
        for i = 1, randomAmountOfSuspects do
            local suspectPedModel = ERS_GetRandomModel(Config.randomPeds)
            local suspectPedCoords = vector3(coords.x, coords.y, coords.z)
            local suspectPedHeading = math.random(360)
            local suspectPedNetId = ERS_CreatePed(suspectPedModel, suspectPedCoords, suspectPedHeading)
            local suspectPed = NetworkGetEntityFromNetworkId(suspectPedNetId)
            SetPedIntoVehicle(suspectPed, suspectVehicle, seatIndex)
            seatIndex = seatIndex + 1
            table.insert(pedList, suspectPedNetId)
        end

        return true
    end
}