local isOpen = false
local activeTestRole = nil

local function sendNui(action, data)
    SendNUIMessage({ action = action, data = data or {} })
end

local function sendUiConfig()
    sendNui('setConfig', {
        defaultTestType = Config.Testing.DefaultType,
        errorDisplayDuration = Config.Testing.ErrorDisplayDuration,
        legalLimit = Config.Evidential.LegalLimit,
        maxBacInput = Config.Evidential.MaxInput,
        decimalPlaces = Config.Evidential.DecimalPlaces,
        unitLabel = Config.Evidential.UnitLabel,
    })
end

local function getEvidentialUiConfig()
    return {
        legalLimit = Config.Evidential.LegalLimit,
        unitLabel = Config.Evidential.UnitLabel,
        maxBacInput = Config.Evidential.MaxInput,
        decimalPlaces = Config.Evidential.DecimalPlaces,
    }
end

local function setBreathalyzerOpen(open)
    isOpen = open
    SetNuiFocus(open, open)
    sendNui('setVisible', { visible = open })
end

local function getClosestPlayer(maxDistance)
    local coords = GetEntityCoords(PlayerPedId())
    local closestPlayer = nil
    local closestDistance = maxDistance

    for _, playerId in ipairs(GetActivePlayers()) do
        if playerId ~= PlayerId() then
            local targetPed = GetPlayerPed(playerId)
            if targetPed and targetPed ~= 0 and DoesEntityExist(targetPed) then
                local distance = #(coords - GetEntityCoords(targetPed))
                if distance < closestDistance then
                    closestDistance = distance
                    closestPlayer = playerId
                end
            end
        end
    end

    if closestPlayer then
        return GetPlayerServerId(closestPlayer)
    end
end

local function notifyDenied(message)
    TriggerEvent('chat:addMessage', {
        color = { 220, 60, 60 },
        multiline = false,
        args = { 'Breathalyzer', message or Config.Permissions.DeniedMessage },
    })
end

local function requestOpenBreathalyzer()
    if Config.Permissions.Mode == 'open' then
        setBreathalyzerOpen(true)
        return
    end

    TriggerServerEvent(ServerEvent('requestOpen'))
end

local function toggleBreathalyzer()
    if isOpen then
        setBreathalyzerOpen(false)
        return
    end

    requestOpenBreathalyzer()
end

local function registerCommands()
    if not Config.Commands.Enabled then
        return
    end

    local description = Config.Commands.Description
    local primary = Config.Commands.Primary
    local secondary = Config.Commands.Secondary

    RegisterCommand(primary, toggleBreathalyzer, false)
    RegisterCommand(secondary, toggleBreathalyzer, false)

    local function addChatSuggestions()
        TriggerEvent('chat:addSuggestion', '/' .. primary, description)
        TriggerEvent('chat:addSuggestion', '/' .. secondary, description)
    end

    CreateThread(function()
        Wait(500)
        addChatSuggestions()
    end)

    AddEventHandler('onClientResourceStart', function(resourceName)
        if resourceName == 'chat' then
            addChatSuggestions()
        end
    end)
end

local function registerKeybind()
    if not Config.Keybind.Enabled then
        return
    end

    RegisterCommand(Config.Keybind.Command, toggleBreathalyzer, false)
    RegisterKeyMapping(
        Config.Keybind.Command,
        Config.Keybind.Description,
        'keyboard',
        Config.Keybind.DefaultKey or ''
    )
end

registerCommands()
registerKeybind()

RegisterNUICallback('close', function(_, cb)
    if activeTestRole == 'tester' then
        TriggerServerEvent(ServerEvent('cancelTest'))
        activeTestRole = nil
    end

    setBreathalyzerOpen(false)
    cb('ok')
end)

RegisterNUICallback('startTest', function(data, cb)
    if activeTestRole == 'tester' then
        cb({ ok = false, error = 'busy' })
        return
    end

    local targetServerId = getClosestPlayer(Config.Testing.MaxDistance)
    if not targetServerId then
        cb({ ok = false, error = 'no_player' })
        return
    end

    TriggerServerEvent(
        ServerEvent('startTest'),
        targetServerId,
        data and data.testType or Config.Testing.DefaultType
    )

    cb({ ok = true })
end)

