-- PD5M SimuvicioPD - Presets de uniformes
-- NOVATO y P2 masculinos. Mezcla de colecciones EUP y componentes globales.

local uniforms = {

    -- ==========================================
    -- NOVATO
    -- ==========================================
    novato = function(ped)
        -- EmergencyEUP
        SetPedCollectionComponentVariation(ped, 11, "mp_m_emergency", 41, 1, 0) -- camisa manga larga
        SetPedCollectionComponentVariation(ped, 8,  "mp_m_emergency", 58, 0, 0) -- cinturon + Taser
        SetPedCollectionComponentVariation(ped, 5,  "mp_m_emergency", 3,  9, 0) -- placa + radio

        -- LSPD_EUP
        SetPedCollectionComponentVariation(ped, 4, "mp_m_lspd", 0, 2, 0) -- pantalon

        -- Base / Global
        SetPedComponentVariation(ped, 3, 1, 0, 0)  -- brazos
        SetPedComponentVariation(ped, 6, 25, 0, 0) -- zapatos negros
        SetPedComponentVariation(ped, 7, 1, 0, 0)  -- sin pistola/accesorio
        SetPedComponentVariation(ped, 10, 0, 0, 0) -- sin galones/insignias
    end,

    -- ==========================================
    -- P2
    -- ==========================================
    p2 = function(ped)
        -- EmergencyEUP
        SetPedCollectionComponentVariation(ped, 11, "mp_m_emergency", 30, 1, 0) -- camisa manga corta
        SetPedCollectionComponentVariation(ped, 8,  "mp_m_emergency", 58, 0, 0) -- cinturon + Taser
        SetPedCollectionComponentVariation(ped, 7,  "mp_m_emergency", 14, 0, 0) -- pistola en cinturon
        SetPedCollectionComponentVariation(ped, 5,  "mp_m_emergency", 3,  9, 0) -- placa + radio

        -- LSPD_EUP
        SetPedCollectionComponentVariation(ped, 4, "mp_m_lspd", 0, 2, 0) -- pantalon

        -- Base / Global
        SetPedComponentVariation(ped, 3, 11, 0, 0) -- brazos
        SetPedComponentVariation(ped, 6, 25, 0, 0) -- zapatos negros
        SetPedComponentVariation(ped, 10, 0, 0, 0) -- galones/insignias
    end
}

RegisterCommand("uniforme", function(_, args)
    local name = string.lower(args[1] or "")
    local fn = uniforms[name]

    if not fn then
        TriggerEvent("chat:addMessage", {
            args = {"PD5M", "Uso: /uniforme novato | /uniforme p2"}
        })
        return
    end

    local ped = PlayerPedId()
    if not DoesEntityExist(ped) then return end

    fn(ped)

    TriggerEvent("chat:addMessage", {
        args = {"PD5M", "Uniforme " .. string.upper(name) .. " aplicado."}
    })
end, false)