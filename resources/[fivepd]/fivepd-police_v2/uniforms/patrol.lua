print("PATROL CARGADO")

CreateThread(function()
    print("THREAD PATROL")
end)

PatrolUniform = {

    model = "mp_m_freemode_01",
	

    components = {

        -- Máscara
        { component = 1, drawable = 0, texture = 0 },

        -- Brazos
        { component = 3, drawable = 0, texture = 0 },

        -- Pantalón
        { component = 4, drawable = 35, texture = 0 },

        -- Mochila
        { component = 5, drawable = 0, texture = 0 },

        -- Zapatos
        { component = 6, drawable = 25, texture = 0 },

        -- Camiseta
        { component = 8, drawable = 58, texture = 0 },

        -- Chaleco
        { component = 9, drawable = 0, texture = 0 },

        -- Torso
        { component = 11, drawable = 55, texture = 0 }

    },

    props = {

        -- Gorra
        { prop = 0, drawable = 46, texture = 0 }

    }

}