RegisterNUICallback('confirmTest', function(_, cb)
    if activeTestRole == 'tester' then
        TriggerServerEvent(ServerEvent('endTest'))
        activeTestRole = nil
    end

    cb('ok')
end)

RegisterNUICallback('playSound', function(data, cb)
    if Config.Audio.Enabled and data and data.sound then
        TriggerServerEvent(ServerEvent('playSound'), data.sound, data.stop or false)
    end

    cb('ok')
end)

RegisterNUICallback('submitTesteeResult', function(data, cb)
    SetNuiFocus(false, false)
    TriggerServerEvent(ServerEvent('submitResult'), data)
    cb('ok')
end)

RegisterNetEvent(ClientEvent('testStarted'), function(data)
    activeTestRole = data.role
    sendNui(data.role == 'tester' and 'testerAwaitingSubject' or 'testeeStart', {
        testType = data.testType,
    })
end)

RegisterNetEvent(ClientEvent('analyzeWait'), function(data)
    sendNui('analyzeWait', {
        testType = data.testType,
        role = activeTestRole,
    })
end)

RegisterNetEvent(ClientEvent('promptInput'), function(data)
    SetNuiFocus(true, true)
    sendNui('testeePrompt', {
        testType = data.testType,
        evidential = getEvidentialUiConfig(),
    })
end)

RegisterNetEvent(ClientEvent('showResult'), function(data)
    if activeTestRole == 'tester' then
        sendNui('testerResult', data)
        return
    end

    SetNuiFocus(false, false)
    sendNui('testeeResult', data)
end)

RegisterNetEvent(ClientEvent('openNpcTest'), function(data)
    if activeTestRole == 'tester' then
        sendNui('testerError', { error = 'busy' })
        return
    end

    local testType = data and data.testType or Config.Testing.DefaultType
    local value = tonumber(data and data.value) or 0.0
    local displayValue = data and data.displayValue

    if testType ~= 'passive' and testType ~= 'evidential' then
        testType = Config.Testing.DefaultType
    end

    if testType == 'evidential' and not displayValue then
        displayValue = string.format('%.' .. Config.Evidential.DecimalPlaces .. 'f', value)
    end

    local result = data and data.result
    if result ~= 'pass' and result ~= 'fail' then
        result = value <= Config.Evidential.LegalLimit and 'pass' or 'fail'
    end

    activeTestRole = 'tester'
    setBreathalyzerOpen(true)
    sendUiConfig()
    sendNui('testerAwaitingSubject', { testType = testType })

    CreateThread(function()
        Wait(650)

        if activeTestRole ~= 'tester' then
            return
        end

        if Config.Audio.Enabled then
            TriggerServerEvent(ServerEvent('playSound'), 'testing', false)
        end

        sendNui('analyzeWait', {
            testType = testType,
            role = 'tester',
        })

        Wait(Config.Testing.Duration)

        if activeTestRole ~= 'tester' then
            return
        end

        if Config.Audio.Enabled then
            TriggerServerEvent(ServerEvent('playSound'), 'testing', true)
            TriggerServerEvent(ServerEvent('playSound'), 'beep', false)
        end

        sendNui('testerResult', {
            result = result,
            displayValue = displayValue or (result == 'pass' and 'Pass' or 'Fail'),
            testType = testType,
        })
    end)
end)

RegisterNetEvent(ClientEvent('testEnded'), function()
    activeTestRole = nil
    SetNuiFocus(isOpen, isOpen)
    sendNui('testEnded')
end)

RegisterNetEvent(ClientEvent('playSound'), function(data)
    if Config.Audio.Enabled then
        sendNui('playProximitySound', data)
    end
end)

RegisterNetEvent(ClientEvent('testError'), function(errorCode)
    sendNui('testerError', { error = errorCode })
end)

RegisterNetEvent(ClientEvent('openAllowed'), function()
    setBreathalyzerOpen(true)
end)

RegisterNetEvent(ClientEvent('permissionDenied'), function(message)
    notifyDenied(message)
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        sendUiConfig()
    end
end)
