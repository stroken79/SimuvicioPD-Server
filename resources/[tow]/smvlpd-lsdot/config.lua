Config = {}

-- ERS identifica el servicio de Grua como "tow". El nombre visible siempre es LSDOT.
Config.ServiceType = 'tow'
Config.DepartmentName = 'LSDOT'
Config.ServiceName = 'Grúa'
Config.InteractionDistance = 2.0
Config.PointDrawDistance = 50.0

Config.Text = {
    ServiceOn = '[E] Entrar de servicio como LSDOT - Grúa',
    ServiceOff = '[E] Salir de servicio de LSDOT - Grúa',
    Garage = '[E] Garaje LSDOT - Grúa',
    Store = '[E] Guardar vehiculo LSDOT',
    Locker = '[E] Vestuario LSDOT - Grúa'
}

Config.Marker = {
    type = 24,
    scale = vec3(0.45, 0.45, 0.45),
    color = { r = 25, g = 75, b = 150, a = 190 }
}

-- Deben coincidir con los ids ya existentes de smvlpd-ranks para "tow".
Config.Ranks = {
    [1] = { name = 'aprendiz' },
    [2] = { name = 'operador' },
    [3] = { name = 'ingeniero' },
    [4] = { name = 'supervisor' },
    [5] = { name = 'capataz' },
    [6] = { name = 'jefe_operaciones' },
    [7] = { name = 'subdirector' },
    [8] = { name = 'director' }
}

-- Configura una sede LSDOT verificada antes de activar los puntos.
Config.ServicePoints = {
}

-- Cada entrada requiere name, marker, spawn y store. No se han inventado coordenadas.
Config.Garages = {
    {
        name = "Garaje LSDOT - Aeropuerto",
        marker = vec3(-1155.7130, -2022.7915, 13.1566),
        spawn = vec4(-1160.2893, -1991.8785, 13.1604, 311.7269),
        store = vec3(-1136.3600, -1993.0688, 13.1679)
    },
    {
    name = "Garaje LSDOT - Benny's",
    marker = vec3(-215.4065, -1318.7451, 30.8904),
    spawn = vec4(-367.0884, -112.0681, 38.6965, 161.8363),
    store = vec3(-182.1086, -1287.9497, 31.2960)
    },
    {
    name = "Garaje LSDOT - LS Customs",
    marker = vec3(-323.8653, -130.0542, 38.9907),
    spawn = vec4(-365.2518, -110.7090, 38.6967, 63.3536),
    store = vec3(-375.0405, -107.1902, 38.6830)
    },
    {
    name = "Garaje LSDOT - Harmony",
    marker = vec3(1177.4556, 2636.2810, 37.7538),
    spawn = vec4(1200.0396, 2665.2803, 37.8099, 322.0638),
    store = vec3(1213.6329, 2665.4033, 37.8020)
    },
    {
    name = "Garaje LSDOT - La Mesa",
    marker = vec3(724.7294, -1071.6212, 23.1265),
    spawn = vec4(718.1848, -1061.9016, 22.0871, 81.7976),
    store = vec3(717.2211, -1076.9102, 22.2524)
    },
    {
    name = "Garaje LSDOT - Mirror Park",
    marker = vec3(1154.0391, -785.3243, 57.5987),
    spawn = vec4(1121.1875, -775.6977, 57.7995, 349.3270),
    store = vec3(1120.8070, -784.5925, 57.7209)
    },
    {
    name = "Garaje LSDOT - Paleto",
    marker = vec3(106.2552, 6627.6006, 31.7872),
    spawn = vec4(114.7222, 6604.6182, 31.9415, 275.6065),
    store = vec3(123.4148, 6620.6147, 31.8262)
    },
    {
    name = "Garaje LSDOT - Sandy Shores",
    marker = vec3(2511.5618, 4109.0986, 38.5789),
    spawn = vec4(2503.7200, 4079.4204, 38.6310, 57.4996),
    store = vec3(2509.4045, 4076.8000, 38.6310)
    },
    {
    name = "Garaje LSDOT - Vinewood",
    marker = vec3(548.2920, -190.8459, 54.4813),
    spawn = vec4(542.7733, -207.6074, 53.9290, 187.1995),
    store = vec3(550.0651, -213.0064, 52.9670)
    }
}
-- Cada entrada requiere name y coords. No se han inventado coordenadas.
Config.LockerRooms = {
    {
        name = "Taller de Benny's",
        coords = vec3(-224.2341, -1320.4956, 30.8904)
    },
    {
        name = "Taller del Aeropuerto",
        coords = vec3(-1149.1045, -2000.4191, 13.1803)
    },
    {
        name = "LS Customs",
        coords = vec3(-346.6447, -133.7080, 39.0096)
    },
	{
    name = "Taller de Harmony",
    coords = vec3(1172.7771, 2636.4121, 37.7866)
    },
	{
    name = "Taller de La Mesa",
    coords = vec3(728.3059, -1064.1039, 22.1687)
    },
	{
    name = "Taller de Mirror Park",
    coords = vec3(1135.7019, -784.9609, 57.5987)
    },
	{
    name = "Taller de Paleto",
    coords = vec3(110.8035, 6630.5859, 31.7873)
    },
	{
    name = "Taller de Sandy Shores",
    coords = vec3(2506.3953, 4097.4810, 38.7061)
    },
	{
    name = "Taller de Vinewood",
    coords = vec3(540.1017, -196.9521, 54.4900)
    }
}

