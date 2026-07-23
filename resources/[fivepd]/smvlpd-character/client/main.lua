local activeCharacter
local creatorOpen = false

local function setPlayerHidden(hidden)
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, hidden)
    SetEntityVisible(ped, not hidden, false)
    SetEntityInvincible(ped, hidden)
end

local function openUi(characters, mode)
    creatorOpen = mode == 'create'
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', mode = mode, characters = characters or {}, maxCharacters = Config.MaxCharacters })
end

local function openSelection()
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()

    setPlayerHidden(true)
    TriggerServerEvent('smvlpd-character:server:requestCharacters')
end

RegisterNetEvent('smvlpd-character:client:showCharacters', function(characters)
    openUi(characters, 'select')
end)

RegisterNetEvent('smvlpd-character:client:characterLoaded', function(character)
    activeCharacter = character
    local appearance = character.appearance
    if type(appearance) == 'string' then appearance = json.decode(appearance) end
    ApplyAppearance(appearance)

    local position = character.last_position
    if type(position) == 'string' then position = json.decode(position) end
    position = position or { x = Config.DefaultSpawn.x, y = Config.DefaultSpawn.y, z = Config.DefaultSpawn.z, w = Config.DefaultSpawn.w }

    SetEntityCoordsNoOffset(PlayerPedId(), position.x, position.y, position.z, false, false, false)
    SetEntityHeading(PlayerPedId(), position.w or Config.DefaultSpawn.w)
    DestroyCreatorCamera()
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
    creatorOpen = false
    setPlayerHidden(false)
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    DoScreenFadeIn(500)
    LocalPlayer.state:set('smvlpdCharacterReady', true, false)
    TriggerEvent('smvlpd-character:client:spawnReady')
end)
RegisterNetEvent('smvlpd-character:client:reloadAppearance', function()

    if not activeCharacter then
        return
    end

    local appearance = activeCharacter.appearance

    if type(appearance) == "string" then
        appearance = json.decode(appearance)
    end

    ApplyAppearance(appearance)

end)
RegisterNUICallback('create', function(data, cb)
    local firstName = tostring(data.firstName or ''):gsub('[^%aÀ-ÿ %-]', '')
    local lastName = tostring(data.lastName or ''):gsub('[^%aÀ-ÿ %-]', '')
    local gender = data.gender == 'female' and 'female' or 'male'
    if #firstName < 2 or #lastName < 2 then
        cb({ ok = false, error = 'Introduce nombre y apellido (mínimo 2 caracteres).' })
        return
    end
    TriggerServerEvent('smvlpd-character:server:createCharacter', firstName, lastName, gender, CaptureAppearance())
    cb({ ok = true })
end)

RegisterNUICallback('select', function(data, cb)
    TriggerServerEvent('smvlpd-character:server:selectCharacter', tonumber(data.id))
    cb({ ok = true })
end)

RegisterNUICallback('startCreate', function(_, cb)
    creatorOpen = true

    SetCreatorGender('male')

SetEntityCoordsNoOffset(PlayerPedId(), 441.18, -981.95, 30.69, false, false, false)
SetEntityHeading(PlayerPedId(), 180.0)

SetEntityVisible(PlayerPedId(), true, false)
setPlayerHidden(false)

DoScreenFadeIn(500)

CreateCreatorCamera()

    SendNUIMessage({ action = 'creator' })

    cb({ ok = true })
end)

RegisterNUICallback('gender', function(data, cb)

    local gender = data.gender == "female" and "female" or "male"

    RegisterNUICallback('gender', function(data, cb)

    SetCreatorGender(data.gender == 'female' and 'female' or 'male')

    cb({ ok = true })

end)

    cb({ ok = true })

end)

RegisterNUICallback('component', function(data, cb)
    PreviewComponent(data.component, data.direction)
    cb({ ok = true })
end)

RegisterNUICallback('feature', function(data, cb)
    PreviewFaceFeature(data.feature, data.value)
    cb({ ok = true })
end)
RegisterNUICallback("appearance", function(data, cb)

    if data.type == "hair" then

        PreviewHair(data.value)

    elseif data.type == "hairColor" then

        PreviewHairColor(data.value)

    elseif data.type == "beard" then

        PreviewBeard(data.value)

    elseif data.type == "glasses" then

        PreviewGlasses(data.value)

    elseif data.type == "face" then

    PreviewFace(data.value)

    end

    cb({ ok = true })

end)

RegisterNetEvent('smvlpd-character:client:notify', function(message)
    SendNUIMessage({ action = 'error', message = message })
end)

RegisterCommand('characters', function()
    if not creatorOpen then openSelection() end
end, false)

CreateThread(function()
    while not NetworkIsSessionStarted() do Wait(100) end
    DoScreenFadeOut(0)
    openSelection()
end)

CreateThread(function()
    while true do
        Wait(Config.SaveInterval)
        if activeCharacter and not creatorOpen and not IsAppearanceSavingPaused() then
            local coords = GetEntityCoords(PlayerPedId())
            TriggerServerEvent('smvlpd-character:server:saveCharacter', activeCharacter.id, CaptureAppearance(), {
                x = coords.x, y = coords.y, z = coords.z, w = GetEntityHeading(PlayerPedId())
            })
        end
    end
end)
