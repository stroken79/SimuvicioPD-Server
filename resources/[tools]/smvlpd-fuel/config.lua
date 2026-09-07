Config = {}

Config.RequireEmergencyDuty = true
Config.RequireDriverSeat = true
Config.RefuelKey = 38 -- E
Config.RefuelDistance = 5.0
Config.DrawDistance = 30.0
Config.RefuelRate = 18.0 -- porcentaje por segundo
Config.FuelTick = 250
Config.MaxFuel = 100.0
Config.StartingFuel = 100.0
Config.ShowHelp = true

-- Blips de las gasolineras publicas en el mapa.
Config.ShowGasStationBlips = true
Config.GasStationBlip = {
    sprite = 361, -- surtidor de gasolina de GTA V
    color = 1,
    scale = 0.75,
    shortRange = true,
    name = "Gasolinera"
}

-- Consumo propio del sistema (porcentaje de combustible por segundo).
-- Se calcula segun velocidad y RPM para que el nivel baje de forma visible y progresiva.
Config.ConsumptionTick = 1000
Config.BaseConsumptionPerSecond = 0.008
Config.SpeedConsumptionPerKmH = 0.00008
Config.RpmConsumptionPerUnit = 0.008

-- Vehiculos de servicio actualmente usados en SIMUVICIOPD.
-- La lista se basa en los vehiculos configurados para LSPD, EMS, LSFD y LSDOT.
Config.EmergencyModels = {
    -- LSPD - flota actual
    'pd8', 'nkscout2020', 'pd9', 'pd', 'pd4', 'pd3', 'pd5', 'pd6', 'pd10', 'police4', 'ndds63sivil',
    -- LSPD - modelos de configuraciones anteriores que siguen pudiendo existir
    'polvic', 'charger', 'explorer14', 'explorer16', 'expedition', 'unmarked', 'f350', 'scout2020',

    -- EMS
    'ambulance', 'qrv', 'dodgeems',

    -- LSFD
    'firetruk', 'pumper', 'ferrara', 'spartan', 'gmc',

    -- LSDOT
    'towtruck', 'towtruck2', 'f450towtruk', '17silverado'
}

-- Radio de deteccion alrededor del surtidor. No hace falta estar exactamente encima.
Config.PumpDetectionRadius = 7.0

Config.GasStations = {
    vec3(49.4187, 2778.793, 58.043),
    vec3(263.894, 2606.463, 44.983),
    vec3(1039.958, 2671.134, 39.550),
    vec3(1207.260, 2660.175, 37.899),
    vec3(2539.685, 2594.192, 37.944),
    vec3(2679.858, 3263.946, 55.240),
    vec3(2005.055, 3773.887, 32.403),
    vec3(1687.156, 4929.392, 42.078),
    vec3(1701.314, 6416.028, 32.763),
    vec3(179.857, 6602.839, 31.868),
    vec3(-94.4619, 6419.594, 31.489),
    vec3(-2554.996, 2334.40, 33.078),
    vec3(-1800.375, 803.661, 138.651),
    vec3(-1437.622, -276.747, 46.207),
    vec3(-2096.243, -320.286, 13.168),
    vec3(-724.619, -935.163, 19.214),
    vec3(-526.019, -1211.003, 18.184),
    vec3(-70.2148, -1761.792, 29.534),
    vec3(265.648, -1261.309, 29.292),
    vec3(819.653, -1028.846, 26.403),
    vec3(1208.951, -1402.567, 35.224),
    vec3(1181.381, -330.847, 69.316),
    vec3(620.843, 269.100, 103.089),
    vec3(2581.321, 362.039, 108.468),
    vec3(176.631, -1562.025, 29.263),
    vec3(-319.292, -1471.715, 30.549),
    vec3(1784.324, 3330.55, 41.253),
}

Config.Marker = {
    type = 1,
    scale = vec3(0.55, 0.55, 0.35),
    color = { r = 0, g = 140, b = 255, a = 180 },
}

Config.EmergencyServices = {
    police = true,
    ambulance = true,
    fire = true,
    tow = true,
}
