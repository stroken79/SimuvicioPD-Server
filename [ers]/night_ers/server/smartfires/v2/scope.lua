-- ============================================================================
--  SFV2.GetCalloutScope — single source of truth for one callout's fire state.
-- ============================================================================
--  Every HUD count, NPC task list, completion check and teardown reads from
--  here. If something doesn't show up in HUD or NPCs miss a flame, the bug
--  belongs in this file, not at the call-site.
--
--  Scope shape:
--      {
--          liveNodes    = array of `GetAllFires` rows (live == true)
--          spawnIds     = array of registered CreateFire ids (append-only)
--          hostIds      = array of distinct incident ids hosting live nodes
--          pendingSeeds = number of registered ids with no live node yet
--          vehicleFires = array of { vehNet, coords, isFullFailure, ... } for
--                         any SmartFires vehicle fire whose coords land inside
--                         this callout's `radiusM` (ambient discovery — we
--                         don't require callouts to explicitly register them).
--                         Empty when SmartFires lacks `GetActiveVehicleFires`.
--          tick         = monotonic integer (per server-tick cache key)
--          center       = vector3 callout origin
--          radiusM      = scene radius used for the scan
--      }
--
--  Cached on the callout per server tick (`callout._sfScope`). Use
--  `SFV2.InvalidateScope(callout)` after mutating state so the next reader
--  recomputes.
-- ============================================================================

if not IsDuplicityVersion() then return end

SFV2 = SFV2 or {}

local SF_RES = 'SmartFires'

local DEFAULT_SCENE_RADIUS = 200.0
local SCENE_RADIUS_PADDING = 80.0

-- ---------------------------------------------------------------------------
--  Helpers
-- ---------------------------------------------------------------------------

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

SFV2.CoordsToVec3 = coordsToVec3

