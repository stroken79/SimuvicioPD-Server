-- ================ General Config ================ --

Config.EnableTowTools = true
Config.RopeType = 2 -- https://docs.fivem.net/natives/?_0xE832D760399EB220

-- ================ Towable Vehicle Classes ================ --

Config.TowableVehicleClasses = {
    [0] = true,  -- Compacts
    [1] = true,  -- Sedans
    [2] = true,  -- SUVs
    [3] = true,  -- Coupes
    [4] = true,  -- Muscle
    [5] = true,  -- Sports Classics
    [6] = true,  -- Sports
    [7] = true,  -- Super
    [8] = false, -- Motorcycles
    [9] = true,  -- Off-road
    [10] = true, -- Industrial
    [11] = true, -- Utility
    [12] = true, -- Vans
    [13] = false,-- Cycles
    [14] = false,-- Boats
    [15] = false,-- Helicopters
    [16] = false,-- Planes
    [17] = true, -- Service
    [18] = true, -- Emergency
    [19] = true, -- Military
    [20] = true, -- Commercial
    [21] = false,-- Trains
    [22] = true, -- Open Wheel
}

-- ================ Vehicles that can tow/winch other vehicles ================ --
-- TO ADD MORE VEHICLES, COPY THE FORMAT AND FILL IN THE VARIABLES

Config.TowVehicles = {
    [`flatbed`] = {
        enginePowerMultiplier = 28.0, -- Required for some tow trucks to have more power to pull heavy vehicles.
        winchAnchorOverride = {
            enabled = true, -- If false, the script will use the default tow anchor position. (Which is using the suspension or wheel bones)
            left = {
                { bone = "suspension_lr", leftRight = 0.0, forwardBack = 0.0, upDown = 0.0 },
            },
            right = {
                { bone = "suspension_rr", leftRight = 0.0, forwardBack = 0.0, upDown = 0.0 },
            }
        }
    },
    [`towtruck`] = {
        enginePowerMultiplier = 10.0, -- Required for some tow trucks to have more power to pull heavy vehicles.
        winchAnchorOverride = {
            enabled = true, -- If false, the script will use the default tow anchor position. (Which is using the suspension or wheel bones)
            left = {
                { bone = "tow_mount_a", leftRight = 0.0, forwardBack = 0.0, upDown = 0.0 },
            },
            right = {
                { bone = "tow_mount_b", leftRight = 0.0, forwardBack = 0.0, upDown = 0.0 },
            }
        }
    },
    [`towtruck2`] = {
        enginePowerMultiplier = 10.0, -- Required for some tow trucks to have more power to pull heavy vehicles.
        winchAnchorOverride = {
            enabled = true, -- If false, the script will use the default tow anchor position. (Which is using the suspension or wheel bones)
            left = {
                { bone = "tow_mount_a", leftRight = 0.0, forwardBack = 0.0, upDown = 0.0 },
            },
            right = {
                { bone = "tow_mount_b", leftRight = 0.0, forwardBack = 0.0, upDown = 0.0 },
            }
        }
    },
    [`aaman`] = {
        enginePowerMultiplier = 10.0, -- Required for some tow trucks to have more power to pull heavy vehicles.
        winchAnchorOverride = {
            enabled = true, -- If false, the script will use the default tow anchor position. (Which is using the suspension or wheel bones)
            left = {
                { bone = "suspension_lr", leftRight = 0.0, forwardBack = 0.0, upDown = 0.0 },
            },
            right = {
                { bone = "suspension_rr", leftRight = 0.0, forwardBack = 0.0, upDown = 0.0 },
            }
        }
    },
    -- Add another vehicle here (example):
    -- [`vehicle_name`] = {
    --     enginePowerMultiplier = 10.0, -- Required for some tow trucks to have more power to pull heavy vehicles.
    --     winchAnchorOverride = {
    --         enabled = true, -- If false, the script will use the default tow anchor position. (Which is using the suspension or wheel bones)
    --         left = {
    --             { bone = "wheel_lr", leftRight = 0.0, forwardBack = 0.0, upDown = 0.0 },
    --         },
    --         right = {
    --             { bone = "wheel_rr", leftRight = 0.0, forwardBack = 0.0, upDown = 0.0 },
    --         }
    --     }
    -- },
}