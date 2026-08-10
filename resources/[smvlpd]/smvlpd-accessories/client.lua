local categories = {
    glasses = { label = 'Gafas', icon = 'glasses', prop = 1 },
    hats = { label = 'Gorras / gorros / sombreros', icon = 'hat-cowboy', prop = 0 },
    watches = { label = 'Relojes', icon = 'clock', prop = 6 }
}

local categoryOrder = { 'glasses', 'hats', 'watches' }
local selectedAccessories = {}
local previousAccessories = {}

local function getGender(ped)
    return IsPedModel(ped, `mp_f_freemode_01`) and 'female' or 'male'
end

local function capturePreviousAccessory(key)
    if previousAccessories[key] then return end
    local prop = categories[key].prop
    local ped = PlayerPedId()
    previousAccessories[key] = {
        drawable = GetPedPropIndex(ped, prop),
        texture = GetPedPropTextureIndex(ped, prop)
    }
end

local function applyEntry(key, entry)
    local ped = PlayerPedId()
    local values = entry[getGender(ped)]
    if not values or not DoesEntityExist(ped) then return false end

    local prop = categories[key].prop
    if values.drawable < 0 or values.drawable >= GetNumberOfPedPropDrawableVariations(ped, prop) then
        return false
    end
    if values.texture < 0 or values.texture >= GetNumberOfPedPropTextureVariations(ped, prop, values.drawable) then
        return false
    end

    capturePreviousAccessory(key)
    if entry.collection then
        SetPedCollectionPropIndex(ped, prop, entry.collection, values.drawable, values.texture or 0, true)
    else
        SetPedPropIndex(ped, prop, values.drawable, values.texture or 0, true)
    end
    selectedAccessories[key] = entry
    return true
end

local function removeAccessory(key)
    local prop = categories[key].prop
    local previous = previousAccessories[key]
    if previous and previous.drawable >= 0 then
        SetPedPropIndex(PlayerPedId(), prop, previous.drawable, previous.texture or 0, true)
    else
        ClearPedProp(PlayerPedId(), prop)
    end
    selectedAccessories[key] = nil
    previousAccessories[key] = nil
end

local function showCategory(service, key)
    local category = categories[key]
    local entries = (Config.Accessories[service] or {})[key] or {}
    local options = {
        { title = 'Quitar', description = 'Restaura el accesorio que llevaba el uniforme.', icon = 'xmark', onSelect = function()
            removeAccessory(key)
            lib.showContext('smvlpd_accessories_' .. service)
        end }
    }

    for _, entry in ipairs(entries) do
        options[#options + 1] = { title = entry.label, icon = category.icon, onSelect = function()
            if not applyEntry(key, entry) then
                lib.notify({ type = 'error', description = 'Este accesorio no está configurado para tu modelo de personaje.' })
                return
            end
            lib.showContext('smvlpd_accessories_' .. service)
        end }
    end

    lib.registerContext({ id = 'smvlpd_accessories_' .. service .. '_' .. key, title = category.label, menu = 'smvlpd_accessories_' .. service, options = options })
    lib.showContext('smvlpd_accessories_' .. service .. '_' .. key)
end

local function OpenAccessories(service)
    service = service == 'ambulance' and 'ems' or service
    if not Config.Accessories[service] then
        lib.notify({ type = 'error', description = 'No hay una whitelist de accesorios configurada para este servicio.' })
        return
    end

    local options = {}
    for _, key in ipairs(categoryOrder) do
        local category = categories[key]
        options[#options + 1] = { title = category.label, description = 'Accesorios permitidos para este servicio.', icon = category.icon, onSelect = function()
            showCategory(service, key)
        end }
    end
    lib.registerContext({ id = 'smvlpd_accessories_' .. service, title = 'ACCESORIOS', options = options })
    lib.showContext('smvlpd_accessories_' .. service)
end

local function ReapplyAccessories()
    for key, entry in pairs(selectedAccessories) do
        previousAccessories[key] = nil
        applyEntry(key, entry)
    end
end

RegisterCommand('accessorycatalog', function()
    local ped = PlayerPedId()
    print(('[smvlpd-accessories] modelo=%s | gorra=%s | gafas=%s | reloj=%s'):format(
        getGender(ped),
        GetNumberOfPedPropDrawableVariations(ped, 0),
        GetNumberOfPedPropDrawableVariations(ped, 1),
        GetNumberOfPedPropDrawableVariations(ped, 6)
    ))
end, false)

exports('OpenAccessories', OpenAccessories)
exports('ReapplyAccessories', ReapplyAccessories)
