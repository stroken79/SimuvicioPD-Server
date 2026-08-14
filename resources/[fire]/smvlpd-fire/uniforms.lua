-- AÑADIR UNIFORMES MASCULINOS Y FEMENINOS AQUÍ.
-- components usa: [componentId] = { drawable, texture }
-- collections usa: [componentId] = { collection = 'nombre', drawable = 0, texture = 0 }
-- props usa: [propId] = { drawable, texture } o false para retirar ese prop.
FireUniforms = {}

-- Mantén cada rango separado para poder modificar una prenda sin afectar al resto.
for _, rankName in ipairs({
    'cadete', 'bombero_2', 'bombero_3', 'ingeniero',
    'teniente', 'capitan', 'jefe_batallon', 'jefe_division',
    'ayudante_jefe', 'jefe_bomberos'
}) do
    FireUniforms[rankName] = {
        male = {
            components = {},
            collections = {},
            props = {}
        },
        female = {
            components = {},
            collections = {},
            props = {}
        }
    }
end

FireUniforms.cadete.male = {
    components = {
        [8]  = { 57, 0 },
        [3]  = { 66, 0 },
        [10] = { 218, 0 },
        [9]  = { 0, 0 },
        [7]  = { 0, 0 },
        [4]  = { 120, 0 },
        [5]  = { 145, 1 },
        [1]  = { 166, 1 },
        [6]  = { 86, 8 },
    },

    collections = {
        [11] = {
            collection = "mp_m_emergency",
            drawable = 49,
            texture = 1
        }
    },

    props = {
        [0] = { 138, 0 }
    }
}


FireUniforms.cadete.female = {
    components = {
        [8]  = { 283, 0 },
        [3]  = { 75, 0 },
        [10] = { 234, 0 },
        [9]  = { 0, 0 },
        [5]  = { 0, 0 },
        [4]  = { 126, 0 },
        [6]  = { 90, 8 },
        [1]  = { 166, 1 },
        [11] = { 642, 1 },
    },

    collections = {},

    props = {
        [0] = { 137, 0 }
    }
}


FireUniforms.bombero_2.male = {
    components = {
        [8]  = { 235, 0 }, -- Camiseta / Interior
        [3]  = { 66, 0 },  -- Brazos / Torso
        [10] = { 218, 0 }, -- Insignias / Decals
        [9]  = { 0, 0 },   -- Chaleco / Armor
        [7]  = { 0, 0 },   -- Accesorios
        [4]  = { 120, 0 }, -- Pantalón
        [5]  = { 145, 1 }, -- Bolsas
        [1]  = { 175, 0 }, -- Máscara
        [6]  = { 86, 8 },  -- Zapatos
        [11] = { 314, 0 }, -- Chaqueta / Top
    },

    collections = {},

    props = {
        [0] = { 242, 0 } -- Casco
    }
}

FireUniforms.bombero_2.female = {
    components = {
        [8]  = { 283, 0 },
        [3]  = { 75, 0 },
        [10] = { 234, 0 },
        [9]  = { 0, 0 },
        [5]  = { 0, 0 },
        [4]  = { 126, 0 },
        [6]  = { 90, 8 },
        [1]  = { 175, 0 },
        [11] = { 325, 0 },
    },

    collections = {},

    props = {
        [0] = { 239, 0 }
    }
}

FireUniforms.bombero_3.male = {
    components = {
        [8]  = { 222, 0 },
        [3]  = { 66, 0 },
        [10] = { 218, 0 },
        [9]  = { 100, 0 },
        [7]  = { 0, 0 },
        [4]  = { 120, 0 },
        [5]  = { 145, 1 },
        [1]  = { 0, 0 },
        [6]  = { 86, 8 },
        [11] = { 314, 0 },
    },

    collections = {},

    props = {
        [0] = { 242, 0 }
    }
}

