--[[
  CALLOUT PACK IMPORT (shared script - runs on BOTH client and server)
  ================================================================
  This file merges optional DLC callout packs into Config.Callouts.
  Each pack is optional: if not installed/started, it is skipped.

  ESCROW-COMPATIBLE: Packs can be fully escrow-protected. We import metadata (config)
  via GetCalloutMetadata(), and run .server/.client logic via ExecuteCalloutServer/Client
  exports. The pack keeps its code in its own VM; night_ers dispatches to it when needed.

  WHEN DOES IMPORT RUN?
  ---------------------
  SERVER: ImportERSCalloutPacks() from PrintIntegrationStatus() in server.lua (~2.5s after start),
          ScheduleImportERSCalloutPacks() from onResourceStart (night_ers + any started resource name listed in PACKS below) with short delays.
  CLIENT: A thread waits 5 seconds, then calls ImportERSCalloutPacks()

  PACK EXPORTS REQUIRED
  ---------------------
  GetCalloutIds()      -> string[] of callout IDs
  GetCalloutMetadata(id) -> table (config only, no .client/.server - those stay in pack)
  ExecuteCalloutServer(id, request, src, calloutData, pedList, ...) -> success, pedList, ... 
  ExecuteCalloutClient(id, plyPed, pedList, vehicleList, ...)

  RETRY LOGIC: Retries every 2s. More attempts if the pack resource exists but is stopped/starting (e.g. you start it right after night_ers).

  DEDUPE: night_ers may call import from several timers plus PrintIntegrationStatus; pack may start before or after night_ers.
  After a successful import for a pack resource name, further runs skip re-import and the ^2Imported^7 line until that pack stops (onResourceStop).
]]

-- Optional 4th field: if true, skip server console status lines for this pack (imported / not found / failed).
local PACKS = {
    { 'night_ers_cp1', 'ERS Callout Pack 1 by Nights Software', 'https://store.nights-software.com/package/7277996' },
    -- { 'night_ers_cp2', 'ERS Callout Pack 2 by Nights Software', 'https://store.nights-software.com', true },
    -- { 'night_ers_cp3', 'ERS Callout Pack 3 by Nights Software', 'https://store.nights-software.com', true },
}

--- True if this started resource name matches a PACKS entry (canonical resource name).
function ERS_IsStartedCalloutPackResource(resourceName)
    if type(resourceName) ~= 'string' or GetResourceState(resourceName) ~= 'started' then
        return false
    end
    for _, pack in ipairs(PACKS) do
        if pack[1] == resourceName then
            return true
        end
    end
    return false
end

--- Import pack metadata (no functions). Pack runs its .server/.client via exports when callout builds.
local function ImportPackMetadata(resourceName)
    local ok, ids = pcall(function() return exports[resourceName]:GetCalloutIds() end)
    if not ok or not ids or type(ids) ~= 'table' then
        error("GetCalloutIds() failed or missing - pack may not have finished loading")
    end

    for _, id in ipairs(ids) do
        if type(id) == 'string' then
            local ok2, meta = pcall(function() return exports[resourceName]:GetCalloutMetadata(id) end)
            if ok2 and meta and type(meta) == 'table' then
                meta.PackSource = resourceName
                meta.CalloutId = id
                Config.Callouts[id] = meta
            end
        end
    end
end

local PACK_IMPORT_RETRY_DELAY_MS = 2000
local PACK_IMPORT_MAX_RETRIES = 5
local PACK_IMPORT_MAX_RETRIES_WHEN_PRESENT = 20

local function maxRetriesForCanonical(canonical)
    local s = GetResourceState(canonical)
    if s == 'stopped' or s == 'starting' then
        return PACK_IMPORT_MAX_RETRIES_WHEN_PRESENT
    end
    return PACK_IMPORT_MAX_RETRIES
end

