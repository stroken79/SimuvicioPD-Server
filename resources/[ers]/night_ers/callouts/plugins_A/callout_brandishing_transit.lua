Config.Callouts["brandishing_transit"] = {

    Enabled = true,
    Priority = 1,
    CalloutName = "Person brandishing a weapon in public transportation",
    CalloutDescriptions = {
        "Emergency: respond immediately to reports of a person wielding a weapon on public transport; ensure the safety of passengers.",
        "Urgent alert: dispatch units to the scene where a weapon has been reported; neutralize the threat and protect civilians.",
        "Critical response: attend to an incident involving a weapon on public transportation; prioritize disarming the suspect.",
        "Immediate action: investigate reports of an armed individual on a bus or train; secure the area and ensure public safety.",
        "Alert: respond to a situation involving a weapon on public transport; take necessary measures to de-escalate and protect passengers.",
        "Incident reported: handle reports of a weapon-wielding person on public transportation; coordinate with relevant authorities to manage the threat.",
        "Situation alert: assist in disarming an individual brandishing a weapon on public transport; ensure the safety of all onboard.",
        "Emergency response: deal with a person brandishing a weapon on a bus or train; follow protocols to secure the scene and protect lives.",
        "Immediate intervention: respond to reports of an armed suspect on public transportation; prioritize de-escalation and passenger safety.",
        "Response needed: investigate an incident involving a weapon on public transport; take appropriate actions to neutralize the threat and safeguard the public.",
    },                                                                           
    CalloutUnitsRequired = {
        description = "Police.",
        policeRequired = true,
        ambulanceRequired = false,
        fireRequired = false,
        towRequired = false,
    },
    CalloutLocations = {
        [1] = vector3(-531.02, -1280.64, 26.05),
        [2] = vector3(-823.61, -111.83, 27.96),
        [3] = vector3(-286.70, -332.71, 18.29),
        [4] = vector3(-1368.22, -527.83, 30.33),
        [5] = vector3(-491.25, -719.88, 23.90),
        [6] = vector3(-212.88, -1028.95, 30.14),
        [7] = vector3(131.76, -1739.58, 30.11),
        [8] = vector3(-1038.86, -2740.55, 13.35),
        [9] = vector3(2663.66, 3928.24, 42.34),
        [10] = vector3(2700.45, 3083.12, 42.76),
        [11] = vector3(2632.89, 2946.15, 40.42),
        [12] = vector3(2851.14, 3440.11, 50.92),
        [13] = vector3(2453.31, 3854.30, 38.94),
        [14] = vector3(2271.27, 3757.01, 38.42),
        [15] = vector3(1820.61, 3507.98, 38.32),
        [16] = vector3(1693.80, 3461.85, 37.02),
        [17] = vector3(1184.28, 3267.64, 39.20),
        [18] = vector3(-3040.17, 3745.06, 70.20),
        [19] = vector3(-4050.71, 5335.75, 83.14),
        [20] = vector3(-4043.33, 5599.94, 68.38),
        [21] = vector3(2874.65, 4868.66, 62.60),
        [22] = vector3(3000.50, 4099.68, 57.18),
        [23] = vector3(-92.55, 6150.44, 31.80)
    },                      
    PedChanceToFleeFromPlayer = 25,      -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToAttackPlayer = 50,        -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToSurrender = 10,           -- Value between 0 and 100 -> Lower is less chance.
    PedChanceToObtainWeapons = 100,      -- Value between 0 and 100 -> Lower is less chance.
    PedActionMinimumTimeoutInMs = 15000, -- Milliseconds for the minimum timeout time to start the secondary action listed above.
    PedActionMaximumTimeoutInMs = 30000, -- Milliseconds for the maximum timeout time to start the secondary action. Must be a higher number than the minimum!
    PedActionOnNoActionFound = "attack", -- When no action of the above options is found. It'll perform this action after the set timeout. Options: "none", "attack", "flee", "surrender"
    PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) from these weapons if PedChanceToObtainWeapons passed.
        "weapon_knife",
        "weapon_bat",
        "weapon_hammer",
        "weapon_wrench",
        "weapon_pistol",
        "weapon_microsmg",
    },

    client = function(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient)

        for index, pedNetId in pairs(pedList) do
            local ped = NetToPed(pedNetId)
            if DoesEntityExist(ped) then
                ERS_RequestNetControlForEntity(ped) 
                ERS_SpawnConfiguredWeaponForPed(ped, calloutDataClient)
                TaskWanderStandard(ped, 10.0, 10)
            end
        end

        ERS_CreateTemporaryBlipForEntities(pedList, 15000)

        ERS_PerformTimedActionOnPed(calloutDataClient, pedList)
    
    end,
    server = function(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList)

        -- Build suspect
        local pedModel = ERS_GetRandomModel(Config.randomPeds)
        local pedCoords = vector3(calloutData.Coordinates.x, calloutData.Coordinates.y, calloutData.Coordinates.z)
        local pedHeading = math.random(360)
        local pedNetId = ERS_CreatePed(pedModel, pedCoords, pedHeading)
        local ped = NetworkGetEntityFromNetworkId(pedNetId)
        table.insert(pedList, pedNetId)

        return true
    end
}