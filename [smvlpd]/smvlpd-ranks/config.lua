Config = {}

-- Permiso ACE necesario para abrir el panel de gestion y modificar rangos.
-- Consulta README.md para asignarlo a los administradores del servidor.
Config.ManagementAce = 'smvlpd.ranks.manage'

-- Los uniformes ya existen en EUP. Esta tabla deja documentada la asignacion
-- y preparada la integracion posterior con los identificadores de tus conjuntos.
Config.Uniforms = {
    [1] = 'Novato - manga larga sin galones',
    [2] = 'Oficial P2 - manga corta',
    [3] = 'Oficial P3 - manga corta',
    [4] = 'Oficial P3+1 / Senior - manga corta',
    [5] = 'Sargento I - manga corta',
    [6] = 'Sargento II - manga corta',
    [7] = 'Teniente I - manga larga',
    [8] = 'Teniente II - manga larga',
    [9] = 'Capitan I - manga larga',
    [10] = 'Capitan II - manga larga',
    [11] = 'Capitan III - manga larga',
}


-- Progresion automatica por puntos. Los puntos son acumulativos y nunca se gastan.
-- Solo los rangos 1-11 forman parte de la progresion automatica.
Config.RankPoints = {
    [1] = 0,
    [2] = 2500,
    [3] = 7500,
    [4] = 15000,
    [5] = 30000,
    [6] = 50000,
    [7] = 80000,
    [8] = 120000,
    [9] = 175000,
    [10] = 250000,
    [11] = 350000,
}

-- Puntos complementarios base. La integracion con callouts/acciones se hara en la siguiente fase.
Config.PointRewards = {
    calloutVeryEasy = 50,
    calloutEasy = 75,
    calloutNormal = 100,
    calloutComplex = 150,
    calloutHighRisk = 200,
    arrest = 25,
    citation = 15,
    breathalyzer = 10,
    drugTest = 10,
    tow = 10,
    searchPerson = 5,
    searchVehicle = 5,
    documents = 5,
    investigation = 5,
    minorAction = 5,
}

Config.Ranks = {
    [1] = {
        label = 'Novato',
        image = nil,
        weapons = {
            { name = 'WEAPON_STUNGUN', ammo = 5 },
            { name = 'WEAPON_FLASHLIGHT', ammo = 1 },
        }
    },

    [2] = {
        label = 'Oficial P2',
        image = nil,
        weapons = {
            { name = 'WEAPON_PISTOL', ammo = 72 },
            { name = 'WEAPON_STUNGUN', ammo = 5 },
            { name = 'WEAPON_FLASHLIGHT', ammo = 1 },
        }
    },

    [3] = {
        label = 'Oficial P3',
        image = 'p3.png',
        weapons = {
            { name = 'WEAPON_PISTOL', ammo = 72, components = { 'COMPONENT_AT_PI_FLSH' } },
            { name = 'WEAPON_STUNGUN', ammo = 5 },
            { name = 'WEAPON_FLASHLIGHT', ammo = 1 },
        }
    },

    [4] = {
        label = 'Oficial P3+1 / Senior',
        image = 'senior.png',
        weapons = {
            { name = 'WEAPON_PISTOL', ammo = 72, components = { 'COMPONENT_AT_PI_FLSH' } },
            { name = 'WEAPON_STUNGUN', ammo = 5 },
            { name = 'WEAPON_FLASHLIGHT', ammo = 1 },
            { name = 'WEAPON_PUMPSHOTGUN', ammo = 24 },
        }
    },

    [5] = {
        label = 'Sargento I',
        image = 'sargento1.png',
        weapons = {
            { name = 'WEAPON_PISTOL', ammo = 72, components = { 'COMPONENT_AT_PI_FLSH' } },
            { name = 'WEAPON_STUNGUN', ammo = 5 },
            { name = 'WEAPON_FLASHLIGHT', ammo = 1 },
            { name = 'WEAPON_PUMPSHOTGUN', ammo = 24 },
        }
    },

    [6] = {
        label = 'Sargento II',
        image = 'sargento2.png',
        weapons = {
            { name = 'WEAPON_PISTOL50', ammo = 54 },
            { name = 'WEAPON_STUNGUN', ammo = 5 },
            { name = 'WEAPON_FLASHLIGHT', ammo = 1 },
            { name = 'WEAPON_PUMPSHOTGUN', ammo = 24 },
        }
    },

    [7] = {
        label = 'Teniente I',
        image = 'teniente.png',
        weapons = {
            { name = 'WEAPON_PISTOL50', ammo = 54 },
            { name = 'WEAPON_STUNGUN', ammo = 5 },
            { name = 'WEAPON_FLASHLIGHT', ammo = 1 },
            { name = 'WEAPON_PUMPSHOTGUN', ammo = 24 },
        }
    },

    [8] = {
        label = 'Teniente II',
        image = 'teniente.png',
        weapons = {
            { name = 'WEAPON_PISTOL50', ammo = 54 },
            { name = 'WEAPON_STUNGUN', ammo = 5 },
            { name = 'WEAPON_FLASHLIGHT', ammo = 1 },
            { name = 'WEAPON_PUMPSHOTGUN', ammo = 24 },
            { name = 'WEAPON_CARBINERIFLE', ammo = 90 },
        }
    },

    [9] = {
        label = 'Capitan I',
        image = 'capitan.png',
        weapons = {
            { name = 'WEAPON_PISTOL50', ammo = 54 },
            { name = 'WEAPON_STUNGUN', ammo = 5 },
            { name = 'WEAPON_FLASHLIGHT', ammo = 1 },
            { name = 'WEAPON_PUMPSHOTGUN', ammo = 24 },
            { name = 'WEAPON_CARBINERIFLE', ammo = 90 },
        }
    },

    [10] = {
        label = 'Capitan II',
        image = 'capitan.png',
        weapons = {
            { name = 'WEAPON_PISTOL50', ammo = 54 },
            { name = 'WEAPON_STUNGUN', ammo = 5 },
            { name = 'WEAPON_FLASHLIGHT', ammo = 1 },
            { name = 'WEAPON_PUMPSHOTGUN', ammo = 24 },
            { name = 'WEAPON_CARBINERIFLE', ammo = 90 },
        }
    },

    [11] = {
        label = 'Capitan III',
        image = 'capitan.png',
        weapons = {
            { name = 'WEAPON_PISTOL50', ammo = 54 },
            { name = 'WEAPON_STUNGUN', ammo = 5 },
            { name = 'WEAPON_FLASHLIGHT', ammo = 1 },
            { name = 'WEAPON_PUMPSHOTGUN', ammo = 24 },
            { name = 'WEAPON_CARBINERIFLE', ammo = 90 },
            { name = 'WEAPON_MARKSMANRIFLE', ammo = 30 },
        }
    },

    [12] = {
        label = 'Commander / Comandante',
        image = 'comandante.png',
        administrative = true
    },

    [13] = {
        label = 'Assistant Chief / Jefe asistente',
        image = 'ayudante.png',
        administrative = true
    },

    [14] = {
        label = 'Chief of Police / Jefe de Policia',
        image = 'jefe.png',
        administrative = true
    },
}
