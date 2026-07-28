Config = Config or {}

Config.GearData = {

    --[[
    ================================================================================
    GEAR WEAPONS — STEP-BY-STEP (which table? which names?)
    ================================================================================
    The server picks EXACTLY ONE weapon list per uniform (see server/gear_server.lua):
      • ESX running              → ESXWeaponData
      • QBCore OR QBox running   → QBCoreWeaponData
      • neither                  → WeaponData
    The other two lists in each uniform are ignored. You can delete them or leave examples.

    --------------------------------------------------------------------------------
    STEP 1 — What is your framework? (only one applies)
    --------------------------------------------------------------------------------
      ESX        → edit ESXWeaponData
      QBCore/QBox → edit QBCoreWeaponData
      neither    → edit WeaponData

    --------------------------------------------------------------------------------
    STEP 2 — How does ERS give the gun? (inventory order: ox first, then qb)
    --------------------------------------------------------------------------------
      If resource ox_inventory is started     → "OX row" below (weapon + attachments in ox format).
      Else if resource qb-inventory is started → "QB-INV row" below (qb item names; attachments = extra items).
      Else                                     → "NO INV row" (native GTA / ESX weapon APIs — no ox/qb items).
      If BOTH ox_inventory and qb-inventory are started, ox wins — configure the ox row (WEAPON_* + at_*), not qb-only names.

    --------------------------------------------------------------------------------
    FULL MAP: framework × inventory → what to put in EACH weapon line
    --------------------------------------------------------------------------------
    Fields: weaponName, ammoCount, optional ammoType, optional componentList

    (1) ESX + ox_inventory
        weaponName     = ox weapon item id → ox_inventory/data/weapons.lua (Weapons), usually WEAPON_PISTOL
        componentList  = ox attachment item ids → same file, section Components → e.g. at_flashlight, at_clip_extended_pistol
        ammo           = ammoCount = rounds; loose ammo item is chosen automatically from ox (omit ammoType)
        ammoType       = omit/nil (auto) | "your-ammo-item-name" (force) | false (all rounds only inside the gun, no loose stack)

    (2) ESX + no ox (es_extended weapons only)
        weaponName     = whatever YOUR es_extended config uses (often WEAPON_PISTOL)
        componentList  = ESX component KEYS from YOUR es_extended (e.g. clip_extended, flashlight) — NOT at_* and NOT COMPONENT_*
        ammo           = ammoCount; ESX handles ammo on the weapon
        ammoType       = not used (ox-only)

    (3) QBCore or QBox + ox_inventory
        Same rules as (1): weaponName and componentList must match ox_inventory item names (WEAPON_* + at_*).

    (4) QBCore or QBox + qb-inventory only (ox NOT started)
        weaponName     = qb-core item name for the gun (e.g. weapon_pistol) — check qb-core/shared/items or your items
        componentList  = qb item names for each attachment, given as SEPARATE items in the inventory (not glued on the gun)
        ammo           = ammoCount; ammo item name from qb Shared.Weapons is resolved automatically (omit ammoType usually)
        ammoType       = same idea as ox if you use custom ammo items: string to force, false for clip-only (see server logic)

    (5) QBCore or QBox + neither ox nor qb-inventory
        weaponName     = must work with GetHashKey() for a GTA weapon (use WEAPON_PISTOL style string, not weapon_pistol)
        componentList  = GTA component names as strings, e.g. COMPONENT_PISTOL_CLIP_02 (see Vespura weapon stats link below)
        ammo           = ammoCount goes to the ped natively

    (6) Standalone (no ESX, no QB) → WeaponData
        weaponName     = same as (5): WEAPON_* style for GetHashKey
        componentList  = same as (5): COMPONENT_* strings
        ammo           = ammoCount natively on the ped

    --------------------------------------------------------------------------------
    COPY-PASTE EXAMPLES (one pistol line each — adjust counts/names to your server)
    --------------------------------------------------------------------------------
    ESX + ox_inventory (ESXWeaponData):
        { weaponName = "WEAPON_PISTOL", ammoCount = 45, componentList = { "at_clip_extended_pistol", "at_flashlight" } },

    ESX (ESXWeaponData — names MUST match YOUR es_extended):
        { weaponName = "WEAPON_PISTOL", ammoCount = 45, componentList = { "clip_extended", "flashlight" } },

    QBCore/QBox + ox_inventory (QBCoreWeaponData):
        { weaponName = "WEAPON_PISTOL", ammoCount = 45, componentList = { "at_clip_extended_pistol", "at_flashlight" } },

    QBCore/QBox + qb-inventory only (QBCoreWeaponData — names MUST match YOUR qb items; example names vary by pack):
        { weaponName = "weapon_pistol", ammoCount = 45, componentList = { "flashlight_attachment", "clip_attachment" } },

    QBCore/QBox + no inventory, OR standalone WeaponData (native components):
        { weaponName = "WEAPON_PISTOL", ammoCount = 45, componentList = { "COMPONENT_PISTOL_CLIP_02", "COMPONENT_AT_PI_FLSH" } },

    Optional ammo overrides (only when using ox_inventory OR qb-inventory path with DistributeGearInventoryRow):
        Force ox ammo item:     ammoType = "ammo-9"
        No loose ammo stack:   ammoType = false

    --------------------------------------------------------------------------------
    COMMON MISTAKES
    --------------------------------------------------------------------------------
      • ESXWeaponData with ox running but componentList = clip_extended or COMPONENT_* → wrong; use at_* names (see (1)).
      • QBCoreWeaponData with qb-inventory but componentList = at_* → wrong; use qb attachment ITEM names (see (4)).
      • weapon_pistol with ox_inventory → wrong item id; ox expects WEAPON_PISTOL (unless your ox renamed items).
      • Mixing two frameworks’ examples in the ONE list your server actually reads.

    Native weapon / COMPONENT reference: https://vespura.com/fivem/weapons/stats/

    ================================================================================
    QUICK START — rest of this file (peds, uniforms, blips)
    ================================================================================
    1) Toggles: Enabled, EnableGiveWeapons, EnableSetClothing (below).
    2) Locations: coords + heading, ServiceType = police | ambulance | fire | tow, then BlipData / NPCPedData.
    3) ClothingData: each numbered entry = one uniform (Name, modelName, props/components for MP peds, HealthData, PermissionRolesOrGroups).
    4) Put weapons only in the list your framework uses (STEP 1). Start ox_inventory before ERS if you use ox (ERS prefers ox when it is running).
    ]]

    -- Enable or disable the option to obtain gear via ERS.
    Enabled = true,
    EnableGiveWeapons = true,                   -- Enable or disable giving weapons to the player.
    EnableSetClothing = true,                   -- Enable or disable setting clothes to the player. Setting both to false will result into the NPC being useless, maybe good for decoration :)
    ForceMPPedWhenPlayerIsNotAnMPPed = true,    -- Set the player to a default MP-Ped when they are not an MP-Ped.
    UseMarkers = false,                         -- Set to true to use markers instead of peds, in case you have an anti cheat or want to use markers.
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

    -- Gear Permissions 
    -- These are used when the player selects a loadout for a service. In the loadout section you can define the role or group that can use the loadout.
    Enable_Gear_Permissions = false,               -- If set to false, everyone can use any loadout as long as they have the correct service type (e.g. 'police'). Otherwise enable permission types below and configure the PermissionRoles for each uniform/loadout.
    Enable_Night_DiscordApi_Permissions = false,   -- server/s_functions.lua
    Enable_Ace_Permissions = false,                -- server/s_functions.lua
    Enable_ESX_Permissions = {
        Check_By_Job = false,                      -- server/s_functions.lua
        Check_By_Permissions = false,              -- server/s_functions.lua
    },
    Enable_QBCore_Permissions = {                   
        Check_By_Job = false,                      -- server/s_functions.lua
        Check_By_Permissions = false,              -- server/s_functions.lua
    },

    -- Locations (gear spots). Each has ClothingData = uniforms for that place.
    Locations = {
        [1] = {
            Name = "Police Gear & Loadout",         -- Give it any name for reference (blip)
            ServiceType = "police",                 -- Options: police | ambulance | fire | tow.
            CoordinatesWithHeading = vector4(454.1983, -980.0516, 30.8896, 89.5176), -- Vector 4 means: x,y,z,heading
            BlipData = {
                Enabled = true, -- Set to false to disable blip for this gear ped.
                Sprite = 205,
                Display = 2, 
                ShortRange = true,
                Colour = 38, 
                Scale = 0.75,
                Alpha = 200, 
            },
            NPCPedData = {  -- It will select one of these (multiple, optional) settings for the NPC ped model offering the gear to the player.
                [1] = {
                    modelName = "s_m_y_cop_01", -- This is not an MP ped model
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
                --         { 2, 1, 1 },    -- Hair
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
            },
            ClothingData = { -- One entry per uniform (model + optional MP outfit + weapons + health).
                [1] = {
                    Name = "Police Default (Male)",
                    Description = "Male police officer.",
                    modelName = "s_m_y_cop_01", -- This is not an MP ped model
                    props = {},                 -- No props needed for non-mp peds.
                    components = {},            -- No components needed for non-mp peds.
                    -- WeaponData = only when server is not ESX and not QBCore/QBox (native GTA weapons).
                    WeaponData = {
                        [1] = {weaponName = "weapon_flashlight", ammoCount = 1, componentList = {}},
                        [2] = {weaponName = "weapon_stungun", ammoCount = 1, componentList = {}},
                        [3] = {weaponName = "weapon_nightstick", ammoCount = 1, componentList = {}},
                        [4] = {weaponName = "weapon_pistol", ammoCount = 45, componentList = {"COMPONENT_PISTOL_CLIP_02", "COMPONENT_AT_PI_FLSH"}},
                    },
                    QBCoreWeaponData = {
                        [1] = {weaponName = "weapon_flashlight", componentList = {}},
                        [2] = {weaponName = "weapon_stungun", componentList = {}},
                        [3] = {weaponName = "weapon_nightstick", componentList = {}},
                        [4] = {weaponName = "weapon_pistol", ammoCount = 45, componentList = {"flashlight_attachment", "clip_attachment"}},
                    },
                    ESXWeaponData = {
                        [1] = {weaponName = "weapon_flashlight", ammoCount = 1, componentList = {}},
                        [2] = {weaponName = "weapon_stungun", ammoCount = 1, componentList = {}},
                        [3] = {weaponName = "weapon_nightstick", ammoCount = 1, componentList = {}},
                        [4] = {weaponName = "weapon_pistol", ammoCount = 45, componentList = {"clip_extended", "flashlight"}},
                    },
                    HealthData = {
                        Enabled = true,
                        Health = 200, -- 101 to 200 (Female peds have max. 150 health)
                        Armor = 200
                    },
                    PermissionRolesOrGroups = {
                        "Essex_Police_Force",
                        "police",
                    }
                },
                [2] = {
                    Name = "Police Default (Female)",
                    Description = "Female police officer.",
                    modelName = "s_f_y_cop_01", -- This is not an MP ped model
                    props = {},         -- No props needed for non-mp peds.
                    components = {},    -- No components needed for non-mp peds.
                    -- WeaponData = only when server is not ESX and not QBCore/QBox (native GTA weapons).
                    WeaponData = {
                        [1] = {weaponName = "weapon_flashlight", ammoCount = 1, componentList = {}},
                        [2] = {weaponName = "weapon_stungun", ammoCount = 1, componentList = {}},
                        [3] = {weaponName = "weapon_nightstick", ammoCount = 1, componentList = {}},
                        [4] = {weaponName = "weapon_pistol", ammoCount = 45, componentList = {"COMPONENT_PISTOL_CLIP_02", "COMPONENT_AT_PI_FLSH"}},
                    },
                    QBCoreWeaponData = {
                        [1] = {weaponName = "weapon_flashlight", componentList = {}},
                        [2] = {weaponName = "weapon_stungun", componentList = {}},
                        [3] = {weaponName = "weapon_nightstick", componentList = {}},
                        [4] = {weaponName = "weapon_pistol", ammoCount = 45, componentList = {"flashlight_attachment", "clip_attachment"}},
                    },
                    ESXWeaponData = {
                        [1] = {weaponName = "weapon_flashlight", ammoCount = 1, componentList = {}},
                        [2] = {weaponName = "weapon_stungun", ammoCount = 1, componentList = {}},
                        [3] = {weaponName = "weapon_nightstick", ammoCount = 1, componentList = {}},
                        [4] = {weaponName = "weapon_pistol", ammoCount = 45, componentList = {"clip_extended", "flashlight"}},
                    },
                    HealthData = {
                        Enabled = true,
                        Health = 200, -- 101 to 200 (Female peds have max. 150 health)
                        Armor = 200
                    },
                    PermissionRolesOrGroups = {
                        "Essex_Police_Force",
                        "police",
                    }
                },
                [3] = {
                    -- Use vMenu to fetch these numbers via Player Appearance. If model is not an MP ped it will not apply any props or components.
                    Name = "Police MP Ped (Male)",
                    Description = "Male police officer.",
                    modelName = "mp_m_freemode_01", 
                    props = {
                        -- Example: {prop type (Helmet), prop type index (Motorcycle helmet), prop colour index (Black colour)}
                        { 0, 9, 1 },    -- Hats / Helments
                        { 1, 0, 0 },    -- Glassess
                        { 2, 0, 0 },    -- Misc
                        { 3, 0, 0 },
                    },
                    components = {
                        -- Example: {component type (Mask), component type index (Clown Mask), component colour index (White colour)}
                        { 1, 122, 1 },  -- Mask
                        { 2, 1, 1 },    -- Hair
                        { 3, 201, 1 },  -- Upper body
                        { 4, 18, 1 },   -- Legs / Pants
                        { 5, 1, 1 },    -- Bags / Parachutes
                        { 6, 26, 1 },   -- Shoes
                        { 7, 4, 1 },    -- Neck / Scarfs
                        { 8, 16, 1 },   -- Shirt / Accessory
                        { 9, 2, 1 },    -- Body Armor
                        { 10, 2, 1 },   -- Badges / Logos
                        { 11, 26, 1 },  -- Jackets
                    },
                    -- WeaponData = only when server is not ESX and not QBCore/QBox (native GTA weapons).
                    WeaponData = {
                        [1] = {weaponName = "weapon_flashlight", ammoCount = 1, componentList = {}},
                        [2] = {weaponName = "weapon_stungun", ammoCount = 1, componentList = {}},
                        [3] = {weaponName = "weapon_nightstick", ammoCount = 1, componentList = {}},
                        [4] = {weaponName = "weapon_pistol", ammoCount = 45, componentList = {"COMPONENT_PISTOL_CLIP_02", "COMPONENT_AT_PI_FLSH"}},
                    },
                    QBCoreWeaponData = {
                        [1] = {weaponName = "weapon_flashlight", componentList = {}},
                        [2] = {weaponName = "weapon_stungun", componentList = {}},
                        [3] = {weaponName = "weapon_nightstick", componentList = {}},
                        [4] = {weaponName = "weapon_pistol", ammoCount = 45, componentList = {"flashlight_attachment", "clip_attachment"}},
                    },
                    ESXWeaponData = {
                        [1] = {weaponName = "weapon_flashlight", ammoCount = 1, componentList = {}},
                        [2] = {weaponName = "weapon_stungun", ammoCount = 1, componentList = {}},
                        [3] = {weaponName = "weapon_nightstick", ammoCount = 1, componentList = {}},
                        [4] = {weaponName = "weapon_pistol", ammoCount = 45, componentList = {"clip_extended", "flashlight"}},
                    },
                    HealthData = {
                        Enabled = true,
                        Health = 200, -- 101 to 200 (Female peds have max. 150 health)
                        Armor = 200
                    },
                    PermissionRolesOrGroups = {
                        "Essex_Police_Force",
                        "police",
                    }
                },
                [4] = {
                    Name = "Police MP Ped (Female)",
                    Description = "Female police officer.",
                    modelName = "mp_f_freemode_01", 
                    props = {
                        { 0, 9, 1 },    -- Hats / Helments
                        { 1, 0, 0 },    -- Glassess
                        { 2, 0, 0 },    -- Misc
                        { 3, 0, 0 },
                    },
                    components = {
                        { 1, 122, 1 },  -- Mask
                        { 2, 1, 1 },    -- Hair
                        { 3, 201, 1 },  -- Upper body
                        { 4, 18, 1 },   -- Legs / Pants
                        { 5, 1, 1 },    -- Bags / Parachutes
                        { 6, 26, 1 },   -- Shoes
                        { 7, 3, 1 },    -- Neck / Scarfs
                        { 8, 18, 1 },   -- Shirt / Accessory
                        { 9, 5, 1 },    -- Body Armor
                        { 10, 2, 1 },   -- Badges / Logos
                        { 11, 26, 1 },  -- Jackets
                    },
                    -- WeaponData = only when server is not ESX and not QBCore/QBox (native GTA weapons).
                    WeaponData = {
                        [1] = {weaponName = "weapon_flashlight", ammoCount = 1, componentList = {}},
                        [2] = {weaponName = "weapon_stungun", ammoCount = 1, componentList = {}},
                        [3] = {weaponName = "weapon_nightstick", ammoCount = 1, componentList = {}},
                        [4] = {weaponName = "weapon_pistol", ammoCount = 45, componentList = {"COMPONENT_PISTOL_CLIP_02", "COMPONENT_AT_PI_FLSH"}},
                    },
                    QBCoreWeaponData = {
                        [1] = {weaponName = "weapon_flashlight", componentList = {}},
                        [2] = {weaponName = "weapon_stungun", componentList = {}},
                        [3] = {weaponName = "weapon_nightstick", componentList = {}},
                        [4] = {weaponName = "weapon_pistol", ammoCount = 45, componentList = {"flashlight_attachment", "clip_attachment"}},
                    },
                    ESXWeaponData = {
                        [1] = {weaponName = "weapon_flashlight", ammoCount = 1, componentList = {}},
                        [2] = {weaponName = "weapon_stungun", ammoCount = 1, componentList = {}},
                        [3] = {weaponName = "weapon_nightstick", ammoCount = 1, componentList = {}},
                        [4] = {weaponName = "weapon_pistol", ammoCount = 45, componentList = {"clip_extended", "flashlight"}},
                    },
                    HealthData = {
                        Enabled = true,
                        Health = 200, -- 101 to 200 (Female peds have max. 150 health)
                        Armor = 200
                    },
                    PermissionRolesOrGroups = {
                        "Essex_Police_Force",
                        "police",
                    }
                },
                [5] = {
                    Name = "SWAT Operator",
                    Description = "SWAT Operator",
                    modelName = "s_m_y_swat_01", 
                    props = {},
                    components = {},
                    -- WeaponData = only when server is not ESX and not QBCore/QBox (native GTA weapons).
                    WeaponData = {
                        [1] = {weaponName = "weapon_flashlight", ammoCount = 1, componentList = {}},
                        [2] = {weaponName = "weapon_stungun", ammoCount = 1, componentList = {}},
                        [3] = {weaponName = "weapon_nightstick", ammoCount = 1, componentList = {}},
                        [4] = {weaponName = "weapon_pistol", ammoCount = 45, componentList = {"COMPONENT_PISTOL_CLIP_02", "COMPONENT_AT_PI_FLSH"}},
                        [5] = {weaponName = "weapon_carbinerifle", ammoCount = 64, componentList = {"COMPONENT_CARBINERIFLE_CLIP_02", "COMPONENT_AT_AR_FLSH"}},
                    },
                    QBCoreWeaponData = {
                        [1] = {weaponName = "weapon_flashlight", componentList = {}},
                        [2] = {weaponName = "weapon_stungun", componentList = {}},
                        [3] = {weaponName = "weapon_nightstick", componentList = {}},
                        [4] = {weaponName = "weapon_pistol", ammoCount = 45, componentList = {"flashlight_attachment", "clip_attachment"}},
                        [5] = {weaponName = "weapon_carbinerifle", ammoCount = 64, componentList = {"grip_attachment", "flashlight_attachment", "clip_attachment"}},
                    },
                    ESXWeaponData = {
                        [1] = {weaponName = "weapon_flashlight", ammoCount = 1, componentList = {}},
                        [2] = {weaponName = "weapon_stungun", ammoCount = 1, componentList = {}},
                        [3] = {weaponName = "weapon_nightstick", ammoCount = 1, componentList = {}},
                        [4] = {weaponName = "weapon_pistol", ammoCount = 45, componentList = {"clip_extended", "flashlight"}},
                        [5] = {weaponName = "weapon_carbinerifle", ammoCount = 64, componentList = {"grip", "clip_extended", "flashlight"}},
                    },
                    HealthData = {
                        Enabled = true,
                        Health = 200, -- 101 to 200 (Female peds have max. 150 health)
                        Armor = 200
                    },
                    PermissionRolesOrGroups = {
                        "AFO",
                        "SWAT",
                    }
                },
            },
        },
        [2] = {
            Name = "Ambulance Gear & Loadout",      -- Give it any name for reference
            ServiceType = "ambulance",              -- Options: police | ambulance | fire | tow.
            CoordinatesWithHeading = vector4(359.2316, -587.5147, 28.8096, 225.0237), -- Vector 4 means: x,y,z,heading
            BlipData = {
                Enabled = true, -- Set to false to disable blip for this gear ped.
                Sprite = 205,
                Display = 2, 
                Category = 2,
                ShortRange = true,
                Colour = 66, 
                Scale = 0.75,
                Alpha = 200, 
            },
            NPCPedData = {  -- It will select one of these settings for the NPC ped model offering the gear to the player.
                [1] = {
                    modelName = "s_m_m_paramedic_01", -- This is not an MP ped model
                    props = {},         -- No props needed for non-mp peds.
                    components = {},    -- No components needed for non-mp peds.
                },
            },
            ClothingData = { -- One entry per uniform (model + optional MP outfit + weapons + health).
                [1] = {
                    Name = "Ambulance Default (Male)",
                    Description = "Male paramedic.",
                    modelName = "s_m_m_paramedic_01", -- This is not an MP ped model
                    props = {},         -- No props needed for non-mp peds.
                    components = {},    -- No components needed for non-mp peds.
                    -- WeaponData = only when server is not ESX and not QBCore/QBox (native GTA weapons).
                    WeaponData = {
                        [1] = {weaponName = "weapon_flashlight", ammoCount = 1, componentList = {}},
                    },
                    QBCoreWeaponData = {
                        [1] = {weaponName = "weapon_flashlight", componentList = {}},
                    },
                    ESXWeaponData = {
                        [1] = {weaponName = "weapon_flashlight", ammoCount = 1, componentList = {}},
                    },
                    HealthData = {
                        Enabled = true,
                        Health = 200, -- 101 to 200 (Female peds have max. 150 health)
                        Armor = 200
                    },
                    PermissionRolesOrGroups = {
                        "Ambulance_Service",
                        "ambulance",
                    }
                },
                [2] = {
                    Name = "Ambulance MP Default (Male)",
                    Description = "Male paramedic.",
                    modelName = "mp_m_freemode_01", -- This is an MP ped model
                    props = {
                        { 0, 0, 0 },    -- Hats / Helments
                        { 1, 0, 0 },    -- Glassess
                        { 2, 0, 0 },    -- Misc
                        { 3, 0, 0 },
                    },
                    components = {
                        { 1, 122, 1 },  -- Mask
                        { 2, 1, 1 },    -- Hair
                        { 3, 86, 1 },  -- Upper body
                        { 4, 21, 1 },   -- Legs / Pants
                        { 5, 4, 1 },    -- Bags / Parachutes
                        { 6, 26, 1 },   -- Shoes
                        { 7, 6, 1 },    -- Neck / Scarfs
                        { 8, 18, 1 },   -- Shirt / Accessory
                        { 9, 1, 1 },    -- Body Armor
                        { 10, 2, 1 },   -- Badges / Logos
                        { 11, 24, 1 },  -- Jackets
                    },
                    -- WeaponData = only when server is not ESX and not QBCore/QBox (native GTA weapons).
                    WeaponData = {
                        [1] = {weaponName = "weapon_flashlight", ammoCount = 1, componentList = {}},
                    },
                    QBCoreWeaponData = {
                        [1] = {weaponName = "weapon_flashlight", componentList = {}},
                    },
                    ESXWeaponData = {
                        [1] = {weaponName = "weapon_flashlight", ammoCount = 1, componentList = {}},
                    },
                    HealthData = {
                        Enabled = true,
                        Health = 200, -- 101 to 200 (Female peds have max. 150 health)
                        Armor = 200
                    },
                    PermissionRolesOrGroups = {
                        "Ambulance_Service",
                        "ambulance",
                    }
                },
                [3] = {
                    Name = "Ambulance MP Default (Female)",
                    Description = "Female paramedic.",
                    modelName = "mp_f_freemode_01", -- This is an MP ped model
                    props = {
                        { 0, 0, 0 },    -- Hats / Helments
                        { 1, 0, 0 },    -- Glassess
                        { 2, 0, 0 },    -- Misc
                        { 3, 0, 0 },
                    },
                    components = {
                        { 1, 122, 1 },  -- Mask
                        { 2, 1, 1 },    -- Hair
                        { 3, 86, 1 },  -- Upper body
                        { 4, 21, 1 },   -- Legs / Pants
                        { 5, 4, 1 },    -- Bags / Parachutes
                        { 6, 26, 1 },   -- Shoes
                        { 7, 6, 1 },    -- Neck / Scarfs
                        { 8, 18, 1 },   -- Shirt / Accessory
                        { 9, 1, 1 },    -- Body Armor
                        { 10, 2, 1 },   -- Badges / Logos
                        { 11, 24, 1 },  -- Jackets
                    },
                    -- WeaponData = only when server is not ESX and not QBCore/QBox (native GTA weapons).
                    WeaponData = {
                        [1] = {weaponName = "weapon_flashlight", ammoCount = 1, componentList = {}},
                    },
                    QBCoreWeaponData = {
                        [1] = {weaponName = "weapon_flashlight", componentList = {}},
                    },
                    ESXWeaponData = {
                        [1] = {weaponName = "weapon_flashlight", ammoCount = 1, componentList = {}},
                    },
                    HealthData = {
                        Enabled = true,
                        Health = 200, -- 101 to 200 (Female peds have max. 150 health)
                        Armor = 200
                    },
                    PermissionRolesOrGroups = {
                        "Ambulance_Service",
                        "ambulance",
                    }
                },
            },
        },
        [3] = {
            Name = "Fire Gear & Loadout",      -- Give it any name for reference
            ServiceType = "fire",              -- Options: police | ambulance | fire | tow.
            CoordinatesWithHeading = vector4(1688.4211, 3607.4341, 35.3719, 237.2189), -- Vector 4 means: x,y,z,heading
            BlipData = {
                Enabled = true, -- Set to false to disable blip for this gear ped.
                Sprite = 205,
                Display = 2, 
                Category = 2,
                ShortRange = true,
                Colour = 1, 
                Scale = 0.75,
                Alpha = 200, 
            },
            NPCPedData = {  -- It will select one of these settings for the NPC ped model offering the gear to the player.
                [1] = {
                    modelName = "s_m_y_fireman_01", -- This is not an MP ped model
                    props = {},         -- No props needed for non-mp peds.
                    components = {},    -- No components needed for non-mp peds.
                },
            },
            ClothingData = { -- One entry per uniform (model + optional MP outfit + weapons + health).
                [1] = {
                    Name = "Fire Default (Male)",
                    Description = "Male firefighter.",
                    modelName = "s_m_y_fireman_01", -- This is not an MP ped model
                    props = {},         -- No props needed for non-mp peds.
                    components = {},    -- No components needed for non-mp peds.
                    -- WeaponData = only when server is not ESX and not QBCore/QBox (native GTA weapons).
                    WeaponData = {
                        [1] = {weaponName = "weapon_flashlight", ammoCount = 1, componentList = {}},
                        [2] = {weaponName = "weapon_fireextinguisher", ammoCount = 999, componentList = {}},
                        [3] = {weaponName = "weapon_crowbar", ammoCount = 1, componentList = {}},
                    },
                    QBCoreWeaponData = {
                        [1] = {weaponName = "weapon_flashlight", componentList = {}},
                        [2] = {weaponName = "weapon_fireextinguisher", componentList = {}},
                        [3] = {weaponName = "weapon_crowbar", componentList = {}},
                    },
                    ESXWeaponData = {
                        [1] = {weaponName = "weapon_flashlight", ammoCount = 1, componentList = {}},
                        [2] = {weaponName = "weapon_fireextinguisher", ammoCount = 999, componentList = {}},
                        [3] = {weaponName = "weapon_crowbar", ammoCount = 1, componentList = {}},
                    },
                    HealthData = {
                        Enabled = true,
                        Health = 200, -- 101 to 200 (Female peds have max. 150 health)
                        Armor = 200
                    },
                    PermissionRolesOrGroups = {
                        "Fire_Service",
                        "fire",
                    }
                },
                [2] = {
                    Name = "Fire MP Default (Male)",
                    Description = "Male firefighter.",
                    modelName = "mp_m_freemode_01", -- This is an MP ped model
                    props = {
                        { 0, 0, 0 },    -- Hats / Helments
                        { 1, 0, 0 },    -- Glassess
                        { 2, 0, 0 },    -- Misc
                        { 3, 0, 0 },
                    },
                    components = {
                        { 1, 122, 1 },  -- Mask
                        { 2, 1, 1 },    -- Hair
                        { 3, 86, 1 },  -- Upper body
                        { 4, 21, 1 },   -- Legs / Pants
                        { 5, 4, 1 },    -- Bags / Parachutes
                        { 6, 26, 1 },   -- Shoes
                        { 7, 6, 1 },    -- Neck / Scarfs
                        { 8, 18, 1 },   -- Shirt / Accessory
                        { 9, 1, 1 },    -- Body Armor
                        { 10, 2, 1 },   -- Badges / Logos
                        { 11, 24, 1 },  -- Jackets
                    },
                    -- WeaponData = only when server is not ESX and not QBCore/QBox (native GTA weapons).
                    WeaponData = {
                        [1] = {weaponName = "weapon_flashlight", ammoCount = 1, componentList = {}},
                        [2] = {weaponName = "weapon_fireextinguisher", ammoCount = 999, componentList = {}},
                        [3] = {weaponName = "weapon_crowbar", ammoCount = 1, componentList = {}},
                    },
                    QBCoreWeaponData = {
                        [1] = {weaponName = "weapon_flashlight", componentList = {}},
                        [2] = {weaponName = "weapon_fireextinguisher", componentList = {}},
                        [3] = {weaponName = "weapon_crowbar", componentList = {}},
                    },
                    ESXWeaponData = {
                        [1] = {weaponName = "weapon_flashlight", ammoCount = 1, componentList = {}},
                        [2] = {weaponName = "weapon_fireextinguisher", ammoCount = 999, componentList = {}},
                        [3] = {weaponName = "weapon_crowbar", ammoCount = 1, componentList = {}},
                    },
                    HealthData = {
                        Enabled = true,
                        Health = 200, -- 101 to 200 (Female peds have max. 150 health)
                        Armor = 200
                    },
                    PermissionRolesOrGroups = {
                        "Fire_Service",
                        "fire",
                    }
                },
                [3] = {
                    Name = "Fire MP Default (Female)",
                    Description = "Female firefighter.",
                    modelName = "mp_f_freemode_01", -- This is an MP ped model
                    props = {
                        { 0, 0, 0 },    -- Hats / Helments
                        { 1, 0, 0 },    -- Glassess
                        { 2, 0, 0 },    -- Misc
                        { 3, 0, 0 },
                    },
                    components = {
                        { 1, 122, 1 },  -- Mask
                        { 2, 1, 1 },    -- Hair
                        { 3, 86, 1 },  -- Upper body
                        { 4, 21, 1 },   -- Legs / Pants
                        { 5, 4, 1 },    -- Bags / Parachutes
                        { 6, 26, 1 },   -- Shoes
                        { 7, 6, 1 },    -- Neck / Scarfs
                        { 8, 18, 1 },   -- Shirt / Accessory
                        { 9, 1, 1 },    -- Body Armor
                        { 10, 2, 1 },   -- Badges / Logos
                        { 11, 24, 1 },  -- Jackets
                    },
                    -- WeaponData = only when server is not ESX and not QBCore/QBox (native GTA weapons).
                    WeaponData = {
                        [1] = {weaponName = "weapon_flashlight", ammoCount = 1, componentList = {}},
                        [2] = {weaponName = "weapon_fireextinguisher", ammoCount = 999, componentList = {}},
                        [3] = {weaponName = "weapon_crowbar", ammoCount = 1, componentList = {}},
                    },
                    QBCoreWeaponData = {
                        [1] = {weaponName = "weapon_flashlight", componentList = {}},
                        [2] = {weaponName = "weapon_fireextinguisher", componentList = {}},
                        [3] = {weaponName = "weapon_crowbar", componentList = {}},
                    },
                    ESXWeaponData = {
                        [1] = {weaponName = "weapon_flashlight", ammoCount = 1, componentList = {}},
                        [2] = {weaponName = "weapon_fireextinguisher", ammoCount = 999, componentList = {}},
                        [3] = {weaponName = "weapon_crowbar", ammoCount = 1, componentList = {}},
                    },
                    HealthData = {
                        Enabled = true,
                        Health = 200, -- 101 to 200 (Female peds have max. 150 health)
                        Armor = 200
                    },
                    PermissionRolesOrGroups = {
                        "Fire_Service",
                        "fire",
                    }
                },
            },
        },
        [4] = {
            Name = "Tow Gear & Loadout",      -- Give it any name for reference
            ServiceType = "tow",              -- Options: police | ambulance | fire | tow.
            CoordinatesWithHeading = vector4(540.9142, -191.4992, 54.4813, 57.7849), -- Vector 4 means: x,y,z,heading
            BlipData = {
                Enabled = true, -- Set to false to disable blip for this gear ped.
                Sprite = 205,
                Display = 2, 
                Category = 2,
                ShortRange = true,
                Colour = 76, 
                Scale = 0.75,
                Alpha = 200, 
            },
            NPCPedData = {  -- It will select one of these settings for the NPC ped model offering the gear to the player.
                [1] = {
                    modelName = "s_m_y_xmech_01", -- This is not an MP ped model
                    props = {},         -- No props needed for non-mp peds.
                    components = {},    -- No components needed for non-mp peds.
                },
            },
            ClothingData = { -- One entry per uniform (model + optional MP outfit + weapons + health).
                [1] = {
                    Name = "Mechanic Default (Male)",
                    Description = "Male mechanic.",
                    modelName = "s_m_y_xmech_01", -- This is not an MP ped model
                    props = {},         -- No props needed for non-mp peds.
                    components = {},    -- No components needed for non-mp peds.
                    -- WeaponData = only when server is not ESX and not QBCore/QBox (native GTA weapons).
                    WeaponData = {
                        [1] = {weaponName = "weapon_flashlight", ammoCount = 1, componentList = {}},
                        [2] = {weaponName = "weapon_hammer", ammoCount = 1, componentList = {}},
                        [3] = {weaponName = "weapon_wrench", ammoCount = 1, componentList = {}},
                    },
                    QBCoreWeaponData = {
                        [1] = {weaponName = "weapon_flashlight", componentList = {}},
                        [2] = {weaponName = "weapon_hammer", componentList = {}},
                        [3] = {weaponName = "weapon_wrench", componentList = {}},
                    },
                    ESXWeaponData = {
                        [1] = {weaponName = "weapon_flashlight", ammoCount = 1, componentList = {}},
                        [2] = {weaponName = "weapon_hammer", ammoCount = 1, componentList = {}},
                        [3] = {weaponName = "weapon_wrench", ammoCount = 1, componentList = {}},
                    },
                    HealthData = {
                        Enabled = true,
                        Health = 200, -- 101 to 200 (Female peds have max. 150 health)
                        Armor = 200
                    },
                    PermissionRolesOrGroups = {
                        "Tow_Service",
                        "tow",
                    }
                },
                -- [2] = {
                --     Name = "Mechanic MP Default (Male)",
                --     Description = "Male mechanic.",
                --     modelName = "mp_m_freemode_01", -- This is an MP ped model
                --     props = {
                --         { 0, 0, 0 },    -- Hats / Helments
                --         { 1, 0, 0 },    -- Glassess
                --         { 2, 0, 0 },    -- Misc
                --         { 3, 0, 0 },
                --     },
                --     components = {
                --         { 1, 122, 1 },  -- Mask
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
                --     -- WeaponData (no framework)
                --     WeaponData = {
                --         [1] = {weaponName = "weapon_flashlight", ammoCount = 1, componentList = {}},
                --         [2] = {weaponName = "weapon_hammer", ammoCount = 1, componentList = {}},
                --         [3] = {weaponName = "weapon_wrench", ammoCount = 1, componentList = {}},
                --     },
                --     -- QBCoreWeaponData (QBCore/QBox only; see Quick start).
                --     QBCoreWeaponData = {
                --         [1] = {weaponName = "weapon_flashlight", componentList = {}},
                --         [2] = {weaponName = "weapon_hammer", componentList = {}},
                --         [3] = {weaponName = "weapon_wrench", componentList = {}},
                --     },
                --     -- ESXWeaponData (ESX only; see Quick start)
                --     ESXWeaponData = {
                --         [1] = {weaponName = "weapon_flashlight", ammoCount = 1, componentList = {}},
                --         [2] = {weaponName = "weapon_hammer", ammoCount = 1, componentList = {}},
                --         [3] = {weaponName = "weapon_wrench", ammoCount = 1, componentList = {}},
                --     },
                --     HealthData = {
                --         Enabled = true,
                --         Health = 200, -- 101 to 200 (Female peds have max. 150 health)
                --         Armor = 200
                --     },
                --     PermissionRolesOrGroups = {
                --         "Tow_Service",
                --         "tow",
                --     }
                -- },
                -- [3] = {
                --     Name = "Mechanic MP Default (Female)",
                --     Description = "Female mechanic.",
                --     modelName = "mp_f_freemode_01", -- This is an MP ped model
                --     props = {
                --         { 0, 0, 0 },    -- Hats / Helments
                --         { 1, 0, 0 },    -- Glassess
                --         { 2, 0, 0 },    -- Misc
                --         { 3, 0, 0 },
                --     },
                --     components = {
                --         { 1, 122, 1 },  -- Mask
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
                --     -- WeaponData (no framework)
                --     WeaponData = {
                --         [1] = {weaponName = "weapon_flashlight", ammoCount = 1, componentList = {}},
                --         [2] = {weaponName = "weapon_hammer", ammoCount = 1, componentList = {}},
                --         [3] = {weaponName = "weapon_wrench", ammoCount = 1, componentList = {}},
                --     },
                --     -- QBCoreWeaponData (QBCore/QBox only; see Quick start).
                --     QBCoreWeaponData = {
                --         [1] = {weaponName = "weapon_flashlight", componentList = {}},
                --         [2] = {weaponName = "weapon_hammer", componentList = {}},
                --         [3] = {weaponName = "weapon_wrench", componentList = {}},
                --     },
                --     -- ESXWeaponData (ESX only; see Quick start)
                --     ESXWeaponData = {
                --         [1] = {weaponName = "weapon_flashlight", ammoCount = 1, componentList = {}},
                --         [2] = {weaponName = "weapon_hammer", ammoCount = 1, componentList = {}},
                --         [3] = {weaponName = "weapon_wrench", ammoCount = 1, componentList = {}},
                --     },
                --     HealthData = {
                --         Enabled = true,
                --         Health = 200, -- 101 to 200 (Female peds have max. 150 health)
                --         Armor = 200
                --     },
                --     PermissionRolesOrGroups = {
                --         "Tow_Service",
                --         "tow",
                --     }
                -- },
            },
        },
        -- Add a new location here...
        -- [5] = {...}
    }
}