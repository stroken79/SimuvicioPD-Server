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
