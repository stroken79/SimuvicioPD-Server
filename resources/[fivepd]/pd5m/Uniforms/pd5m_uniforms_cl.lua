-- PD5M SimuvicioPD - Presets de uniformes
-- NOVATO y P2 masculinos. Mezcla de colecciones EUP y componentes globales.
local function IsFemalePed(ped)
    return GetEntityModel(ped) == joaat("mp_f_freemode_01")
end
local uniforms = {

    -- ==========================================
    -- NOVATO
    -- ==========================================
    novato = function(ped)

    if IsFemalePed(ped) then

        -- EmergencyEUP
        SetPedCollectionComponentVariation(ped, 11, "mp_f_emergency", 38, 1, 0)
        SetPedCollectionComponentVariation(ped, 8,  "mp_f_emergency", 13, 0, 0)
        SetPedCollectionComponentVariation(ped, 5,  "mp_f_emergency", 0, 9, 0)

        -- LSPD_EUP
        SetPedCollectionComponentVariation(ped, 4, "mp_f_lspd", 0, 2, 0)
        SetPedCollectionComponentVariation(ped, 6, "mp_f_lspd", 0, 0, 0)

        -- Base
        SetPedComponentVariation(ped, 3, 1, 0, 0)
        SetPedComponentVariation(ped, 7, 0, 0, 0)  
        SetPedComponentVariation(ped, 10, 0, 0, 0)
        
    else

        -- EmergencyEUP
        SetPedCollectionComponentVariation(ped, 11, "mp_m_emergency", 41, 1, 0)
        SetPedCollectionComponentVariation(ped, 8,  "mp_m_emergency", 58, 0, 0)
        SetPedCollectionComponentVariation(ped, 5,  "mp_m_emergency", 3, 9, 0)

        -- LSPD_EUP
        SetPedCollectionComponentVariation(ped, 4, "mp_m_lspd", 0, 2, 0)

        -- Base / Global
        SetPedComponentVariation(ped, 3, 1, 0, 0)
        SetPedComponentVariation(ped, 6, 25, 0, 0)
        SetPedComponentVariation(ped, 7, 1, 0, 0)
        SetPedComponentVariation(ped, 10, 0, 0, 0)

    end

end,
    -- ==========================================
    -- P2
    -- ==========================================
    p2 = function(ped)

        if IsFemalePed(ped) then

    -- EmergencyEUP
    SetPedCollectionComponentVariation(ped, 11, "mp_f_emergency", 33, 1, 0) -- Camisa manga corta
    SetPedCollectionComponentVariation(ped, 8,  "mp_f_emergency", 31, 0, 0) -- Interior / cinturón
    SetPedCollectionComponentVariation(ped, 7,  "mp_f_emergency", 20, 0, 0) -- Accesorio
    SetPedCollectionComponentVariation(ped, 5,  "mp_f_emergency", 0, 9, 0)  -- Placa + radio

    -- LSPD_EUP
    SetPedCollectionComponentVariation(ped, 4, "mp_f_lspd", 0, 2, 0) -- Pantalón
    SetPedCollectionComponentVariation(ped, 6, "mp_f_lspd", 0, 0, 0) -- Zapatos

    -- Base / Global
    SetPedComponentVariation(ped, 3, 2, 0, 0)  -- Brazos
    SetPedComponentVariation(ped, 7, 182, 0, 0)
    SetPedComponentVariation(ped, 10, 0, 0, 0) -- Sin galones

else
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
        end
end,

    -- ==========================================
    -- P3 - OFICIAL
    -- Igual que P2, cambiando solo los galones
    -- ==========================================
    p3 = function(ped)

    if IsFemalePed(ped) then

        -- EmergencyEUP
        SetPedCollectionComponentVariation(ped, 11, "mp_f_emergency", 33, 1, 0) -- Camisa manga corta
        SetPedCollectionComponentVariation(ped, 8,  "mp_f_emergency", 31, 0, 0) -- Interior / cinturón
        SetPedCollectionComponentVariation(ped, 5,  "mp_f_emergency", 0, 9, 0)  -- Placa + radio

        -- LSPD_EUP
        SetPedCollectionComponentVariation(ped, 4, "mp_f_lspd", 0, 2, 0)
        SetPedCollectionComponentVariation(ped, 6, "mp_f_lspd", 0, 0, 0)

        -- Base / Global
        SetPedComponentVariation(ped, 3, 2, 0, 0)    -- Brazos
        SetPedComponentVariation(ped, 7, 182, 0, 0)  -- Pistola cinturón
        SetPedCollectionComponentVariation(ped, 10, "mp_f_emergency", 0, 0, 0) -- Insignia P3

    else

        -- EmergencyEUP
        SetPedCollectionComponentVariation(ped, 11, "mp_m_emergency", 30, 1, 0)
        SetPedCollectionComponentVariation(ped, 8,  "mp_m_emergency", 58, 0, 0)
        SetPedCollectionComponentVariation(ped, 7,  "mp_m_emergency", 14, 0, 0)
        SetPedCollectionComponentVariation(ped, 5,  "mp_m_emergency", 3, 9, 0)

        -- LSPD_EUP
        SetPedCollectionComponentVariation(ped, 4, "mp_m_lspd", 0, 2, 0)

        -- Base / Global
        SetPedComponentVariation(ped, 3, 11, 0, 0)
        SetPedComponentVariation(ped, 6, 25, 0, 0)

        -- Insignia P3
        SetPedCollectionComponentVariation(ped, 10, "mp_m_emergency", 6, 0, 0)

    end

end,

    -- ==========================================
    -- OFICIAL SENIOR
    -- Igual que P3, cambiando solo los galones
    -- ==========================================
    senior = function(ped)

    if IsFemalePed(ped) then

        -- EmergencyEUP
        SetPedCollectionComponentVariation(ped, 11, "mp_f_emergency", 33, 1, 0) -- Camisa manga corta
        SetPedCollectionComponentVariation(ped, 8,  "mp_f_emergency", 31, 0, 0) -- Interior / cinturón
        SetPedCollectionComponentVariation(ped, 5,  "mp_f_emergency", 0, 9, 0)  -- Placa + radio

        -- LSPD_EUP
        SetPedCollectionComponentVariation(ped, 4, "mp_f_lspd", 0, 2, 0)
        SetPedCollectionComponentVariation(ped, 6, "mp_f_lspd", 0, 0, 0)

        -- Base / Global
        SetPedComponentVariation(ped, 3, 2, 0, 0)    -- Brazos
        SetPedComponentVariation(ped, 7, 182, 0, 0)  -- Pistola cinturón

        -- Insignia Senior
        SetPedCollectionComponentVariation(ped, 10, "mp_f_emergency", 0, 1, 0)

    else

        -- EmergencyEUP
        SetPedCollectionComponentVariation(ped, 11, "mp_m_emergency", 30, 1, 0)
        SetPedCollectionComponentVariation(ped, 8,  "mp_m_emergency", 58, 0, 0)
        SetPedCollectionComponentVariation(ped, 7,  "mp_m_emergency", 14, 0, 0)
        SetPedCollectionComponentVariation(ped, 5,  "mp_m_emergency", 3, 9, 0)

        -- LSPD_EUP
        SetPedCollectionComponentVariation(ped, 4, "mp_m_lspd", 0, 2, 0)

        -- Base / Global
        SetPedComponentVariation(ped, 3, 11, 0, 0)
        SetPedComponentVariation(ped, 6, 25, 0, 0)

        -- Insignia Senior
        SetPedCollectionComponentVariation(ped, 10, "mp_m_emergency", 6, 1, 0)

    end

end,

    -- ==========================================
    -- SARGENTO 1
    -- Base Senior + galones y placa específicos
    -- ==========================================
    sargento1 = function(ped)

    if IsFemalePed(ped) then

        -- EmergencyEUP
        SetPedCollectionComponentVariation(ped, 11, "mp_f_emergency", 33, 1, 0) -- Camisa manga corta
        SetPedCollectionComponentVariation(ped, 8,  "mp_f_emergency", 31, 0, 0) -- Interior / cinturón
        SetPedCollectionComponentVariation(ped, 5,  "mp_f_emergency", 0, 1, 0)  -- Placa Sargento I

        -- LSPD_EUP
        SetPedCollectionComponentVariation(ped, 4, "mp_f_lspd", 0, 2, 0)
        SetPedCollectionComponentVariation(ped, 6, "mp_f_lspd", 0, 0, 0)

        -- Base / Global
        SetPedComponentVariation(ped, 3, 2, 0, 0)    -- Brazos
        SetPedComponentVariation(ped, 7, 182, 0, 0)  -- Pistola cinturón

        -- Insignia Sargento I
        SetPedCollectionComponentVariation(ped, 10, "mp_f_emergency", 0, 2, 0)

    else

        -- EmergencyEUP
        SetPedCollectionComponentVariation(ped, 11, "mp_m_emergency", 30, 1, 0)
        SetPedCollectionComponentVariation(ped, 8,  "mp_m_emergency", 58, 0, 0)
        SetPedCollectionComponentVariation(ped, 7,  "mp_m_emergency", 14, 0, 0)
        SetPedCollectionComponentVariation(ped, 5,  "mp_m_emergency", 3, 1, 0)

        -- LSPD_EUP
        SetPedCollectionComponentVariation(ped, 4, "mp_m_lspd", 0, 2, 0)

        -- Base / Global
        SetPedComponentVariation(ped, 3, 11, 0, 0)
        SetPedComponentVariation(ped, 6, 25, 0, 0)

        -- Insignia Sargento I
        SetPedCollectionComponentVariation(ped, 10, "mp_m_emergency", 6, 2, 0)

    end

end,

    -- ==========================================
    -- SARGENTO 2
    -- Igual que Sargento 1, cambia solo el galon
    -- ==========================================
    sargento2 = function(ped)

    if IsFemalePed(ped) then

        -- EmergencyEUP
        SetPedCollectionComponentVariation(ped, 11, "mp_f_emergency", 33, 1, 0) -- Camisa manga corta
        SetPedCollectionComponentVariation(ped, 8,  "mp_f_emergency", 31, 0, 0) -- Interior / cinturón
        SetPedCollectionComponentVariation(ped, 5,  "mp_f_emergency", 0, 1, 0)  -- Placa Sargento

        -- LSPD_EUP
        SetPedCollectionComponentVariation(ped, 4, "mp_f_lspd", 0, 2, 0)
        SetPedCollectionComponentVariation(ped, 6, "mp_f_lspd", 0, 0, 0)

        -- Base / Global
        SetPedComponentVariation(ped, 3, 2, 0, 0)    -- Brazos
        SetPedComponentVariation(ped, 7, 182, 0, 0)  -- Pistola cinturón

        -- Insignia Sargento II
        SetPedCollectionComponentVariation(ped, 10, "mp_f_emergency", 0, 3, 0)

    else

        -- EmergencyEUP
        SetPedCollectionComponentVariation(ped, 11, "mp_m_emergency", 30, 1, 0)
        SetPedCollectionComponentVariation(ped, 8,  "mp_m_emergency", 58, 0, 0)
        SetPedCollectionComponentVariation(ped, 7,  "mp_m_emergency", 14, 0, 0)
        SetPedCollectionComponentVariation(ped, 5,  "mp_m_emergency", 3, 1, 0)

        -- LSPD_EUP
        SetPedCollectionComponentVariation(ped, 4, "mp_m_lspd", 0, 2, 0)

        -- Base / Global
        SetPedComponentVariation(ped, 3, 11, 0, 0)
        SetPedComponentVariation(ped, 6, 25, 0, 0)

        -- Insignia Sargento II
        SetPedCollectionComponentVariation(ped, 10, "mp_m_emergency", 6, 3, 0)

    end

end,

    -- ==========================================
    -- TENIENTE
    -- Uniforme comun para Teniente 1 y Teniente 2
    -- ==========================================
    teniente = function(ped)

    if IsFemalePed(ped) then

        -- EmergencyEUP
        SetPedCollectionComponentVariation(ped, 11, "mp_f_emergency", 38, 1, 0) -- Camisa manga larga
        SetPedCollectionComponentVariation(ped, 8,  "mp_f_emergency", 31, 0, 0) -- Interior / cinturón
        SetPedCollectionComponentVariation(ped, 5,  "mp_f_emergency", 0, 2, 0)  -- Placa Teniente

        -- LSPD_EUP
        SetPedCollectionComponentVariation(ped, 4, "mp_f_lspd", 0, 2, 0)
        SetPedCollectionComponentVariation(ped, 6, "mp_f_lspd", 0, 0, 0)

        -- Base / Global
        SetPedComponentVariation(ped, 3, 1, 0, 0)    -- Brazos manga larga
        SetPedComponentVariation(ped, 7, 182, 0, 0)  -- Pistola cinturón

        -- Insignia Teniente
        SetPedCollectionComponentVariation(ped, 10, "mp_f_emergency", 20, 0, 0)

    else

        -- EmergencyEUP
        SetPedCollectionComponentVariation(ped, 11, "mp_m_emergency", 63, 1, 0)
        SetPedCollectionComponentVariation(ped, 8,  "mp_m_emergency", 58, 0, 0)
        SetPedCollectionComponentVariation(ped, 7,  "mp_m_emergency", 14, 0, 0)
        SetPedCollectionComponentVariation(ped, 5,  "mp_m_emergency", 3, 2, 0)

        -- LSPD_EUP
        SetPedCollectionComponentVariation(ped, 4, "mp_m_lspd", 0, 2, 0)

        -- Base / Global
        SetPedComponentVariation(ped, 3, 1, 0, 0)
        SetPedComponentVariation(ped, 6, 25, 0, 0)

        -- Insignia Teniente
        SetPedCollectionComponentVariation(ped, 10, "mp_m_emergency", 3, 0, 0)

    end

end,

    -- ==========================================
    -- CAPITAN
    -- Uniforme comun para Capitan 1, 2 y 3
    -- ==========================================
    capitan = function(ped)

    if IsFemalePed(ped) then

        -- EmergencyEUP
        SetPedCollectionComponentVariation(ped, 11, "mp_f_emergency", 38, 1, 0) -- Camisa manga larga
        SetPedCollectionComponentVariation(ped, 8,  "mp_f_emergency", 31, 0, 0) -- Interior / cinturón
        SetPedCollectionComponentVariation(ped, 5,  "mp_f_emergency", 0, 3, 0)  -- Placa Capitán

        -- LSPD_EUP
        SetPedCollectionComponentVariation(ped, 4, "mp_f_lspd", 0, 2, 0)
        SetPedCollectionComponentVariation(ped, 6, "mp_f_lspd", 0, 0, 0)

        -- Base / Global
        SetPedComponentVariation(ped, 3, 1, 0, 0)    -- Brazos manga larga
        SetPedComponentVariation(ped, 7, 182, 0, 0)  -- Pistola cinturón

        -- Insignia Capitán
        SetPedCollectionComponentVariation(ped, 10, "mp_f_emergency", 20, 1, 0)

    else

        -- EmergencyEUP
        SetPedCollectionComponentVariation(ped, 11, "mp_m_emergency", 63, 1, 0)
        SetPedCollectionComponentVariation(ped, 8,  "mp_m_emergency", 58, 0, 0)
        SetPedCollectionComponentVariation(ped, 7,  "mp_m_emergency", 14, 0, 0)
        SetPedCollectionComponentVariation(ped, 5,  "mp_m_emergency", 3, 3, 0)

        -- LSPD_EUP
        SetPedCollectionComponentVariation(ped, 4, "mp_m_lspd", 0, 2, 0)

        -- Base / Global
        SetPedComponentVariation(ped, 3, 1, 0, 0)
        SetPedComponentVariation(ped, 6, 25, 0, 0)

        -- Insignia Capitán
        SetPedCollectionComponentVariation(ped, 10, "mp_m_emergency", 3, 1, 0)

    end

end,

    -- ==========================================
    -- COMANDANTE
    -- Uniforme de administracion / mando
    -- ==========================================
    comandante = function(ped)

    if IsFemalePed(ped) then

        -- EmergencyEUP
        SetPedCollectionComponentVariation(ped, 11, "mp_f_emergency", 69, 1, 0) -- Camisa manga larga + corbata
        SetPedCollectionComponentVariation(ped, 8,  "mp_f_emergency", 12, 0, 0) -- Cinturón de mando
        SetPedCollectionComponentVariation(ped, 5,  "mp_f_emergency", 0, 5, 0)  -- Placa Comandante

        -- LSPD_EUP
        SetPedCollectionComponentVariation(ped, 4, "mp_f_lspd", 0, 2, 0)
        SetPedCollectionComponentVariation(ped, 6, "mp_f_lspd", 0, 0, 0)

        -- Base / Global
        SetPedComponentVariation(ped, 3, 1, 0, 0)    -- Brazos manga larga
        SetPedComponentVariation(ped, 7, 182, 0, 0)  -- Pistola cinturón

        -- Insignia Comandante
        SetPedCollectionComponentVariation(ped, 10, "mp_f_emergency", 20, 2, 0)

    else

        -- EmergencyEUP
        SetPedCollectionComponentVariation(ped, 11, "mp_m_emergency", 63, 1, 0)
        SetPedCollectionComponentVariation(ped, 8,  "mp_m_emergency", 44, 0, 0)
        SetPedCollectionComponentVariation(ped, 7,  "mp_m_emergency", 14, 0, 0)
        SetPedCollectionComponentVariation(ped, 5,  "mp_m_emergency", 3, 5, 0)

        -- LSPD_EUP
        SetPedCollectionComponentVariation(ped, 4, "mp_m_lspd", 0, 2, 0)

        -- Base / Global
        SetPedComponentVariation(ped, 3, 1, 0, 0)
        SetPedComponentVariation(ped, 6, 25, 0, 0)

        -- Insignia Comandante
        SetPedCollectionComponentVariation(ped, 10, "mp_m_emergency", 3, 2, 0)

    end

end,

    -- ==========================================
    -- AYUDANTE DEL JEFE
    -- Misma base de mando; cambia placa y galones
    -- ==========================================
    ayudante = function(ped)

    if IsFemalePed(ped) then

        -- EmergencyEUP
        SetPedCollectionComponentVariation(ped, 11, "mp_f_emergency", 69, 1, 0) -- Camisa manga larga + corbata
        SetPedCollectionComponentVariation(ped, 8,  "mp_f_emergency", 12, 0, 0) -- Cinturón de mando
        SetPedCollectionComponentVariation(ped, 5,  "mp_f_emergency", 0, 7, 0)  -- Placa Ayudante

        -- LSPD_EUP
        SetPedCollectionComponentVariation(ped, 4, "mp_f_lspd", 0, 2, 0)
        SetPedCollectionComponentVariation(ped, 6, "mp_f_lspd", 0, 0, 0)

        -- Base / Global
        SetPedComponentVariation(ped, 3, 1, 0, 0)    -- Brazos manga larga
        SetPedComponentVariation(ped, 7, 182, 0, 0)  -- Pistola cinturón

        -- Insignia Ayudante
        SetPedCollectionComponentVariation(ped, 10, "mp_f_emergency", 20, 3, 0)

    else

        -- EmergencyEUP
        SetPedCollectionComponentVariation(ped, 11, "mp_m_emergency", 63, 1, 0)
        SetPedCollectionComponentVariation(ped, 8,  "mp_m_emergency", 44, 0, 0)
        SetPedCollectionComponentVariation(ped, 7,  "mp_m_emergency", 14, 0, 0)
        SetPedCollectionComponentVariation(ped, 5,  "mp_m_emergency", 3, 7, 0)

        -- LSPD_EUP
        SetPedCollectionComponentVariation(ped, 4, "mp_m_lspd", 0, 2, 0)

        -- Base / Global
        SetPedComponentVariation(ped, 3, 1, 0, 0)
        SetPedComponentVariation(ped, 6, 25, 0, 0)

        -- Insignia Ayudante
        SetPedCollectionComponentVariation(ped, 10, "mp_m_emergency", 3, 3, 0)

    end

end,

    -- ==========================================
    -- JEFE DE POLICIA
    -- Misma base de mando; cambia placa y galones
    -- ==========================================
    jefe = function(ped)

    if IsFemalePed(ped) then

        -- EmergencyEUP
        SetPedCollectionComponentVariation(ped, 11, "mp_f_emergency", 69, 1, 0) -- Camisa manga larga + corbata
        SetPedCollectionComponentVariation(ped, 8,  "mp_f_emergency", 12, 0, 0) -- Cinturón de mando
        SetPedCollectionComponentVariation(ped, 5,  "mp_f_emergency", 0, 8, 0)  -- Placa Jefe

        -- LSPD_EUP
        SetPedCollectionComponentVariation(ped, 4, "mp_f_lspd", 0, 2, 0)
        SetPedCollectionComponentVariation(ped, 6, "mp_f_lspd", 0, 0, 0)

        -- Base / Global
        SetPedComponentVariation(ped, 3, 1, 0, 0)    -- Brazos manga larga
        SetPedComponentVariation(ped, 7, 182, 0, 0)  -- Pistola cinturón

        -- Insignia Jefe
        SetPedCollectionComponentVariation(ped, 10, "mp_f_emergency", 20, 5, 0)

    else

        -- EmergencyEUP
        SetPedCollectionComponentVariation(ped, 11, "mp_m_emergency", 63, 1, 0)
        SetPedCollectionComponentVariation(ped, 8,  "mp_m_emergency", 44, 0, 0)
        SetPedCollectionComponentVariation(ped, 7,  "mp_m_emergency", 14, 0, 0)
        SetPedCollectionComponentVariation(ped, 5,  "mp_m_emergency", 3, 8, 0)

        -- LSPD_EUP
        SetPedCollectionComponentVariation(ped, 4, "mp_m_lspd", 0, 2, 0)

        -- Base / Global
        SetPedComponentVariation(ped, 3, 1, 0, 0)
        SetPedComponentVariation(ped, 6, 25, 0, 0)

        -- Insignia Jefe
        SetPedCollectionComponentVariation(ped, 10, "mp_m_emergency", 3, 5, 0)

    end

end,
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
