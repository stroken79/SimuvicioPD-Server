-- ============================================================================
--  SFV2.SpawnFire / SpawnSmoke
-- ============================================================================
--  Thin wrappers around SmartFires `CreateFire` / `CreateSmoke`.
--  Callout spawns pass suppressExternalDispatch=true (CreateFire arg 8 /
--  CreateSmoke arg 6) so ERS remains the single MDT/CAD source on arrival.
--
--  All fires use SmartFires' default behaviour, which includes native merge:
--  spawns close enough to an existing incident are absorbed into the host
--  and the bridge resolves the canonical host id via SmartFires'
--  `GetCanonicalIncidentId` export when HUD / NPC scope counts incidents, so
--  a merged spawn never double-counts. If a callout needs a layout where
--  every spawn stays a distinct front, space the coords beyond the engine's
--  merge radius rather than fighting the merge.
--
--  `opts.interiorId` (default 0 = auto-probe). SmartFires already auto-detects
--  the interior from coords on every CreateFire, so passing `fireType =
--  "indoors"` (or simply spawning at coords inside a probed interior) gets you
--  a correctly classified indoor incident. Override this only when the
--  coord-based probe misses the right interior (rare; some custom-MLO
--  scenarios).
--
--  Inter-spawn throttle (`CREATE_MIN_GAP_MS`) avoids slamming the SmartFires
--  registration path with concurrent calls. The real client-side rate
--  protection lives in the SmartFires patches (cl_outdoors.lua seed queue +
--  per-master Wait); the ERS gap only needs to be large enough that
--  `GetIncidentStatus` polling settles before the next CreateFire is issued.
--
--  Post-create validation polls `GetIncidentStatus` until it returns `active`
--  or times out. Failure path: forget the id, broadcast a visual purge at the
--  coords (Phase 1.2 `fire:cl:stopBySource` makes this idempotent), and let
--  the callout plugin retry if it wants.
-- ============================================================================

if not IsDuplicityVersion() then return end

SFV2 = SFV2 or {}

local SF_RES = 'SmartFires'

local CREATE_MIN_GAP_MS = 600
local CREATE_VALIDATE_TIMEOUT_MS = 800
local CREATE_VALIDATE_STEP_MS = 50

local lastCreateAt = 0

local function log(step, detail)
    if not (SFV2 and SFV2.IsDebug and SFV2.IsDebug()) then return end
    print('[ERS-SF] ' .. step .. (detail and (' | ' .. detail) or ''))
end

local function waitCreateGap()
    local now = GetGameTimer()
    local elapsed = now - lastCreateAt
    if elapsed < CREATE_MIN_GAP_MS then
        Citizen.Wait(CREATE_MIN_GAP_MS - elapsed)
    end
end

local function radiusToNodeCount(radius)
    local r = tonumber(radius) or 10.0
    local n = math.floor(r / 3.0) + 3
    if n < 4 then n = 4 end
    if n > 8 then n = 8 end
    return n
end

local function waitForIncidentValid(incidentId)
    if incidentId == nil then return false end
    local deadline = GetGameTimer() + CREATE_VALIDATE_TIMEOUT_MS
    while GetGameTimer() < deadline do
        local ok, status = pcall(function()
            return exports[SF_RES]:GetIncidentStatus(incidentId)
        end)
        if ok and type(status) == 'table' then
            if status.state == 'active' then return true end
            if status.state == 'gone' or status.state == 'invalid' then return false end
        end
        Citizen.Wait(CREATE_VALIDATE_STEP_MS)
    end
    return false
end

