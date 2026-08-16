-- Client Functions

-- Framework globals (ESX, QBCore, QBox). Inventory scripts (ox_inventory, qb-inventory) are separate resources.
QBCore = nil
ESX = nil
-- QBox framework: same qb-core bridge object as QBCore (https://docs.qbox.re/faq). For Notify / HasGroup etc. use exports.qbx_core — https://docs.qbox.re/resources/qbx_core/exports/client
QBox = nil

local function tryInitESX()
    if GetResourceState("es_extended") ~= "started" then return end
    local ok, obj = pcall(function()
        return exports["es_extended"]:getSharedObject()
    end)
    if ok and obj then ESX = obj end
end

local function tryInitQBCore()
    if GetResourceState("qb-core") ~= "started" then return end
    local ok, obj = pcall(function()
        return exports["qb-core"]:GetCoreObject()
    end)
    if ok and obj then QBCore = obj end 
end

local function tryInitQBox()
    if GetResourceState("qbx_core") ~= "started" then return end
    local ok, obj = pcall(function()
        return exports["qb-core"]:GetCoreObject()
    end)
    if ok and obj then QBox = obj end
end

Citizen.CreateThread(function()
    Wait(0)
    tryInitESX()
    tryInitQBCore()
    tryInitQBox()
end)


-- ERS task-progress bridge for smvlpd-ranks.
-- The NUI task tracker reports a decrement in one of its objective counters.
RegisterNUICallback('ersTaskProgress', function(data, cb)
    data = type(data) == 'table' and data or {}

    local calloutId = data.calloutId
    local taskType = tostring(data.taskType or 'task')
    local amount = math.floor(tonumber(data.amount) or 0)

    if calloutId and amount > 0 then
        TriggerServerEvent(
            'ErsIntegration::OnCalloutTaskProgress',
            calloutId,
            taskType,
            amount
        )
    end

    cb({ ok = true })
end)

-- ============================================
-- FUNCTIONS FOR EXTERNAL USAGE (For developers only, no support will be provided for this by Nights Software)
-- ============================================

--- Handles when a callout is offered to the player.
-- @param calloutData table The data of the callout.
function OnIsOfferedCallout(calloutData)
    -- Add your code here. Keep in mind they are offered a callout. It is possible they will not accept the callout.
    -- local jsonReady = CloneWithoutFunctions(calloutData)
    TriggerServerEvent('ErsIntegration::OnIsOfferedCallout', calloutData)
end

--- Handles when a callout is accepted by the player.
-- @param calloutData table The data of the callout.
function OnAcceptedCalloutOffer(calloutData)
    -- Add your code here. Keep in mind they have accepted a callout. It is possible they will cancel before arrival (and spawn of entities).
    TriggerServerEvent('ErsIntegration::OnAcceptedCalloutOffer', calloutData)
end

--- Handles when the player arrives at a callout.
-- @param calloutData table The data of the callout.
function OnArrivedAtCallout(calloutData)
    -- Add your code here. This is triggered right before the entities are built for a callout. This code will execute first.
    TriggerServerEvent('ErsIntegration::OnArrivedAtCallout', calloutData)
end

--- Handles when a callout is ended (as the host). This does not mean the callout is completed.
-- @param calloutData table The data of the callout.
function OnEndedACallout(calloutData)
    -- Add your code here. This is triggered right before the entities are deleted or callout is cancelled serverside. This code will execute first.
    TriggerServerEvent('ErsIntegration::OnEndedACallout', calloutData)
end

--- Handles when a callout is completed successfully.
-- @param calloutData table The data of the callout.
function OnCalloutCompletedSuccesfully(calloutData)
    -- Add your code here. This is triggered right after the entire callout task list is completed.
    TriggerServerEvent('ErsIntegration::OnCalloutCompletedSuccesfully', calloutData)
end

--- Handles when a pullover is initiated.
-- @param pedData table The data of the ped.
-- @param vehicleData table The data of the vehicle.
function OnPullover(pedData, vehicleData)
    -- Add your custom pullover logic here or trigger (and build) a server event to handle it.
    TriggerServerEvent('ErsIntegration::OnPullover', pedData, vehicleData)
end

--- Handles when a pullover is ended.
-- @param pedData table The data of the ped.
-- @param vehicleData table The data of the vehicle.
function OnPulloverEnded(pedData, vehicleData)
    -- Add your custom pullover ended logic here or trigger (and build) a server event to handle it.
    TriggerServerEvent('ErsIntegration::OnPulloverEnded', pedData, vehicleData)
end

--- Handles when a pursuit is started.
-- @param pedData table The data of the ped.
function OnPursuitStarted(pedData)
    -- Add your custom pursuit started logic here or trigger (and build) a server event to handle it.
    TriggerServerEvent('ErsIntegration::OnPursuitStarted', pedData)
end

--- Handles when a pursuit is ended.
-- @param pedData table The data of the ped.
function OnPursuitEnded(pedData)
    -- Add your custom pursuit ended logic here or trigger (and build) a server event to handle it.
    TriggerServerEvent('ErsIntegration::OnPursuitEnded', pedData)
end

--- Handles when an AI person is delivered to hospital (built-in stretcher or ErsIntegration::DeliverPedToHospital).
-- Server-side integrators should use ErsIntegration::OnPersonDeliveredToHospital in s_functions.lua instead.
-- @param pedData table The data of the ped.
function OnPersonDeliveredToHospital(pedData)
    TriggerServerEvent('ErsIntegration::OnPersonDeliveredToHospital', pedData)
end

-- ============================================
-- GEAR SYSTEM
-- ============================================

--- Handles when a NPC gives gear to the player.
-- @param data table The data of the NPC.
function OnNPCGivesGear(data)
    local clothingData, weaponData, healthData = data.clothingData, data.weaponData, data.healthData

    -- Player ped model
    local isModelAMultiplayerModel = (clothingData.modelName == "mp_m_freemode_01" or clothingData.modelName == "mp_f_freemode_01")
    local pedEntityModelHash = GetEntityModel(PlayerPedId())
    if isModelAMultiplayerModel then
        if Config.GearData.ForceMPPedWhenPlayerIsNotAnMPPed then
            if pedEntityModelHash ~= GetHashKey(clothingData.modelName) then
                local newModel = GetHashKey(clothingData.modelName)
                RequestModel(newModel)
                
                local attempts = 0
                while not HasModelLoaded(newModel) and attempts < 10 do
                    Citizen.Wait(500)
                    attempts = attempts + 1
                end
                
                if HasModelLoaded(newModel) then
                    
                    SetPlayerModel(PlayerId(), newModel)
                    SetPedComponentVariation(PlayerPedId(), 0, 0, 0, 2)
                    
                    pedEntityModelHash = GetEntityModel(PlayerPedId())
                    
                    SetModelAsNoLongerNeeded(newModel)
                    Citizen.Wait(500)
                    
                    -- Confirm the model is set correctly
                    attempts = 0
                    while (pedEntityModelHash ~= GetHashKey(clothingData.modelName)) and attempts < 5 do
                        SetPlayerModel(PlayerId(), newModel)
                        Citizen.Wait(500)
                        pedEntityModelHash = GetEntityModel(PlayerPedId())
                        attempts = attempts + 1
                    end
                    
                    SetPedDefaultComponentVariation(PlayerPedId())
                    
                    if Config.Debug then
                        print("Set player model to: " .. newModel)
                    end
                else
                    print("ERROR: Could not load model, please try fetching gear again...")
                end
            end
        end
    else
        if Config.GearData.EnableSetClothing then
            local model = clothingData.modelName
            if IsModelInCdimage(model) and IsModelValid(model) then
                RequestModel(model)
                while not HasModelLoaded(model) do
                    Wait(0)
                end
                SetPlayerModel(PlayerId(), model)
                SetModelAsNoLongerNeeded(model)
            end
        end
    end

    -- Clothes
    if Config.GearData.EnableSetClothing then
        if isModelAMultiplayerModel then
            ERS_SetOutfit(PlayerPedId(), clothingData)
            if Config.Debug then
                print("Setting outfit...")
            end
        end
    end

    -- Weapons
    if Config.GearData.EnableGiveWeapons then
        TriggerServerEvent(Config.EventPrefix..":setWeaponsAmmoComponents", weaponData)
    end

    -- Health and armor
    if healthData.Enabled then
        local playerPed = PlayerPedId()
        -- Health
        if healthData.Health then
            local entityHealth = GetEntityHealth(playerPed)
            local newHealth = math.min(entityHealth + healthData.Health, 200)
            
            if newHealth ~= entityHealth then
                SetEntityHealth(playerPed, newHealth)
            end
        end

        -- Armor
        if healthData.Armor then
            local entityArmor = GetPedArmour(playerPed)
            local newArmor = math.min(entityArmor + healthData.Armor, 200)
            
            if newArmor ~= entityArmor then
                SetPedArmour(playerPed, newArmor)
            end
        end
    end
end

exports("OnNPCGivesGear", OnNPCGivesGear)

-- ============================================
-- FUNCTIONS
-- ============================================

function message(lineOne, lineTwo, lineThree, duration)
    BeginTextCommandDisplayHelp("THREESTRINGS")
    AddTextComponentSubstringPlayerName(lineOne)
    AddTextComponentSubstringPlayerName(lineTwo or "")
    AddTextComponentSubstringPlayerName(lineThree or "")
    EndTextCommandDisplayHelp(0, false, true, duration or 5000)
end

function notify(notificationText)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(notificationText)
    DrawNotification(true, true)
end

function Draw3DText(x,y,z,text,scl) 
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px,py,pz, x,y,z, 1)
    local scale = (1/dist)*scl
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov
    if onScreen then
        SetTextScale(0.0*scale, 1.1*scale)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        --SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString("~h~"..text)
        DrawText(_x,_y)
    end
