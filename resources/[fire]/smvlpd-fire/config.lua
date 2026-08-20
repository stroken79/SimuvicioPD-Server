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
    -- Cadete
    [1] = {
        { model = 'pumper', label = 'Pumper' }
    },

    -- Bombero II
    [2] = {
        { model = 'pumper', label = 'Pumper' },
        { model = 'ferrara', label = 'Ferrara' }
    },

    -- Bombero III
    [3] = {
        { model = 'firetruk', label = 'Fire Truck GTA V' },
        { model = 'pumper', label = 'Pumper' },
        { model = 'ferrara', label = 'Ferrara' }
    },

    -- Ingeniero
    [4] = {
        { model = 'firetruk', label = 'Fire Truck GTA V' },
        { model = 'pumper', label = 'Pumper' },
        { model = 'ferrara', label = 'Ferrara' },
        { model = 'spartan', label = 'Spartan' }
    },

    -- Teniente
    [5] = {
        { model = 'firetruk', label = 'Fire Truck GTA V' },
        { model = 'pumper', label = 'Pumper' },
        { model = 'ferrara', label = 'Ferrara' },
        { model = 'spartan', label = 'Spartan' }
    },

    -- Capitán
    [6] = {
        { model = 'firetruk', label = 'Fire Truck GTA V' },
        { model = 'pumper', label = 'Pumper' },
        { model = 'ferrara', label = 'Ferrara' },
        { model = 'spartan', label = 'Spartan' }
    },

    -- Jefe de Batallón
    [7] = {
        { model = 'firetruk', label = 'Fire Truck GTA V' },
        { model = 'pumper', label = 'Pumper' },
        { model = 'ferrara', label = 'Ferrara' },
        { model = 'spartan', label = 'Spartan' }
    },

    -- Jefe de División
    [8] = {
        { model = 'firetruk', label = 'Fire Truck GTA V' },
        { model = 'pumper', label = 'Pumper' },
        { model = 'ferrara', label = 'Ferrara' },
        { model = 'spartan', label = 'Spartan' }
    },

    -- Ayudante de Jefe
    [9] = {
        { model = 'firetruk', label = 'Fire Truck GTA V' },
        { model = 'pumper', label = 'Pumper' },
        { model = 'ferrara', label = 'Ferrara' },
        { model = 'spartan', label = 'Spartan' },
        { model = 'qrv', label = 'QRV Jefatura', livery = 4 }
    },

    -- Jefe de Bomberos
    [10] = {
        { model = 'firetruk', label = 'Fire Truck GTA V' },
        { model = 'pumper', label = 'Pumper' },
        { model = 'ferrara', label = 'Ferrara' },
        { model = 'spartan', label = 'Spartan' },
        { model = 'qrv', label = 'QRV Jefatura', livery = 4 }
    }
}


-- =========================================================
-- VEHICULO ESPECIAL POR ESTACION
-- GMC: solo Paleto y Sandy Shores, desde Ingeniero (rango 4)
-- =========================================================
Config.GarageExtraVehicles = {
    ['Estación Paleto'] = {
        [4] = { { model = 'gmc', label = 'GMC' } },
        [5] = { { model = 'gmc', label = 'GMC' } },
        [6] = { { model = 'gmc', label = 'GMC' } },
        [7] = { { model = 'gmc', label = 'GMC' } },
        [8] = { { model = 'gmc', label = 'GMC' } },
        [9] = { { model = 'gmc', label = 'GMC' } },
        [10] = { { model = 'gmc', label = 'GMC' } }
    },
    ['Estación Sandy Shores'] = {
        [4] = { { model = 'gmc', label = 'GMC' } },
        [5] = { { model = 'gmc', label = 'GMC' } },
        [6] = { { model = 'gmc', label = 'GMC' } },
        [7] = { { model = 'gmc', label = 'GMC' } },
        [8] = { { model = 'gmc', label = 'GMC' } },
        [9] = { { model = 'gmc', label = 'GMC' } },
        [10] = { { model = 'gmc', label = 'GMC' } }
    }
}

-- =========================================================
-- ACCESORIOS DE BOMBEROS
-- =========================================================

