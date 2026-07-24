local RESOURCE_NAME = GetCurrentResourceName()
local CURRENT_VERSION = GetResourceMetadata(RESOURCE_NAME, 'version', 0) or '0.0.0'
local INNER_WIDTH = 85
local BORDER_WIDTH = INNER_WIDTH + 2

local ASCII_ART = {
    '███████╗██╗    ██╗██╗███████╗████████╗██████╗ ██╗   ██╗██╗',
    '██╔════╝██║    ██║██║██╔════╝╚══██╔══╝██╔══██╗██║   ██║██║',
    '███████╗██║ █╗ ██║██║█████╗     ██║   ██║  ██║██║   ██║██║',
    '╚════██║██║███╗██║██║██╔══╝     ██║   ██║  ██║██║   ██║██║',
    '███████║╚███╔███╔╝██║██║        ██║   ██████╔╝╚██████╔╝██║',
    '╚══════╝ ╚══╝╚══╝ ╚═╝╚═╝        ╚═╝   ╚═════╝  ╚═════╝ ╚═╝',
}

local function logPrefix()
    return ('^2[%s]^0'):format(RESOURCE_NAME)
end

local function logLine(text)
    print(text)
end

local function textLength(text)
    text = text:gsub('%^%d', '')

    if utf8 and utf8.len then
        return utf8.len(text)
    end

    return #text
end

local function boxBorder()
    return ('^4%s^0'):format(string.rep('=', BORDER_WIDTH))
end

local function boxRow(text, color)
    local length = textLength(text)
    local padding = math.max(0, INNER_WIDTH - length)
    local leftPad = math.floor(padding / 2)
    local centered = string.rep(' ', leftPad) .. text .. string.rep(' ', padding - leftPad)

    return ('^4|%s%s%s|^0'):format(color or '^7', centered, '^4')
end

local function parseVersion(version)
    version = tostring(version):gsub('^v', '')
    local parts = {}

    for part in version:gmatch('%d+') do
        parts[#parts + 1] = tonumber(part)
    end

    return parts
end

local function isRemoteNewer(current, remote)
    local currentParts = parseVersion(current)
    local remoteParts = parseVersion(remote)
    local length = math.max(#currentParts, #remoteParts)

    for index = 1, length do
        local currentPart = currentParts[index] or 0
        local remotePart = remoteParts[index] or 0

        if remotePart > currentPart then
            return true
        end

        if remotePart < currentPart then
            return false
        end
    end

    return false
end

local function isServerStillStarting()
    for index = 0, GetNumResources() - 1 do
        if GetResourceState(GetResourceByFindIndex(index)) == 'starting' then
            return true
        end
    end

    return false
end

local function waitForServerReady()
    while isServerStillStarting() do
        Wait(250)
    end

    Wait(1000)
end

local function printStartupBanner(versionLines)
    logLine('')
    logLine(boxBorder())
    logLine(boxRow(''))

    for _, line in ipairs(ASCII_ART) do
        logLine(boxRow(line, '^2'))
    end

    logLine(boxRow(''))
    logLine(boxRow('Swift Studios - Alcotest 7510 Breathalyzer'))
    logLine(boxRow(''))
    logLine(boxBorder())
    logLine(('%s ^7Resource ^2successfully started^0'):format(logPrefix()))
    logLine(('%s ^7Installed version:^0 ^3v%s^0'):format(logPrefix(), CURRENT_VERSION))
    logLine(('%s ^7Permission mode:^0 ^5%s^0'):format(logPrefix(), GetPermissionModeLabel()))

    for _, line in ipairs(versionLines) do
        logLine(line)
    end

    logLine('')
end

local function fetchVersionLines(callback)
    local repository = Config.UpdateChecker.Repository

    if not repository or repository == '' then
        callback({ ('%s ^7No GitHub repository configured.^0'):format(logPrefix()) })
        return
    end

    PerformHttpRequest(
        ('https://api.github.com/repos/%s/releases/latest'):format(repository),
        function(statusCode, body)
            if statusCode ~= 200 or not body then
                callback({
                    ('%s ^7Unable to check GitHub ^0(^1HTTP %s^0^7).^0'):format(logPrefix(), tostring(statusCode)),
                })
                return
            end

            local ok, response = pcall(json.decode, body)
            if not ok or not response or not response.tag_name then
                callback({ ('%s ^7GitHub response could not be parsed.^0'):format(logPrefix()) })
                return
            end

            local latestVersion = response.tag_name:gsub('^v', '')
            local releaseUrl = response.html_url or ('https://github.com/%s/releases/latest'):format(repository)

            if isRemoteNewer(CURRENT_VERSION, latestVersion) then
                callback({
                    ('%s ^1Update available!^0 ^7Installed:^0 ^3v%s^0 ^7| Latest:^0 ^2v%s^0'):format(
                        logPrefix(),
                        CURRENT_VERSION,
                        latestVersion
                    ),
                    ('%s ^7Download:^0 ^4%s^0'):format(logPrefix(), releaseUrl),
                })
                return
            end

            callback({
                ('%s ^7You are running the latest release ^0(^3v%s^0^7).^0'):format(logPrefix(), CURRENT_VERSION),
            })
        end,
        'GET',
        '',
        {
            ['User-Agent'] = RESOURCE_NAME,
            ['Accept'] = 'application/vnd.github+json',
        }
    )
end

local STARTUP_SHOWN_KEY = 'sstudios_breathalyzer_startup_shown'

if Config.UpdateChecker.Enabled and not _G[STARTUP_SHOWN_KEY] then
    AddEventHandler('onResourceStart', function(resourceName)
        if resourceName ~= RESOURCE_NAME or _G[STARTUP_SHOWN_KEY] then
            return
        end

        _G[STARTUP_SHOWN_KEY] = true

        CreateThread(function()
            waitForServerReady()
            fetchVersionLines(printStartupBanner)
        end)
    end)
end
