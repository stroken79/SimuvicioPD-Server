Config.Vehicles = {

    [1] = { "pd8" },

    [2] = {
        "pd8",
        "nkscout2020",
        "pd9"
    },

    [3] = {
        "pd8",
        "nkscout2020",
        "pd9",
        "pd",
        "pd4"
    },

    [4] = {
        "pd8",
        "nkscout2020",
        "pd9",
        "pd",
        "pd4",
        "pd3",
        "pd5"
    },

    [5] = {
        "pd8",
        "nkscout2020",
        "pd9",
        "pd",
        "pd4",
        "pd3",
        "pd5",
        "pd6",
        "pd10"
    },

    [6] = {
        "pd8",
        "nkscout2020",
        "pd9",
        "pd",
        "pd4",
        "pd3",
        "pd5",
        "pd6",
        "pd10"
    },

    [7] = {
        "pd8",
        "nkscout2020",
        "pd9",
        "pd",
        "pd4",
        "pd3",
        "pd5",
        "pd6",
        "pd10",
        "police4"
    },

    [8] = {
        "pd8",
        "nkscout2020",
        "pd9",
        "pd",
        "pd4",
        "pd3",
        "pd5",
        "pd6",
        "pd10",
        "police4"
    },

    [9] = {
        "pd8",
        "nkscout2020",
        "pd9",
        "pd",
        "pd4",
        "pd3",
        "pd5",
        "pd6",
        "pd10",
        "police4"
    },

    [10] = {
        "pd8",
        "nkscout2020",
        "pd9",
        "pd",
        "pd4",
        "pd3",
        "pd5",
        "pd6",
        "pd10",
        "police4"
    },

    [11] = {
        "pd8",
        "nkscout2020",
        "pd9",
        "pd",
        "pd4",
        "pd3",
        "pd5",
        "pd6",
        "pd10",
        "police4",
        "ndds63sivil"
    },

    [12] = {
        "pd8",
        "nkscout2020",
        "pd9",
        "pd",
        "pd4",
        "pd3",
        "pd5",
        "pd6",
        "pd10",
        "police4",
        "ndds63sivil"
    },

    [13] = {
        "pd8",
        "nkscout2020",
        "pd9",
        "pd",
        "pd4",
        "pd3",
        "pd5",
        "pd6",
        "pd10",
        "police4",
        "ndds63sivil"
    },

    [14] = {
        "pd8",
        "nkscout2020",
        "pd9",
        "pd",
        "pd4",
        "pd3",
        "pd5",
        "pd6",
        "pd10",
        "police4",
        "ndds63sivil"
    }

}

-- Vehiculos separados por servicio. La tabla policial anterior se conserva
-- para mantener compatibilidad con el garaje existente.
Config.ServiceVehicles = {
    police = Config.Vehicles,

    ambulance = {
        -- Cadete EMS
        [1] = {
            {
                model = "ambulance",
                label = "Ambulancia GTA"
            }
        },

        -- EMT
        [2] = {
            {
                model = "ambulance",
                label = "Ambulancia GTA"
            }
        },

        -- AEMT
        [3] = {
            {
                model = "ambulance",
                label = "Ambulancia GTA"
            }
        },

        -- Paramedico
        [4] = {
            {
                model = "qrv",
                label = "FPIU Medic 8",
                livery = 0
            }
        },

        -- Paramedico Senior
        [5] = {
            {
                model = "qrv",
                label = "FPIU Medic 8",
                livery = 0
            }
        },

        -- Medico
        [6] = {
            {
                model = "qrv",
                label = "FPIU Tactical Medic",
                livery = 2
            },
            {
                model = "dodgeems",
                label = "Dodge EMS"
            }
        },

        -- Cirujano
        [7] = {
            {
                model = "qrv",
                label = "FPIU Tactical Medic",
                livery = 2
            },
            {
                model = "dodgeems",
                label = "Dodge EMS"
            }
        },

        -- Especialista
        [8] = {
            {
                model = "qrv",
                label = "FPIU Tactical Medic",
                livery = 2
            },
            {
                model = "dodgeems",
                label = "Dodge EMS"
            }
        },

        -- Supervisor
        [9] = {
            {
                model = "qrv",
                label = "FPIU Supervisor",
                livery = 1
            },
            {
                model = "dodgeems",
                label = "Dodge EMS"
            }
        },

        -- Director Adjunto
        [10] = {
            {
                model = "qrv",
                label = "FPIU Administración",
                livery = 4
            },
            {
                model = "dodgeems",
                label = "Dodge EMS"
            }
        },

        -- Director EMS
        [11] = {
            {
                model = "qrv",
                label = "FPIU Administración",
                livery = 4
            },
            {
                model = "dodgeems",
                label = "Dodge EMS"
            }
        },

        -- Director General
        [12] = {
            {
                model = "qrv",
                label = "FPIU Administración",
                livery = 4
            },
            {
                model = "dodgeems",
                label = "Dodge EMS"
            }
        },
    }
}
