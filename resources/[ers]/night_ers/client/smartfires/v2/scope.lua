-- ============================================================================
--  SFV2.CountSceneNodes / PurgeCalloutVisuals (client)
-- ============================================================================
--  After Phase 1.1 SmartFires patch, client `GetAllFires()` returns the same
--  shape as server (`live`, `sourceIncidentId`). That lets us mirror server
--  scope here instead of guessing with GTA `GetNumberOfFiresInRange`.
-- ============================================================================

if IsDuplicityVersion() then return end

SFV2 = SFV2 or {}

local SF_RES = 'SmartFires'

local DEFAULT_SCENE_RADIUS = 200.0
local SCENE_RADIUS_PADDING = 80.0

local function coordsToVec3(c)
    if not c then return nil end
    local t = type(c)
    if t == 'vector3' or t == 'vector4' then
        return vector3(c.x + 0.0, c.y + 0.0, c.z + 0.0)
    end
    if t == 'table' then
        local x = tonumber(c.x) or tonumber(c.X)
        local y = tonumber(c.y) or tonumber(c.Y)
        local z = tonumber(c.z) or tonumber(c.Z)
        if x and y and z then return vector3(x, y, z) end
    end
    return nil
end

local function fetchRows()
    if GetResourceState(SF_RES) ~= 'started' then return {} end
    local ok, rows = pcall(function() return exports[SF_RES]:GetAllFires() end)
    if not ok or type(rows) ~= 'table' then return {} end
    if rows[1] ~= nil then return rows end
    local arr = {}
    for _, row in pairs(rows) do arr[#arr + 1] = row end
    return arr
end

local function rowIsLive(row)
    if not row or not row.coords or row.active == false then return false end
    if row.pendingSeed == true then return false end
    if row.live == true then return true end
    if row.live == false then return false end
    return row.id ~= nil and row.id ~= 0
end

local function calloutSpawnSet(callout)
    local set = {}
    if not callout then return set end
    for _, id in ipairs(callout.sfAllSpawnIds or {}) do
        if id ~= nil then set[tostring(id)] = true end
    end
    if next(set) == nil then
        for _, id in ipairs(callout.fireList or {}) do
            if id ~= nil then set[tostring(id)] = true end
        end
    end
    return set
end

local function sceneRadius(callout, center)
    local r = DEFAULT_SCENE_RADIUS
    if not center or not callout then return r end
    if type(callout.sfSpawnCoordsById) == 'table' then
        for _, c in pairs(callout.sfSpawnCoordsById) do
            local fc = coordsToVec3(c)
            if fc then
                local d = #(center - fc)
                if d > r then r = d end
            end
        end
    end
    return r + SCENE_RADIUS_PADDING
end

--- Internal: scan callout rows once and return everything HUD/NPC needs.
---@return number liveNodes
---@return number liveIncidents
---@return number pendingIncidents
local function scanCallout(callout)
    if not callout then return 0, 0, 0 end
    local center = coordsToVec3(callout.calloutData and callout.calloutData.Coordinates)
    if not center then return 0, 0, 0 end
    local radius = sceneRadius(callout, center)
    local spawnSet = calloutSpawnSet(callout)

    local nodeCount = 0
    local liveHosts = {}
    local pendingHosts = {}
    for _, row in ipairs(fetchRows()) do
        if row.coords then
            local fc = coordsToVec3(row.coords)
            if fc and #(center - fc) <= radius then
                local host = row.incidentId and tostring(row.incidentId)
                local src = row.sourceIncidentId and tostring(row.sourceIncidentId)
                local inCallout = (host and spawnSet[host]) or (src and spawnSet[src])
                if inCallout then
                    if rowIsLive(row) then
                        nodeCount = nodeCount + 1
                        if host then liveHosts[host] = true end
                    elseif row.pendingSeed == true or (row.live == false and (row.id == 0 or row.id == nil)) then
                        if host then pendingHosts[host] = true end
                    end
                end
            end
        end
    end
    local liveIncidents = 0
    for _ in pairs(liveHosts) do liveIncidents = liveIncidents + 1 end
    local pendingIncidents = 0
    for h in pairs(pendingHosts) do
        if not liveHosts[h] then pendingIncidents = pendingIncidents + 1 end
    end
    return nodeCount, liveIncidents, pendingIncidents
end

--- Public: live flame node count + pending incident count for one callout.
--- Use for diagnostics / NPC exits (NPCs fight every node).
---@return number liveNodes
---@return number pendingIncidents
function SFV2.CountSceneNodes(callout)
    local nodes, _, pending = scanCallout(callout)
    return nodes, pending
end

--- Public: live incident count + pending incident count for one callout.
--- Use for HUD numerator and callout-completion checks (matches blip count).
---@return number liveIncidents
---@return number pendingIncidents
function SFV2.CountSceneIncidents(callout)
    local _, incidents, pending = scanCallout(callout)
    return incidents, pending
end

--- Public: client-side purge for a callout. Fires `fire:cl:stopBySource`
--- locally; safe to call repeatedly.
function SFV2.PurgeCalloutVisuals(callout)
    if not callout then return end
    local ids = {}
    local seen = {}
    local function addId(id)
        if id == nil then return end
        local key = tostring(id)
        if seen[key] then return end
        seen[key] = true
        ids[#ids + 1] = id
    end
    for _, id in ipairs(callout.sfAllSpawnIds or {}) do addId(id) end
    for _, id in ipairs(callout.fireList or {}) do addId(id) end
    if #ids < 1 then return end
    TriggerEvent('fire:cl:stopBySource', ids, true)
end

--- Public: ask server to broadcast a defensive purge for these ids.
--- Rate-limited so worker loops can call freely.
local lastPurgeRequestAt = 0
function SFV2.RequestPurgeFromServer(spawnIds)
    if type(spawnIds) ~= 'table' or #spawnIds < 1 then return end
    local now = GetGameTimer()
    if now - lastPurgeRequestAt < 3000 then return end
    lastPurgeRequestAt = now
    TriggerServerEvent(Config.EventPrefix .. ':sfv2_purgeRequest', spawnIds)
end