FireUniforms.bombero_3.female = {
    components = {
        [8]  = { 270, 0 },
        [3]  = { 75, 0 },
        [10] = { 234, 0 },
        [9]  = { 76, 0 },
        [5]  = { 0, 0 },
        [4]  = { 126, 0 },
        [6]  = { 90, 8 },
        [1]  = { 0, 0 },
        [11] = { 325, 0 },
    },

    collections = {},

    props = {
        [0] = { 239, 0 }
    }
}

FireUniforms.ingeniero.male = {
    components = {
        [8]  = { 235, 0 },
        [3]  = { 66, 0 },
        [10] = { 218, 0 },
        [9]  = { 0, 0 },
        [7]  = { 0, 0 },
        [4]  = { 120, 0 },
        [5]  = { 145, 1 },
        [1]  = { 0, 0 },
        [6]  = { 86, 8 },
        [11] = { 314, 0 },
    },

    collections = {},

    props = {
        [0] = { 248, 0 }
    }
}

FireUniforms.ingeniero.female = {
    components = {
        [8]  = { 283, 0 },
        [3]  = { 75, 0 },
        [10] = { 234, 0 },
        [9]  = { 0, 0 },
        [5]  = { 0, 0 },
        [4]  = { 126, 0 },
        [6]  = { 90, 8 },
        [1]  = { 0, 0 },
        [11] = { 325, 0 },
    },

    collections = {},

    props = {
        [0] = { 239, 0 }
    }
}
FireUniforms.teniente.male = {
    components = {
        [8]  = { 235, 0 },
        [3]  = { 66, 0 },
        [10] = { 218, 0 },
        [9]  = { 0, 0 },
        [7]  = { 0, 0 },
        [4]  = { 120, 0 },
        [5]  = { 145, 1 },
        [1]  = { 0, 0 },
        [6]  = { 86, 8 },
        [11] = { 314, 0 },
    },

    collections = {},

    props = {
        [0] = { 138, 1 }
    }
}

FireUniforms.teniente.female = {
    components = {
        [8]  = { 283, 0 },
        [3]  = { 75, 0 },
        [10] = { 234, 0 },
        [9]  = { 0, 0 },
        [5]  = { 0, 0 },
        [4]  = { 126, 0 },
        [6]  = { 90, 8 },
        [1]  = { 0, 0 },
        [11] = { 325, 0 },
    },

    collections = {},

    props = {
        [0] = { 137, 1 }
    }
}

FireUniforms.capitan.male = {
    components = {
        [8] = { 15, 0 },
        [3]  = { 66, 0 },
        [10] = { 218, 0 },
        [9]  = { 0, 0 },
        [7]  = { 0, 0 },
        [4]  = { 120, 0 },
        [5]  = { 145, 4 },
        [1]  = { 0, 0 },
        [6]  = { 86, 8 },
        [11] = { 593, 0 },
    },

    collections = {},

    props = {
        [0] = { 242, 1 }
    }
}

FireUniforms.capitan.female = {
    components = {
        [8]  = { 283, 0 },
        [3]  = { 75, 0 },
        [10] = { 234, 0 },
        [9]  = { 0, 0 },
        [5]  = { 0, 0 },
        [4]  = { 126, 1 },
        [6]  = { 90, 8 },
        [1]  = { 0, 0 },
        [11] = { 642, 0 },
    },

    collections = {},

    props = {
        [0] = { 239, 1 },
    }
}

FireUniforms.jefe_batallon.male = {
    components = {
        [8] = { 252, 0 },
        [3] = { 11, 0 },
        [10] = { 0, 0 },
        [9] = { 100, 0 },
        [7] = { 0, 0 },
        [4] = { 221, 0 },
        [5] = { 145, 1 },
        [1] = { 0, 0 },
        [6] = { 111, 0 },
        [11] = { 576, 8 },
    },

    collections = {},

    props = {
        [0] = { 242, 2 }
    }
}

