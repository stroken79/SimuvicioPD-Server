Config = Config or {}

--====================== IMPOUND SETTINGS ======================--

Config.ImpoundEnabled = true
Config.ImpoundMarkersEnabled = true
Config.ImpoundBlipsEnabled = true
Config.ImpoundUseMarkers = false -- Set to true to use markers instead of peds, in case you have an anti cheat or want to use markers.
Config.ImpoundMarkerData = {
    MarkerId = 21 --[[ integer ]], 
    dirX = 0 --[[ number ]], 
    dirY = 0 --[[ number ]], 
    dirZ = 0 --[[ number ]], 
    rotX = 0 --[[ number ]], 
    rotY = 0 --[[ number ]], 
    rotZ = 0 --[[ number ]], 
    scaleX = 0.5 --[[ number ]], 
    scaleY = 0.5 --[[ number ]], 
    scaleZ = 0.5 --[[ number ]], 
    red = 255 --[[ integer ]], 
    green = 165 --[[ integer ]], 
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

Config.ImpoundLocations = {
    {
        Name = "Los Santos",
        AcceptedVehicleClasses = {  
            -- Don't remove any, just set the Allowed value to false if you don't want to allow that vehicle class to be impounded here.  
            [0] = { Name = "compacts", Allowed = true },
            [1] = { Name = "sedans", Allowed = true },
            [2] = { Name = "suvs", Allowed = true },
            [3] = { Name = "coupes", Allowed = true },
            [4] = { Name = "muscle", Allowed = true },
            [5] = { Name = "sportsclassics", Allowed = true },
            [6] = { Name = "sports", Allowed = true },
            [7] = { Name = "super", Allowed = true },
            [8] = { Name = "motorcycles", Allowed = true },
            [9] = { Name = "offroad", Allowed = true },
            [10] = { Name = "industrial", Allowed = true },
            [11] = { Name = "utility", Allowed = true },
            [12] = { Name = "vans", Allowed = true },
            [13] = { Name = "cycles", Allowed = true },
            [14] = { Name = "boats", Allowed = true },
            [15] = { Name = "helicopters", Allowed = true },
            [16] = { Name = "planes", Allowed = true },
            [17] = { Name = "service", Allowed = true },
            [18] = { Name = "emergency", Allowed = true },
            [19] = { Name = "military", Allowed = true },
            [20] = { Name = "commercial", Allowed = true },
            [21] = { Name = "trains", Allowed = true },
            [22] = { Name = "openwheel", Allowed = true },
        },
        Coordinates = vector3(408.9608, -1622.8490, 29.2920),               -- Coordinates of the impound location
        ImpoundLocation = vector3(401.3103, -1631.1549, 29.2920),           -- Coordinates of the drop off location
        Heading = 233.0054,     
        NPCPedData = {
            [1] = {
                modelName = "s_m_y_xmech_02", -- This is not an MP ped model
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
        },                                            -- Heading of the impound location
        MarkerData = {
            MarkerId = 21 --[[ integer ]], 
            dirX = 0 --[[ number ]], 
            dirY = 0 --[[ number ]], 
            dirZ = 0 --[[ number ]], 
            rotX = 0 --[[ number ]], 
            rotY = 0 --[[ number ]], 
            rotZ = 0 --[[ number ]], 
            scaleX = 0.5 --[[ number ]], 
            scaleY = 0.5 --[[ number ]], 
            scaleZ = 0.5 --[[ number ]], 
            red = 255 --[[ integer ]], 
            green = 165 --[[ integer ]], 
            blue = 0 --[[ integer ]], 
            alpha = 100 --[[ integer ]], 
            bobUpAndDown = true --[[ boolean ]], 
            faceCamera = true --[[ boolean ]], 
            p19 = 0 --[[ integer ]], 
            rotate = false --[[ boolean ]], 
            textureDict = 0 --[[ string ]], 
            textureName = 0 --[[ string ]], 
            drawOnEnts = 0 --[[ boolean ]]
        },
        BlipData = {
            Name = "Impound Location",
            Sprite = 317,
            Display = 2,
            Scale = 0.75,
            Alpha = 225,
            Colour = 76,
            ShortRange = true,
        },
    },
    {
        Name = "Paleto Bay",
        AcceptedVehicleClasses = {  
            -- Don't remove any, just set the Allowed value to false if you don't want to allow that vehicle class to be impounded here.  
            [0] = { Name = "compacts", Allowed = true },
            [1] = { Name = "sedans", Allowed = true },
            [2] = { Name = "suvs", Allowed = true },
            [3] = { Name = "coupes", Allowed = true },
            [4] = { Name = "muscle", Allowed = true },
            [5] = { Name = "sportsclassics", Allowed = true },
            [6] = { Name = "sports", Allowed = true },
            [7] = { Name = "super", Allowed = true },
            [8] = { Name = "motorcycles", Allowed = true },
            [9] = { Name = "offroad", Allowed = true },
            [10] = { Name = "industrial", Allowed = true },
            [11] = { Name = "utility", Allowed = true },
            [12] = { Name = "vans", Allowed = true },
            [13] = { Name = "cycles", Allowed = true },
            [14] = { Name = "boats", Allowed = true },
            [15] = { Name = "helicopters", Allowed = true },
            [16] = { Name = "planes", Allowed = true },
            [17] = { Name = "service", Allowed = true },
            [18] = { Name = "emergency", Allowed = true },
            [19] = { Name = "military", Allowed = true },
            [20] = { Name = "commercial", Allowed = true },
            [21] = { Name = "trains", Allowed = true },
            [22] = { Name = "openwheel", Allowed = true },
        },
        Coordinates = vector3(105.2473, 6613.5591, 32.3973),               -- Coordinates of the impound location
        ImpoundLocation = vector3(110.8162, 6605.3364, 31.8927),           -- Coordinates of the drop off location
        Heading = 231.9876,
        NPCPedData = {
            [1] = {
                modelName = "s_m_y_xmech_02", -- This is not an MP ped model
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
        },                                            -- Heading of the impound location
        MarkerData = {
            MarkerId = 21 --[[ integer ]], 
            dirX = 0 --[[ number ]], 
            dirY = 0 --[[ number ]], 
            dirZ = 0 --[[ number ]], 
            rotX = 0 --[[ number ]], 
            rotY = 0 --[[ number ]], 
            rotZ = 0 --[[ number ]], 
            scaleX = 0.5 --[[ number ]], 
            scaleY = 0.5 --[[ number ]], 
            scaleZ = 0.5 --[[ number ]], 
            red = 255 --[[ integer ]], 
            green = 165 --[[ integer ]], 
            blue = 0 --[[ integer ]], 
            alpha = 100 --[[ integer ]], 
            bobUpAndDown = true --[[ boolean ]], 
            faceCamera = true --[[ boolean ]], 
            p19 = 0 --[[ integer ]], 
            rotate = false --[[ boolean ]], 
            textureDict = 0 --[[ string ]], 
            textureName = 0 --[[ string ]], 
            drawOnEnts = 0 --[[ boolean ]]
        },
        BlipData = {
            Name = "Impound Location",
            Sprite = 317,
            Display = 2,
            Scale = 0.75,
            Alpha = 225,
            Colour = 76,
            ShortRange = true,
        },
    }
}