Config.Accessories = {
    fire = {
        glasses = {
             { label = 'Gafas tácticas', male = { drawable = 23, texture = 0 }, female = { drawable = 25, texture = 0 } },
            { label = 'Gafas profesionales oscuras', male = { drawable = 5, texture = 1 }, female = { drawable = 11, texture = 0 } },
            { label = 'Gafas profesionales claras', male = { drawable = 5, texture = 2 }, female = { drawable = 11, texture = 5 } },
            { label = 'Gafas EMS 63-0', male = { drawable = 63, texture = 0 }, female = { drawable = 63, texture = 0 } },
            { label = 'Gafas EMS 1-1', male = { drawable = 1, texture = 1 }, female = { drawable = 1, texture = 1 } },
            { label = 'Gafas EMS 2-2', male = { drawable = 2, texture = 2 }, female = { drawable = 2, texture = 2 } },
            { label = 'Gafas EMS 3-9', male = { drawable = 3, texture = 9 }, female = { drawable = 3, texture = 9 } },
            { label = 'Gafas EMS 4-6', male = { drawable = 4, texture = 6 }, female = { drawable = 4, texture = 6 } },
            { label = 'Gafas EMS 7-7', male = { drawable = 7, texture = 7 }, female = { drawable = 7, texture = 7 } },
            { label = 'Gafas EMS 9-9', male = { drawable = 9, texture = 9 }, female = { drawable = 9, texture = 9 } },
            { label = 'Gafas EMS 15-7', male = { drawable = 15, texture = 7 }, female = { drawable = 15, texture = 7 } },
            { label = 'Gafas EMS 17-7', male = { drawable = 17, texture = 7 }, female = { drawable = 17, texture = 7 } },
            { label = 'Gafas EMS 17-9', male = { drawable = 17, texture = 9 }, female = { drawable = 17, texture = 9 } },
            { label = 'Gafas EMS 19-9', male = { drawable = 19, texture = 9 }, female = { drawable = 19, texture = 9 } },
            { label = 'Gafas EMS 20-2', male = { drawable = 20, texture = 2 }, female = { drawable = 20, texture = 2 } },
            { label = 'Gafas EMS 34-0', male = { drawable = 34, texture = 0 }, female = { drawable = 34, texture = 0 } },
            { label = 'Gafas EMS 35-0', male = { drawable = 35, texture = 0 }, female = { drawable = 35, texture = 0 } },
            { label = 'Gafas EMS 37-0', male = { drawable = 37, texture = 0 }, female = { drawable = 37, texture = 0 } }
        },
        hats = {
            {
                label = 'Gorra de bombero',
                male = { drawable = 248, texture = 0 },
                female = { drawable = 247, texture = 0 }
            },
           
        },

         watches = {
            { label = 'Reloj EmergencyEUP 1', male = { drawable = 1, texture = 0 }, female = { drawable = 1, texture = 0 } },
            { label = 'Reloj EmergencyEUP 3', male = { drawable = 3, texture = 0 }, female = { drawable = 3, texture = 0 } },
            { label = 'Reloj EmergencyEUP 4', male = { drawable = 4, texture = 0 }, female = { drawable = 4, texture = 0 } },
            { label = 'Reloj EmergencyEUP 6', male = { drawable = 6, texture = 0 }, female = { drawable = 6, texture = 0 } },
            { label = 'Reloj EmergencyEUP 7', male = { drawable = 7, texture = 0 }, female = { drawable = 7, texture = 0 } },
            { label = 'Reloj EmergencyEUP 10', male = { drawable = 10, texture = 0 }, female = { drawable = 10, texture = 0 } },
            { label = 'Reloj EmergencyEUP 11', male = { drawable = 11, texture = 0 }, female = { drawable = 11, texture = 0 } },
            { label = 'Reloj EmergencyEUP 12', male = { drawable = 12, texture = 0 }, female = { drawable = 12, texture = 0 } },
            { label = 'Reloj EmergencyEUP 13', male = { drawable = 13, texture = 0 }, female = { drawable = 13, texture = 0 } },
            { label = 'Reloj EmergencyEUP 14', male = { drawable = 14, texture = 0 }, female = { drawable = 14, texture = 0 } },
            { label = 'Reloj EmergencyEUP 15', male = { drawable = 15, texture = 0 }, female = { drawable = 15, texture = 0 } },
            { label = 'Reloj EmergencyEUP 16', male = { drawable = 16, texture = 0 }, female = { drawable = 16, texture = 0 } },
            { label = 'Reloj EmergencyEUP 18', male = { drawable = 18, texture = 0 }, female = { drawable = 18, texture = 0 } },
            { label = 'Reloj EmergencyEUP 19', male = { drawable = 19, texture = 0 }, female = { drawable = 19, texture = 0 } },
            { label = 'Reloj EmergencyEUP 20', male = { drawable = 20, texture = 0 }, female = { drawable = 20, texture = 0 } },
            { label = 'Reloj EmergencyEUP 30', male = { drawable = 30, texture = 0 }, female = { drawable = 30, texture = 0 } },
            { label = 'Reloj EmergencyEUP 31', male = { drawable = 31, texture = 0 }, female = { drawable = 31, texture = 0 } },
            { label = 'Reloj EmergencyEUP 32', male = { drawable = 32, texture = 0 }, female = { drawable = 32, texture = 0 } },
            { label = 'Reloj EmergencyEUP 33', male = { drawable = 33, texture = 0 }, female = { drawable = 33, texture = 0 } },
            { label = 'Reloj EmergencyEUP 34', male = { drawable = 34, texture = 0 }, female = { drawable = 34, texture = 0 } },
            { label = 'Reloj EmergencyEUP 35', male = { drawable = 35, texture = 0 }, female = { drawable = 35, texture = 0 } },
            { label = 'Reloj EmergencyEUP 36', male = { drawable = 36, texture = 0 }, female = { drawable = 36, texture = 0 } },
            { label = 'Reloj EmergencyEUP 37', male = { drawable = 37, texture = 0 }, female = { drawable = 37, texture = 0 } },
            { label = 'Reloj EmergencyEUP 38', male = { drawable = 38, texture = 0 }, female = { drawable = 38, texture = 0 } },
            { label = 'Reloj EmergencyEUP 39', male = { drawable = 39, texture = 0 }, female = { drawable = 39, texture = 0 } }
        }
    }
}