local function printPackNotAvailable(canonical, displayName, storeUrl, hideStatus)
    if not IsDuplicityVersion() or hideStatus then return end
    local s = GetResourceState(canonical)
    if s == 'stopped' or s == 'starting' then
        local storeHint = ''
        if type(storeUrl) == 'string' and storeUrl ~= '' then
            storeHint = ' Get it at ^4' .. storeUrl .. '^7.'
        end
        print("^3[night_ers]^7 ^5" .. displayName .. "^7: resource ^2" .. canonical .. "^7 is ^1" .. tostring(s) .. "^7. "
            .. "If you restarted only ^2night_ers^7, start the pack too (^2ensure " .. canonical .. "^7). "
            .. "In ^2server.cfg^7 use ^2ensure night_ers^7 then ^2ensure " .. canonical .. "^7."
            .. storeHint)
    elseif s == 'missing' then
        print("^5[^7" .. displayName .. "^5] ^1Not installed^7 (no resource ^3" .. canonical .. "^7). Get it at ^4" .. storeUrl .. " ^7")
    else
        print("^5[^7" .. displayName .. "^5] ^1Not available^7 (^3" .. canonical .. "^7 state: ^1" .. tostring(s) .. "^7). Store: ^4" .. storeUrl .. " ^7")
    end
end

-- New import wave bumps this so older staggered retries stop (avoids duplicate failure lines).
local packImportGeneration = 0

-- Per VM (client/server): successful import for this pack resource; cleared on pack onResourceStop so restart re-imports.
local packImportSucceeded = {}

local function TryImportPack(pack, retryCount, gen, maxRetries)
    if gen ~= packImportGeneration then return end

    local canonical, name, url, hideStatus = pack[1], pack[2], pack[3], pack[4] == true
    if maxRetries == nil then
        maxRetries = maxRetriesForCanonical(canonical)
    end

    local state = GetResourceState(canonical)

    if state ~= 'started' then
        if retryCount < maxRetries then
            Citizen.SetTimeout(PACK_IMPORT_RETRY_DELAY_MS, function()
                TryImportPack(pack, retryCount + 1, gen, maxRetries)
            end)
        elseif IsDuplicityVersion() and not hideStatus then
            printPackNotAvailable(canonical, name, url, hideStatus)
        end
        return
    end

    if packImportSucceeded[canonical] then
        return
    end

    local ok, err = pcall(ImportPackMetadata, canonical)
    if ok then
        packImportSucceeded[canonical] = true
        if IsDuplicityVersion() and not hideStatus then
            print("^5[^7" .. name .. "^5] ^2Imported^7")
        end
    elseif retryCount < maxRetries then
        Citizen.SetTimeout(PACK_IMPORT_RETRY_DELAY_MS, function()
            TryImportPack(pack, retryCount + 1, gen, maxRetries)
        end)
    elseif IsDuplicityVersion() and not hideStatus then
        print("^1[night_ers] Pack import failed (" .. name .. "): " .. tostring(err) .. "^7")
    end
end

--- Entry point: import all packs. Called from server (PrintIntegrationStatus) and client (delayed thread).
function ImportERSCalloutPacks()
    packImportGeneration = packImportGeneration + 1
    local gen = packImportGeneration
    for _, pack in ipairs(PACKS) do
        TryImportPack(pack, 0, gen, nil)
    end
end

-- SERVER ONLY: defer import so pack exports are registered (onResourceStart often fires before exports exist).
local PACK_IMPORT_DEFER_MS_DEFAULT = 750
function ScheduleImportERSCalloutPacks(delayMs)
    if not IsDuplicityVersion() then return end
    local ms = tonumber(delayMs) or PACK_IMPORT_DEFER_MS_DEFAULT
    if ms < 0 then ms = 0 end
    Citizen.SetTimeout(ms, function()
        ImportERSCalloutPacks()
    end)
end

AddEventHandler('onResourceStop', function(resourceName)
    if type(resourceName) ~= 'string' then return end
    for _, pack in ipairs(PACKS) do
        if pack[1] == resourceName then
            packImportSucceeded[resourceName] = nil
            break
        end
    end
end)

-- CLIENT ONLY: Delay import so NUI and other client systems are ready. Server calls ImportERSCalloutPacks directly.
if not IsDuplicityVersion() then
    Citizen.CreateThread(function()
        Citizen.Wait(5000)
        ImportERSCalloutPacks()
    end)
end
