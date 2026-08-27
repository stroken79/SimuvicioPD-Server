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

        -- Camisa / Top
        SetPedComponentVariation(ped, 11, 626, 1, 0)

        -- Camiseta / Interior
        SetPedComponentVariation(ped, 8, 308, 0, 0)

        -- Bolsas
        SetPedComponentVariation(ped, 5, 111, 0, 0)

        -- Pantalón
        SetPedComponentVariation(ped, 4, 186, 0, 0)

        -- Zapatos
        SetPedComponentVariation(ped, 6, 115, 0, 0)

        -- Brazos
        SetPedComponentVariation(ped, 3, 2, 0, 0)

        -- Accesorio
        SetPedComponentVariation(ped, 7, 0, 0, 0)

        -- Sin galones / insignias
        SetPedComponentVariation(ped, 10, 0, 0, 0)

        -- Sin chaleco
        SetPedComponentVariation(ped, 9, 0, 0, 0)

    else

        -- ==========================================
        -- NOVATO MASCULINO - SIN EUP / SIN LSPD
        -- ==========================================

        -- Camisa / Top
        SetPedComponentVariation(ped, 11, 585, 1, 0)

        -- Camiseta / Interior
        SetPedComponentVariation(ped, 8, 271, 0, 0)

        -- Bolsas / accesorio
        SetPedComponentVariation(ped, 5, 114, 0, 0)

        -- Pantalón
        SetPedComponentVariation(ped, 4, 173, 0, 0)

        -- Brazos
        SetPedComponentVariation(ped, 3, 1, 0, 0)

        -- Zapatos
        SetPedComponentVariation(ped, 6, 25, 0, 0)

        -- Accesorio
        SetPedComponentVariation(ped, 7, 1, 0, 0)

        -- Sin galones
        SetPedComponentVariation(ped, 10, 0, 0, 0)

    end

end,
    -- ==========================================
    -- P2
    -- ==========================================
    p2 = function(ped)

    if IsFemalePed(ped) then

        -- Camisa / Top
        SetPedComponentVariation(ped, 11, 621, 1, 0)

        -- Camiseta / Interior
        SetPedComponentVariation(ped, 8, 308, 0, 0)

        -- Bolsas
        SetPedComponentVariation(ped, 5, 111, 0, 0)

        -- Pantalón
        SetPedComponentVariation(ped, 4, 186, 0, 0)

        -- Zapatos
        SetPedComponentVariation(ped, 6, 115, 0, 0)

        -- Brazos
        SetPedComponentVariation(ped, 3, 2, 0, 0)

        -- Accesorios
        SetPedComponentVariation(ped, 7, 182, 0, 0)

        -- Sin insignias
        SetPedComponentVariation(ped, 10, 0, 0, 0)

        -- Sin chaleco
        SetPedComponentVariation(ped, 9, 0, 0, 0)

    else

        -- ==========================================
        -- P2 MASCULINO - SIN EUP / SIN LSPD
        -- ==========================================

        -- Camisa / Top
        SetPedComponentVariation(ped, 11, 574, 1, 0)

        -- Camiseta / Interior
        SetPedComponentVariation(ped, 8, 271, 0, 0)

        -- Bolsas / placa-radio
        SetPedComponentVariation(ped, 5, 114, 0, 0)

        -- Accesorio / cinturón-pistola
        SetPedComponentVariation(ped, 7, 206, 0, 0)

        -- Pantalón
        SetPedComponentVariation(ped, 4, 173, 0, 0)

        -- Brazos
        SetPedComponentVariation(ped, 3, 11, 0, 0)

        -- Zapatos
        SetPedComponentVariation(ped, 6, 25, 0, 0)

        -- Sin galones
        SetPedComponentVariation(ped, 10, 0, 0, 0)

    end

