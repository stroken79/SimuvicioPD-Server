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
        SetPedComponentVariation(ped, 10, 0, 0, 0) -- galones/insignias P2
    end,

    -- ==========================================
    -- P3 - OFICIAL
    -- Igual que P2, cambiando solo los galones
    -- ==========================================
    p3 = function(ped)
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

        -- Galones P3 - EmergencyEUP
        SetPedCollectionComponentVariation(ped, 10, "mp_m_emergency", 6, 0, 0)
    end,

    -- ==========================================
    -- OFICIAL SENIOR
    -- Igual que P3, cambiando solo los galones
    -- ==========================================
    senior = function(ped)
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

        -- Galones Oficial Senior - EmergencyEUP
        SetPedCollectionComponentVariation(ped, 10, "mp_m_emergency", 6, 1, 0)
    end,

    -- ==========================================
    -- SARGENTO 1
    -- Base Senior + galones y placa específicos
    -- ==========================================
    sargento1 = function(ped)
        -- EmergencyEUP
        SetPedCollectionComponentVariation(ped, 11, "mp_m_emergency", 30, 1, 0) -- camisa manga corta
        SetPedCollectionComponentVariation(ped, 8,  "mp_m_emergency", 58, 0, 0) -- cinturon + Taser
        SetPedCollectionComponentVariation(ped, 7,  "mp_m_emergency", 14, 0, 0) -- pistola en cinturon
        SetPedCollectionComponentVariation(ped, 5,  "mp_m_emergency", 3,  1, 0) -- placa/radio Sargento 1

        -- LSPD_EUP
        SetPedCollectionComponentVariation(ped, 4, "mp_m_lspd", 0, 2, 0) -- pantalon

        -- Base / Global
        SetPedComponentVariation(ped, 3, 11, 0, 0) -- brazos
        SetPedComponentVariation(ped, 6, 25, 0, 0) -- zapatos negros

        -- Galones Sargento 1 - EmergencyEUP
        SetPedCollectionComponentVariation(ped, 10, "mp_m_emergency", 6, 2, 0)
    end,

    -- ==========================================
    -- SARGENTO 2
    -- Igual que Sargento 1, cambia solo el galon
    -- ==========================================
    sargento2 = function(ped)
        -- EmergencyEUP
        SetPedCollectionComponentVariation(ped, 11, "mp_m_emergency", 30, 1, 0) -- camisa manga corta
        SetPedCollectionComponentVariation(ped, 8,  "mp_m_emergency", 58, 0, 0) -- cinturon + Taser
        SetPedCollectionComponentVariation(ped, 7,  "mp_m_emergency", 14, 0, 0) -- pistola en cinturon
        SetPedCollectionComponentVariation(ped, 5,  "mp_m_emergency", 3,  1, 0) -- placa/radio Sargento

        -- LSPD_EUP
        SetPedCollectionComponentVariation(ped, 4, "mp_m_lspd", 0, 2, 0) -- pantalon

        -- Base / Global
        SetPedComponentVariation(ped, 3, 11, 0, 0) -- brazos
        SetPedComponentVariation(ped, 6, 25, 0, 0) -- zapatos negros

        -- Galones Sargento 2 - EmergencyEUP
        SetPedCollectionComponentVariation(ped, 10, "mp_m_emergency", 6, 3, 0)
    end,

    -- ==========================================
    -- TENIENTE
    -- Uniforme comun para Teniente 1 y Teniente 2
    -- ==========================================
    teniente = function(ped)
        -- EmergencyEUP
        SetPedCollectionComponentVariation(ped, 11, "mp_m_emergency", 63, 1, 0) -- manga larga + corbata
        SetPedCollectionComponentVariation(ped, 8,  "mp_m_emergency", 58, 0, 0) -- cinturon + Taser
        SetPedCollectionComponentVariation(ped, 7,  "mp_m_emergency", 14, 0, 0) -- pistola en cinturon
        SetPedCollectionComponentVariation(ped, 5,  "mp_m_emergency", 3,  2, 0) -- placa Teniente

        -- LSPD_EUP
        SetPedCollectionComponentVariation(ped, 4, "mp_m_lspd", 0, 2, 0) -- pantalon

        -- Base / Global
        SetPedComponentVariation(ped, 3, 1, 0, 0)  -- brazos/torso para manga larga
        SetPedComponentVariation(ped, 6, 25, 0, 0) -- zapatos negros

        -- Galones Teniente - EmergencyEUP
        SetPedCollectionComponentVariation(ped, 10, "mp_m_emergency", 3, 0, 0)
    end,

    -- ==========================================
    -- CAPITAN
    -- Uniforme comun para Capitan 1, 2 y 3
    -- ==========================================
    capitan = function(ped)
        -- EmergencyEUP
        SetPedCollectionComponentVariation(ped, 11, "mp_m_emergency", 63, 1, 0) -- manga larga + corbata
        SetPedCollectionComponentVariation(ped, 8,  "mp_m_emergency", 58, 0, 0) -- cinturon + Taser
        SetPedCollectionComponentVariation(ped, 7,  "mp_m_emergency", 14, 0, 0) -- pistola en cinturon
        SetPedCollectionComponentVariation(ped, 5,  "mp_m_emergency", 3,  3, 0) -- placa Capitan

        -- LSPD_EUP
        SetPedCollectionComponentVariation(ped, 4, "mp_m_lspd", 0, 2, 0) -- pantalon

        -- Base / Global
        SetPedComponentVariation(ped, 3, 1, 0, 0)  -- brazos/torso para manga larga
        SetPedComponentVariation(ped, 6, 25, 0, 0) -- zapatos negros

        -- Galones Capitan - EmergencyEUP
        SetPedCollectionComponentVariation(ped, 10, "mp_m_emergency", 3, 1, 0)
    end,

    -- ==========================================
    -- COMANDANTE
    -- Uniforme de administracion / mando
    -- ==========================================
    comandante = function(ped)
        -- EmergencyEUP
        SetPedCollectionComponentVariation(ped, 11, "mp_m_emergency", 63, 1, 0) -- manga larga + corbata
        SetPedCollectionComponentVariation(ped, 8,  "mp_m_emergency", 44, 0, 0) -- cinturon de mando
        SetPedCollectionComponentVariation(ped, 7,  "mp_m_emergency", 14, 0, 0) -- pistola en cinturon
        SetPedCollectionComponentVariation(ped, 5,  "mp_m_emergency", 3,  5, 0) -- placa Comandante

        -- LSPD_EUP
        SetPedCollectionComponentVariation(ped, 4, "mp_m_lspd", 0, 2, 0) -- pantalon

        -- Base / Global
        SetPedComponentVariation(ped, 3, 1, 0, 0)  -- brazos/torso para manga larga
        SetPedComponentVariation(ped, 6, 25, 0, 0) -- zapatos negros

        -- Galones Comandante - EmergencyEUP
        SetPedCollectionComponentVariation(ped, 10, "mp_m_emergency", 3, 2, 0)
    end,

    -- ==========================================
    -- AYUDANTE DEL JEFE
    -- Misma base de mando; cambia placa y galones
    -- ==========================================
    ayudante = function(ped)
        SetPedCollectionComponentVariation(ped, 11, "mp_m_emergency", 63, 1, 0) -- manga larga + corbata
        SetPedCollectionComponentVariation(ped, 8,  "mp_m_emergency", 44, 0, 0) -- cinturon de mando
        SetPedCollectionComponentVariation(ped, 7,  "mp_m_emergency", 14, 0, 0) -- pistola
        SetPedCollectionComponentVariation(ped, 5,  "mp_m_emergency", 3,  7, 0) -- placa Ayudante

        SetPedCollectionComponentVariation(ped, 4, "mp_m_lspd", 0, 2, 0) -- pantalon
        SetPedComponentVariation(ped, 3, 1, 0, 0)  -- brazos/torso
        SetPedComponentVariation(ped, 6, 25, 0, 0) -- zapatos

        SetPedCollectionComponentVariation(ped, 10, "mp_m_emergency", 3, 3, 0) -- galones Ayudante
    end,

    -- ==========================================
    -- JEFE DE POLICIA
    -- Misma base de mando; cambia placa y galones
    -- ==========================================
    jefe = function(ped)
        SetPedCollectionComponentVariation(ped, 11, "mp_m_emergency", 63, 1, 0) -- manga larga + corbata
        SetPedCollectionComponentVariation(ped, 8,  "mp_m_emergency", 44, 0, 0) -- cinturon de mando
        SetPedCollectionComponentVariation(ped, 7,  "mp_m_emergency", 14, 0, 0) -- pistola
        SetPedCollectionComponentVariation(ped, 5,  "mp_m_emergency", 3,  8, 0) -- placa Jefe

        SetPedCollectionComponentVariation(ped, 4, "mp_m_lspd", 0, 2, 0) -- pantalon
        SetPedComponentVariation(ped, 3, 1, 0, 0)  -- brazos/torso
        SetPedComponentVariation(ped, 6, 25, 0, 0) -- zapatos

        SetPedCollectionComponentVariation(ped, 10, "mp_m_emergency", 3, 5, 0) -- galones Jefe
    end
}
function ApplyUniform(name)

    local fn = uniforms[string.lower(name)]

    if not fn then
        return false
    end

    local ped = PlayerPedId()

    if not DoesEntityExist(ped) then
        return false
    end

    fn(ped)

    return true
end
exports("ApplyUniform", ApplyUniform)




RegisterCommand("uniforme", function(_, args)
    local name = string.lower(args[1] or "")
    local fn = uniforms[name]

    if not fn then
        TriggerEvent("chat:addMessage", {
        args = {"PD5M", "Uso: /uniforme novato | /uniforme p2 | /uniforme p3 | /uniforme senior | /uniforme sargento1 | /uniforme sargento2 | /uniforme teniente | /uniforme capitan | /uniforme comandante | /uniforme ayudante | /uniforme jefe"}

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
