local sessions = {}
local sessionsByTarget = {}

local function sendClient(playerId, event, data)
    TriggerClientEvent(ClientEvent(event), playerId, data)
end

local function denyPermission(source)
    sendClient(source, 'permissionDenied', Config.Permissions.DeniedMessage)
end

local function requirePermission(source)
    if CanUseBreathalyzer(source) then
        return true
    end

    denyPermission(source)
    return false
end

local function clearSession(testerId)
    local session = sessions[testerId]
    if not session then
        return
    end

    sessionsByTarget[session.target] = nil
    sessions[testerId] = nil
end

local function getListenerVolume(distance, maxDistance)
    if distance > maxDistance then
        return nil
    end

    return 1.0 - (distance / maxDistance)
end

local function broadcastSoundFromPlayer(playerId, sound, stop)
    if not Config.Audio.Enabled then
        return
    end

    local ped = GetPlayerPed(playerId)
    if not ped or ped == 0 then
        return
    end

    local coords = GetEntityCoords(ped)

    for _, listenerId in ipairs(GetPlayers()) do
        local listener = tonumber(listenerId)
        local listenerPed = GetPlayerPed(listener)

        if listenerPed and listenerPed ~= 0 then
            local distance = #(coords - GetEntityCoords(listenerPed))
            local volume = getListenerVolume(distance, Config.Audio.HearDistance)

            if volume and (stop or volume > 0.02) then
                sendClient(listener, 'playSound', {
                    sound = sound,
                    volume = volume,
                    stop = stop or false,
                })
            end
        end
    end
end

local function endSession(testerId)
    local session = sessions[testerId]
    if not session then
        return
    end

    local targetId = session.target
    clearSession(testerId)
    broadcastSoundFromPlayer(testerId, 'testing', true)

    sendClient(testerId, 'testEnded')
    sendClient(targetId, 'testEnded')
end

local function showSessionResult(testerId, session)
    broadcastSoundFromPlayer(testerId, 'testing', true)
    broadcastSoundFromPlayer(testerId, 'beep', false)

    local payload = {
        result = session.result,
        displayValue = session.displayValue,
        testType = session.testType,
    }

    sendClient(testerId, 'showResult', payload)
    sendClient(session.target, 'showResult', payload)
end

local function resolveResult(session, data)
    if session.testType == 'passive' then
        if not data or (data.outcome ~= 'pass' and data.outcome ~= 'fail') then
            return nil
        end

        return data.outcome, data.outcome == 'pass' and 'Pass' or 'Fail'
    end

    local value = tonumber(data and data.value)
    if value == nil or value < 0 or value > Config.Evidential.MaxInput then
        return nil
    end

    local result = value <= Config.Evidential.LegalLimit and 'pass' or 'fail'
    local displayValue = string.format('%.' .. Config.Evidential.DecimalPlaces .. 'f', value)

    return result, displayValue
end

local function sendTestError(testerId, errorCode)
    sendClient(testerId, 'testError', errorCode)
end

RegisterNetEvent(ServerEvent('requestOpen'), function()
    local src = source
    if requirePermission(src) then
        sendClient(src, 'openAllowed')
    end
end)

RegisterNetEvent(ServerEvent('startTest'), function(targetId, testType)
    local testerId = source

    if not requirePermission(testerId) then
        return
    end

    if sessions[testerId] or sessionsByTarget[testerId] then
        sendTestError(testerId, 'busy')
        return
    end

    if testType ~= 'passive' and testType ~= 'evidential' then
        return
    end

    if not targetId or targetId == testerId or GetPlayerPing(targetId) == 0 then
        sendTestError(testerId, 'no_player')
        return
    end

    if sessionsByTarget[targetId] then
        sendTestError(testerId, 'busy')
        return
    end

    sessions[testerId] = {
        target = targetId,
        testType = testType,
        phase = 'input',
    }
    sessionsByTarget[targetId] = testerId

    local started = { testType = testType }
    sendClient(testerId, 'testStarted', { role = 'tester', testType = testType })
    sendClient(targetId, 'testStarted', { role = 'testee', testType = testType })
    sendClient(targetId, 'promptInput', started)
end)

RegisterNetEvent(ServerEvent('submitResult'), function(data)
    local testeeId = source
    local testerId = sessionsByTarget[testeeId]
    local session = testerId and sessions[testerId] or nil

    if not session or session.target ~= testeeId or session.phase ~= 'input' then
        return
    end

    local result, displayValue = resolveResult(session, data)
    if not result then
        return
    end

    session.result = result
    session.displayValue = displayValue
    session.phase = 'analyzing'

    broadcastSoundFromPlayer(testerId, 'testing', false)

    local waitData = { testType = session.testType }
    sendClient(testerId, 'analyzeWait', waitData)
    sendClient(testeeId, 'analyzeWait', waitData)

    SetTimeout(Config.Testing.Duration, function()
        local active = sessions[testerId]
        if not active or active.phase ~= 'analyzing' then
            return
        end

        active.phase = 'result'
        showSessionResult(testerId, active)
    end)
end)

RegisterNetEvent(ServerEvent('endTest'), function()
    endSession(source)
end)

RegisterNetEvent(ServerEvent('cancelTest'), function()
    endSession(source)
end)

RegisterNetEvent(ServerEvent('playSound'), function(sound, stop)
    if requirePermission(source) then
        broadcastSoundFromPlayer(source, sound, stop)
    end
end)

AddEventHandler('playerDropped', function()
    local src = source

    if sessions[src] then
        endSession(src)
        return
    end

    local testerId = sessionsByTarget[src]
    if testerId then
        endSession(testerId)
    end
end)
