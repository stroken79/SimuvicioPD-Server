-- Uniformes exclusivos de LSDOT. Añade solo indices verificados en juego.
-- components usa [componentId] = { drawable, texture }.
-- props usa [propId] = { drawable, texture } o false para retirar el prop.
LsdotUniforms = {}

for _, rankName in ipairs({ 'cadete', 'gruero_1', 'gruero_2', 'gruero_3', 'supervisor' }) do
    LsdotUniforms[rankName] = {
        male = { components = {}, collections = {}, props = {} },
        female = { components = {}, collections = {}, props = {} }
    }
end
