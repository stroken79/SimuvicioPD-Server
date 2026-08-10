local o = false
local m = 1
local p = 6
local d = 0
local t = 0
local section = 1

local modes = {
    {"LSPD_EUP", "mp_m_lspd"},
    {"EmergencyEUP", "mp_m_emergency"},
    {"ROPA BASE / GLOBAL", false}
}

local parts = {
    {"Máscara", 1},
    {"Brazos / Torso", 3},
    {"Pantalón", 4},
    {"Bolsas", 5},
    {"Zapatos", 6},
    {"Accesorios", 7},
    {"Camiseta / Interior", 8},
    {"Chaleco / Armor", 9},
    {"Insignias / Decals", 10},
    {"Chaqueta / Top", 11}
}

local props = {
    {"Gorras / Cascos", 0},
    {"Gafas", 1},
    {"Orejas", 2},
    {"Relojes", 6},
    {"Pulseras", 7}
}

local function ped()
    return PlayerPedId()
end

local function getComponentDrawableCount()
    local component = parts[p][2]

    if modes[m][2] then
        return GetNumberOfPedCollectionDrawableVariations(
            ped(),
            component,
            modes[m][2]
        )
    end

    return GetNumberOfPedDrawableVariations(ped(), component)
end

local function getComponentTextureCount()
    local count = getComponentDrawableCount()

    if count <= 0 or d >= count then
        return 0
    end

    local component = parts[p][2]

    if modes[m][2] then
        return GetNumberOfPedCollectionTextureVariations(
            ped(),
            component,
            modes[m][2],
            d
        )
    end

    return GetNumberOfPedTextureVariations(
        ped(),
        component,
        d
    )
end

local function applyComponent()
    local count = getComponentDrawableCount()

    if count <= 0 then
        return
    end

    if d < 0 then
        d = count - 1
    elseif d >= count then
        d = 0
    end

    local textures = getComponentTextureCount()

    if textures > 0 then
        if t < 0 then
            t = textures - 1
        elseif t >= textures then
            t = 0
        end
    else
        t = 0
    end

    if modes[m][2] then
        SetPedCollectionComponentVariation(
            ped(),
            parts[p][2],
            modes[m][2],
            d,
            t,
            0
        )
    else
        SetPedComponentVariation(
            ped(),
            parts[p][2],
            d,
            t,
            0
        )
    end
end

local function getPropDrawableCount()
    return GetNumberOfPedPropDrawableVariations(
        ped(),
        props[p][2]
    )
end

local function getPropTextureCount()
    local count = getPropDrawableCount()

    if count <= 0 or d >= count then
        return 0
    end

    return GetNumberOfPedPropTextureVariations(
        ped(),
        props[p][2],
        d
    )
end

local function applyProp()
    local prop = props[p][2]
    local count = getPropDrawableCount()

    if count <= 0 then
        ClearPedProp(ped(), prop)
        return
    end

    if d < 0 then
        d = count - 1
    elseif d >= count then
        d = 0
    end

    local textures = getPropTextureCount()

    if textures > 0 then
        if t < 0 then
            t = textures - 1
        elseif t >= textures then
            t = 0
        end
    else
        t = 0
    end

    SetPedPropIndex(
        ped(),
        prop,
        d,
        t,
        true
    )
end

local function reset()
    d = 0
    t = 0
end

local function drawText(x, y, scale, text)
    SetTextFont(0)
    SetTextScale(scale, scale)
    SetTextColour(255, 255, 255, 255)
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end

local function printCurrent()
    if section == 1 then
        print(
            ("[PD5M V4] COMPONENT | origen=%s | pieza=%s | component=%d | drawable=%d | texture=%d | collection=%s")
            :format(
                modes[m][1],
                parts[p][1],
                parts[p][2],
                d,
                t,
                modes[m][2] or "NONE"
            )
        )
    else
        print(
            ("[PD5M V4] PROP | origen=%s | tipo=%s | prop=%d | drawable=%d | texture=%d")
            :format(
                modes[m][1],
                props[p][1],
                props[p][2],
                d,
                t
            )
        )
    end
