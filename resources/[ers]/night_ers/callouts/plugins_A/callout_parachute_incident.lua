Config.Callouts["parachute_incident"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Incident with a parachutist",
    CalloutDescriptions = {
        "Respond immediately to a report of a parachutist in distress; secure the area and provide necessary assistance.",
        "Emergency alert: parachutist in trouble; deploy units to manage the situation and ensure their safety.",
        "Urgent response required: parachutist has encountered an issue; focus on rescue operations and medical aid.",
        "Critical situation: parachutist in distress; act swiftly to provide help and secure the scene.",
        "Alert: parachutist emergency reported; immediate intervention needed to assist the individual and ensure safety.",
        "Parachutist incident: urgent action required to secure the area and provide aid to the affected person.",
        "Handle a parachutist emergency; prioritize rescue efforts and coordinate with emergency teams.",
        "Emergency situation: parachutist in trouble; ensure the area is safe and assist in the rescue operation.",
        "Urgent alert: parachutist distress call; respond quickly to manage the scene and provide necessary support.",
        "Critical response needed: parachutist incident; secure the area, assist the individual, and ensure their safety.",
    },                   
    CalloutUnitsRequired = {
        description = "Ambulance.",
        policeRequired = false,
        ambulanceRequired = true,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(952.2233, -587.2217, 58.2773), -- chute hangs about 3.5 above in an object.
        [2] = vector3(892.8412, -644.2815, 58.5624), 
        [3] = vector3(-1689.7689, -738.7968, 10.1216),
        [4] = vector3(-1665.2777, -963.7534, 7.7066),
        [5] = vector3(-1341.0793, -1471.0431, 4.5780),
        [6] = vector3(-622.7783, -1535.9728, 14.3249),
        [7] = vector3(-769.7225, -1698.9756, 29.3284),
        [8] = vector3(-962.4874, -1945.5409, 13.1916),
        [9] = vector3(-302.1057, -1197.8782, 37.1781),
        [10] = vector3(-1813.5688, -491.2219, 41.1071),
        [11] = vector3(-3072.2017, 209.4451, 12.2777),
        [12] = vector3(-3113.3748, 705.1713, 7.3118),
        [13] = vector3(-3063.7551, 1781.3798, 34.1570),
        [14] = vector3(-2527.3540, 3573.0752, 14.5031),
        [15] = vector3(-1978.0129, 4550.1206, 41.6057),
        [16] = vector3(-1683.3534, 4875.0195, 51.7314),
        [17] = vector3(-1215.4250, 5341.8916, 15.8113),
        [18] = vector3(-248.8048, 6599.2861, 2.1546),
        [19] = vector3(77.6183, 7106.6396, 21.5626),
        [20] = vector3(687.1104, 6019.8105, 379.7889),
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

        for index, objNetId in pairs(objectList) do
            local obj = NetToObj(objNetId)
            if DoesEntityExist(obj) then
                ERS_RequestNetControlForEntity(obj) 
                PlaceObjectOnGroundProperly(obj)
            end
        end

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped)
                ERS_GivePedParachute(ped)

                local pedCoords = GetEntityCoords(ped)
                local chanceToSurvive = math.random(100)            

                ERS_SetMovementAnimClipSetToPed(ped, "move_m@injured")

                if chanceToSurvive > 20 then
                    -- Dead
                    SetEntityHealth(ped, 0)
                    TaskSetBlockingOfNonTemporaryEvents(ped, true)
                    ERS_ApplyBloodToPed(ped)
                    SetPedKeepTask(ped, true)
                else
                    -- Alive
                    TaskSetBlockingOfNonTemporaryEvents(ped, true)
                    ERS_SpawnConfiguredWeaponForPed(ped, calloutDataClient)
                    if IsPedInAnyVehicle(ped, false) then
                        TaskLeaveAnyVehicle(ped)
                        Wait(500)
                    end
                    TaskSetBlockingOfNonTemporaryEvents(ped, true)
                    SetPedKeepTask(ped, true)

                    ERS_ApplyBloodToPed(ped)
                    local scenario = ERS_SelectRandomWoundedPersonScenario()
                    TaskStartScenarioInPlace(ped, scenario, 0, true)
                end
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        -- ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        -- Build ped
        local pedModel = ERS_GetRandomModel(Config.randomPeds)
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        table.insert(pedList, pedNetId)

        -- Build object
        local objModel = ERS_GetRandomModel(Config.parachuteObjects)
        local objCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local objHeading = math.random(360)
        local objNetId = ERS_CreateObject(objModel, objCoords, objHeading)
        if objNetId then    
            local obj = NetworkGetEntityFromNetworkId(objNetId)
            table.insert(objectList, objNetId)
        else
            DebugPrint("^1ERROR ^7Could not create object: "..objModel)
        end
   
        return true
    end
}