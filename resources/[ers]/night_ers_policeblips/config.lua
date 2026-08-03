Config = {}

-- Frecuencia de actualizacion de los blips policiales.
Config.UpdateInterval = 1000

Config.PoliceBlip = {
    sprite = 1,
    colour = 3,
    scale = 0.85,
    name = 'Unidad policial'
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