--- Pull `GetAllFires()` and normalise to an array.
local function fetchAllFireRows()
    if GetResourceState(SF_RES) ~= 'started' then return {} end
    local ok, rows = pcall(function() return exports[SF_RES]:GetAllFires() end)
    if not ok or type(rows) ~= 'table' then return {} end
    if rows[1] ~= nil then return rows end
    local arr = {}
    for _, row in pairs(rows) do arr[#arr + 1] = row end
    return arr
end

SFV2.FetchAllFireRows = fetchAllFireRows

--- Pull `GetActiveVehicleFires(opts)` if the SmartFires build exposes it.
--- Older SmartFires builds without the export return an empty array so the
--- ERS pipeline keeps working — vehicle fires just won't show in scope.
local function fetchActiveVehicleFires(center, radiusM)
    if GetResourceState(SF_RES) ~= 'started' then return {} end
    local opts = nil
    if center then
        opts = { center = { x = center.x, y = center.y, z = center.z } }
        if radiusM then opts.radius = radiusM end
    end
    local ok, rows = pcall(function() return exports[SF_RES]:GetActiveVehicleFires(opts) end)
    if not ok or type(rows) ~= 'table' then return {} end
    if rows[1] ~= nil then return rows end
    local arr = {}
    for _, row in pairs(rows) do arr[#arr + 1] = row end
    return arr
end

SFV2.FetchActiveVehicleFires = fetchActiveVehicleFires

--- Resolve any (possibly merged) incidentId to its canonical surviving host id.
--- Uses SmartFires' `GetCanonicalIncidentId` export when available, with a
--- safe fallback for older SmartFires builds that lack it (returns the input).
---@param incidentId any
---@return any|nil
function SFV2.ResolveCanonicalIncidentId(incidentId)
    if incidentId == nil then return nil end
    if GetResourceState(SF_RES) ~= 'started' then return incidentId end
    local ok, resolved = pcall(function()
        return exports[SF_RES]:GetCanonicalIncidentId(incidentId)
    end)
    if not ok or resolved == nil then return incidentId end
    return resolved
end

--- Count distinct canonical incident ids in the given spawn id set. Two ids
--- that merged into the same host count as one for HUD/baseline purposes.
---@param spawnSet table  {[id]=true} as returned by `BuildCalloutSpawnSet`
---@return number distinctCanonicalCount
function SFV2.CountDistinctCanonicalSpawns(spawnSet)
    if type(spawnSet) ~= 'table' then return 0 end
    local seen = {}
    local n = 0
    for spawnId in pairs(spawnSet) do
        local canon = tostring(SFV2.ResolveCanonicalIncidentId(spawnId) or spawnId)
        if not seen[canon] then
            seen[canon] = true
            n = n + 1
        end
    end
    return n
end

--- True for rows representing an actual burnable flame node (not a placeholder).
local function rowIsLiveFlameNode(row)
    if not row or not row.coords or row.active == false then return false end
    if row.pendingSeed == true then return false end
    if row.live == true then return true end
    if row.live == false then return false end
    -- Legacy SmartFires builds lacked `live`: fall back to `id ~= 0` heuristic.
    return row.id ~= nil and row.id ~= 0
end

SFV2.RowIsLiveFlameNode = rowIsLiveFlameNode

--- True for rows that represent an incident registered but not yet seeded.
local function rowIsPendingSeed(row)
    if not row or row.active == false then return false end
    if row.pendingSeed == true then return true end
    if row.live == false and (row.id == 0 or row.id == nil) then return true end
    return false
end

SFV2.RowIsPendingSeed = rowIsPendingSeed

--- Build a lookup of {[spawnId]=true} from a callout's append-only registry.
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

SFV2.BuildCalloutSpawnSet = calloutSpawnSet

--- Discover scene radius wide enough to cover spread away from the spawn coords.
local function sceneRadiusForCallout(callout, center)
    local radiusM = DEFAULT_SCENE_RADIUS
    if not center or not callout then return radiusM end
    -- Stretch by registered spawn coords (covers forest fire 6-point sets).
    if type(callout.sfSpawnCoordsById) == 'table' then
        for _, c in pairs(callout.sfSpawnCoordsById) do
            local fc = coordsToVec3(c)
            if fc then
                local d = #(center - fc)
                if d > radiusM then radiusM = d end
            end
        end
    end
    -- Stretch by any live node that already belongs to a registered spawn.
    local spawnSet = calloutSpawnSet(callout)
    for _, row in ipairs(fetchAllFireRows()) do
        if row.coords and (rowIsLiveFlameNode(row) or rowIsPendingSeed(row)) then
            local host = row.incidentId and tostring(row.incidentId)
            local src = row.sourceIncidentId and tostring(row.sourceIncidentId)
            if (host and spawnSet[host]) or (src and spawnSet[src]) then
                local fc = coordsToVec3(row.coords)
                if fc then
                    local d = #(center - fc)
                    if d > radiusM then radiusM = d end
                end
            end
        end
    end
    return radiusM + SCENE_RADIUS_PADDING
end

SFV2.SceneRadiusForCallout = sceneRadiusForCallout

-- ---------------------------------------------------------------------------
--  Scope computation
-- ---------------------------------------------------------------------------

local scopeTickSeq = 0

--- Force the next `GetCalloutScope` call to recompute (after spawn/teardown).
function SFV2.InvalidateScope(callout)
    if not callout then return end
    callout._sfScope = nil
end

--- Returns the per-tick scope. Computes once per server poll then caches.
function SFV2.GetCalloutScope(callout)
    if not callout then return nil end
    if callout._sfScope and callout._sfScope.tick == scopeTickSeq then
        return callout._sfScope
    end

    local center = coordsToVec3(callout.calloutData and callout.calloutData.Coordinates)
    if not center then
        local scope = {
            liveNodes = {},
            spawnIds = {},
            hostIds = {},
            pendingSeeds = 0,
            vehicleFires = {},
            tick = scopeTickSeq,
            center = nil,
            radiusM = 0,
        }
        callout._sfScope = scope
        return scope
    end

    local radiusM = sceneRadiusForCallout(callout, center)
    local spawnSet = calloutSpawnSet(callout)

    local liveNodes = {}
    local hostSet = {}
    for _, row in ipairs(fetchAllFireRows()) do
        if rowIsLiveFlameNode(row) and row.coords then
            local fc = coordsToVec3(row.coords)
            if fc and #(center - fc) <= radiusM then
                local host = row.incidentId and tostring(row.incidentId)
                local src = row.sourceIncidentId and tostring(row.sourceIncidentId)
                if (host and spawnSet[host]) or (src and spawnSet[src]) then
                    liveNodes[#liveNodes + 1] = row
                    if host then hostSet[host] = true end
                end
            end
        end
    end

    -- Pending seeds = registered ids whose incident is still active but has
    -- no live row in the array yet.
    local pendingSeeds = 0
    for spawnId in pairs(spawnSet) do
        local ok, status = pcall(function()
            return exports[SF_RES]:GetIncidentStatus(spawnId)
        end)
        if ok and type(status) == 'table' and status.state == 'active' then
            -- Active but does it have any live node?
            local hasLive = false
            for _, row in ipairs(liveNodes) do
                local host = row.incidentId and tostring(row.incidentId)
                local src = row.sourceIncidentId and tostring(row.sourceIncidentId)
                if host == spawnId or src == spawnId then
                    hasLive = true
                    break
                end
            end
            if not hasLive then pendingSeeds = pendingSeeds + 1 end
        end
    end

    local spawnIds = {}
    for id in pairs(spawnSet) do spawnIds[#spawnIds + 1] = id end
    local hostIds = {}
    for id in pairs(hostSet) do hostIds[#hostIds + 1] = id end

    -- Ambient vehicle-fire discovery. Any SmartFires vehicle fire whose coords
    -- fall inside `radiusM` is treated as part of the callout's task list —
    -- callouts don't need to register them. Coords here come from the entry's
    -- `data.coords` or the live entity (handled by the SmartFires export).
    local vehicleFires = {}
    for _, vrow in ipairs(fetchActiveVehicleFires(center, radiusM)) do
        if vrow and vrow.vehNet then
            local vc = coordsToVec3(vrow.coords)
            if vc then
                vehicleFires[#vehicleFires + 1] = {
                    vehNet            = tonumber(vrow.vehNet) or vrow.vehNet,
                    coords            = vc,
                    isFullFailure     = vrow.isFullFailure == true,
                    isArson           = vrow.isArson == true,
                    isRescue          = vrow.isRescue == true,
                    hasVehicleFire    = vrow.hasVehicleFire == true,
                    suppressExplosion = vrow.suppressExplosion == true,
                }
            end
        end
    end

    local scope = {
        liveNodes = liveNodes,
        spawnIds = spawnIds,
        hostIds = hostIds,
        pendingSeeds = pendingSeeds,
        vehicleFires = vehicleFires,
        tick = scopeTickSeq,
        center = center,
        radiusM = radiusM,
    }
    callout._sfScope = scope
    return scope
end

--- Bump the tick counter — call from `SFV2.Poll` before each refresh.
function SFV2.AdvanceScopeTick()
    scopeTickSeq = scopeTickSeq + 1
end

--- Append-only spawn registry (callout-scoped + global coord cache).
local globalSpawnCoords = {}

function SFV2.RegisterSpawnId(callout, incidentId, coords)
    if not callout or incidentId == nil then return end
    local key = tostring(incidentId)
    callout.sfAllSpawnIds = callout.sfAllSpawnIds or {}
    local found = false
    for _, id in ipairs(callout.sfAllSpawnIds) do
        if id ~= nil and tostring(id) == key then found = true; break end
    end
    if not found then
        callout.sfAllSpawnIds[#callout.sfAllSpawnIds + 1] = incidentId
    end
    local c = coordsToVec3(coords) or globalSpawnCoords[key]
    if c then
        globalSpawnCoords[key] = c
        callout.sfSpawnCoordsById = callout.sfSpawnCoordsById or {}
        callout.sfSpawnCoordsById[key] = { x = c.x, y = c.y, z = c.z }
    end
end

function SFV2.GetSpawnCoords(incidentId)
    if incidentId == nil then return nil end
    return globalSpawnCoords[tostring(incidentId)]
end

function SFV2.ForgetSpawnId(incidentId)
    if incidentId == nil then return end
    globalSpawnCoords[tostring(incidentId)] = nil
end

--- Append any newly discovered spread host id to the spawn registry so future
--- scopes pick it up.
function SFV2.AppendSpreadHostsToCallout(callout)
    if not callout then return 0 end
    local scope = SFV2.GetCalloutScope(callout)
    if not scope then return 0 end
    local added = 0
    local existing = {}
    for _, id in ipairs(callout.sfAllSpawnIds or {}) do
        if id ~= nil then existing[tostring(id)] = true end
    end
    for _, hostId in ipairs(scope.hostIds) do
        if not existing[hostId] then
            SFV2.RegisterSpawnId(callout, hostId, nil)
            existing[hostId] = true
            added = added + 1
        end
    end
    if added > 0 then SFV2.InvalidateScope(callout) end
    return added
end