end,

    -- ==========================================
    -- P3 - OFICIAL
    -- Igual que P2, cambiando solo los galones
    -- ==========================================
    p3 = function(ped)

    if IsFemalePed(ped) then

        -- Camisa / Top
        SetPedComponentVariation(ped, 11, 621, 1, 0)

        -- Camiseta / Interior
        SetPedComponentVariation(ped, 8, 308, 0, 0)

        -- Bolsas
        SetPedComponentVariation(ped, 5, 111, 0, 0)

        -- Pantalón
        SetPedComponentVariation(ped, 4, 186, 0, 0)

        -- Zapatos
        SetPedComponentVariation(ped, 6, 115, 0, 0)

        -- Brazos
        SetPedComponentVariation(ped, 3, 2, 0, 0)

        -- Accesorios
        SetPedComponentVariation(ped, 7, 182, 0, 0)

        -- Insignias P3
        SetPedComponentVariation(ped, 10, 223, 0, 0)

        -- Sin chaleco
        SetPedComponentVariation(ped, 9, 0, 0, 0)

    else

         -- Camisa / Top
        SetPedComponentVariation(ped, 11, 574, 1, 0)

        -- Camiseta / Interior
        SetPedComponentVariation(ped, 8, 271, 0, 0)

        -- Bolsas
        SetPedComponentVariation(ped, 5, 114, 0, 0)

        -- Accesorio / cinturón
        SetPedComponentVariation(ped, 7, 206, 0, 0)

        -- Pantalón
        SetPedComponentVariation(ped, 4, 173, 0, 0)

        -- Brazos
        SetPedComponentVariation(ped, 3, 11, 0, 0)

        -- Zapatos
        SetPedComponentVariation(ped, 6, 25, 0, 0)

        -- Insignias P3
        SetPedComponentVariation(ped, 10, 213, 0, 0)

    end

end,

    -- ==========================================
    -- OFICIAL SENIOR
    -- Igual que P3, cambiando solo los galones
    -- ==========================================
    senior = function(ped)

    if IsFemalePed(ped) then

        -- Camisa / Top
        SetPedComponentVariation(ped, 11, 621, 1, 0)

        -- Camiseta / Interior
        SetPedComponentVariation(ped, 8, 308, 0, 0)

        -- Bolsas
        SetPedComponentVariation(ped, 5, 111, 0, 0)

        -- Pantalón
        SetPedComponentVariation(ped, 4, 186, 0, 0)

        -- Zapatos
        SetPedComponentVariation(ped, 6, 115, 0, 0)

        -- Brazos
        SetPedComponentVariation(ped, 3, 2, 0, 0)

        -- Accesorios
        SetPedComponentVariation(ped, 7, 182, 0, 0)

        -- Insignias P3
        SetPedComponentVariation(ped, 10, 223, 1, 0)

        -- Sin chaleco
        SetPedComponentVariation(ped, 9, 0, 0, 0)

    else

        -- Camisa / Top
        SetPedComponentVariation(ped, 11, 574, 1, 0)

        -- Camiseta / Interior
        SetPedComponentVariation(ped, 8, 271, 0, 0)

        -- Bolsas
        SetPedComponentVariation(ped, 5, 114, 0, 0)

        -- Accesorio / cinturón
        SetPedComponentVariation(ped, 7, 206, 0, 0)

        -- Pantalón
        SetPedComponentVariation(ped, 4, 173, 0, 0)

        -- Brazos
        SetPedComponentVariation(ped, 3, 11, 0, 0)

        -- Zapatos
        SetPedComponentVariation(ped, 6, 25, 0, 0)

        -- Insignias Senior
        SetPedComponentVariation(ped, 10, 223, 1, 0)

    end

end,

    -- ==========================================
    -- SARGENTO 1
    -- Base Senior + galones y placa específicos
    -- ==========================================
    sargento1 = function(ped)

    if IsFemalePed(ped) then

        -- ==========================================
        -- SARGENTO 1 FEMENINO - SIN EUP / SIN LSPD
        -- ==========================================

        -- Camisa / Top
        SetPedComponentVariation(ped, 11, 621, 1, 0)

        -- Camiseta / Interior
        SetPedComponentVariation(ped, 8, 308, 0, 0)

        -- Bolsas / Placa Sargento 1
        SetPedComponentVariation(ped, 5, 111, 1, 0)

        -- Pantalón
        SetPedComponentVariation(ped, 4, 186, 0, 0)

        -- Zapatos
        SetPedComponentVariation(ped, 6, 115, 0, 0)

        -- Brazos
        SetPedComponentVariation(ped, 3, 2, 0, 0)

        -- Accesorios
        SetPedComponentVariation(ped, 7, 182, 0, 0)

        -- Insignias Sargento 1
        SetPedComponentVariation(ped, 10, 223, 2, 0)

        -- Sin chaleco
        SetPedComponentVariation(ped, 9, 0, 0, 0)

    else

        -- Camisa / Top
        SetPedComponentVariation(ped, 11, 574, 1, 0)

        -- Camiseta / Interior
        SetPedComponentVariation(ped, 8, 271, 0, 0)

        -- Bolsas / placa
        SetPedComponentVariation(ped, 5, 114, 1, 0)

        -- Accesorio / cinturón
        SetPedComponentVariation(ped, 7, 206, 0, 0)

        -- Pantalón
        SetPedComponentVariation(ped, 4, 173, 0, 0)

        -- Brazos
        SetPedComponentVariation(ped, 3, 11, 0, 0)

        -- Zapatos
        SetPedComponentVariation(ped, 6, 25, 0, 0)

        -- Insignias Sargento 1
        SetPedComponentVariation(ped, 10, 213, 2, 0)

    end