FireUniforms.jefe_batallon.female = {
    components = {
        [8]  = { 292, 0 },
        [3]  = { 2, 0 },
        [10] = { 234, 0 },
        [9]  = { 76, 0 },
        [7]  = { 0, 0 },
        [4]  = { 243, 2 },
        [5]  = { 153, 3 },
        [6]  = { 115, 0 },
        [1]  = { 0, 0 },
        [11] = { 604, 4 },
    },

    collections = {},

    props = {
        [0] = { 239, 2 }
    }
}

FireUniforms.jefe_division.male = {
    components = {
        [8] = { 252, 0 },
        [3] = { 11, 0 },
        [10] = { 0, 0 },
        [9] = { 100, 0 },
        [7] = { 0, 0 },
        [4] = { 221, 0 },
        [5] = { 145, 1 },
        [1] = { 0, 0 },
        [6] = { 111, 0 },
        [11] = { 576, 8 },
    },

    collections = {},

    props = {
        [0] = { 242, 2 }
    }
}

FireUniforms.jefe_division.female = {
    components = {
        [8]  = { 292, 0 },
        [3]  = { 2, 0 },
        [10] = { 234, 0 },
        [9]  = { 76, 0 },
        [7]  = { 0, 0 },
        [4]  = { 243, 2 },
        [5]  = { 153, 3 },
        [6]  = { 115, 0 },
        [1]  = { 0, 0 },
        [11] = { 604, 4 },
    },

    collections = {},

    props = {
        [0] = { 239, 2 }
    }
}

FireUniforms.ayudante_jefe.male = {
    components = {
        [3]  = { 1, 0 },
        [9]  = { 68, 0 },
        [7]  = { 0, 0 },
        [4]  = { 7, 0 },
        [5]  = { 150, 4 },
        [6]  = { 12, 6 },
        [8]  = { 252, 0 },
        [10] = { 218, 0 },
    },

    collections = {
        [11] = {
            collection = "mp_m_emergency",
            drawable = 50,
            texture = 8
        }
    },

    props = {
        [0] = { 242, 2 }
    }
}
FireUniforms.ayudante_jefe.female = {
    components = {
        [8]  = { 294, 0 },    -- Camiseta / Interior
        [3]  = { 1, 0 },
        [10] = { 0, 0 },      -- Insignias / Decals
        [9]  = { 0, 0 },      -- Chaleco / Armor
        [7]  = { 0, 0 },
        [4]  = { 243, 2 },    -- Pantalón
        [5]  = { 147, 0 },    -- Bolsas
        [6]  = { 115, 0 },    -- Zapatos
        [1]  = { 0, 0 },
        [11] = { 641, 8 },    -- Chaqueta / Top
    },

    collections = {},

    props = {
        [0] = { 239, 2 }       -- Gorra / Casco
    }
}


FireUniforms.jefe_bomberos.male = {
    components = {
        [8]  = { 257, 0 },
        [3]  = { 1, 0 },
        [10] = { 218, 0 },
        [9]  = { 0, 0 },
        [7]  = { 0, 0 },
        [4]  = { 10, 0 },
        [5]  = { 145, 4 },
        [1]  = { 0, 0 },
        [6]  = { 10, 0 },
     
    },

    collections = {
        [11] = {
            collection = "mp_m_emergency",
            drawable = 50,
            texture = 8
        }
    },
    props = {
        [0] = { 242, 2 }
    }
}

FireUniforms.jefe_bomberos.female = {
    components = {
        [8]  = { 295, 0 }, -- Camiseta / Interior
        [3]  = { 1, 0 },
        [10] = { 0, 0 },
        [9]  = { 0, 0 },
        [7]  = { 0, 0 },
        [4]  = { 23, 11 }, -- Pantalón
        [5]  = { 153, 3 }, -- Bolsas
        [6]  = { 77, 0 }, -- Zapatos
        [1]  = { 0, 0 },
        [11] = { 641, 8 },
    },

    collections = {},

    props = {
        [0] = { 239, 2 }
    }
}