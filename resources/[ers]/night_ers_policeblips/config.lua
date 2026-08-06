Config = {}

-- Frecuencia de actualizacion de los blips de unidades de servicio.
Config.UpdateInterval = 1000

Config.ServiceBlips = {
    police = {
        sprite = 1,
        colour = 3,
        scale = 0.85,
        name = 'Unidad policial'
    },
    ambulance = {
        sprite = 1,
        colour = 1,
        scale = 0.85,
        name = 'Ambulancia'
    },
    fire = {
        sprite = 1,
        colour = 5,
        scale = 0.85,
        name = 'Bomberos'
    },
    tow = {
        sprite = 1,
        colour = 2,
        scale = 0.85,
        name = 'Grua'
    }
}

Config.Help = {
    command = 'ayuda',
    cooldownSeconds = 30,
    offerSeconds = 20,
    durationSeconds = 120,
    arrivalDistance = 25.0,
    acceptKey = 'Y',
    rejectKey = 'X',
    sprite = 161,
    colour = 1,
    scale = 1.2,
    name = 'Solicitud de ayuda'
}
