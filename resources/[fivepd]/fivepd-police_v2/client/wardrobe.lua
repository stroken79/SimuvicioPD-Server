local civilAppearance

local function notify(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, false)
end

local function characterResourceReady()
    return GetResourceState('smvlpd-character') == 'started'
end

function LoadUniform(uniform)
    print("^2[fivepd-police] PatrolUniform =", PatrolUniform)

    local model = GetHashKey(uniform.model)
    local ped = PlayerPedId()

    -- Cambiar el modelo reinicia cara, pelo y rasgos. El uniforme solo puede
    -- ponerse sobre un personaje del mismo modelo (masculino o femenino).
    if GetEntityModel(ped) ~= model then
        notify('Este uniforme no corresponde al modelo de tu personaje.')
        return
    end

    if not civilAppearance then
        if not characterResourceReady() then
            notify('No se puede guardar la ropa civil: falta smvlpd-character.')
            return
        end

        civilAppearance = exports['smvlpd-character']:CaptureAppearance()
        exports['smvlpd-character']:SetAppearanceSavingPaused(true)
    end

    -- El uniforme limpia los props para aplicar gorra y accesorios propios,
    -- pero las gafas personales deben mantenerse durante la patrulla.
    local glassesDrawable = GetPedPropIndex(ped, 1)
    local glassesTexture = GetPedPropTextureIndex(ped, 1)

    -- Componentes
    for _, comp in ipairs(uniform.components) do
        SetPedComponentVariation(
            ped,
            comp.component,
            comp.drawable,
            comp.texture,
            0
        )
    end

    -- Props (gorras, gafas...)
    ClearAllPedProps(ped)

    for _, prop in ipairs(uniform.props) do
        SetPedPropIndex(
            ped,
            prop.prop,
            prop.drawable,
            prop.texture,
            true
        )
    end

    if glassesDrawable and glassesDrawable >= 0 then
        SetPedPropIndex(ped, 1, glassesDrawable, glassesTexture or 0, true)
    end

end

function RestoreCivilianClothes()
    if not civilAppearance then
        notify('No tienes una apariencia civil guardada.')
        return
    end

    if not characterResourceReady() then
        notify('No se puede restaurar la ropa civil: falta smvlpd-character.')
        return
    end

    exports['smvlpd-character']:ApplyAppearance(civilAppearance)
    exports['smvlpd-character']:SetAppearanceSavingPaused(false)
    civilAppearance = nil
    notify('Has vuelto a estar de civil.')
end

function EquipPatrolUniform()

    print("PatrolUniform =", PatrolUniform)

    if PatrolUniform == nil then
        print("^1ERROR: PatrolUniform es NIL^7")
        return
    end

    LoadUniform(PatrolUniform)

end
