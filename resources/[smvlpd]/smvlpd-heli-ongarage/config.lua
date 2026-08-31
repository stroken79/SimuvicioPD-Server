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
    type = 35,
    scale = vec3(0.60, 0.60, 0.60),
    color = { r = 0, g = 0, b = 0, a = 190 }
}

Config.ServiceLabels = {
    police = 'LSPD',
    ambulance = 'EMS'
}

-- Añade helipuertos únicamente cuando tengas coordenadas verificadas.
Config.HeliGarages = {
    -- {
    --     name = 'Helipuerto',
    --     marker = vec3(x, y, z),
    --     spawn = vec4(x, y, z, heading),
    --     store = vec3(x, y, z)
    -- }
}

-- Cada entrada requiere model, label y minRank.
-- Los ejemplos están comentados: activa o sustituye solo modelos instalados.
Config.HeliVehicles = {
    police = {
        -- { model = 'polmav', label = 'Helicóptero LSPD', minRank = 1 },
        -- { model = 'tu_modelo_lspd', label = 'Helicóptero LSPD personalizado', minRank = 1, color = { r = 255, g = 255, b = 255 } }
    },

    ambulance = {
        -- { model = 'tu_modelo_ems', label = 'Helicóptero EMS', minRank = 1, color = { r = 255, g = 255, b = 255 } }
    }
}
