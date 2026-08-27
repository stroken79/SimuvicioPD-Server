Config = {}

Config.InteractionDistance = 2.0
Config.PointDrawDistance = 50.0
Config.ModelLoadTimeout = 10000

Config.Text = {
    Garage = '[E] Garaje Marítimo',
    Store = '[E] Guardar embarcación'
}

Config.Marker = {
    type = 24,
    scale = vec3(0.45, 0.45, 0.45),
    color = { r = 25, g = 125, b = 200, a = 190 }
}

-- Servicios reales de night_ers: police (LSPD), fire (LSFD) y tow (LSDOT).
Config.ServiceLabels = {
    police = 'LSPD',
    fire = 'LSFD',
    tow = 'LSDOT'
}

-- Añade aquí los puertos cuando dispongas de coordenadas verificadas.
-- No se incluyen coordenadas inventadas.
Config.BoatGarages = {
    -- {
    --     name = 'Base Marítima',
    --     marker = vec3(x, y, z),
    --     spawn = vec4(x, y, z, heading),
    --     store = vec3(x, y, z)
    -- }
}

-- Cada entrada requiere model, label y minRank. Los modelos siguientes son solo
-- ejemplos comentados: activa o sustituye únicamente modelos instalados en tu servidor.
Config.BoatVehicles = {
    police = {
        -- { model = 'predator', label = 'Police Predator', minRank = 1 }
    },
    fire = {
        -- { model = 'dinghy', label = 'Rescue Boat', minRank = 1 },
        -- { model = 'fireboat', label = 'Fireboat LSFD', minRank = 6 }
    },
    tow = {
        -- { model = 'dinghy', label = 'Embarcación de servicio LSDOT', minRank = 1 },
        -- { model = 'tug', label = 'Tug LSDOT', minRank = 6 }
    }
}
