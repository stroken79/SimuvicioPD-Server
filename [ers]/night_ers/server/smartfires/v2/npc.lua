-- ============================================================================
--  SFV2.BuildNpcNodeTasks / OnNpcNodeKilled
-- ============================================================================
--  NPC firefighters fight one task per live flame node. Tasks are built from
--  the same scope the HUD reads, so what NPCs target == what players see.
--
--  Flame-node task shape:
--      {
--          nodeKey        = "incidentId:nth"   -- stable across polls
--          fireId         = sourceIncidentId   -- callout spawn id
--          incidentId     = host id            -- may differ after spread
--          nodeNth        = number             -- server-side index
--          fireData       = row                -- full GetAllFires row
--      }
--
--  Vehicle-fire task shape (one per ambient SmartFires vehicle fire in scope):
--      {
--          nodeKey        = "veh:<vehNet>"     -- prefix marks it as vehicular
--          fireId         = "veh:<vehNet>"     -- same key — `:stopFire` no-ops
--                                                 on this key (SmartFires fires
--                                                 its own extinguish chain when
--                                                 the strength hits zero).
--          isVehicleFire  = true
--          vehNet         = number             -- network id of the vehicle
--          fireData       = {                  -- synthetic, mirrors row shape
--              coords        = vector3,
--              type          = 'vehicle',
--              isVehicleFire = true,
--              vehNet        = number,
--          }
--      }
-- ============================================================================

if not IsDuplicityVersion() then return end

SFV2 = SFV2 or {}

local SF_RES = 'SmartFires'

local function log(step, detail)
    if not (SFV2 and SFV2.IsDebug and SFV2.IsDebug()) then return end
    print('[ERS-SF] ' .. step .. (detail and (' | ' .. detail) or ''))
end

--- Stable key per node (used by NPC client workers to dedupe).
local function nodeKey(incidentId, nth)
    if incidentId == nil or nth == nil then return nil end
    return tostring(incidentId) .. ':' .. tostring(nth)
end
SFV2.NodeKey = nodeKey

function SFV2.ParseNodeKey(key)
    if key == nil then return nil, nil end
    local inc, nthStr = tostring(key):match('^(.+):(%d+)$')
    if not inc then return nil, nil end
    return inc, tonumber(nthStr)
end

--- Build a synthetic NPC task for one ambient vehicle-fire scope entry.
local function buildVehicleFireTask(vrow)
    if not vrow or not vrow.vehNet or not vrow.coords then return nil end
    local vc = vrow.coords
    local key = 'veh:' .. tostring(vrow.vehNet)
    return {
        nodeKey       = key,
        fireId        = key,
        isVehicleFire = true,
        vehNet        = tonumber(vrow.vehNet) or vrow.vehNet,
        fireData = {
            coords        = vector3(vc.x + 0.0, vc.y + 0.0, vc.z + 0.0),
            type          = 'vehicle',
            isVehicleFire = true,
            vehNet        = tonumber(vrow.vehNet) or vrow.vehNet,
        },
    }
end
SFV2.BuildVehicleFireTask = buildVehicleFireTask

--- True for a node key that targets a SmartFires vehicle fire (`veh:<vehNet>`).
function SFV2.IsVehicleFireKey(key)
    return type(key) == 'string' and key:sub(1, 4) == 'veh:'
end

--- Returns the vehicle network id from a `veh:<vehNet>` key, or nil.
function SFV2.ParseVehicleFireKey(key)
    if not SFV2.IsVehicleFireKey(key) then return nil end
    return tonumber(key:sub(5))
end

--- Public: array of node tasks for the given callout. Order matches scope.
--- Includes both flame-node tasks (from `scope.liveNodes`) and ambient
--- vehicle-fire tasks (from `scope.vehicleFires`). NPC workers consume both
--- shapes transparently; the client AI branches on `task.isVehicleFire`.
function SFV2.BuildNpcNodeTasks(callout)
    local scope = SFV2.GetCalloutScope(callout)
    if not scope then return {} end
    local out = {}
    for _, row in ipairs(scope.liveNodes) do
        local inc = row.incidentId
        local nth = row.id
        if inc ~= nil and nth ~= nil and nth ~= 0 then
            out[#out + 1] = {
                nodeKey = nodeKey(inc, nth),
                fireId = row.sourceIncidentId or inc,
                incidentId = inc,
                nodeNth = nth,
                fireData = row,
            }
        end
    end
    for _, vrow in ipairs(scope.vehicleFires or {}) do
        local task = buildVehicleFireTask(vrow)
        if task then out[#out + 1] = task end
    end
    return out
end

--- Public: NPC client reports a node was extinguished. Damage the node so
--- SmartFires marks it dead, then invalidate scope so next read drops it.
---@return boolean ok  true when the node is gone from scope
function SFV2.OnNpcNodeKilled(callout, incidentId, nth)
    if not callout or incidentId == nil then return false end
    local scope = SFV2.GetCalloutScope(callout)
    if not scope then return false end

    -- Find row to damage by node key OR by host/nth.
    local key = nodeKey(incidentId, nth)
    local row
    for _, r in ipairs(scope.liveNodes) do
        if r.incidentId and tostring(r.incidentId) == tostring(incidentId)
            and tonumber(r.id) == tonumber(nth)
        then
            row = r
            break
        end
        if key and r.nodeKey == key then row = r; break end
    end

    if row and row.coords then
        SFV2.ApplyDamageAtCoords(row.coords, 4.0, 200.0, { creditSrc = 0 })
    elseif nth ~= nil then
        -- Fall back to relaying a single-node removal request.
        TriggerClientEvent(Config.EventPrefix .. ':sfRelayRemoveFireNode', -1, incidentId, tonumber(nth))
    end

    SFV2.InvalidateScope(callout)
    log('NPC_KILL', string.format('inc=%s nth=%s', tostring(incidentId), tostring(nth)))
    return true
end

--- Has the registered spawn id any live or pending row?
function SFV2.HasLiveContribution(spawnId)
    if spawnId == nil then return false end
    local key = tostring(spawnId)
    local ok, rows = pcall(function() return exports[SF_RES]:GetAllFires() end)
    if not ok or type(rows) ~= 'table' then return false end
    for _, row in ipairs(rows) do
        if row and row.coords and row.active ~= false then
            local host = row.incidentId and tostring(row.incidentId)
            local src = row.sourceIncidentId and tostring(row.sourceIncidentId)
            if host == key or src == key then return true end
        end
    end
    return false
end