end

function DrawTxt(text, x, y, scale, size)
	SetTextFont(0)
	SetTextProportional(1)
	SetTextScale(scale, size)
	SetTextDropshadow(1, 0, 0, 0, 255)
    SetTextColour(255, 255, 255, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x, y)
end

function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

function allToUpper(str)
    return (string.upper(str))
end

function LoadAnimDict(dict)
    RequestAnimDict(dict)
    -- 1.5s timeout with debug print if timeout is reached
    local startTime = GetGameTimer()
    while (not HasAnimDictLoaded(dict)) and (GetGameTimer() - startTime < 1500) do
        Citizen.Wait(1)
    end
    if not HasAnimDictLoaded(dict) then
        print(string.format("ERROR: Failed to load animation dictionary: %s in 1.5s", dict))
    else
        local timeTaken = GetGameTimer() - startTime
        print(string.format("INFO: Successfully loaded animation dictionary: %s in %s ms", dict, timeTaken))
    end
end

function PlaySound(folder, file, vol)
    SendNUIMessage({
        transactionType     = 'playSound',
        transactionFolder   = folder,
        transactionFile     = file, 
        transactionVolume   = vol
    })
end

function PlayRadioAnimation()
    local plyPed = PlayerPedId()
    local userServerId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(plyPed))
    local playerNetId = NetworkGetNetworkIdFromEntity(plyPed)

    local animDict = Config.RadioAnimationDictionary
    local animName = Config.RadioAnimationName
    local duration = Config.RadioAnimationDuration

    local taskType = "TaskPlayAnim"
    local paramsList = {
        initiatorSrc = userServerId,
        targetNetId = playerNetId,
        dict = animDict,
        anim = animName,
        blendInSpeed = 8.0,
        blendOutSpeed = -8.0,
        duration = duration,
        flag = 50,
        playbackRate = 0,
        lockX = false,
        lockY = false,
        lockZ = false
    }
    ERS_TriggerEntityTaskForAllClients(taskType, paramsList)
