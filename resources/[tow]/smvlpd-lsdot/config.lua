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
    [1] = {},
    [2] = {},
    [3] = {},
    [4] = {},
    [5] = {}
}