end,

    -- ==========================================
    -- SARGENTO 2
    -- Igual que Sargento 1, cambia solo el galon
    -- ==========================================
    sargento2 = function(ped)

    if IsFemalePed(ped) then

        -- Camisa / Top
        SetPedComponentVariation(ped, 11, 621, 1, 0)

        -- Camiseta / Interior
        SetPedComponentVariation(ped, 8, 308, 0, 0)

        -- Bolsas / Placa Sargento 1
        SetPedComponentVariation(ped, 5, 111, 1, 0)

        -- Pantalón
        SetPedComponentVariation(ped, 4, 186, 0, 0)

        -- Zapatos
        SetPedComponentVariation(ped, 6, 115, 0, 0)

        -- Brazos
        SetPedComponentVariation(ped, 3, 2, 0, 0)

        -- Accesorios
        SetPedComponentVariation(ped, 7, 182, 0, 0)

        -- Insignias Sargento 2
        SetPedComponentVariation(ped, 10, 223, 3, 0)

        -- Sin chaleco
        SetPedComponentVariation(ped, 9, 0, 0, 0)

    else

        -- Camisa / Top
        SetPedComponentVariation(ped, 11, 574, 1, 0)

        -- Camiseta / Interior
        SetPedComponentVariation(ped, 8, 271, 0, 0)

        -- Bolsas / placa
        SetPedComponentVariation(ped, 5, 114, 1, 0)

        -- Accesorio / cinturón
        SetPedComponentVariation(ped, 7, 206, 0, 0)

        -- Pantalón
        SetPedComponentVariation(ped, 4, 173, 0, 0)

        -- Brazos
        SetPedComponentVariation(ped, 3, 11, 0, 0)

        -- Zapatos
        SetPedComponentVariation(ped, 6, 25, 0, 0)

        -- Insignias Sargento 1
        SetPedComponentVariation(ped, 10, 213, 3, 0)

    end
end,

    -- ==========================================
    -- TENIENTE
    -- Uniforme comun para Teniente 1 y Teniente 2
    -- ==========================================
    teniente = function(ped)

    if IsFemalePed(ped) then

        -- Camisa / Top
        SetPedComponentVariation(ped, 11, 657, 1, 0)

        -- Camiseta / Interior
        SetPedComponentVariation(ped, 8, 308, 0, 0)

        -- Bolsas / Placa
        SetPedComponentVariation(ped, 5, 111, 2, 0)

        -- Pantalón
        SetPedComponentVariation(ped, 4, 186, 0, 0)

        -- Zapatos
        SetPedComponentVariation(ped, 6, 115, 0, 0)

        -- Brazos
        SetPedComponentVariation(ped, 3, 2, 0, 0)

        -- Accesorios
        SetPedComponentVariation(ped, 7, 182, 0, 0)

        -- Insignias Teniente
        SetPedComponentVariation(ped, 10, 243, 0, 0)

        -- Sin chaleco
        SetPedComponentVariation(ped, 9, 0, 0, 0)

    else

        -- Camisa / Top
        SetPedComponentVariation(ped, 11, 607, 1, 0)

        -- Camiseta / Interior
        SetPedComponentVariation(ped, 8, 271, 0, 0)

        -- Bolsas / Placa
        SetPedComponentVariation(ped, 5, 114, 2, 0)

        -- Accesorio / cinturón
        SetPedComponentVariation(ped, 7, 206, 0, 0)

        -- Pantalón
        SetPedComponentVariation(ped, 4, 173, 0, 0)

        -- Brazos
        SetPedComponentVariation(ped, 3, 1, 0, 0)

        -- Zapatos
        SetPedComponentVariation(ped, 6, 25, 0, 0)

        -- Insignias Teniente
        SetPedComponentVariation(ped, 10, 210, 0, 0)

    end

