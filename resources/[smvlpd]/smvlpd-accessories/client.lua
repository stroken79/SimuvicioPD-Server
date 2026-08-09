local accessories = {
    glasses = { label = 'Gafas', icon = 'glasses', prop = 1 },
    cap = { label = 'Gorra', icon = 'hat-cowboy', prop = 0 },
    watch = { label = 'Reloj', icon = 'clock', prop = 6 }
}

local accessoryOrder = { 'glasses', 'cap', 'watch' }
local selectedAccessories = {}

local function applyAccessory(key, drawable, texture)
    local ped = PlayerPedId()
    local accessory = accessories[key]
    if not accessory or not DoesEntityExist(ped) then return end
    SetPedPropIndex(ped, accessory.prop, drawable, texture, true)
    selectedAccessories[key] = { drawable = drawable, texture = texture }
end

local function removeAccessory(key)
    local accessory = accessories[key]
    if not accessory then return end
    ClearPedProp(PlayerPedId(), accessory.prop)
    selectedAccessories[key] = nil
end

local function showTextureMenu(key, drawable)
    local ped = PlayerPedId()
    local accessory = accessories[key]
    local textureCount = GetNumberOfPedPropTextureVariations(ped, accessory.prop, drawable)
    local options = {}
    for texture = 0, textureCount - 1 do
        options[#options + 1] = { title = ('Variante %s'):format(texture), icon = accessory.icon, onSelect = function()
            applyAccessory(key, drawable, texture)
            lib.showContext('smvlpd_accessories_' .. key)
        end }
    end
    lib.registerContext({ id = 'smvlpd_accessories_textures_' .. key .. '_' .. drawable, title = accessory.label .. ' - modelo ' .. drawable, menu = 'smvlpd_accessories_' .. key, options = options })
    lib.showContext('smvlpd_accessories_textures_' .. key .. '_' .. drawable)
end

local function showDrawableMenu(key)
    local ped = PlayerPedId()
    local accessory = accessories[key]
    local drawableCount = GetNumberOfPedPropDrawableVariations(ped, accessory.prop)
    local options = {
        { title = 'Quitar ' .. string.lower(accessory.label), description = 'No modifica ninguna otra prenda del uniforme.', icon = 'xmark', onSelect = function()
            removeAccessory(key)
            lib.showContext('smvlpd_accessories_' .. key)
        end }
    }
    for drawable = 0, drawableCount - 1 do
        options[#options + 1] = { title = ('Modelo %s'):format(drawable), description = 'Elegir variante de color/textura.', icon = accessory.icon, onSelect = function()
            showTextureMenu(key, drawable)
        end }
    end
    lib.registerContext({ id = 'smvlpd_accessories_' .. key, title = accessory.label, menu = 'smvlpd_accessories_menu', options = options })
    lib.showContext('smvlpd_accessories_' .. key)
end

local function OpenAccessories()
    local options = {}
    for _, key in ipairs(accessoryOrder) do
        local accessory = accessories[key]
        options[#options + 1] = { title = accessory.label, description = 'Poner, cambiar o quitar ' .. string.lower(accessory.label) .. '.', icon = accessory.icon, onSelect = function()
            showDrawableMenu(key)
        end }
    end
    lib.registerContext({ id = 'smvlpd_accessories_menu', title = 'ACCESORIOS', options = options })
    lib.showContext('smvlpd_accessories_menu')
end

local function ReapplyAccessories()
    for key, selection in pairs(selectedAccessories) do applyAccessory(key, selection.drawable, selection.texture) end
end

exports('OpenAccessories', OpenAccessories)
exports('ReapplyAccessories', ReapplyAccessories)
