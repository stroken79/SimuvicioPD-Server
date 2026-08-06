Config = {}

-- Permiso ACE necesario para abrir el panel de gestion y modificar rangos.
-- Consulta README.md para asignarlo a los administradores del servidor.
Config.ManagementAce = 'smvlpd.ranks.manage'

-- Los uniformes ya existen en EUP. Esta tabla deja documentada la asignacion
-- y preparada la integracion posterior con los identificadores de tus conjuntos.
Config.Uniforms = {
    [1] = 'Cadete',
    [2] = 'EMT',
    [3] = 'AEMT',
    [4] = 'Paramédico',
    [5] = 'Paramédico Senior',
    [6] = 'Médico',
    [7] = 'Cirujano',
    [8] = 'Especialista',
    [9] = 'Supervisor',
    [10] = 'Director Adjunto',
    [11] = 'Director EMS',
    [12] = 'Director General',
}


-- Progresion automatica por puntos. Los puntos son acumulativos y nunca se gastan.
-- Solo los rangos 1-9 forman parte de la progresion automatica.
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

-- Los avisos no incluidos se consideran de dificultad normal.
Config.CalloutDifficulties = {
    ['Vehiculo abandonado'] = 'calloutVeryEasy',
    ['Vehiculo muy pequeno'] = 'calloutVeryEasy',
    ['Conductor demasiado lento'] = 'calloutEasy',
    ['Vehiculo sobredimensionado'] = 'calloutEasy',
    ['Venta de drogas en la playa'] = 'calloutComplex',
    ['Secuestro'] = 'calloutComplex',
    ['Secuestro en furgoneta'] = 'calloutComplex',
    ['Tirador activo en el muelle'] = 'calloutHighRisk',
    ['Persecucion de sospechosos armados'] = 'calloutHighRisk',
    ['Tiradores con armas pesadas'] = 'calloutHighRisk',
    ['Secta con rehenes'] = 'calloutHighRisk',
}

-- Clasificación de los avisos de night_ers por su identificador interno.
-- Cualquier aviso de ERS no incluido se valora como normal (100 puntos).
Config.ERSCalloutDifficulties = {
    abandoned_vehicle = 'calloutVeryEasy',
    animal_on_road = 'calloutVeryEasy',
    taxi_fare_dodger = 'calloutEasy',
    drunk_ped = 'calloutEasy',
    traffic_incident = 'calloutNormal',
    domestic_dispute = 'calloutNormal',
    vehicle_theft = 'calloutComplex',
    drug_deal = 'calloutComplex',
    shop_robbery = 'calloutComplex',
    armed_robbery = 'calloutHighRisk',
    shots_fired = 'calloutHighRisk',
    moneytruck_raid = 'calloutHighRisk',
    prisoner_escape = 'calloutHighRisk',
    riot = 'calloutHighRisk',
}

Config.Ranks = {
    [1] = {
        label = 'Prueba EMS',
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
            
         -- { name = 'WEAPON_FLASHLIGHT', ammo = 1 },--
    
    },

    [4] = {
        label = 'Paramédico',
        image = 'Paramédico.png',
        weapons = {}
    },

    [5] = {
        label = 'Paramédico Senior',
        image = 'Paramédico Senior.png',
        weapons = {}
    },

    [6] = {
        label = 'Médico',
        image = 'Médico.png',
        weapons = {}
    },

    [7] = {
        label = 'Cirujano',
        image = 'Cirujano.png',
        weapons = {}
    },

    [8] = {
        label = 'Especialista',
        image = 'Especialista.png',
        weapons = {}
    },

    [9] = {
        label = 'Supervisor',
        image = 'Supervisor.png',
        weapons = {}
    },

    [10] = {
        label = 'Director Adjunto',
        image = 'Director Adjunto.png',
        administrative = true
    },

    [11] = {
        label = 'Director EMS',
        image = 'Director EMS.png',
        administrative = true
    },

    [12] = {
        label = 'Director General',
        image = 'Director General.png',
        administrative = true
    },
}
