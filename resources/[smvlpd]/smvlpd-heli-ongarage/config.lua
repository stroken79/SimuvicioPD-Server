Config = {}

Config.InteractionDistance = 2.0
Config.StoreInteractionDistance = 10.0
Config.PointDrawDistance = 50.0
Config.ModelLoadTimeout = 10000

Config.Text = {
    Garage = '[E] Garaje de Helicópteros',
    Store = '[E] Guardar helicóptero'
}

Config.Marker = {
    type = 34,
    scale = vec3(0.60, 0.60, 0.60),
    color = { r = 0, g = 191, b = 255, a = 190 }
}

Config.ServiceLabels = {
    police = 'LSPD',
    ambulance = 'EMS'
}

-- Añade helipuertos únicamente cuando tengas coordenadas verificadas.
Config.HeliGarages = {
    {
        name = 'Helipuerto LSPD - Mission Row',
        marker = vec3(458.1299, -985.6751, 30.6896),
        spawn = vec4(449.2569, -980.9638, 43.6917, 187.5252),
        store = vec3(449.2569, -980.9638, 43.6917)
    },
    {
        name = 'Helipuerto LSPD - Vespucci',
        marker = vec3(-1106.9956, -847.1813, 19.3169),
        spawn = vec4(-1095.6038, -835.5444, 37.6754, 306.3891),
        store = vec3(-1095.6038, -835.5444, 37.6754)
    },
    {
        name = 'Helipuerto LSPD - Vinewood',
        marker = vec3(644.5487, 10.6659, 82.7865),
        spawn = vec4(579.3170, 12.0722, 103.2336, 311.3948),
        store = vec3(579.3170, 12.0722, 103.2336)
    },
    {
        name = 'Helipuerto LSPD - Base Aérea',
        marker = vec3(-741.1767, -1505.2854, 5.0005),
        spawn = vec4(-725.3656, -1444.4833, 5.0005, 322.6189),
        store = vec3(-725.3656, -1444.4833, 5.0005)
    },
    {
        name = 'Helipuerto LSPD - Aeropuerto',
        marker = vec3(-1147.5956, -2826.5093, 13.9644),
        spawn = vec4(-1177.6182, -2846.0198, 13.9457, 61.0210),
        store = vec3(-1177.6182, -2846.0198, 13.9457)
    },
    {
        name = 'Helipuerto LSPD - Paleto Bay',
        marker = vec3(-452.1511, 6005.8232, 31.8409),
        spawn = vec4(-475.7111, 5988.8521, 31.3367, 228.6185),
        store = vec3(-475.7111, 5988.8521, 31.3367)
    },
    {
        name = 'Helipuerto LSPD - Sandy Shores',
        marker = vec3(1758.5129, 3298.0505, 41.1517),
        spawn = vec4(1770.3330, 3239.9553, 42.1232, 111.5296),
        store = vec3(1770.3330, 3239.9553, 42.1232)
    },
    {
        name = 'Helipuerto EMS - Pillbox',
        marker = vec3(319.2629, -573.5031, 43.3174),
        spawn = vec4(351.1425, -587.3683, 74.1656, 221.2272),
        store = vec3(351.1425, -587.3683, 74.1656)
    },
    {
        name = 'Helipuerto EMS - Davis',
        marker = vec3(293.7164, -1447.6224, 29.9666),
        spawn = vec4(299.5282, -1453.4911, 46.5095, 47.9535),
        store = vec3(299.5282, -1453.4911, 46.5095)
    },
}
-- Cada entrada requiere model, label y minRank.
-- Los ejemplos están comentados: activa o sustituye solo modelos instalados.
Config.HeliVehicles = {
    police = {
        {
            model = 'polmav',
            label = 'Helicóptero LSPD',
            minRank = 7,
            livery = 0
        },
    },

    ambulance = {
        {
            model = 'polmav',
            label = 'Helicóptero EMS',
            minRank = 4,
            livery = 1
        },
        {
            model = 'aw109',
            label = 'AW109 EMS',
            minRank = 6
        }
    }
}
