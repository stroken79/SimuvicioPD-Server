Config = Config or {}

--=============== PURSUIT SETTINGS =================--

Config.PursuitModeEnabled = true
Config.EnablePursuitModeUI = true -- Displays a UI when in pursuit mode. (Indicates when backup is available)
Config.EnablePursuitHotkeyHints = true -- Displays hotkey hints in the chatbox.
Config.PursuitMaxDistance = 400.0 -- Max distance for pursuit to continue (Limited to 400.0)
Config.PursuitDrivingStyle = 786944 -- Driving style for the vehicle being pursued.

-- Pursuit zoom camera + marker [Set the hotkey in config.lua OR ESC -> Keybinds in-game]
Config.ZoomOnPursuitStart = false -- Enables or disables initially zooming in when a pursuit is started.
Config.PursuitZoomDuration = 2000 -- 2 seconds
Config.PursuitZoomInitialDistance = 30.0  -- Camera will start at this distance
Config.PursuitZoomFinalDistance = 10.0 -- Camera will zoom in to this distance
Config.PursuitZoomHeight = 5.0 -- Camera height
Config.DeletePursuitBackupWhenOutOfRange = false -- false = spawn units closer to the player if they are out of range | true = delete all units if only one is out of range
Config.EnableHelicopterSearchLight = true -- Draws a sphere of light around the chased target entity and a searchlight for the area. (more resmon usage)

-- Map blip on the chased suspect (follows vehicle while they drive, ped while on foot). Pullover traffic-stop blip is removed when pursuit starts.
Config.EnablePursuitSuspectBlip = true
Config.PursuitSuspectBlipData = {
    Sprite = 458,
    Category = 2,
    Display = 4,
    Scale = 0.9,
    Colour = 1,
    ShortRange = false,
    Flashes = false,
    Cone = false,
}

Config.EnablePursuitZoomMarker = true
Config.PursuitMarkerData = {
    MarkerId = 21 --[[ integer ]], 
    dirX = 0 --[[ number ]], 
    dirY = 0 --[[ number ]], 
    dirZ = 0 --[[ number ]], 
    rotX = 0 --[[ number ]], 
    rotY = 180.0 --[[ number ]], 
    rotZ = 0 --[[ number ]], 
    scaleX = 2.5 --[[ number ]], 
    scaleY = 2.5 --[[ number ]], 
    scaleZ = 2.5 --[[ number ]], 
    red = 255 --[[ integer ]], 
    green = 0 --[[ integer ]], 
    blue = 0 --[[ integer ]], 
    alpha = 100 --[[ integer ]], 
    bobUpAndDown = true --[[ boolean ]], 
    faceCamera = true --[[ boolean ]], 
    p19 = 0 --[[ integer ]], 
    rotate = false --[[ boolean ]], 
    textureDict = 0 --[[ string ]], 
    textureName = 0 --[[ string ]], 
    drawOnEnts = 0 --[[ boolean ]]
}

