Config = {}

-- Permiso ACE necesario para abrir el panel de gestion y modificar rangos.
-- Consulta README.md para asignarlo a los administradores del servidor.
Config.ManagementAce = 'smvlpd.ranks.manage'

Config.ServiceLabels = {
    police = 'Policia',
    ambulance = 'Ambulancia',
    fire = 'Bomberos',
    tow = 'Grua'
}

-- Los uniformes ya existen en EUP. Esta tabla deja documentada la asignacion
-- y preparada la integracion posterior con los identificadores de tus conjuntos.
Config.Uniforms = {
    [1] = 'Novato - manga larga sin galones',
    [2] = 'Oficial P2 - manga corta',
    [3] = 'Oficial P3 - manga corta',
    [4] = 'Senior - manga corta',
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
Config.ERSCalloutDifficulties = {

    -- =========================
    -- MUY FÁCIL (50 puntos)
    -- =========================
    abandoned_vehicle        = "calloutVeryEasy",
    animal_on_road           = "calloutVeryEasy",
    animal_on_tracks         = "calloutVeryEasy",
    drunk_ped                = "calloutVeryEasy",
    drunk_entering_vehicle   = "calloutVeryEasy",
    illegal_dumping          = "calloutVeryEasy",
    motorist_trouble         = "calloutVeryEasy",
    road_rubble              = "calloutVeryEasy",
    smoking_weed             = "calloutVeryEasy",
    suspicious_situation     = "calloutVeryEasy",
    taxi_fare_dodger         = "calloutVeryEasy",
    unidentified_object      = "calloutVeryEasy",

    -- =========================
    -- FÁCIL (75 puntos)
    -- =========================
    airport_tresspass        = "calloutEasy",
    animals_escaped          = "calloutEasy",
    anpr_alert               = "calloutEasy",
    bicycle_accident         = "calloutEasy",
    boat_engine_fail         = "calloutEasy",
    climate_protest          = "calloutEasy",
    domestic_dispute         = "calloutEasy",
    driving_seizure          = "calloutEasy",
    emergency_heli_land      = "calloutEasy",
    fall_height              = "calloutEasy",
    fall_stairs              = "calloutEasy",
    fire_dumpster            = "calloutEasy",
    gas_smell                = "calloutEasy",
    hitnrun_ped              = "calloutEasy",
    illegal_party            = "calloutEasy",
    inj_bone_fracture        = "calloutEasy",
    inj_drowning             = "calloutEasy",
    inj_stroke               = "calloutEasy",
    inj_suffocation          = "calloutEasy",
    missing_found            = "calloutEasy",
    officer_assist           = "calloutEasy",
    overheated_transformer   = "calloutEasy",
    parachute_incident       = "calloutEasy",
    repeated_hotline         = "calloutEasy",
    stuck_roof               = "calloutEasy",
    traffic_incident         = "calloutEasy",
    unknown_smoke            = "calloutEasy",
    vehicle_fire             = "calloutEasy",

    -- =========================
    -- NORMAL (100 puntos)
    -- =========================
    animal_dog_attack        = "calloutNormal",
    animal_fire              = "calloutNormal",
    animals_under_attack     = "calloutNormal",
    arson                    = "calloutNormal",
    atm_robbery              = "calloutNormal",
    boat_fire                = "calloutNormal",
    boat_migrants            = "calloutNormal",
    brandishing              = "calloutNormal",
    brandishing_transit      = "calloutNormal",
    construction_incident    = "calloutNormal",
    drug_deal                = "calloutNormal",
    drug_overdose            = "calloutNormal",
    fight                    = "calloutNormal",
    fire                     = "calloutNormal",
    fire_ped                 = "calloutNormal",
    fire_petrol              = "calloutNormal",
    house_fire               = "calloutNormal",
    illegal_hunting          = "calloutNormal",
    illegal_race             = "calloutNormal",
    inj_cardiac_arrest       = "calloutNormal",
    inj_electrocution        = "calloutNormal",
    protest_haybales         = "calloutNormal",
    reckless_driving_heavy   = "calloutNormal",
    rock_thrower             = "calloutNormal",
    sr_stranded_island       = "calloutNormal",
    sr_wounded_hiker         = "calloutNormal",
    suspect_identified       = "calloutNormal",
    tree_fire                = "calloutNormal",
    tunnel_smoke             = "calloutNormal",
    valet_theft              = "calloutNormal",

    -- =========================
    -- COMPLEJO (150 puntos)
    -- =========================
    aircraft_hard_landing    = "calloutComplex",
    airport_fire             = "calloutComplex",
    animal_lion_loose        = "calloutComplex",
    animal_rat_plague        = "calloutComplex",
    capsized_bus             = "calloutComplex",
    capsized_vehicle         = "calloutComplex",
    drug_warehouse           = "calloutComplex",
    highway_pileup           = "calloutComplex",
    illegal_mining           = "calloutComplex",
    moneytruck_incident      = "calloutComplex",
    prisoner_escape          = "calloutComplex",
    prisoner_escape_bus      = "calloutComplex",
    road_rage                = "calloutComplex",
    shop_robbery             = "calloutComplex",
    stolen_boat              = "calloutComplex",
    stolen_helicopter        = "calloutComplex",
    stolen_plane             = "calloutComplex",
    stolen_sportscar         = "calloutComplex",
    stolen_tractor           = "calloutComplex",
    stolen_truck             = "calloutComplex",
    train_derailed           = "calloutComplex",

    -- =========================
    -- ALTO RIESGO (200 puntos)
    -- =========================
    armed_robbery            = "calloutHighRisk",
    moneytruck_raid          = "calloutHighRisk",
    possible_murder          = "calloutHighRisk",
    riot                     = "calloutHighRisk",
    shots_fired              = "calloutHighRisk",
    taxi_kidnap              = "calloutHighRisk",
    unidentified_body        = "calloutHighRisk",
    vehicle_theft            = "calloutHighRisk",
    wildfire                 = "calloutHighRisk",
    Stolen_motorbike         = "calloutHighRisk",
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
        label = 'Senior',
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