end

RegisterCommand("ropav4", function()
    o = not o
    reset()
end, false)

CreateThread(function()
    while true do
        if not o then
            Wait(200)
        else
            Wait(0)

            DrawRect(0.21, 0.23, 0.43, 0.42, 0, 0, 0, 195)

            drawText(0.025, 0.035, 0.48, "PD5M - Explorador V4")

            if section == 1 then
                drawText(0.025, 0.075, 0.35, "SECCION: COMPONENTES")
                drawText(0.025, 0.105, 0.35, "Origen: " .. modes[m][1])
                drawText(0.025, 0.135, 0.35, ("Pieza: %s [ID %d]"):format(parts[p][1], parts[p][2]))
                drawText(0.025, 0.165, 0.35, ("Drawable: %d / %d"):format(d, math.max(0, getComponentDrawableCount() - 1)))
                drawText(0.025, 0.195, 0.35, ("Texture: %d / %d"):format(t, math.max(0, getComponentTextureCount() - 1)))
            else
                drawText(0.025, 0.075, 0.35, "SECCION: PROPS")
                drawText(0.025, 0.105, 0.35, "Origen: " .. modes[m][1])
                drawText(0.025, 0.135, 0.35, ("Prop: %s [ID %d]"):format(props[p][1], props[p][2]))
                drawText(0.025, 0.165, 0.35, ("Drawable: %d / %d"):format(d, math.max(0, getPropDrawableCount() - 1)))
                drawText(0.025, 0.195, 0.35, ("Texture: %d / %d"):format(t, math.max(0, getPropTextureCount() - 1)))
            end

            drawText(0.025, 0.235, 0.30, "A/D origen | ARR/ABAJO pieza")
            drawText(0.025, 0.265, 0.30, "IZQ/DER drawable | Q/E textura")
            drawText(0.025, 0.295, 0.30, "TAB cambia COMPONENTES/PROPS")
            drawText(0.025, 0.325, 0.30, "ENTER imprime datos en F8 | BACKSPACE cierra")
            drawText(0.025, 0.355, 0.30, "DELETE quita el prop actual")

            if IsControlJustPressed(0, 34) then
                m = m - 1
                if m < 1 then
                    m = #modes
                end
                reset()

            elseif IsControlJustPressed(0, 35) then
                m = m + 1
                if m > #modes then
                    m = 1
                end
                reset()

            elseif IsControlJustPressed(0, 37) then
                section = section == 1 and 2 or 1
                p = section == 1 and 6 or 1
                reset()

            elseif IsControlJustPressed(0, 172) then
                p = p - 1

                if section == 1 then
                    if p < 1 then
                        p = #parts
                    end
                else
                    if p < 1 then
                        p = #props
                    end
                end

                reset()

            elseif IsControlJustPressed(0, 173) then
                p = p + 1

                if section == 1 then
                    if p > #parts then
                        p = 1
                    end
                else
                    if p > #props then
                        p = 1
                    end
                end

                reset()

            elseif IsControlJustPressed(0, 174) then
                d = d - 1

                if section == 1 then
                    applyComponent()
                else
                    applyProp()
                end

            elseif IsControlJustPressed(0, 175) then
                d = d + 1

                if section == 1 then
                    applyComponent()
                else
                    applyProp()
                end

            elseif IsControlJustPressed(0, 44) then
                t = t - 1

                if section == 1 then
                    applyComponent()
                else
                    applyProp()
                end

            elseif IsControlJustPressed(0, 38) then
                t = t + 1

                if section == 1 then
                    applyComponent()
                else
                    applyProp()
                end

            elseif IsControlJustPressed(0, 191) then
                printCurrent()

            elseif IsControlJustPressed(0, 178) and section == 2 then
                ClearPedProp(ped(), props[p][2])

            elseif IsControlJustPressed(0, 177) then
                o = false
            end
        end
    end
end)