--- Internal: one CreateFire attempt with validation. Returns nil on failure.
local function attemptCreate(x, y, z, fireType, radius, count, interiorId)
    local interior = tonumber(interiorId) or 0
    local incidentId
    local ok = pcall(function()
        -- ERS owns MDT/CAD for callouts; skip SmartFires external dispatch per fire.
        incidentId = exports[SF_RES]:CreateFire(x, y, z, fireType, radius, count, interior, true)
    end)
    if not ok or incidentId == nil then
        log('CREATE_FAIL', string.format('nil_id at=%.0f,%.0f,%.0f', x, y, z))
        return nil
    end
    lastCreateAt = GetGameTimer()
    if not waitForIncidentValid(incidentId) then
        log('CREATE_FAIL', string.format('not_active id=%s at=%.0f,%.0f,%.0f', tostring(incidentId), x, y, z))
        TriggerClientEvent('fire:cl:stopBySource', -1, { tostring(incidentId) }, true)
        return nil
    end
    log('CREATE_FIRE', string.format(
        'id=%s at=%.0f,%.0f,%.0f count=%d interior=%d',
        tostring(incidentId), x, y, z, count, interior
    ))
    return incidentId
end

--- Public: spawn one fire for a callout. Registers the id + coords so scope
--- and teardown can find them later.
---@param callout table  ActiveCalloutsList entry
---@param coords vector3|table
---@param radius number  legacy ERS radius (mapped to v2 node count)
---@param fireType string|nil  default 'standard'. Pass `'indoors'` to force
---                            indoor placement regardless of where coords
---                            probe. Any other type still gets auto-classified
---                            indoor when coords are inside a probed interior.
---@param opts table|nil  options table:
---                       - `interiorId` (number, default 0 = auto-probe coords):
---                         force a specific interior id. Use only when the
---                         coord-based probe misses the right interior; the
---                         default works for ~99% of cases.
---@return string|nil  incidentId
function SFV2.SpawnFire(callout, coords, radius, fireType, opts)
    if GetResourceState(SF_RES) ~= 'started' then return nil end
    local c = SFV2.CoordsToVec3(coords)
    if not c then return nil end
    waitCreateGap()
    local count = radiusToNodeCount(radius)
    local rad = tonumber(radius) or 10.0
    local ft = tostring(fireType or 'standard')
    local interiorId = type(opts) == 'table' and tonumber(opts.interiorId) or 0

    local incidentId = attemptCreate(c.x, c.y, c.z, ft, rad, count, interiorId)
    if not incidentId then
        Citizen.Wait(150)
        waitCreateGap()
        incidentId = attemptCreate(c.x, c.y, c.z, ft, rad, count, interiorId)
        if not incidentId then return nil end
    end

    if callout then
        SFV2.RegisterSpawnId(callout, incidentId, c)
        callout.fireList = callout.fireList or {}
        callout.fireList[#callout.fireList + 1] = incidentId
        SFV2.InvalidateScope(callout)
    end
    return incidentId
end

--- Public: spawn one smoke for a callout. Smoke has no spread / merge in the
--- same sense, so we don't retry or validate.
function SFV2.SpawnSmoke(callout, coords, radius, smokeType)
    if GetResourceState(SF_RES) ~= 'started' then return nil end
    local c = SFV2.CoordsToVec3(coords)
    if not c then return nil end
    local rad = tonumber(radius) or 10.0
    local st = tostring(smokeType or 'standard')
    local id
    local ok = pcall(function()
        id = exports[SF_RES]:CreateSmoke(c.x, c.y, c.z, st, rad, true)
    end)
    if not ok or id == nil then return nil end
    if callout then
        callout.smokeList = callout.smokeList or {}
        callout.smokeList[#callout.smokeList + 1] = { smokeId = id }
    end
    log('CREATE_SMOKE', string.format('id=%s', tostring(id)))
    return id
end

--- Public: damage relay for NPC hose pulses.
function SFV2.ApplyDamageAtCoords(coords, radius, amount, opts)
    if GetResourceState(SF_RES) ~= 'started' then return 0 end
    local c = SFV2.CoordsToVec3(coords)
    if not c then return 0 end
    local ok, hit = pcall(function()
        return exports[SF_RES]:ApplyFireDamageAtCoords(
            c.x, c.y, c.z, tonumber(radius) or 5.0, tonumber(amount) or 50.0, opts or {}
        )
    end)
    if not ok or type(hit) ~= 'number' then return 0 end
    return hit
end
