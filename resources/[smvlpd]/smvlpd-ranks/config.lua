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
    police = {
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
},
    ambulance = {
        [1] = 'Cadete',
        [2] = 'EMT',
        [3] = 'AEMT',
        [4] = 'Paramedico',
        [5] = 'Paramedico Senior',
        [6] = 'Medico',
        [7] = 'Cirujano',
        [8] = 'Especialista',
        [9] = 'Supervisor',
    },


       
    fire = {
    [1] = 'cadete',
    [2] = 'bombero_2',
    [3] = 'bombero_3',
    [4] = 'ingeniero',
    [5] = 'teniente',
    [6] = 'capitan',
    [7] = 'jefe_batallon',
    [8] = 'jefe_division',
    [9] = 'ayudante_jefe',
    [10] = 'jefe_bomberos'
   
    },
    tow = {
        [1] = 'Aprendiz LSDOT',
        [2] = 'Operador LSDOT',
        [3] = 'Ingeniero LSDOT',
        [4] = 'Supervisor LSDOT',
        [5] = 'Capataz LSDOT',
        [6] = 'Jefe de Operaciones LSDOT',
        [7] = 'Subdirector LSDOT',
        [8] = 'Director LSDOT',
    }
}


-- Progresion automatica por puntos. Los puntos son acumulativos y nunca se gastan.
-- Solo los rangos 1-11 forman parte de la progresion automatica.
Config.RankPoints = {
    police = {
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
},
    ambulance = {
        [1] = 0,
        [2] = 5000,
        [3] = 10000,
        [4] = 25000,
        [5] = 50000,
        [6] = 75000,
        [7] = 125000,
        [8] = 180000,
        [9] = 250000,
    },
    fire = {
        [1] = 0,
        [2] = 3000,
        [3] = 7500,
        [4] = 15000,
        [5] = 25000,
        [6] = 45000,
        [7] = 65000,
        [8] = 80000,
        [9] = 150000,
        [10] = 250000,
    },
    tow = {
        [1] = 0,
        [2] = 3000,
        [3] = 7500,
        [4] = 15000,
        [5] = 30000,
        [6] = 50000,
        [7] = 80000,
        [8] = 120000,
    }
}


-- Puntos complementarios base. La integracion con callouts/acciones se hara en la siguiente fase.
Config.PointRewards = {
    ersTask = 15,
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
    fire_dumpster            = "calloutNormal",
    gas_smell                = "calloutNormal",
    hitnrun_ped              = "calloutEasy",
    illegal_party            = "calloutEasy",
    inj_bone_fracture        = "calloutEasy",
    inj_drowning             = "calloutNormal",
    inj_stroke               = "calloutNormal",
    inj_suffocation          = "calloutNormal",
    missing_found            = "calloutEasy",
    officer_assist           = "calloutEasy",
    overheated_transformer   = "calloutEasy",
    parachute_incident       = "calloutEasy",
    repeated_hotline         = "calloutEasy",
    stuck_roof               = "calloutEasy",
    traffic_incident         = "calloutEasy",
    unknown_smoke            = "calloutNormal",
    vehicle_fire             = "calloutNormal",

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
    drug_overdose            = "calloutComplex",
    fight                    = "calloutNormal",
    fire                     = "calloutNormal",
    fire_ped                 = "calloutNormal",
    fire_petrol              = "calloutComplex",
    house_fire               = "calloutComplex",
    illegal_hunting          = "calloutNormal",
    illegal_race             = "calloutNormal",
    inj_cardiac_arrest       = "calloutComplex",
    inj_electrocution        = "calloutComplex",
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
    aircraft_hard_landing    = "calloutHighRisk",
    airport_fire             = "calloutHighRisk",
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
    train_derailed           = "calloutHighRisk",

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
    Stolen_motorbike         = "calloutNormal",
}





Config.Ranks = {

    police = {
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
    }
    },
    ambulance = {
         [1] = {
            label = 'Cadete',
            image = 'cadete.png',
            weapons = {}
        },

        [2] = {
            label = 'EMT',
            image = 'EMT.png',
            weapons = {}
        },

        [3] = {
            label = 'AEMT',
            image = 'AEMT.png',
            weapons = {}
        },

        [4] = {
            label = 'Paramedico',
            image = 'paramedico.png',
            weapons = {}
        },

        [5] = {
            label = 'Paramedico Senior',
            image = 'paramedico_senior.png',
            weapons = {}
        },

        [6] = {
            label = 'Medico',
            image = 'medico.png',
            weapons = {}
        },

        [7] = {
            label = 'Cirujano',
            image = 'cirujano.png',
            weapons = {}
        },

        [8] = {
            label = 'Especialista',
            image = 'especialista.png',
            weapons = {}
        },

        [9] = {
            label = 'Supervisor',
            image = 'supervisor.png',
            weapons = {}
        },

        [10] = {
            label = 'Director Adjunto',
            image = 'director_adjunto.png',
            administrative = true
        },

        [11] = {
            label = 'Director EMS',
            image = 'director_ems.png',
            administrative = true
        },

        [12] = {
            label = 'Director General',
            image = 'director_general.png',
            administrative = true
        }

    },

    -- Servicio independiente de Bomberos. Sin armas ni imágenes hasta que se
    -- configuren recursos propios; no altera los rangos de Policía o EMS.
    fire = {
        [1] = { label = 'Cadete', image = nil, weapons = {} },
        [2] = { label = 'Bombero II', image = nil, weapons = {} },
        [3] = { label = 'Bombero III', image = nil, weapons = {} },
        [4] = { label = 'Ingeniero', image = nil, weapons = {} },
        [5] = { label = 'Teniente', image = 'teniente.png', weapons = {} },
        [6] = { label = 'Capitán', image = 'capitan.png', weapons = {} },
        [7] = { label = 'Jefe de Batallón', image = 'jefe_batallon.png', weapons = {} },
        [8] = { label = 'Jefe de División', image = 'jefe_division.png', weapons = {} },
        [9] = { label = 'Ayudante de Jefe', image = 'ayudante_jefe.png', weapons = {} },
        [10] = { label = 'Jefe de Bomberos', image = 'jefe_bomberos.png', weapons = {} }
    },

    tow = {
        [1] = {
            label = 'Aprendiz LSDOT',
            image = 'aprendiz.png',
            weapons = {}
        },

        [2] = {
            label = 'Operador LSDOT',
            image = 'operador.png',
            weapons = {}
        },

        [3] = {
            label = 'Ingeniero LSDOT',
            image = 'ingeniero.png',
            weapons = {}
        },

        [4] = {
            label = 'Supervisor LSDOT',
            image = 'supervisor.png',
            weapons = {}
        },

        [5] = {
            label = 'Capataz LSDOT',
            image = 'capataz.png',
            weapons = {}
        },

        [6] = {
            label = 'Jefe de Operaciones LSDOT',
            image = 'jefe_operaciones.png',
            weapons = {}
        },

        [7] = {
            label = 'Subdirector LSDOT',
            image = 'subdirector.png',
            weapons = {},
            administrative = true
        },

        [8] = {
            label = 'Director LSDOT',
            image = 'director.png',
            weapons = {},
            administrative = true
        }
    }

}

-- Los uniformes ya existen en EUP. Esta tabla deja documentada la asignacion
-- y preparada la integracion posterior con los identificadores de tus conjuntos.

