Config = Config or {}

--====================== EMERGENCY SERVICE UNIT REQUEST SETTINGS ======================--

Config.NPCBackupDrivingStyle = 2900796  -- (2900796 avoids vehicles, peds and objects. Drives through speedzones and red lights.) https://vespura.com/fivem/drivingstyle/ (Previously: 279356)
Config.NPCDrivingSpeed = 10.0           -- Seems like a proper speed. Not too fast, not too slow.
Config.NPCStoppingDistance = 40.0       -- The distance when the backup will stop when reaching the location.
Config.NPCMaxDistanceToDespawn = 280    -- The max distance for the backup to be able to drive before getting despawned
Config.NPCMaxDistanceWarning = 200      -- The distance when a warning should appear that the backup has problems reaching the location
Config.NPCTimeToForceTeleport = 60      -- The time in seconds after which the backup will be forced to teleport to a nearby position if it has not arrived at the callout location.

Config.NPCBackupRequestData = {
    Police = {
        BlipData = {
            SpriteId = 1,
            ColourId = 38,
            Flashes = true,
            Cone = true
        },
        VehicleData = { -- Contains 2 examples.
            [1] = {
                modelName = "policet", 
                extraIds = {1, 2, 3, 4, 5, 10, 15, 20}, -- Extra's which are turned ON by default.
                liveryId = -1, 
                vehicleColours = { primary = -1, secondary = -1, pearlescent = -1, wheel = -1}, 
                windowTintId = -1, -- 0 to 6 where 0 is no window tint. -1 does nothing which is also fine.
                dirtLevel = 0.0    -- 0.0 to 15.0 where 15.0 is very dirty.
            },
            [2] = {
                modelName = "police", 
                extraIds = {1, 2, 3, 4, 5, 10, 15, 20}, -- Extra's which are turned ON by default.
                liveryId = -1, 
                vehicleColours = { primary = -1, secondary = -1, pearlescent = -1, wheel = -1}, 
                windowTintId = -1, -- 0 to 6 where 0 is no window tint. -1 does nothing which is also fine.
                dirtLevel = 0.0    -- 0.0 to 15.0 where 15.0 is very dirty.
            },
            -- Add more here.
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
    },
    Ambulance = {
        BlipData = {
            SpriteId = 1,
            ColourId = 1,
            Flashes = true,
            Cone = true
        },
        VehicleData = {
            [1] = {
                modelName = "ambulance", 
                extraIds = {1, 2, 3, 4, 5, 10, 15, 20}, 
                liveryId = -1, 
                vehicleColours = { primary = -1, secondary = -1, pearlescent = -1, wheel = -1}, 
                windowTintId = -1, 
                dirtLevel = 0.0
            },
            -- Add more here. Don't forget about defining the correct next index number: [2]
        },
        PedData = {
            [1] = {
                -- Use vMenu to fetch these numbers via Player Appearance. If model is not an MP ped it will not apply any props or components.
                modelName = "s_m_m_paramedic_01", -- This is not an MP ped model
                props = {},         -- No props needed for non-mp peds.
                components = {},    -- No components needed for non-mp peds.
            },
            -- [2] = {
            --     -- Use vMenu to fetch these numbers via Player Appearance. If model is not an MP ped it will not apply any props or components.
            --     modelName = "mp_m_freemode_01", -- This is an MP ped model
            --     props = {
            --         -- Example: {prop type (Helmet), prop type index (Motorcycle helmet), prop colour index (Black colour)}
            --         { 0, 0, 0 },    -- Hats / Helments
            --         { 1, 0, 0 },    -- Glassess
            --         { 2, 0, 0 },    -- Misc
            --         { 3, 0, 0 },
            --     },
            --     components = {
            --         -- Example: {component type (Mask), component type index (Clown Mask), component colour index (White colour)}
            --         { 1, 122, 1 },  -- Mask
            --         { 2, 1, 1 },    -- Hair
            --         { 3, 86, 1 },  -- Upper body
            --         { 4, 21, 1 },   -- Legs / Pants
            --         { 5, 4, 1 },    -- Bags / Parachutes
            --         { 6, 26, 1 },   -- Shoes
            --         { 7, 6, 1 },    -- Neck / Scarfs
            --         { 8, 18, 1 },   -- Shirt / Accessory
            --         { 9, 1, 1 },    -- Body Armor
            --         { 10, 2, 1 },   -- Badges / Logos
            --         { 11, 24, 1 },  -- Jackets
            --     },
            -- },
            -- Add more peds here. Don't forget about defining the correct next index number: [3]
        },
    },
    Taxi = {
        BlipData = {
            SpriteId = 1,
            ColourId = 47,
            Flashes = true,
            Cone = true
        },
        VehicleData = {
            [1] = {
                modelName = "taxi", 
                extraIds = {1, 2, 3, 4, 5, 10, 15, 20}, 
                liveryId = -1, 
                vehicleColours = { primary = -1, secondary = -1, pearlescent = -1, wheel = -1}, 
                windowTintId = -1, 
                dirtLevel = 0.0
            },
            -- Add more here. Don't forget about defining the correct next index number: [2]
        },
        PedData = { 
            [1] = {
                modelName = "a_m_m_prolhost_01",
                props = {},
                components = {},
            },
            [2] = {
                modelName = "a_m_y_business_02",
                props = {},
                components = {},
            },
            [3] = {
                modelName = "a_m_y_business_03", 
                props = {},
                components = {},
            },
        },
    },
    Tow = {
        BlipData = {
            SpriteId = 1,
            ColourId = 76,
            Flashes = true,
            Cone = true
        },
        VehicleData = {
            [1] = {
                modelName = "flatbed", 
                extraIds = {1, 2, 3, 4, 5, 10, 15, 20}, 
                liveryId = 2, 
                vehicleColours = { primary = 3, secondary = 3, pearlescent = 22, wheel = 22}, 
                windowTintId = -1, 
                dirtLevel = 2.0,
                -- Additional offsets for towing vehicles.
                TowOffsetX = -0.5,      -- Vehicle position on the back of the flatbed relative to x 0.0 of model 'flatbed' (left-right)
                TowOffsetY = -5.0,      -- Vehicle position on the back of the flatbed relative to y 0.0 of model 'flatbed' 'flatbed' (forward-backward)
                TowOffsetZ = 0.4,       -- Vehicle position on the back of the flatbed relative to z 0.0 of model 'flatbed' 'flatbed' (up-down)
                TowRotOffsetX = 0.0,    -- Vehicle rotation position on the back of the flatbed relative to z 0.0 of model 'flatbed' 
                TowRotOffsetY = -0.5,   -- Vehicle rotation position on the back of the flatbed relative to y 0.0 of model 'flatbed' 
                TowRotOffsetZ = 0.0,    -- Vehicle rotation position on the back of the flatbed relative to z 0.0 of model 'flatbed' 
            },
            -- Add more here. Don't forget about defining the correct next index number: [2]
        },
        PedData = { 
            [1] = {
                modelName = "mp_m_waremech_01",
                props = {},
                components = {},
            },
            [2] = {
                modelName = "s_m_m_dockwork_01",
                props = {},
                components = {},
            },
            [3] = {
                modelName = "s_m_y_uscg_01",
                props = {},
                components = {},
            },
        },
    },
    RoadService = {
        BlipData = {
            SpriteId = 1,
            ColourId = 60,
            Flashes = true,
            Cone = true
        },
        VehicleData = {
            [1] = {
                modelName = "utillitruck3", 
                extraIds = {}, 
                liveryId = -1, 
                vehicleColours = { primary = -1, secondary = -1, pearlescent = -1, wheel = -1}, 
                windowTintId = -1, 
                dirtLevel = 10.0,
            },
            -- Add more here. Don't forget about defining the correct next index number: [2]
        },
        PedData = { 
            [1] = {
                modelName = "s_m_y_winclean_01",
                props = {},
                components = {},
            },
            [2] = {
                modelName = "csb_trafficwarden",
                props = {},
                components = {},
            },
            [3] = {
                modelName = "s_m_y_dwservice_01",
                props = {},
                components = {},
            },
            [4] = {
                modelName = "s_m_y_dwservice_02",
                props = {},
                components = {},
            },
        },
    },
    Coroner = {
        BlipData = {
            SpriteId = 1,
            ColourId = 85,
            Flashes = true,
            Cone = true
        },
        VehicleData = {
            [1] = {
                modelName = "speedo4", 
                extraIds = {}, 
                liveryId = -1, 
                vehicleColours = { primary = -1, secondary = -1, pearlescent = -1, wheel = -1}, 
                windowTintId = -1, 
                dirtLevel = 0.0,
            },
            -- Add more here. Don't forget about defining the correct next index number: [2]
        },
        PedData = { 
            [1] = {
                modelName = "s_m_m_doctor_01",
                props = {},
                components = {},
            },
        },
    },
    AnimalRescue = {
        BlipData = {
            SpriteId = 1,
            ColourId = 24,
            Flashes = true,
            Cone = true
        },
        VehicleData = {
            [1] = {
                modelName = "rumpo3", 
                extraIds = {}, 
                liveryId = -1, 
                vehicleColours = { primary = -1, secondary = -1, pearlescent = -1, wheel = -1}, 
                windowTintId = -1, 
                dirtLevel = 0.0,
            },
            -- Add more here. Don't forget about defining the correct next index number: [2]
        },
        PedData = { 
            [1] = {
                modelName = "s_m_y_pestcont_01",
                props = {},
                components = {},
            },
        },
    },
    Mechanic = {
        BlipData = {
            SpriteId = 1,
            ColourId = 62,
            Flashes = true,
            Cone = true
        },
        VehicleData = {
            [1] = {
                modelName = "burrito", 
                extraIds = {1, 12}, 
                liveryId = 1, 
                vehicleColours = { primary = -1, secondary = -1, pearlescent = -1, wheel = -1}, 
                windowTintId = -1, 
                dirtLevel = 0.0,
            },
        },
        PedData = { 
            [1] = {
                modelName = "s_m_m_autoshop_02",
                props = {},
                components = {},
            },
        },
    },
    Fire = {    
        AmountOfFireFighters = 2, -- Match this to the seat count of the vehicle you are using for NPC fire backup.
        BlipData = {
            SpriteId = 1,
            ColourId = 1,
            Flashes = true,
            Cone = true
        },
        VehicleData = {
            [1] = {
                modelName = "firetruk", 
                extraIds = {1, 2, 3, 4, 5, 10, 15, 20}, 
                liveryId = -1, 
                vehicleColours = { primary = -1, secondary = -1, pearlescent = -1, wheel = -1}, 
                windowTintId = -1, 
                dirtLevel = 0.0,
            },
        },
        PedData = { 
            [1] = {
                modelName = "s_m_y_fireman_01",
                props = {},
                components = {},
            },
        },
    }
}

 --====================== ANIMAL RESCUE CAGE SETTINGS ======================--

 Config.AnimalModelsWithCagesList = {
    -- Small
    {model = "a_c_cat_01", cage = "prop_dog_cage_03"},
    {model = "a_c_cormorant", cage = "prop_dog_cage_03"},
    {model = "a_c_coyote", cage = "prop_dog_cage_03"},
    {model = "a_c_hen", cage = "prop_dog_cage_03"},
    {model = "a_c_poodle", cage = "prop_dog_cage_03"},
    {model = "a_c_pug", cage = "prop_dog_cage_03"},
    {model = "a_c_rabbit_01", cage = "prop_dog_cage_03"},
    {model = "a_c_rat", cage = "prop_dog_cage_03"},

    -- Medium
    {model = "a_c_chop", cage = "prop_dog_cage_05"},
    {model = "a_c_husky", cage = "prop_dog_cage_05"},
    {model = "a_c_pig", cage = "prop_dog_cage_05"},
    {model = "a_c_retriever", cage = "prop_dog_cage_05"},
    {model = "a_c_rhesus", cage = "prop_dog_cage_05"},
    {model = "a_c_rottweiler", cage = "prop_dog_cage_05"},
    {model = "a_c_shepherd", cage = "prop_dog_cage_05"},
    {model = "a_c_westy", cage = "prop_dog_cage_05"},

    -- Large
    {model = "a_c_chimp", cage = "prop_dog_cage_04"},
    {model = "a_c_boar", cage = "prop_dog_cage_04"},
    {model = "a_c_cow", cage = "prop_dog_cage_04"},
    {model = "a_c_deer", cage = "prop_dog_cage_04"},
    {model = "a_c_mtlion", cage = "prop_dog_cage_04"},
}