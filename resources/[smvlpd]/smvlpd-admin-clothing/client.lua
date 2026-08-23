local savedOutfit = nil
local wearingAdminUniform = false

local componentIds = {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12}
local propIds = {0, 1, 2, 3, 4, 5, 6, 7}

local function Notify(message)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, false)
end

RegisterNetEvent("smvlpd-admin-clothing:notify", function(message)
    Notify(message)
end)

local function SaveOutfit(ped)
    savedOutfit = {
        components = {},
        props = {}
    }

    for _, component in ipairs(componentIds) do
        savedOutfit.components[component] = {
            drawable = GetPedDrawableVariation(ped, component),
            texture = GetPedTextureVariation(ped, component),
            palette = GetPedPaletteVariation(ped, component)
        }
    end

    for _, prop in ipairs(propIds) do
        savedOutfit.props[prop] = {
            drawable = GetPedPropIndex(ped, prop),
            texture = GetPedPropTextureIndex(ped, prop)
        }
    end
end

local function RestoreOutfit(ped)
    if not savedOutfit then return end

    for component, data in pairs(savedOutfit.components) do
        SetPedComponentVariation(ped, component, data.drawable, data.texture, data.palette)
    end

    for prop, data in pairs(savedOutfit.props) do
        if data.drawable and data.drawable >= 0 then
            SetPedPropIndex(ped, prop, data.drawable, data.texture or 0, true)
        else
            ClearPedProp(ped, prop)
        end
    end
end

local function EquipAdminUniform(ped)
    local jbib = Config.AdminJbib

    if not IsPedCollectionComponentVariationValid(
        ped,
        jbib.component,
        jbib.collection,
        jbib.drawable,
        jbib.texture,
        jbib.palette
    ) then
        Notify("~r~La sudadera de Administración no es compatible con este personaje.")
        return false
    end

    SaveOutfit(ped)

    -- Aplicar componentes globales elegidos.
    for component, data in pairs(Config.Components) do
        SetPedComponentVariation(
            ped,
            component,
            data.drawable,
            data.texture,
            data.palette
        )
    end

    -- Aplicar la sudadera del AdminPack.
    SetPedCollectionComponentVariation(
        ped,
        jbib.component,
        jbib.collection,
        jbib.drawable,
        jbib.texture,
        jbib.palette
    )

    -- Limpiar todos los props y poner únicamente los definidos.
    for _, prop in ipairs(propIds) do
        ClearPedProp(ped, prop)
    end

    for prop, data in pairs(Config.Props) do
        SetPedPropIndex(
            ped,
            prop,
            data.drawable,
            data.texture or 0,
            true
        )
    end

    return true
end

RegisterNetEvent("smvlpd-admin-clothing:toggle", function()
    local ped = PlayerPedId()

    if wearingAdminUniform then
        RestoreOutfit(ped)
        wearingAdminUniform = false
        savedOutfit = nil
        Notify("~g~Uniforme de Administración quitado. Ropa anterior restaurada.")
        return
    end

    if EquipAdminUniform(ped) then
        wearingAdminUniform = true
        Notify("~g~Uniforme de Administración equipado.")
    end
end)

AddEventHandler("playerSpawned", function()
    savedOutfit = nil
    wearingAdminUniform = false
end)
