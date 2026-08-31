Config = {}

Config.InteractionDistance = 2.0
Config.StoreInteractionDistance = 10.0
Config.PointDrawDistance = 50.0
Config.ModelLoadTimeout = 10000

Config.Text = {
    Garage = '[E] Garaje Marítimo',
    Store = '[E] Guardar embarcación'
}

Config.Marker = {
    type = 35,
    scale = vec3(0.60, 0.60, 0.60),
    color = { r = 0, g = 0, b = 0, a = 190 }
}

-- Servicios reales de night_ers: police (LSPD), fire (LSFD) y tow (LSDOT).
Config.ServiceLabels = {
    police = 'LSPD',
    fire = 'LSFD',
    tow = 'LSDOT',
    ambulance = 'EMS'
}

-- Añade aquí los puertos cuando dispongas de coordenadas verificadas.
-- No se incluyen coordenadas inventadas.
Config.BoatGarages = {
    {
        name = 'Base Marítima',
        marker = vec3(-760.0477, -1514.2179, 4.9751),
        spawn = vec4(-805.3864, -1507.1210, -0.4745, 111.0541),
        store = vec3(-798.4766, -1502.1653, 1.1294)
    },
    {
        name = 'Embarcadero Pier',
        marker = vec3(-1793.0677, -1198.0619, 13.0174),
        spawn = vec4(-1789.9846, -1244.3481, -0.6020, 159.0454),
        store = vec3(-1789.9846, -1244.3481, -0.6020)
    },
    {
        name = 'Embarcadero Paleto',
        marker = vec3(-188.3088, 6549.5571, 11.0978),
        spawn = vec4(-291.7972, 6647.6963, 0.5477, 55.2231),
        store = vec3(-291.7972, 6647.6963, 0.5477)
    }
}

-- Cada entrada requiere model, label y minRank. Los modelos siguientes son solo
-- ejemplos comentados: activa o sustituye únicamente modelos instalados en tu servidor.
Config.BoatVehicles = {
    police = {
        { model = 'predator', label = 'Police Predator', minRank = 6 }
    },

    fire = {
    {
        model = 'dinghy',
        label = 'Dinghy LSFD',
        minRank = 3,
        color = { r = 255, g = 0, b = 0 }
    },
    {
        model = 'fireboat',
        label = 'Fireboat LSFD',
        minRank = 5
    }
},

    tow = {
    {
        model = 'tug',
        label = 'Remolcador LSDOT',
        minRank = 3
    }
},

    ambulance = {
        {
            model = 'dinghy',
            label = 'Dinghy EMS',
            minRank = 6,
            color = { r = 255, g = 255, b = 255 }
        }
    }
}