-- Vehiculos independientes de LSDOT por rango. No se han inventado modelos.
Config.VehiclesByRank = {
    [1] = {
        { model = "towtruck2", label = "Grua LSDOT 2" }
    },
    [2] = {
        { model = "towtruck", label = "Grua LSDOT" },
        { model = "towtruck2", label = "Grua LSDOT 2" }
    },
    [3] = {
        { model = "towtruck", label = "Grua LSDOT" },
        { model = "towtruck2", label = "Grua LSDOT 2" },
        { model = "f450towtruk", label = "Ford F-450 LSDOT" }
    },
    [4] = {
        { model = "towtruck", label = "Grua LSDOT" },
        { model = "towtruck2", label = "Grua LSDOT 2" },
        { model = "f450towtruk", label = "Ford F-450 LSDOT" }
    },
    [5] = {
        { model = "towtruck", label = "Grua LSDOT" },
        { model = "towtruck2", label = "Grua LSDOT 2" },
        { model = "f450towtruk", label = "Ford F-450 LSDOT" }
    },
    [6] = {
        { model = "towtruck", label = "Grua LSDOT" },
        { model = "towtruck2", label = "Grua LSDOT 2" },
        { model = "f450towtruk", label = "Ford F-450 LSDOT" },
        { model = "17silverado", label = "Chevrolet Silverado LSDOT" }
    },
    [7] = {
        { model = "towtruck", label = "Grua LSDOT" },
        { model = "towtruck2", label = "Grua LSDOT 2" },
        { model = "f450towtruk", label = "Ford F-450 LSDOT" },
        { model = "17silverado", label = "Chevrolet Silverado LSDOT" }
    },
    [8] = {
        { model = "towtruck", label = "Grua LSDOT" },
        { model = "towtruck2", label = "Grua LSDOT 2" },
        { model = "f450towtruk", label = "Ford F-450 LSDOT" },
        { model = "17silverado", label = "Chevrolet Silverado LSDOT" }
    }
}


-- =========================================================
-- ACCESORIOS LSDOT
-- =========================================================

