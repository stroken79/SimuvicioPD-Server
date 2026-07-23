local menuOpen = false
local componentIndex = 1
local drawable = 0
local texture = 0

local entries = {
    {name='Máscara', type='component', id=1},
    {name='Brazos / Torso', type='component', id=3},
    {name='Pantalón', type='component', id=4},
    {name='Bolsas / Paracaídas', type='component', id=5},
    {name='Zapatos', type='component', id=6},
    {name='Accesorios', type='component', id=7},
    {name='Camiseta / Interior', type='component', id=8},
    {name='Chaleco / Armor', type='component', id=9},
    {name='Insignias / Decals', type='component', id=10},
    {name='Chaqueta / Top', type='component', id=11},
    {name='Sombrero / Gorra', type='prop', id=0},
    {name='Gafas', type='prop', id=1},
    {name='Orejas', type='prop', id=2},
    {name='Reloj', type='prop', id=6},
    {name='Pulsera', type='prop', id=7},
}

local function entry()
    return entries[componentIndex]
end

local function limits()
    local ped = PlayerPedId()
    local e = entry()
    if e.type == 'component' then
        local dmax = math.max(0, GetNumberOfPedDrawableVariations(ped, e.id) - 1)
        local d = math.min(drawable, dmax)
        local tmax = math.max(0, GetNumberOfPedTextureVariations(ped, e.id, d) - 1)
        return dmax, tmax
    else
        local dmax = math.max(-1, GetNumberOfPedPropDrawableVariations(ped, e.id) - 1)
        if drawable < 0 then return dmax, 0 end
        local d = math.min(drawable, dmax)
        local tmax = math.max(0, GetNumberOfPedPropTextureVariations(ped, e.id, d) - 1)
        return dmax, tmax
    end
end

local function readCurrent()
    local ped = PlayerPedId()
    local e = entry()
    if e.type == 'component' then
        drawable = GetPedDrawableVariation(ped, e.id)
        texture = GetPedTextureVariation(ped, e.id)
    else
        drawable = GetPedPropIndex(ped, e.id)
        texture = drawable >= 0 and GetPedPropTextureIndex(ped, e.id) or 0
    end
end

local function apply()
    local ped = PlayerPedId()
    local e = entry()
    local dmax, tmax = limits()
    drawable = math.max(e.type == 'prop' and -1 or 0, math.min(drawable, dmax))
    texture = math.max(0, math.min(texture, tmax))
    if e.type == 'component' then
        SetPedComponentVariation(ped, e.id, drawable, texture, 0)
    else
        if drawable < 0 then
            ClearPedProp(ped, e.id)
        else
            SetPedPropIndex(ped, e.id, drawable, texture, true)
        end
    end
end

local function drawText(x, y, scale, text)
    SetTextFont(0)
    SetTextScale(scale, scale)
    SetTextColour(255,255,255,255)
    SetTextOutline()
    SetTextEntry('STRING')
    AddTextComponentString(text)
    DrawText(x,y)
end

local function help()
    local e = entry()
    local dmax, tmax = limits()
    DrawRect(0.19, 0.18, 0.35, 0.27, 0,0,0,190)
    drawText(0.025,0.065,0.48,'PD5M - Explorador de ropa')
    drawText(0.025,0.105,0.36,('Pieza: %s  [ID %d]'):format(e.name,e.id))
    drawText(0.025,0.135,0.36,('Drawable: %d / %d'):format(drawable,dmax))
    drawText(0.025,0.165,0.36,('Texture: %d / %d'):format(texture,tmax))
    drawText(0.025,0.205,0.31,'ARRIBA/ABAJO: cambiar pieza')
    drawText(0.025,0.230,0.31,'IZQ/DER: cambiar drawable')
    drawText(0.025,0.255,0.31,'Q / E: cambiar textura')
    drawText(0.025,0.280,0.31,'ENTER: imprimir IDs en F8')
    drawText(0.025,0.305,0.31,'BACKSPACE o /ropa: cerrar')
end

RegisterCommand('ropa', function()
    menuOpen = not menuOpen
    if menuOpen then readCurrent() end
end, false)

CreateThread(function()
    while true do
        if not menuOpen then
            Wait(250)
        else
            Wait(0)
            help()

            if IsControlJustPressed(0, 172) then
                componentIndex = componentIndex - 1
                if componentIndex < 1 then componentIndex = #entries end
                readCurrent()
            elseif IsControlJustPressed(0, 173) then
                componentIndex = componentIndex + 1
                if componentIndex > #entries then componentIndex = 1 end
                readCurrent()
            elseif IsControlJustPressed(0, 174) then
                drawable = drawable - 1
                texture = 0
                apply()
            elseif IsControlJustPressed(0, 175) then
                drawable = drawable + 1
                texture = 0
                apply()
            elseif IsControlJustPressed(0, 44) then -- Q
                texture = texture - 1
                apply()
            elseif IsControlJustPressed(0, 38) then -- E
                texture = texture + 1
                apply()
            elseif IsControlJustPressed(0, 191) then -- Enter
                local e = entry()
                print(('[PD5M CLOTHING] %s | type=%s id=%d drawable=%d texture=%d'):format(
                    e.name, e.type, e.id, drawable, texture))
            elseif IsControlJustPressed(0, 177) then
                menuOpen = false
            end
        end
    end
end)