Config.EnablePursuitBackupRadialMenu = true
Config.PursuitBackupTypes = {
    -- IMPORTANT: You can edit existing backup types. But do not add or remove ones.
    [1] = {
        PursuitBackupName = "Solicitud de refuerzos ligeros",
        PursuitBackupDescription = "Solicitar refuerzos ligeros hara que la central envie varias unidades motorizadas para ayudar en la persecucion del vehiculo.",
        PursuitType = "light", -- do not change
        PursuitVehicles = {"policeb"}, -- Will randomly select one of these vehicles per amount of units.
        PursuitVehicleType = 'bike', -- Make sure all the vehicles in PursuitVehicles are of this type. https://docs.fivem.net/natives/?_0xA273060E
        PursuitChaseFlag = 32, -- https://docs.fivem.net/natives/?_0xCC665AAC360D31E7
        AmountOfUnits = 2,
        PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) once on foot.
            "weapon_stungun",
        },
        ChanceForPursuitTargetToBeArmed = 5, -- Chance is 5% for the pursued target to be armed in a response to a light backup request.
        PursuitTargetWeaponData = { -- The pursued target will be given one randomly selected weapon (in hand) once on foot.
            "weapon_knife",
            "weapon_pistol",
        },
        BlipData = { -- https://docs.fivem.net/docs/game-references/blips/
            Enabled = true,
            Sprite = 42,
            Category = 2,
            Display = 4,
            Scale = 0.8,
            Colour = 0,
            ShortRange = true,
            Flashes = false,
            Cone = true
        },
        PedData = { -- Contains 2 examples, last one (index [2]) is an MP ped example. Remove it if you don't want to use MP peds.
            [1] = {
                -- Use vMenu to fetch these numbers via Player Appearance. If model is not an MP ped it will not apply any props or components.
                modelName = "s_m_y_hwaycop_01", -- This is not an MP ped model
                props = {},         -- No props needed for non-mp peds.
                components = {},    -- No components needed for non-mp peds.
            },
            -- [2] = {
            --     -- Use vMenu to fetch these numbers via Player Appearance. If model is not an MP ped it will not apply any props or components.
            --     modelName = "mp_m_freemode_01", -- This is an MP ped model
            --     props = {
            --         -- Example: {prop type (Helmet), prop type index (Motorcycle helmet), prop colour index (Black colour)}
            --         { 0, 9, 1 },    -- Hats / Helments
            --         { 1, 0, 0 },    -- Glassess
            --         { 2, 0, 0 },    -- Misc
            --         { 3, 0, 0 },
            --     },
            --     components = {
            --         -- Example: {component type (Mask), component type index (Clown Mask), component colour index (White colour)}
            --         { 1, 122, 1 },  -- Mask
            --         { 3, 201, 1 },  -- Upper body
            --         { 4, 18, 1 },   -- Legs / Pants
            --         { 5, 1, 1 },    -- Bags / Parachutes
            --         { 6, 26, 1 },   -- Shoes
            --         { 7, 4, 1 },    -- Neck / Scarfs
            --         { 8, 16, 1 },   -- Shirt / Accessory
            --         { 9, 2, 1 },    -- Body Armor
            --         { 10, 2, 1 },   -- Badges / Logos
            --         { 11, 26, 1 },  -- Jackets
            --     },
            -- },
            -- Add more peds here. Don't forget about defining the correct next index number: [3]
        },
        VehicleData = { -- Contains 2 examples.
            [1] = {
                modelName = "policeb", 
                extraIds = {1, 2, 3, 4, 5, 10, 15, 20}, -- Extra's which are turned ON by default.
                liveryId = -1, 
                vehicleColours = { primary = -1, secondary = -1, pearlescent = -1, wheel = -1}, 
                windowTintId = -1, -- 0 to 6 where 0 is no window tint. -1 does nothing which is also fine.
                dirtLevel = 0.0    -- 0.0 to 15.0 where 15.0 is very dirty.
            },
        },
    },
    [2] = {
        PursuitBackupName = "Solicitud de refuerzos medios",
PursuitBackupDescription = "Solicitar refuerzos medios hara que la central envie varias unidades de patrulla para ayudar en la persecucion del vehiculo.",
        PursuitType = "medium", -- do not change
        PursuitVehicles = {"sheriff", "sheriff2"}, --"police3", "sheriff2", "police", "policet", "fbi", "fbi2"
        PursuitVehicleType = 'automobile', -- Make sure all the vehicles in PursuitVehicles are of this type. https://docs.fivem.net/natives/?_0xA273060E
        PursuitChaseFlag = 8, -- https://docs.fivem.net/natives/?_0xCC665AAC360D31E7
        AmountOfUnits = 3,
        PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) once on foot.
            "weapon_pistol",
        },
        ChanceForPursuitTargetToBeArmed = 15, -- Chance is 15% for the pursued target to be armed in a response to a medium backup request.
        PursuitTargetWeaponData = { -- The pursued target will be given one randomly selected weapon (in hand) once on foot.
            "weapon_knife",
            "weapon_pistol",
            "weapon_microsmg",
        },
        BlipData = {
            Enabled = true,
            Sprite = 42,
            Category = 2,
            Display = 4,
            Scale = 0.8,
            Colour = 0,
            ShortRange = true,
            Flashes = false,
            Cone = true
        },
        PedData = { -- Contains 4 examples, last one (index [4]) is an MP ped example. Remove it if you don't want to use MP peds.
            [1] = {
                -- Use vMenu to fetch these numbers via Player Appearance. If model is not an MP ped it will not apply any props or components.
                modelName = "s_f_y_cop_01", -- This is not an MP ped model
                props = {},         -- No props needed for non-mp peds.
                components = {},    -- No components needed for non-mp peds.
            },
            [2] = {
                -- Use vMenu to fetch these numbers via Player Appearance. If model is not an MP ped it will not apply any props or components.
                modelName = "s_m_y_cop_01",
                props = {},         -- No props needed for non-mp peds.
                components = {},    -- No components needed for non-mp peds.
            },
            -- [3] = {
            --     -- Use vMenu to fetch these numbers via Player Appearance. If model is not an MP ped it will not apply any props or components.
            --     modelName = "csb_cop",
            --     props = {},         -- No props needed for non-mp peds.
            --     components = {},    -- No components needed for non-mp peds.
            -- },
            -- [4] = {
            --     -- Use vMenu to fetch these numbers via Player Appearance. If model is not an MP ped it will not apply any props or components.
            --     modelName = "mp_m_freemode_01", -- This is an MP ped model
            --     props = {
            --         -- Example: {prop type (Helmet), prop type index (Motorcycle helmet), prop colour index (Black colour)}
            --         { 0, 9, 1 },    -- Hats / Helments
            --         { 1, 0, 0 },    -- Glassess
            --         { 2, 0, 0 },    -- Misc
            --         { 3, 0, 0 },
            --     },
            --     components = {
            --         -- Example: {component type (Mask), component type index (Clown Mask), component colour index (White colour)}
            --         { 1, 122, 1 },  -- Mask
            --         { 3, 201, 1 },  -- Upper body
            --         { 4, 18, 1 },   -- Legs / Pants
            --         { 5, 1, 1 },    -- Bags / Parachutes
            --         { 6, 26, 1 },   -- Shoes
            --         { 7, 4, 1 },    -- Neck / Scarfs
            --         { 8, 16, 1 },   -- Shirt / Accessory
            --         { 9, 2, 1 },    -- Body Armor
            --         { 10, 2, 1 },   -- Badges / Logos
            --         { 11, 26, 1 },  -- Jackets
            --     },
            -- },
            -- Add more peds here. Don't forget about defining the correct next index number: [5]
        },
        VehicleData = { -- Contains 2 examples.
            [1] = {
                modelName = "sheriff", 
                extraIds = {1, 2, 3, 4, 5, 10, 15, 20}, -- Extra's which are turned ON by default.
                liveryId = -1, 
                vehicleColours = { primary = -1, secondary = -1, pearlescent = -1, wheel = -1}, 
                windowTintId = -1, -- 0 to 6 where 0 is no window tint. -1 does nothing which is also fine.
                dirtLevel = 0.0    -- 0.0 to 15.0 where 15.0 is very dirty.
            },
            [2] = {
                modelName = "sheriff2", 
                extraIds = {1, 2, 3, 4, 5, 10, 15, 20}, -- Extra's which are turned ON by default.
                liveryId = -1, 
                vehicleColours = { primary = -1, secondary = -1, pearlescent = -1, wheel = -1}, 
                windowTintId = -1, -- 0 to 6 where 0 is no window tint. -1 does nothing which is also fine.
                dirtLevel = 0.0    -- 0.0 to 15.0 where 15.0 is very dirty.
            },
            -- Add more here.
        },
    },
    [3] = {
        PursuitBackupName = "Solicitud de refuerzos pesados",
PursuitBackupDescription = "Solicitar refuerzos pesados hara que la central envie varias unidades armadas para ayudar en la persecucion del vehiculo.",
        PursuitType = "heavy", -- do not change
        PursuitVehicles = {"riot", "riot2"},
        PursuitVehicleType = 'automobile', -- Make sure all the vehicles in PursuitVehicles are of this type. https://docs.fivem.net/natives/?_0xA273060E
        PursuitChaseFlag = 2, -- https://docs.fivem.net/natives/?_0xCC665AAC360D31E7
        AmountOfUnits = 4,
        PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) once on foot.
            "weapon_carbinerifle",
        },
        ChanceForPursuitTargetToBeArmed = 30, -- Chance is 30% for the pursued target to be armed in a response to a heavy backup request.
        PursuitTargetWeaponData = { -- The pursued target will be given one randomly selected weapon (in hand) once on foot.
            "weapon_assaultrifle",
        },
        BlipData = {
            Enabled = true,
            Sprite = 42,
            Category = 2,
            Display = 4,
            Scale = 0.8,
            Colour = 0,
            ShortRange = true,
            Flashes = false,
            Cone = true
        },
        PedData = {
            [1] = {
                -- Use vMenu to fetch these numbers via Player Appearance. If model is not an MP ped it will not apply any props or components.
                modelName = "s_m_y_swat_01", -- This is not an MP ped model
                props = {},         -- No props needed for non-mp peds.
                components = {},    -- No components needed for non-mp peds.
            },
        },
        VehicleData = { -- Contains 2 examples.
            [1] = {
                modelName = "riot", 
                extraIds = {1, 2, 3, 4, 5, 10, 15, 20}, -- Extra's which are turned ON by default.
                liveryId = -1, 
                vehicleColours = { primary = -1, secondary = -1, pearlescent = -1, wheel = -1}, 
                windowTintId = -1, -- 0 to 6 where 0 is no window tint. -1 does nothing which is also fine.
                dirtLevel = 0.0    -- 0.0 to 15.0 where 15.0 is very dirty.
            },
            [2] = {
                modelName = "riot2", 
                extraIds = {1, 2, 3, 4, 5, 10, 15, 20}, -- Extra's which are turned ON by default.
                liveryId = -1, 
                vehicleColours = { primary = -1, secondary = -1, pearlescent = -1, wheel = -1}, 
                windowTintId = -1, -- 0 to 6 where 0 is no window tint. -1 does nothing which is also fine.
                dirtLevel = 0.0    -- 0.0 to 15.0 where 15.0 is very dirty.
            },
            -- Add more here.
        },
    },
    [4] = {
        PursuitBackupName = "Solicitud de apoyo aereo",
PursuitBackupDescription = "Solicitar apoyo aereo hara que la central envie unidades de helicopteros del condado (NPC) para ayudar en la persecucion del vehiculo.",
        PursuitType = "air", -- do not change
        PursuitVehicles = {"polmav"},
        PursuitVehicleType = 'heli', -- Make sure all the vehicles in PursuitVehicles are of this type. https://docs.fivem.net/natives/?_0xA273060E
        PursuitChaseFlag = 0, -- Irrelevant for air units
        AmountOfUnits = 1,
        PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) once on foot.
            "weapon_combatpistol",
        },
        ChanceForPursuitTargetToBeArmed = 5, -- Chance is 5% for the pursued target to be armed in a response to a air backup request.
        PursuitTargetWeaponData = { -- The pursued target will be given one randomly selected weapon (in hand) once on foot.
            "weapon_knife",
            "weapon_pistol",
        },
        BlipData = {
            Enabled = true,
            Sprite = 15,
            Category = 2,
            Display = 4,
            Scale = 0.8,
            Colour = 0,
            ShortRange = true,
            Flashes = false,
            Cone = true
        },
        PedData = {
            [1] = {
                -- Use vMenu to fetch these numbers via Player Appearance. If model is not an MP ped it will not apply any props or components.
                modelName = "s_m_y_swat_01", -- This is not an MP ped model
                props = {},         -- No props needed for non-mp peds.
                components = {},    -- No components needed for non-mp peds.
            },
        },
        VehicleData = {
            [1] = {
                modelName = "polmav", 
                extraIds = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20}, -- Extra's which are turned ON by default, some are REQUIRED for custom helicopters to prevent them from crashing!
                liveryId = -1, 
                vehicleColours = { primary = -1, secondary = -1, pearlescent = -1, wheel = -1}, 
                windowTintId = -1, -- 0 to 6 where 0 is no window tint. -1 does nothing which is also fine.
                dirtLevel = 0.0    -- 0.0 to 15.0 where 15.0 is very dirty.
            },
            -- Add more here.
        },
    },
    [5] = {
        PursuitBackupName = "Solicitud de apoyo militar",
PursuitBackupDescription = "Solicitar apoyo militar hara que la central envie unidades del ejercito para ayudar en la persecucion del vehiculo.",
        PursuitType = "army", -- do not change
        PursuitVehicles = {"barracks", "crusader"},
        PursuitVehicleType = 'automobile', -- Make sure all the vehicles in PursuitVehicles are of this type. https://docs.fivem.net/natives/?_0xA273060E
        PursuitChaseFlag = 1, -- https://docs.fivem.net/natives/?_0xCC665AAC360D31E7
        AmountOfUnits = 4,
        PedWeaponData = { -- The ped will be given one randomly selected weapon (in hand) once on foot.
            "weapon_heavyrifle",
        },
        ChanceForPursuitTargetToBeArmed = 50, -- Chance is 50% for the pursued target to be armed in a response to a army backup request.
        PursuitTargetWeaponData = { -- The pursued target will be given one randomly selected weapon (in hand) once on foot.
            "weapon_assaultrifle",
        },
        BlipData = {
            Enabled = true,
            Sprite = 42,
            Category = 2,
            Display = 4,
            Scale = 0.8,
            Colour = 0,
            ShortRange = true,
            Flashes = false,
            Cone = true
        },
        PedData = {
            [1] = {
                -- Use vMenu to fetch these numbers via Player Appearance. If model is not an MP ped it will not apply any props or components.
                modelName = "s_m_y_blackops_01", -- This is not an MP ped model
                props = {},         -- No props needed for non-mp peds.
                components = {},    -- No components needed for non-mp peds.
            },
            [2] = {
                -- Use vMenu to fetch these numbers via Player Appearance. If model is not an MP ped it will not apply any props or components.
                modelName = "s_m_y_blackops_02", -- This is not an MP ped model
                props = {},         -- No props needed for non-mp peds.
                components = {},    -- No components needed for non-mp peds.
            },
            [3] = {
                -- Use vMenu to fetch these numbers via Player Appearance. If model is not an MP ped it will not apply any props or components.
                modelName = "s_m_y_blackops_03", -- This is not an MP ped model
                props = {},         -- No props needed for non-mp peds.
                components = {},    -- No components needed for non-mp peds.
            },
        },
        VehicleData = { -- Contains 2 examples.
            [1] = {
                modelName = "barracks", 
                extraIds = {1, 2, 3, 4, 5, 10, 15, 20}, -- Extra's which are turned ON by default.
                liveryId = -1, 
                vehicleColours = { primary = -1, secondary = -1, pearlescent = -1, wheel = -1}, 
                windowTintId = -1, -- 0 to 6 where 0 is no window tint. -1 does nothing which is also fine.
                dirtLevel = 0.0    -- 0.0 to 15.0 where 15.0 is very dirty.
            },
            [2] = {
                modelName = "crusader", 
                extraIds = {1, 2, 3, 4, 5, 10, 15, 20}, -- Extra's which are turned ON by default.
                liveryId = -1, 
                vehicleColours = { primary = -1, secondary = -1, pearlescent = -1, wheel = -1}, 
                windowTintId = -1, -- 0 to 6 where 0 is no window tint. -1 does nothing which is also fine.
                dirtLevel = 0.0    -- 0.0 to 15.0 where 15.0 is very dirty.
            },
            -- Add more here.
        },
    }
}