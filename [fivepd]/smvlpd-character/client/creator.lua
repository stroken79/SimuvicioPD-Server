local CreatorState = {
    components = {
        [3] = 0,
        [4] = 0,
        [6] = 0,
        [8] = 0,
        [9] = 0,
        [11] = 0
    }
}
local function requestModel(model)
    local hash = joaat(model)
	local CreatorState = {
    components = {
        [3] = 0,
        [4] = 0,
        [6] = 0,
        [8] = 0,
        [9] = 0,
        [11] = 0
    }
}

    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(0)
    end

    SetPlayerModel(PlayerId(), hash)
    SetModelAsNoLongerNeeded(hash)

    while GetEntityModel(PlayerPedId()) ~= hash do
        Wait(0)
    end

    local ped = PlayerPedId()

    SetPedDefaultComponentVariation(ped)
    ClearAllPedProps(ped)
	

    
end

function SetCreatorGender(gender)
    local model = Config.Models.male

    if gender == "female" then
        model = Config.Models.female
    end

    requestModel(model)

    local ped = PlayerPedId()

    SetEntityVisible(ped, true, false)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
	    SetPedDefaultComponentVariation(ped)

    SetPedComponentVariation(ped, 11, 0, 0, 0) -- Torso
    SetPedComponentVariation(ped, 8, 0, 0, 0)  -- Camiseta
    SetPedComponentVariation(ped, 4, 0, 0, 0)  -- Pantalón
    SetPedComponentVariation(ped, 6, 0, 0, 0)  -- Zapatos
    SetPedComponentVariation(ped, 3, 0, 0, 0)  -- Brazos

    
end

function CaptureAppearance()
    local ped = PlayerPedId()
    local components, props, features = {}, {}, {}

    for componentId = 0, 11 do
        components[#components + 1] = {
            id = componentId,
            drawable = GetPedDrawableVariation(ped, componentId),
            texture = GetPedTextureVariation(ped, componentId)
        }
    end

    for _, propId in ipairs({0,1,2,6,7}) do
        props[#props + 1] = {
            id = propId,
            drawable = GetPedPropIndex(ped, propId),
            texture = GetPedPropTextureIndex(ped, propId)
        }
    end

    for featureId = 0, 19 do
        features[#features + 1] = {
            id = featureId,
            value = GetPedFaceFeature(ped, featureId)
        }
    end
	local beardIndex = GetPedHeadOverlayValue(ped, 1)

    return {
    model = GetEntityModel(ped) == joaat(Config.Models.female) and Config.Models.female or Config.Models.male,
    components = components,
    props = props,
    faceFeatures = features,
    hairColor = GetPedHairColor(ped),
    hairHighlight = GetPedHairHighlightColor(ped),
    face = CurrentFace,
    beard = beardIndex
}
end

function ApplyAppearance(appearance)
    if not appearance or not appearance.model then
        return
    end

    requestModel(appearance.model)

    local ped = PlayerPedId()
	if appearance.face then
    CurrentFace = appearance.face

    SetPedHeadBlendData(
        ped,
        CurrentFace,
        CurrentFace,
        0,
        CurrentFace,
        CurrentFace,
        0,
        0.5,
        0.5,
        0.0,
        false
    )
end

if appearance.beard then
    SetPedHeadOverlay(ped, 1, appearance.beard, 1.0)

    SetPedHeadOverlayColor(
        ped,
        1,
        1,
        appearance.hairColor or 0,
        appearance.hairColor or 0
    )
end

    for _, component in ipairs(appearance.components or {}) do
        SetPedComponentVariation(
            ped,
            component.id,
            component.drawable,
            component.texture or 0,
            0
        )
    end

    ClearAllPedProps(ped)

    for _, prop in ipairs(appearance.props or {}) do
        if prop.drawable and prop.drawable >= 0 then
            SetPedPropIndex(
                ped,
                prop.id,
                prop.drawable,
                prop.texture or 0,
                true
            )
        end
    end

    for _, feature in ipairs(appearance.faceFeatures or {}) do
        SetPedFaceFeature(
            ped,
            feature.id,
            feature.value
        )
    end

    if type(appearance.hairColor) == 'number' then
        SetPedHairColor(
            ped,
            appearance.hairColor,
            appearance.hairHighlight or 0
        )
    end
end

-- API para los recursos de ropa: permite guardar y restaurar la apariencia
-- sin que el uniforme pase a ser el aspecto permanente del personaje.
local appearanceSavingPaused = false

exports('CaptureAppearance', function()
    return CaptureAppearance()
end)

exports('ApplyAppearance', function(appearance)
    ApplyAppearance(appearance)
end)

exports('SetAppearanceSavingPaused', function(paused)
    appearanceSavingPaused = paused == true
end)

function IsAppearanceSavingPaused()
    return appearanceSavingPaused
end

function PreviewComponent(componentId, direction)
    local ped = PlayerPedId()

    componentId = math.max(0, math.min(11, tonumber(componentId) or 0))

    local count = GetNumberOfPedDrawableVariations(ped, componentId)

    if count <= 0 then
        return
    end

    local current = CreatorState.components[componentId]

    if current == nil then
        current = GetPedDrawableVariation(ped, componentId)
    end

    local drawable = (current + (tonumber(direction) or 0)) % count

    CreatorState.components[componentId] = drawable

    SetPedComponentVariation(
        ped,
        componentId,
        drawable,
        0,
        0
    )

    SendNUIMessage({
        action = "preview",
        component = componentId,
        drawable = drawable
    })
end

function PreviewFaceFeature(featureId, value)
    featureId = math.max(0, math.min(19, tonumber(featureId) or 0))
    value = math.max(-1.0, math.min(1.0, tonumber(value) or 0.0))

    SetPedFaceFeature(
        PlayerPedId(),
        featureId,
        value
    )
end
function PreviewFace(face)

    CurrentFace = tonumber(face) or 0

    local ped = PlayerPedId()

    SetPedHeadBlendData(
        ped,
        CurrentFace,
        CurrentFace,
        0,
        CurrentFace,
        CurrentFace,
        0,
        0.5,
        0.5,
        0.0,
        false
    )

    print("^2Cara: "..CurrentFace.."^7")

end
function PreviewHair(drawable)

print("^2PreviewHair ejecutándose^7")

    local ped = PlayerPedId()

    local max = GetNumberOfPedDrawableVariations(ped, 2)

    if max <= 0 then return end

    drawable = drawable % max

    SetPedComponentVariation(
        ped,
        2,
        drawable,
        0,
        0
    )

end

function PreviewHairColor(color)

    local ped = PlayerPedId()

    color = math.max(0, math.min(63, tonumber(color) or 0))

    SetPedHairColor(
        ped,
        color,
        color
    )

end

function PreviewGlasses(drawable)
print("^2PreviewGlasses ejecutándose^7")

    local ped = PlayerPedId()

    if drawable < 0 then

        ClearPedProp(ped, 1)

    else

        local max = GetNumberOfPedPropDrawableVariations(ped, 1)

        if max <= 0 then return end

        drawable = drawable % max

        SetPedPropIndex(
            ped,
            1,
            drawable,
            0,
            true
        )

    end

end

function PreviewBeard(style)

    local ped = PlayerPedId()

    style = math.max(0, math.min(28, tonumber(style) or 0))

    SetPedHeadOverlay(ped, 1, style, 1.0)

    SetPedHeadOverlayColor(
        ped,
        1,
        1,
        GetPedHairColor(ped),
        GetPedHairColor(ped)
    )

end