end

function CloneWithoutFunctions(tbl)
    local copy = {}
    for key, value in pairs(tbl) do
        if type(value) == "table" then
            copy[key] = CloneWithoutFunctions(value)
        elseif type(value) ~= "function" then
            copy[key] = value
        end
    end
    return copy
end

--============ POSTAL (auto-detect; no separate bridge resource) ============--
-- Order: (1) Static/postal_file hints (mnr_postals, nearest-postal, …) for arbitrary X/Y.
--        (2) Fall back to a server callback — the server can use rHUD's server export `get_postal(vector2)`
--            (per https://rhud.raxdiam.com/docs/exports/server/) which DOES accept coordinates,
--            plus its own static data discovery.
-- NOTE: rHUD's *client* `get_postal()` takes NO arguments — it always returns the LOCAL player's
--       nearest postal and silently ignores anything passed in. Calling it with a vector2 looked
--       like it worked but produced the player's postal for every coord, which is why callout
--       postals showed the location of where the unit accepted the call instead of the call site.
-- SimpleHUD/ModernHUD only offer player-scoped client getPostal() — wired on MDT client and in
-- server getPostalForPlayer, not in ERS getPostal(x,y,z).
-- Optional Z defaults to 30.0 for providers that use 3D (e.g. mnr export).

local POSTAL_HINTS = {
    'mnr_postals',
    'nearest-postal',
}

local function postalResStarted(name)
    return name and GetResourceState(name) == 'started'
end

local function postalOxLibStarted()
    return GetResourceState('ox_lib') == 'started'
end

local function postalLoadJsonData(res)
    local fname = GetResourceMetadata(res, 'postal_file', 0)
    if not fname or fname == '' then return nil end
    local raw = LoadResourceFile(res, fname)
    if not raw then return nil end
    local ok, decoded = pcall(json.decode, raw)
    if not ok or type(decoded) ~= 'table' or #decoded == 0 then return nil end
    local first = decoded[1]
    if type(first) ~= 'table' or first.x == nil or first.y == nil or first.code == nil then return nil end
    return decoded
end

local function postalNearestFromList(data, xf, yf)
    local ndm, ni = -1, -1
    for i, p in ipairs(data) do
        local px, py = tonumber(p.x), tonumber(p.y)
        if px and py then
            local dm = (xf - px) ^ 2 + (yf - py) ^ 2
            if ni == -1 or dm < ndm then
                ni, ndm = i, dm
            end
        end
    end
    if ni ~= -1 and data[ni].code ~= nil then
        return tostring(data[ni].code)
    end
    return nil
end

local worldPostal = nil

local function postalTryMnrExport(res)
    if res == 'mnr_postals' and not postalOxLibStarted() then return false end
    local ok = pcall(function()
        exports[res]:getNearestPostal(vector3(0.0, 0.0, 30.0))
    end)
    if ok then
        worldPostal = { kind = 'mnr', res = res }
        return true
    end
    return false
end

local function postalResolveMnrExport(res, xf, yf, zf)
    if res == 'mnr_postals' and not postalOxLibStarted() then return nil end
    local ok, code = pcall(function()
        return exports[res]:getNearestPostal(vector3(xf, yf, zf))
    end)
    if not ok or code == nil then return nil end
    local n = tonumber(code)
    if not n or n == 0 then return nil end
    return tostring(math.floor(n + 0.5))
end

local function postalLoadMnrLuaList(res)
    if not postalResStarted(res) then return nil end
    local cfgRaw = LoadResourceFile(res, 'config/config.lua')
    if not cfgRaw or cfgRaw == '' then return nil end
    local cfgFn = load(cfgRaw, '@' .. res .. '/config', 't', {})
    if not cfgFn then return nil end
    local okCfg, cfg = pcall(cfgFn)
    if not okCfg or type(cfg) ~= 'table' then return nil end
    local path = cfg.PostalFilePath or cfg.path or 'data.ocrp'
    if type(path) ~= 'string' or path == '' then return nil end
    local rel = path:gsub('^data%.', 'data/') .. '.lua'
    local dataRaw = LoadResourceFile(res, rel)
    if not dataRaw or dataRaw == '' then return nil end
    local v2 = vec2 or vector2
    local env = { vec2 = v2, vector2 = vector2 }
    setmetatable(env, { __index = _G })
    local dataFn = load(dataRaw, '@' .. res .. '/data', 't', env)
    if not dataFn then return nil end
    local okData, postals = pcall(dataFn)
    if not okData or type(postals) ~= 'table' then return nil end
    local list = {}
    for code, v in pairs(postals) do
        local px, py = tonumber(v and v.x), tonumber(v and v.y)
        if px and py then
            list[#list + 1] = { code = code, x = px, y = py }
        end
    end
    if #list == 0 then return nil end
    return list
end

local function postalTryMnrLua(res)
    local list = postalLoadMnrLuaList(res)
    if not list then return false end
    worldPostal = { kind = 'mnr_lua', res = res, data = list }
    return true
end

local function postalTryCoordsExport(res)
    local ok = pcall(function()
        exports[res]:getPostalAtCoords(0.0, 0.0, 30.0)
    end)
    if not ok then return false end
    worldPostal = { kind = 'coords', res = res }
    return true
end

local function postalTryJson(res)
    local data = postalLoadJsonData(res)
    if not data then return false end
    worldPostal = { kind = 'json', data = data }
    return true
end

local function postalDiscoverWorld()
    if worldPostal then
        if worldPostal.res and not postalResStarted(worldPostal.res) then
            worldPostal = nil
        elseif worldPostal.kind == 'json' and worldPostal.data then
            return
        elseif worldPostal.kind == 'mnr_lua' and worldPostal.data and worldPostal.res and postalResStarted(worldPostal.res) then
            return
        elseif worldPostal.kind == 'mnr' and worldPostal.res and postalResStarted(worldPostal.res) and postalOxLibStarted() then
            return
        elseif worldPostal.kind == 'coords' and worldPostal.res and postalResStarted(worldPostal.res) then
            return
        end
    end
    worldPostal = nil
    local function tryRes(res)
        if not postalResStarted(res) then return false end
        if postalTryMnrExport(res) then return true end
        if postalTryMnrLua(res) then return true end
        if postalTryCoordsExport(res) then return true end
        if postalTryJson(res) then return true end
        return false
    end
    for _, res in ipairs(POSTAL_HINTS) do
        if tryRes(res) then return end
    end
end

local function postalNearestFromCoordsOnly(x, y, z)
    local xf = tonumber(x) or 0.0
    local yf = tonumber(y) or 0.0
    local zf = tonumber(z) or 30.0
    postalDiscoverWorld()
    if not worldPostal then return nil end
    if worldPostal.kind == 'mnr' and worldPostal.res then
        return postalResolveMnrExport(worldPostal.res, xf, yf, zf)
    end
    if worldPostal.kind == 'mnr_lua' and worldPostal.data then
        return postalNearestFromList(worldPostal.data, xf, yf)
    end
    if worldPostal.kind == 'coords' and worldPostal.res then
        local ok, result = pcall(function()
            return exports[worldPostal.res]:getPostalAtCoords(xf, yf, zf)
        end)
        if ok and result and tostring(result) ~= '' then return tostring(result) end
        return nil
    end
    if worldPostal.kind == 'json' and worldPostal.data then
        return postalNearestFromList(worldPostal.data, xf, yf)
    end
    return nil
end

-- Server-callback fallback: rHUD's *server* get_postal(vector2) DOES accept coordinates,
-- and the server also discovers static postal data on its own. We route world-coord lookups
-- through the server when no client-side static backend is available, so installs that only
-- have rHUD still get correct postals for arbitrary coordinates (e.g. callout locations).
local serverPostalRequestId = 0
local serverPostalResults = {}
local serverPostalEventRegistered = false

local function ensureServerPostalEvent()
    if serverPostalEventRegistered then return end
    serverPostalEventRegistered = true
    local prefix = (Config and Config.EventPrefix) or 'night_ers'
    RegisterNetEvent(prefix..':postalResult', function(requestId, code)
        if requestId ~= nil then
            serverPostalResults[requestId] = code or false
        end
    end)
end

local function postalFromServer(xf, yf)
    ensureServerPostalEvent()
    serverPostalRequestId = serverPostalRequestId + 1
    local id = serverPostalRequestId
    local prefix = (Config and Config.EventPrefix) or 'night_ers'
    TriggerServerEvent(prefix..':requestPostal', id, xf, yf)
    local deadline = GetGameTimer() + 1500
    while serverPostalResults[id] == nil and GetGameTimer() < deadline do
        Wait(20)
    end
    local result = serverPostalResults[id]
    serverPostalResults[id] = nil
    if type(result) == 'string' and result ~= '' then return result end
    return nil
end

local function unknownPostalLabel()
    local pack = Config.Messages and Config.Messages[Config.Language]
    local s = pack and pack.UnknownPostal
    if s and s ~= "" then
        return s
    end
    return "Unknown postal"
end

--- @param x number
--- @param y number
--- @param z number|nil optional; defaults to 30.0 for 3D postal exports
--- @return string
function getPostal(x, y, z)
    local xf = tonumber(x) or 0.0
    local yf = tonumber(y) or 0.0
    local zf = tonumber(z) or 30.0
    local code = postalNearestFromCoordsOnly(xf, yf, zf)
    if code and tostring(code) ~= '' then
        return tostring(code)
    end
    -- No client-side static backend (or it returned nothing). Ask the server, which can use
    -- rHUD's server export `get_postal(vector2)` and/or its own static data.
    local serverCode = postalFromServer(xf, yf)
    if serverCode and serverCode ~= '' then
        return serverCode
    end
    return unknownPostalLabel()
end


-- Discord Webhook Integrations

function OnSendDispatchMessage(message)
    local messageData = {
        title = "DISPATCH MESSAGE SYSTEM",
        description = tostring(message),
        color = 11876095, -- https://www.mathsisfun.com/hexadecimal-decimal-colors.html (Decimal colors is what this requires, so the one with numbers only)
        authorname = "Emergency Response Simulator",
        -- authoravatarurl = player.discordMember.avatar,

        sender = "Discord user",
        senderdiscordid = 0, -- Set serverside

        -- subjecttitle = "Plate: "..plate,
        -- subjectdescription = PersonalData.userCurrentStreetName.." at postal: "..PersonalData.userCurrentPostal,

        footer = "Emergency Response Simulator - by Nights Software in collaboration with London Studios",
        footericon = "https://assets.ea-rp.com/img/ERS_Logo.png",

        thumbnail = "https://assets.ea-rp.com/img/ERS_Logo_Sq.png",
        image = "https://assets.ea-rp.com/img/ERS_Logo.png",

        discordwebhookurltype = "dispatch",
        systemname = "Dispatch - System",
    }
    TriggerServerEvent(Config.EventPrefix..":sendDiscordEmbedMessage", messageData)
end