end,

    -- ==========================================
    -- CAPITAN
    -- Uniforme comun para Capitan 1, 2 y 3
    -- ==========================================
    capitan = function(ped)

    if IsFemalePed(ped) then

       -- Camisa / Top
        SetPedComponentVariation(ped, 11, 657, 1, 0)

        -- Camiseta / Interior
        SetPedComponentVariation(ped, 8, 308, 0, 0)

        -- Bolsas / Placa
        SetPedComponentVariation(ped, 5, 111, 3, 0)

        -- Pantalón
        SetPedComponentVariation(ped, 4, 186, 0, 0)

        -- Zapatos
        SetPedComponentVariation(ped, 6, 115, 0, 0)

        -- Brazos
        SetPedComponentVariation(ped, 3, 2, 0, 0)

        -- Accesorios
        SetPedComponentVariation(ped, 7, 182, 0, 0)

        -- Insignias Capitán
        SetPedComponentVariation(ped, 10, 243, 1, 0)

        -- Sin chaleco
        SetPedComponentVariation(ped, 9, 0, 0, 0)

    else

        -- Camisa / Top
        SetPedComponentVariation(ped, 11, 607, 1, 0)

        -- Camiseta / Interior
        SetPedComponentVariation(ped, 8, 271, 0, 0)

        -- Bolsas / Placa
        SetPedComponentVariation(ped, 5, 114, 3, 0)

        -- Accesorio / cinturón
        SetPedComponentVariation(ped, 7, 206, 0, 0)

        -- Pantalón
        SetPedComponentVariation(ped, 4, 173, 0, 0)

        -- Brazos
        SetPedComponentVariation(ped, 3, 1, 0, 0)

        -- Zapatos
        SetPedComponentVariation(ped, 6, 25, 0, 0)

        -- Insignias Capitán
        SetPedComponentVariation(ped, 10, 210, 1, 0)

    end

end,

   

    -- ==========================================
    -- JEFE DE POLICIA
    -- Misma base de mando; cambia placa y galones
    -- ==========================================
    jefe = function(ped)

    if IsFemalePed(ped) then

        -- Camisa / Top
        SetPedComponentVariation(ped, 11, 657, 1, 0)

        -- Camiseta / Interior
        SetPedComponentVariation(ped, 8, 271, 0, 0)

        -- Bolsas / Placa
        SetPedComponentVariation(ped, 5, 111, 8, 0)

        -- Pantalón
        SetPedComponentVariation(ped, 4, 186, 0, 0)

        -- Zapatos
        SetPedComponentVariation(ped, 6, 115, 0, 0)

        -- Brazos
        SetPedComponentVariation(ped, 3, 2, 0, 0)

        -- Accesorios
        SetPedComponentVariation(ped, 7, 182, 0, 0)

        -- Insignias Jefe de Policía
        SetPedComponentVariation(ped, 10, 243, 5, 0)

        -- Sin chaleco
        SetPedComponentVariation(ped, 9, 0, 0, 0)

    else

        -- Camisa / Top
        SetPedComponentVariation(ped, 11, 607, 1, 0)

        -- Camiseta / Interior
        SetPedComponentVariation(ped, 8, 257, 0, 0)

        -- Bolsas / Placa Jefe
        SetPedComponentVariation(ped, 5, 114, 8, 0)

        -- Accesorio / cinturón
        SetPedComponentVariation(ped, 7, 206, 0, 0)

        -- Pantalón
        SetPedComponentVariation(ped, 4, 173, 0, 0)

        -- Brazos manga larga
        SetPedComponentVariation(ped, 3, 1, 0, 0)

        -- Zapatos
        SetPedComponentVariation(ped, 6, 25, 0, 0)

        -- Insignias Jefe
        SetPedComponentVariation(ped, 10, 210, 5, 0)

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
    args = {
        "PD5M",
        "Uso: /uniforme novato | /uniforme p2 | /uniforme p3 | /uniforme senior | /uniforme sargento1 | /uniforme sargento2 | /uniforme teniente | /uniforme capitan | /uniforme jefe"
    }
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
