Config = {}

Config.ServiceType = 'fire'
Config.InteractionDistance = 2.0
Config.PointDrawDistance = 50.0
Config.DefaultRank = 1

Config.Text = {
    ServiceOn = '[E] Entrar de servicio como Bombero',
    ServiceOff = '[E] Salir de servicio de Bomberos',
    Garage = '[E] Garaje de Bomberos',
    Store = '[E] Guardar vehiculo de Bomberos',
    Locker = '[E] Vestuario de Bomberos'
}

Config.Marker = {
    type = 24,
    scale = vec3(0.45, 0.45, 0.45),
    color = { r = 220, g = 45, b = 35, a = 190 }
}

-- AÑADIR RANGOS DE BOMBEROS AQUÍ. Las claves deben coincidir con uniforms.lua.
Config.Ranks = {
    [1] = { name = 'cadete' },
    [2] = { name = 'bombero_2' },
    [3] = { name = 'bombero_3' },
    [4] = { name = 'ingeniero' },
    [5] = { name = 'teniente' },
    [6] = { name = 'capitan' },
    [7] = { name = 'jefe_batallon' },
    [8] = { name = 'jefe_division' },
    [9] = { name = 'ayudante_jefe' },
    [10] = { name = 'jefe_bomberos' }
}

-- AÑADIR PUNTOS DE SERVICIO AQUÍ.
Config.ServicePoints = {
    -- { name = 'Central Bomberos', coords = vec3(x, y, z) }
}

-- AÑADIR GARAJES AQUÍ.
Config.Garages = {
    {
        name = 'Estación Davis',
        marker = vec3(206.1924, -1661.5367, 29.8032),
        spawn = vec4(212.6450, -1650.1761, 29.8032, 322.4126),
        store = vec3(209.9021, -1646.2655, 29.8032)
    },
    {
        name = 'Estación El Burro',
        marker = vec3(1208.1218, -1480.9943, 34.8595),
        spawn = vec4(1205.0499, -1468.8496, 34.8595, 358.9514),
        store = vec3(1200.3875, -1467.1221, 34.8595)
    },
    {
        name = 'Estación Paleto',
        marker = vec3(-377.6346, 6122.0049, 31.4752),
        spawn = vec4(-371.1192, 6130.2632, 31.4446, 52.9641),
        store = vec3(-360.4156, 6132.1099, 31.4401)
    },
    {
        name = 'Estación Rockford',
        marker = vec3(-632.5903, -113.7082, 38.0623),
        spawn = vec4(-641.0996, -114.1747, 37.9598, 125.6312),
        store = vec3(-645.2010, -108.4951, 37.9290)
    },
    {
        name = 'Estación Sandy Shores',
        marker = vec3(1690.6205, 3589.1426, 35.6210),
        spawn = vec4(1714.5295, 3597.0200, 35.3137, 196.2194),
        store = vec3(1710.5735, 3594.9204, 35.4204)
    }
}

-- AÑADIR VESTUARIOS AQUÍ.
Config.LockerRooms = {
    { name = 'Estación Davis', coords = vec3(214.6444, -1650.9832, 29.8032) },
    { name = 'Estación El Burro', coords = vec3(1207.5073, -1467.3682, 34.8595) },
    { name = 'Estación Paleto', coords = vec3(-380.2392, 6118.5977, 31.8487) },
    { name = 'Estación Rockford', coords = vec3(-633.2742, -120.8461, 39.0138) },
    { name = 'Estación Sandy Shores', coords = vec3(1692.0574, 3585.7756, 35.6209) }
}

-- AÑADIR VEHÍCULOS POR RANGO AQUÍ. No se han inventado modelos.
Config.VehiclesByRank = {
    [1] = {
        -- { model = 'modelo_vehiculo', label = 'Nombre visible', livery = 0 }
    },
    [2] = {},
    [3] = {},
    [4] = {},
    [5] = {},
    [6] = {},
    [7] = {},
    [8] = {},
    [9] = {},
    [10] = {}
}