Config.Accessories = {
    tow = {
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

            -- Gorra 234: texturas 0-7
            { label = 'Gorra LSDOT 234 - 0', male = { drawable = 234, texture = 0 }, female = { drawable = 234, texture = 0 } },
            { label = 'Gorra LSDOT 234 - 1', male = { drawable = 234, texture = 1 }, female = { drawable = 234, texture = 1 } },
            { label = 'Gorra LSDOT 234 - 2', male = { drawable = 234, texture = 2 }, female = { drawable = 234, texture = 2 } },
            { label = 'Gorra LSDOT 234 - 3', male = { drawable = 234, texture = 3 }, female = { drawable = 234, texture = 3 } },
            { label = 'Gorra LSDOT 234 - 4', male = { drawable = 234, texture = 4 }, female = { drawable = 234, texture = 4 } },
            { label = 'Gorra LSDOT 234 - 5', male = { drawable = 234, texture = 5 }, female = { drawable = 234, texture = 5 } },
            { label = 'Gorra LSDOT 234 - 6', male = { drawable = 234, texture = 6 }, female = { drawable = 234, texture = 6 } },
            { label = 'Gorra LSDOT 234 - 7', male = { drawable = 234, texture = 7 }, female = { drawable = 234, texture = 7 } },

            -- Gorra 175: texturas 0-25
            { label = 'Gorra LSDOT 175 - 0', male = { drawable = 175, texture = 0 }, female = { drawable = 175, texture = 0 } },
            { label = 'Gorra LSDOT 175 - 1', male = { drawable = 175, texture = 1 }, female = { drawable = 175, texture = 1 } },
            { label = 'Gorra LSDOT 175 - 2', male = { drawable = 175, texture = 2 }, female = { drawable = 175, texture = 2 } },
            { label = 'Gorra LSDOT 175 - 3', male = { drawable = 175, texture = 3 }, female = { drawable = 175, texture = 3 } },
            { label = 'Gorra LSDOT 175 - 4', male = { drawable = 175, texture = 4 }, female = { drawable = 175, texture = 4 } },
            { label = 'Gorra LSDOT 175 - 5', male = { drawable = 175, texture = 5 }, female = { drawable = 175, texture = 5 } },
            { label = 'Gorra LSDOT 175 - 6', male = { drawable = 175, texture = 6 }, female = { drawable = 175, texture = 6 } },
            { label = 'Gorra LSDOT 175 - 7', male = { drawable = 175, texture = 7 }, female = { drawable = 175, texture = 7 } },
            { label = 'Gorra LSDOT 175 - 8', male = { drawable = 175, texture = 8 }, female = { drawable = 175, texture = 8 } },
            { label = 'Gorra LSDOT 175 - 9', male = { drawable = 175, texture = 9 }, female = { drawable = 175, texture = 9 } },
            { label = 'Gorra LSDOT 175 - 10', male = { drawable = 175, texture = 10 }, female = { drawable = 175, texture = 10 } },
            { label = 'Gorra LSDOT 175 - 11', male = { drawable = 175, texture = 11 }, female = { drawable = 175, texture = 11 } },
            { label = 'Gorra LSDOT 175 - 12', male = { drawable = 175, texture = 12 }, female = { drawable = 175, texture = 12 } },
            { label = 'Gorra LSDOT 175 - 13', male = { drawable = 175, texture = 13 }, female = { drawable = 175, texture = 13 } },
            { label = 'Gorra LSDOT 175 - 14', male = { drawable = 175, texture = 14 }, female = { drawable = 175, texture = 14 } },
            { label = 'Gorra LSDOT 175 - 15', male = { drawable = 175, texture = 15 }, female = { drawable = 175, texture = 15 } },
            { label = 'Gorra LSDOT 175 - 16', male = { drawable = 175, texture = 16 }, female = { drawable = 175, texture = 16 } },
            { label = 'Gorra LSDOT 175 - 17', male = { drawable = 175, texture = 17 }, female = { drawable = 175, texture = 17 } },
            { label = 'Gorra LSDOT 175 - 18', male = { drawable = 175, texture = 18 }, female = { drawable = 175, texture = 18 } },
            { label = 'Gorra LSDOT 175 - 19', male = { drawable = 175, texture = 19 }, female = { drawable = 175, texture = 19 } },
            { label = 'Gorra LSDOT 175 - 20', male = { drawable = 175, texture = 20 }, female = { drawable = 175, texture = 20 } },
            { label = 'Gorra LSDOT 175 - 21', male = { drawable = 175, texture = 21 }, female = { drawable = 175, texture = 21 } },
            { label = 'Gorra LSDOT 175 - 22', male = { drawable = 175, texture = 22 }, female = { drawable = 175, texture = 22 } },
            { label = 'Gorra LSDOT 175 - 23', male = { drawable = 175, texture = 23 }, female = { drawable = 175, texture = 23 } },
            { label = 'Gorra LSDOT 175 - 24', male = { drawable = 175, texture = 24 }, female = { drawable = 175, texture = 24 } },
            { label = 'Gorra LSDOT 175 - 25', male = { drawable = 175, texture = 25 }, female = { drawable = 175, texture = 25 } },

            -- Gorra 154: texturas 0-13
            { label = 'Gorra LSDOT 154 - 0', male = { drawable = 154, texture = 0 }, female = { drawable = 154, texture = 0 } },
            { label = 'Gorra LSDOT 154 - 1', male = { drawable = 154, texture = 1 }, female = { drawable = 154, texture = 1 } },
            { label = 'Gorra LSDOT 154 - 2', male = { drawable = 154, texture = 2 }, female = { drawable = 154, texture = 2 } },
            { label = 'Gorra LSDOT 154 - 3', male = { drawable = 154, texture = 3 }, female = { drawable = 154, texture = 3 } },
            { label = 'Gorra LSDOT 154 - 4', male = { drawable = 154, texture = 4 }, female = { drawable = 154, texture = 4 } },
            { label = 'Gorra LSDOT 154 - 5', male = { drawable = 154, texture = 5 }, female = { drawable = 154, texture = 5 } },
            { label = 'Gorra LSDOT 154 - 6', male = { drawable = 154, texture = 6 }, female = { drawable = 154, texture = 6 } },
            { label = 'Gorra LSDOT 154 - 7', male = { drawable = 154, texture = 7 }, female = { drawable = 154, texture = 7 } },
            { label = 'Gorra LSDOT 154 - 8', male = { drawable = 154, texture = 8 }, female = { drawable = 154, texture = 8 } },
            { label = 'Gorra LSDOT 154 - 9', male = { drawable = 154, texture = 9 }, female = { drawable = 154, texture = 9 } },
            { label = 'Gorra LSDOT 154 - 10', male = { drawable = 154, texture = 10 }, female = { drawable = 154, texture = 10 } },
            { label = 'Gorra LSDOT 154 - 11', male = { drawable = 154, texture = 11 }, female = { drawable = 154, texture = 11 } },
            { label = 'Gorra LSDOT 154 - 12', male = { drawable = 154, texture = 12 }, female = { drawable = 154, texture = 12 } },
            { label = 'Gorra LSDOT 154 - 13', male = { drawable = 154, texture = 13 }, female = { drawable = 154, texture = 13 } },

            -- Gorra 120: texturas 0-25
            { label = 'Gorra LSDOT 120 - 0', male = { drawable = 120, texture = 0 }, female = { drawable = 120, texture = 0 } },
            { label = 'Gorra LSDOT 120 - 1', male = { drawable = 120, texture = 1 }, female = { drawable = 120, texture = 1 } },
            { label = 'Gorra LSDOT 120 - 2', male = { drawable = 120, texture = 2 }, female = { drawable = 120, texture = 2 } },
            { label = 'Gorra LSDOT 120 - 3', male = { drawable = 120, texture = 3 }, female = { drawable = 120, texture = 3 } },
            { label = 'Gorra LSDOT 120 - 4', male = { drawable = 120, texture = 4 }, female = { drawable = 120, texture = 4 } },
            { label = 'Gorra LSDOT 120 - 5', male = { drawable = 120, texture = 5 }, female = { drawable = 120, texture = 5 } },
            { label = 'Gorra LSDOT 120 - 6', male = { drawable = 120, texture = 6 }, female = { drawable = 120, texture = 6 } },
            { label = 'Gorra LSDOT 120 - 7', male = { drawable = 120, texture = 7 }, female = { drawable = 120, texture = 7 } },
            { label = 'Gorra LSDOT 120 - 8', male = { drawable = 120, texture = 8 }, female = { drawable = 120, texture = 8 } },
            { label = 'Gorra LSDOT 120 - 9', male = { drawable = 120, texture = 9 }, female = { drawable = 120, texture = 9 } },
            { label = 'Gorra LSDOT 120 - 10', male = { drawable = 120, texture = 10 }, female = { drawable = 120, texture = 10 } },
            { label = 'Gorra LSDOT 120 - 11', male = { drawable = 120, texture = 11 }, female = { drawable = 120, texture = 11 } },
            { label = 'Gorra LSDOT 120 - 12', male = { drawable = 120, texture = 12 }, female = { drawable = 120, texture = 12 } },
            { label = 'Gorra LSDOT 120 - 13', male = { drawable = 120, texture = 13 }, female = { drawable = 120, texture = 13 } },
            { label = 'Gorra LSDOT 120 - 14', male = { drawable = 120, texture = 14 }, female = { drawable = 120, texture = 14 } },
            { label = 'Gorra LSDOT 120 - 15', male = { drawable = 120, texture = 15 }, female = { drawable = 120, texture = 15 } },
            { label = 'Gorra LSDOT 120 - 16', male = { drawable = 120, texture = 16 }, female = { drawable = 120, texture = 16 } },
            { label = 'Gorra LSDOT 120 - 17', male = { drawable = 120, texture = 17 }, female = { drawable = 120, texture = 17 } },
            { label = 'Gorra LSDOT 120 - 18', male = { drawable = 120, texture = 18 }, female = { drawable = 120, texture = 18 } },
            { label = 'Gorra LSDOT 120 - 19', male = { drawable = 120, texture = 19 }, female = { drawable = 120, texture = 19 } },
            { label = 'Gorra LSDOT 120 - 20', male = { drawable = 120, texture = 20 }, female = { drawable = 120, texture = 20 } },
            { label = 'Gorra LSDOT 120 - 21', male = { drawable = 120, texture = 21 }, female = { drawable = 120, texture = 21 } },
            { label = 'Gorra LSDOT 120 - 22', male = { drawable = 120, texture = 22 }, female = { drawable = 120, texture = 22 } },
            { label = 'Gorra LSDOT 120 - 23', male = { drawable = 120, texture = 23 }, female = { drawable = 120, texture = 23 } },
            { label = 'Gorra LSDOT 120 - 24', male = { drawable = 120, texture = 24 }, female = { drawable = 120, texture = 24 } },
            { label = 'Gorra LSDOT 120 - 25', male = { drawable = 120, texture = 25 }, female = { drawable = 120, texture = 25 } },

            -- Gorra 77: texturas 0-20
            { label = 'Gorra LSDOT 77 - 0', male = { drawable = 77, texture = 0 }, female = { drawable = 77, texture = 0 } },
            { label = 'Gorra LSDOT 77 - 1', male = { drawable = 77, texture = 1 }, female = { drawable = 77, texture = 1 } },
            { label = 'Gorra LSDOT 77 - 2', male = { drawable = 77, texture = 2 }, female = { drawable = 77, texture = 2 } },
            { label = 'Gorra LSDOT 77 - 3', male = { drawable = 77, texture = 3 }, female = { drawable = 77, texture = 3 } },
            { label = 'Gorra LSDOT 77 - 4', male = { drawable = 77, texture = 4 }, female = { drawable = 77, texture = 4 } },
            { label = 'Gorra LSDOT 77 - 5', male = { drawable = 77, texture = 5 }, female = { drawable = 77, texture = 5 } },
            { label = 'Gorra LSDOT 77 - 6', male = { drawable = 77, texture = 6 }, female = { drawable = 77, texture = 6 } },
            { label = 'Gorra LSDOT 77 - 7', male = { drawable = 77, texture = 7 }, female = { drawable = 77, texture = 7 } },
            { label = 'Gorra LSDOT 77 - 8', male = { drawable = 77, texture = 8 }, female = { drawable = 77, texture = 8 } },
            { label = 'Gorra LSDOT 77 - 9', male = { drawable = 77, texture = 9 }, female = { drawable = 77, texture = 9 } },
            { label = 'Gorra LSDOT 77 - 10', male = { drawable = 77, texture = 10 }, female = { drawable = 77, texture = 10 } },
            { label = 'Gorra LSDOT 77 - 11', male = { drawable = 77, texture = 11 }, female = { drawable = 77, texture = 11 } },
            { label = 'Gorra LSDOT 77 - 12', male = { drawable = 77, texture = 12 }, female = { drawable = 77, texture = 12 } },
            { label = 'Gorra LSDOT 77 - 13', male = { drawable = 77, texture = 13 }, female = { drawable = 77, texture = 13 } },
            { label = 'Gorra LSDOT 77 - 14', male = { drawable = 77, texture = 14 }, female = { drawable = 77, texture = 14 } },
            { label = 'Gorra LSDOT 77 - 15', male = { drawable = 77, texture = 15 }, female = { drawable = 77, texture = 15 } },
            { label = 'Gorra LSDOT 77 - 16', male = { drawable = 77, texture = 16 }, female = { drawable = 77, texture = 16 } },
            { label = 'Gorra LSDOT 77 - 17', male = { drawable = 77, texture = 17 }, female = { drawable = 77, texture = 17 } },
            { label = 'Gorra LSDOT 77 - 18', male = { drawable = 77, texture = 18 }, female = { drawable = 77, texture = 18 } },
            { label = 'Gorra LSDOT 77 - 19', male = { drawable = 77, texture = 19 }, female = { drawable = 77, texture = 19 } },
            { label = 'Gorra LSDOT 77 - 20', male = { drawable = 77, texture = 20 }, female = { drawable = 77, texture = 20 } },

            -- Gorra 76: texturas 0-20
            { label = 'Gorra LSDOT 76 - 0', male = { drawable = 76, texture = 0 }, female = { drawable = 76, texture = 0 } },
            { label = 'Gorra LSDOT 76 - 1', male = { drawable = 76, texture = 1 }, female = { drawable = 76, texture = 1 } },
            { label = 'Gorra LSDOT 76 - 2', male = { drawable = 76, texture = 2 }, female = { drawable = 76, texture = 2 } },
            { label = 'Gorra LSDOT 76 - 3', male = { drawable = 76, texture = 3 }, female = { drawable = 76, texture = 3 } },
            { label = 'Gorra LSDOT 76 - 4', male = { drawable = 76, texture = 4 }, female = { drawable = 76, texture = 4 } },
            { label = 'Gorra LSDOT 76 - 5', male = { drawable = 76, texture = 5 }, female = { drawable = 76, texture = 5 } },
            { label = 'Gorra LSDOT 76 - 6', male = { drawable = 76, texture = 6 }, female = { drawable = 76, texture = 6 } },
            { label = 'Gorra LSDOT 76 - 7', male = { drawable = 76, texture = 7 }, female = { drawable = 76, texture = 7 } },
            { label = 'Gorra LSDOT 76 - 8', male = { drawable = 76, texture = 8 }, female = { drawable = 76, texture = 8 } },
            { label = 'Gorra LSDOT 76 - 9', male = { drawable = 76, texture = 9 }, female = { drawable = 76, texture = 9 } },
            { label = 'Gorra LSDOT 76 - 10', male = { drawable = 76, texture = 10 }, female = { drawable = 76, texture = 10 } },
            { label = 'Gorra LSDOT 76 - 11', male = { drawable = 76, texture = 11 }, female = { drawable = 76, texture = 11 } },
            { label = 'Gorra LSDOT 76 - 12', male = { drawable = 76, texture = 12 }, female = { drawable = 76, texture = 12 } },
            { label = 'Gorra LSDOT 76 - 13', male = { drawable = 76, texture = 13 }, female = { drawable = 76, texture = 13 } },
            { label = 'Gorra LSDOT 76 - 14', male = { drawable = 76, texture = 14 }, female = { drawable = 76, texture = 14 } },
            { label = 'Gorra LSDOT 76 - 15', male = { drawable = 76, texture = 15 }, female = { drawable = 76, texture = 15 } },
            { label = 'Gorra LSDOT 76 - 16', male = { drawable = 76, texture = 16 }, female = { drawable = 76, texture = 16 } },
            { label = 'Gorra LSDOT 76 - 17', male = { drawable = 76, texture = 17 }, female = { drawable = 76, texture = 17 } },
            { label = 'Gorra LSDOT 76 - 18', male = { drawable = 76, texture = 18 }, female = { drawable = 76, texture = 18 } },
            { label = 'Gorra LSDOT 76 - 19', male = { drawable = 76, texture = 19 }, female = { drawable = 76, texture = 19 } },
            { label = 'Gorra LSDOT 76 - 20', male = { drawable = 76, texture = 20 }, female = { drawable = 76, texture = 20 } }
        },

        watches = {}
    }
}