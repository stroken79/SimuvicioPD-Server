Config = {}

Config.JobName = "ems"

Config.InteractionDistance = 2.0

Config.Text = {
    Locker = "[E] Vestuario EMS",
    Garage = "[E] Garaje EMS",
    Armory = "[E] Material EMS",
    Treatment = "[E] Zona de tratamiento"
}

Config.LockerMarker = {
    Type = 24,
    Scale = vec3(0.45, 0.45, 0.45),
    Color = {
        r = 255,
        g = 140,
        b = 0,
        a = 200
    }
}

Config.GarageMarker = {
    Type = 36,
    Scale = vec3(0.45, 0.45, 0.45),
    Color = {
        r = 255,
        g = 140,
        b = 0,
        a = 200
    }
}

Config.ArmoryMarker = {
    Type = 21,
    Scale = vec3(0.45, 0.45, 0.45),
    Color = {
        r = 255,
        g = 140,
        b = 0,
        a = 200
    }
}

Config.TreatmentMarker = {
    Type = 1,
    Scale = vec3(0.45, 0.45, 0.45),
    Color = {
        r = 255,
        g = 140,
        b = 0,
        a = 200
    }
}

Config.LockerLocations = {

    {
        name = "Pillbox Medical Center",
        coords = vec3(335.08, -570.52, 43.32),
        heading = 252.52
    },

    {
        name = "Mount Zonah Medical Center",
        coords = vec3(-498.6849, -336.3391, 34.5018),
        heading = 74.4698
    },

    {
        name = "St. Fiacre Hospital",
        coords = vec3(1154.18, -1546.07, 35.03),
        heading = 93.47
    },

    {
        name = "Central Los Santos Medical Center",
        coords = vec3(-672.50, 312.97, 83.08),
        heading = 0.20
    },

    {
        name = "Sandy Shores Medical Center",
        coords = vec3(1837.63, 3672.50, 34.28),
        heading = 36.74
    },

    {
        name = "Paleto Bay Medical Center",
        coords = vec3(-247.58, 6332.36, 32.43),
        heading = 43.45
    }

}


Config.GarageLocations = {

    {
        name = "Pillbox Medical Center",

        marker = vec3(319.6248, -580.6374, 43.3174),

        spawn = vec4(340.8693, -561.7181, 28.7438, 326.0265),

        store = vec3(328.4555, -557.6608, 28.7438)
    },

  {
        name = "Mount Zonah Medical Center",

        marker = vec3(-498.3325, -332.6978, 34.5017),

        spawn = vec4(-469.8881, -312.5031, 34.5444, 20.4104),

        store = vec3(-487.0748, -299.4598, 35.2730)
     },

  {
        name = "St. Fiacre Hospital",

        marker = vec3(1172.0945, -1527.5646, 35.0509),

        spawn = vec4(1177.7056, -1545.5173, 34.6926, 354.8202),

        store = vec3(1191.5964, -1544.2065, 34.6926)
},

{
    name = "Central Los Santos Medical Center",

    marker = vec3(-692.3315, 314.4183, 83.1080),

    spawn = vec4(-698.3793, 314.8546, 83.0087, 168.0471),

    store = vec3(-654.5237, 308.1081, 82.8522)
},

{
    name = "Sandy Shores Medical Center",

    marker = vec3(1815.7260, 3679.1943, 34.2765),

    spawn = vec4(1833.6863, 3697.1880, 34.2242, 299.5454),

    store = vec3(1822.8899, 3691.3975, 34.2243)
},

{
    name = "Paleto Bay Medical Center",

    marker = vec3(-243.5903, 6325.2002, 32.4262),

    spawn = vec4(-263.2809, 6341.0610, 32.4262, 265.2237),

    store = vec3(-268.3589, 6336.8721, 32.4262)
}

}



Config.ArmoryLocations = {

}

Config.TreatmentLocations = {

}