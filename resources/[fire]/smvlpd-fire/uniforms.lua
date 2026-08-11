-- AÑADIR UNIFORMES MASCULINOS Y FEMENINOS AQUÍ.
-- components usa: [componentId] = { drawable, texture }
-- collections usa: [componentId] = { collection = 'nombre', drawable = 0, texture = 0 }
-- props usa: [propId] = { drawable, texture } o false para retirar ese prop.
FireUniforms = {}

-- Mantén cada rango separado para poder modificar una prenda sin afectar al resto.
for _, rankName in ipairs({
    'cadete', 'bombero_1', 'bombero_2', 'bombero_3',
    'sargento_1', 'sargento_2', 'teniente_1', 'teniente_2'
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
