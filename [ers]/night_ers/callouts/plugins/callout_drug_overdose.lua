Config.Callouts["drug_overdose"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Drug overdose",
    CalloutDescriptions = {
        "Individual found with signs of a drug overdose; paramedics needed urgently.",
        "Witness reports a person exhibiting overdose symptoms; immediate help required.",
        "Emergency alert: suspected drug overdose at the scene; quick medical response needed.",
        "Authorities called for a potential overdose victim; additional medical teams requested.",
        "Person down from an apparent overdose; urgent response from emergency services needed.",
        "Immediate assistance required for an overdose case; signs of severe reaction noted.",
        "Critical overdose situation reported; emergency medical support essential.",
        "Urgent medical help requested for an individual suspected of overdosing on drugs.",
        "Call received about a drug overdose; person in critical condition, need paramedics now.",
        "Medical emergency: suspected overdose; life-saving intervention needed immediately.",
    },                     
    CalloutUnitsRequired = {
        description = "Police, Ambulance.",
        policeRequired = true,
        ambulanceRequired = true,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(-1321.16, -585.79, 28.8),         -- Marathon Avenue, Del Perro
        [2] = vector3(-1249.80, -1540.82, 3.97),        -- Goma Street, Vespucci Beach
        [3] = vector3(520.26, -530.31, 24.49),          -- Del Perro Fwy, La Messa
        [4] = vector3(-619.21, 206.26, 73.84),          -- Strawberry Avenue, West Vinewood
        [5] = vector3(1624.92, 3784.92, 34.37),         -- Cholla Springs, Sandy Shores
        [6] = vector3(1445.61, 3759.23, 31.42),         -- Marina Drive, Sandy Shores 
        [7] = vector3(897.10, 3610.56, 32.50),          -- Marina Drive, Almo Sea
        [8] = vector3(339.63, 3568.78, 33.12),          -- Marina Drive, Zancudo River
        [9] = vector3(1637.30, -4856.22, 41.82),        -- Grapeseed Main Street, Grapeseed 
        [10] = vector3(104.11, 6633.31, 30.99),         -- Paleto Boulevard, Paleto Bay
        [11] = vector3(-177.90, 6427.10, 30.19),        -- Procopio Drive, Paleto Bay
        [12] = vector3(-365.73, 6063.14, 31.18),        -- Duluoz Avenue, Paleto Bay
        [13] = vector3(193.02, 6373.75, 31.38),         -- Great Ocean Highway, Mount Chilliad
        [14] = vector3(-678.70, 5797.49, 17.01),        -- North Bound Procopio Promenade, Paleto Bay
        [15] = vector3(-3422.26, 967.87, 8.02),         -- Eastbound Barbareno road, Chumash
        [16] = vector3(-3067.34, 420.56, 6.10),        -- Eastbound Ineseno Road, Banham Canyon
        [17] = vector3(-2047.95, -129.75, 28.49),       -- Eastbound West Eclipse Boulevard, Pacific Buffs 
        [18] = vector3(-2332.37, 264.49, 169.28),       -- Kortz Drive, Pacific Bluffs
        [19] = vector3(2663.66, 3928.24, 42.34),
        [20] = vector3(2700.45, 3083.12, 42.76), 
        [21] = vector3(2632.89, 2946.15, 40.42), 
        [22] = vector3(2851.14, 3440.11, 50.92), 
        [23] = vector3(2453.31, 3854.3, 38.94), 
        [24] = vector3(2271.27, 3757.01, 38.42), 
        [25] = vector3(1820.61, 3507.98, 38.32), 
        [26] = vector3(1693.8, 3461.85, 37.02), 
        [27] = vector3(1184.28, 3267.64, 39.2), 
        [28] = vector3(-3040.17, 3745.06, 70.2), 
        [29] = vector3(-4050.71, 5335.75, 83.14), 
        [30] = vector3(-4043.33, 5599.94, 68.38),
        [31] = vector3(2874.65, 4868.66, 62.6), 
        [32] = vector3(3000.5, 4099.68, 57.18), 
        [33] = vector3(-92.55, 6150.44, 31.8),
        [34] = vector3(-109.52, 6465.71, 31.63),
        [35] = vector3(63.26, 6560.11, 29.33),
        [36] = vector3(1985.06, 3774.55, 32.18),
        [37] = vector3(2432.03, 4022.39, 36.88),
        [38] = vector3(2455.81, 4978.84, 46.81),
        [39] = vector3(3316.37, 5167.69, 18.41),
        [40] = vector3(446.51, 5572.15, 781.19),
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
            local deadPed
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 

                if index == 1 then
                    SetEntityHealth(ped, 0)
                    TaskSetBlockingOfNonTemporaryEvents(ped, true)
                    deadPed = ped
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

        local diameter = 6 

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