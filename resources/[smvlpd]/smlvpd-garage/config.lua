Config = {}

Config.DrawDistance = 20.0

Config.Marker = {
    type = 36,
    size = vec3(1.2, 1.2, 1.2),
    color = {
        r = 0,
        g = 120,
        b = 255,
        a = 180
    }
}

Config.Garages = {
    MissionRow = {
    label = "Mission Row Police Department",

    menu = vec3(
        444.56,
        -974.96,
        30.69
    ),

    spawns = {
        vec4(
            436.47,
            -997.55,
            25.76,
            174.23
        ),
        vec4(
            431.34,
            -997.49,
            25.76,
            177.08
        )
    },

        stores = {
        vec3(
            452.51,
            -997.49,
            25.76
        ),
        vec3(
            447.22,
            -997.40,
            25.76
        )
    }
    },
    DelPerro = {
    label = "Del Perro Police Station",

    menu = vec3(-1615.68, -1014.88, 13.13),

    spawns = {
        vec4(-1626.71, -1016.25, 13.15, 56.63),
    },

    stores = {
        vec3(-1622.94, -1012.79, 13.15),
    }
},
    RockfordHills = {
    label = "Rockford Hills Police Station",

    menu = vec3(-566.48, -132.92, 37.96),

    spawns = {
        vec4(-575.90, -148.56, 37.87, 205.47),
    },

    stores = {
        vec3(-570.56, -144.77, 37.67),
    }
},
    Vespucci = {
    label = "Vespucci Police Station",

    menu = vec3(-1112.31, -824.58, 19.32),

    spawns = {
        vec4(-1121.63, -842.18, 13.38, 125.11),
    },

    stores = {
        vec3(-1125.12, -838.42, 13.43),
    }
},

    VespucciBeach = {
    label = "Vespucci Beach Police Station",

    menu = vec3(-1320.33, -1532.10, 4.42),

    spawns = {
        vec4(-1309.02, -1508.45, 4.31, 320.82),
    },

    stores = {
        vec3(-1314.58, -1503.84, 4.31),
    }
},
    Winewood = {
    label = "Winewood Police Station",

    menu = vec3(638.12, -1.10, 82.79),

    spawns = {
        vec4(534.00, -26.24, 70.63, 205.96),
    },

    stores = {
        vec3(530.14, -29.30, 70.63),
    }
},

    LaMesa = {
    label = "La Mesa Police Station",

    menu = vec3(830.33, -1311.43, 28.14),

    spawns = {
        vec4(872.03, -1350.17, 26.31, 85.78),
    },

    stores = {
        vec3(859.13, -1343.10, 26.03),
    }
}
}