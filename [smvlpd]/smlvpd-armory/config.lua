Config = {}

Config.Armories = {
    {
        label = "Armería Central",
        coords = vec3(452.28, -980.03, 30.69)
    }
}

Config.Loadouts = {

    novato = {
        armour = 100,
        weapons = {
            { weapon = "WEAPON_FLASHLIGHT" },
            { weapon = "WEAPON_STUNGUN_MP" },
            { weapon = "WEAPON_FLARE", ammo = 5 }
        }
    },

    p2 = {
        armour = 100,
        weapons = {
            { weapon = "WEAPON_FLASHLIGHT" },
            { weapon = "WEAPON_STUNGUN_MP" },
            { weapon = "WEAPON_FLARE", ammo = 5 },
            { weapon = "WEAPON_COMBATPISTOL", ammo = 60, flashlight = true }
        }
    },

    p3 = {
        armour = 100,
        weapons = {
            { weapon = "WEAPON_FLASHLIGHT" },
            { weapon = "WEAPON_STUNGUN_MP" },
            { weapon = "WEAPON_FLARE", ammo = 5 },
            { weapon = "WEAPON_PISTOL_MK2", ammo = 60, flashlight = true }
        }
    },

    p3plus1 = {
        armour = 100,
        weapons = {
            { weapon = "WEAPON_FLASHLIGHT" },
            { weapon = "WEAPON_STUNGUN_MP" },
            { weapon = "WEAPON_FLARE", ammo = 5 },
            { weapon = "WEAPON_PISTOL_MK2", ammo = 60, flashlight = true },
            { weapon = "WEAPON_PUMPSHOTGUN_MK2", ammo = 32, flashlight = true }
        }
    },

    sargento1 = {
        inherit = "p3plus1"
    },

    sargento2 = {
        armour = 100,
        weapons = {
            { weapon = "WEAPON_FLASHLIGHT" },
            { weapon = "WEAPON_STUNGUN_MP" },
            { weapon = "WEAPON_FLARE", ammo = 5 },
            { weapon = "WEAPON_HEAVYPISTOL", ammo = 60, flashlight = true },
            { weapon = "WEAPON_PUMPSHOTGUN_MK2", ammo = 32, flashlight = true }
        }
    },

    teniente1 = {
        inherit = "sargento2"
    },

    teniente2 = {
        armour = 100,
        weapons = {
            { weapon = "WEAPON_FLASHLIGHT" },
            { weapon = "WEAPON_STUNGUN_MP" },
            { weapon = "WEAPON_FLARE", ammo = 5 },
            { weapon = "WEAPON_HEAVYPISTOL", ammo = 60, flashlight = true },
            { weapon = "WEAPON_PUMPSHOTGUN_MK2", ammo = 32, flashlight = true },
            { weapon = "WEAPON_SMG_MK2", ammo = 180, flashlight = true }
        }
    },

    capitan1 = {
        inherit = "teniente2"
    },

    capitan2 = {
        inherit = "teniente2"
    },

    capitan3 = {
        armour = 100,
        weapons = {
            { weapon = "WEAPON_FLASHLIGHT" },
            { weapon = "WEAPON_STUNGUN_MP" },
            { weapon = "WEAPON_FLARE", ammo = 5 },
            { weapon = "WEAPON_HEAVYPISTOL", ammo = 60, flashlight = true },
            { weapon = "WEAPON_PUMPSHOTGUN_MK2", ammo = 32, flashlight = true },
            { weapon = "WEAPON_SMG_MK2", ammo = 180, flashlight = true },
            { weapon = "WEAPON_CARBINERIFLE_MK2", ammo = 240, flashlight = true }
        }
    },

    comandante = {
        inherit = "capitan3"
    },

    ayudantejefe = {
        inherit = "capitan3"
    },

    jefepolicia = {
        inherit = "capitan3"
    }

}