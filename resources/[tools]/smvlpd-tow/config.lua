Config = {}

-- Vehiculos que pueden utilizar el sistema de grua.
Config.TowVehicles = {
    f450towtruk = {
        label = 'Ford F-450 Tow Truck',
        rear = true,
        maxDistance = 9.0
    },

    hvywrecker = {
        label = 'Kenworth T440 Heavy Wrecker',
        rear = true,
        maxDistance = 9.0
    },

    towtruck = {
        label = 'Towtruck',
        rear = true,
        maxDistance = 9.0
    },

    towtruck2 = {
        label = 'Towtruck 2',
        rear = true,
        maxDistance = 9.0
    }
}

-- Tecla del menu de grua.
Config.MenuKey = 'F6'

-- Tecla rapida para desenganchar.
Config.DetachKey = 'H'

-- Distancia para encontrar un vehiculo cercano.
Config.TargetDistance = 8.0

-- Intento de usar la configuración base del kit del T440 (0 = default).
Config.AutoPrepareT440 = true
