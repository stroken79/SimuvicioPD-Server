-- ============================================================================
--  SFV2.GetHudCounts — task UI numerator/denominator derived from scope only.
-- ============================================================================
--  HUD counts INCIDENTS (matches SmartFires blip granularity):
--
--      current  = distinct canonical fronts the player still has to fight
--                 (live hosts + spawn ids still 'active' per
--                 GetIncidentStatus, deduped through GetCanonicalIncidentId,
--                 plus one count per ambient `scope.vehicleFires` entry).
--                 This matches the visible SmartFires blip count one-to-one;
--                 a "pending" incident that has registered but not yet seeded
--                 its first flame still shows a blip and is still a front the
--                 player must clear, so it counts here.
--      pending  = scope.pendingSeeds (spawns active but no live node yet).
--                 Kept as a separate metric for completion bookkeeping and
--                 debug logs; it is a subset of `current`. Vehicle fires
--                 never sit in `pending` (SmartFires `StartVehicleFire`
--                 ignites them synchronously).
--      baseline = "fronts to fight", driven by the canonical-deduped spawn
--                 count via `SFV2.ResolveCanonicalIncidentId` plus the
--                 ambient vehicle-fire count. After the merge-settle window
--                 the baseline is locked against shrink by a monotonic peak
--                 so extinguishing fires doesn't move the goal posts.
--
--  Why a settle window?
--  --------------------
--  SmartFires takes a few seconds after CreateFire to decide which spawns
--  that ended up "on top of each other" should merge. During that transient
--  the canonical resolver returns each id as its own host (no merge yet) and
--  `pending` momentarily lists every freshly spawned id, so a naive peak over
--  `liveIncidents + pending` locks the baseline at the pre-merge spawn count
--  (e.g. 6 spawns -> 1 surviving merged incident still reports "1/6"). The
--  settle window lets the canonical count shrink as merges resolve; only
--  after the window do we start protecting the baseline against shrink.
--
--  Spread hosts (wind-jumped fronts discovered by `AppendSpreadHostsToCallout`)
--  get added to `sfAllSpawnIds`, canonicalize to themselves, and grow the
--  baseline normally regardless of which side of the window we're in.
--
--  NPC firefighters and players still fight every individual flame node (see
--  `SFV2.BuildNpcNodeTasks`); the HUD just clears one slot when the last node
--  of an incident dies, matching the disappearing blip.
-- ============================================================================

if not IsDuplicityVersion() then return end

SFV2 = SFV2 or {}

--- Floor for the merge-settle window (small scenes only need a few seconds
--- but we still want enough cushion for SmartFires to decide "Spawned on
--- top of each other" merges before locking the baseline).
local HUD_MERGE_SETTLE_FLOOR_MS = 25000

--- Padding added to (spawnCount × spawn-gap) when sizing the settle window
--- dynamically. Covers the last merge tick after the final spawn completes.
local HUD_MERGE_SETTLE_PADDING_MS = 8000

--- Mirrors `CREATE_MIN_GAP_MS` from v2/spawn.lua (and `V2_CREATE_MIN_GAP_MS`
--- in this file's bridge). Kept as a local constant so the HUD doesn't depend
--- on import order. If you tune the spawn gap, update this too.
local HUD_ASSUMED_SPAWN_GAP_MS = 600

local function settleWindowMs(spawnCount)
    spawnCount = tonumber(spawnCount) or 0
    return math.max(
        HUD_MERGE_SETTLE_FLOOR_MS,
        spawnCount * HUD_ASSUMED_SPAWN_GAP_MS + HUD_MERGE_SETTLE_PADDING_MS
    )
end

local function logHud(callout, current, pending, baseline, liveNodes, spawnN, canonical, liveHosts, vehFires, settling)
    if not (SFV2 and SFV2.IsDebug and SFV2.IsDebug()) then return end
    -- `current` is the HUD numerator (active canonical fronts == blip count).
    -- `liveHosts` is the subset that actually has flame nodes right now and is
    -- only logged for debug; the player sees and fights `current`. `vehFires`
    -- is the count of ambient SmartFires vehicle fires inside scene radius.
    print(string.format(
        '[ERS-SF] HUD callout=%s current=%d pending=%d baseline=%d (liveHosts=%d liveNodes=%d spawns=%d active=%d veh=%d%s)',
        tostring(callout and callout.calloutId),
        current, pending, baseline, liveHosts, liveNodes, spawnN, canonical, vehFires,
        settling and ' settling' or ''
    ))
end

--- Reset HUD state at attach time (called by `SFV2.AttachCallout`).
function SFV2.ResetHud(callout)
    if not callout then return end
    callout.sfFireHudCurrent = nil
    callout.sfFireHudBaseline = nil
    callout.sfFirePendingSeedTickets = nil
    callout.sfHudPeak = 0
    callout.sfHudAttachAt = GetGameTimer()
end

--- Compute the per-poll HUD counts. Updates callout fields in place so
--- `:updateCalloutUserInterface` reads consistent values.
---@return number current  live incident count (== visible blips)
---@return number baseline merge-aware peak (post-settle: monotonic)
---@return number pending  registered incidents not yet seeded
function SFV2.GetHudCounts(callout)
    if not callout then return 0, 0, 0 end

    local scope = SFV2.GetCalloutScope(callout)
    local liveIncidents = scope and #scope.hostIds or 0
    local liveNodes = scope and #scope.liveNodes or 0
    local pending = scope and scope.pendingSeeds or 0
    local spawnN = (scope and scope.spawnIds and #scope.spawnIds) or 0
    local vehicleFireN = (scope and scope.vehicleFires and #scope.vehicleFires) or 0

    -- "Active canonicals" = distinct fronts the player will actually fight.
    -- = distinct live hosts (already canonical by definition)
    --   + spawn ids that are still 'active' per GetIncidentStatus and not yet
    --     mapped onto a live host (resolved through GetCanonicalIncidentId so
    --     pre-merge transient pairs collapse correctly).
    --   + each ambient SmartFires vehicle fire (`scope.vehicleFires`) — those
    --     are a parallel track in SmartFires, do not appear in `GetAllFires`,
    --     and never merge, so each is its own canonical front.
    -- Particle-failed and merged-away ids return state != 'active' and drop
    -- out, which is exactly what we want — they never burned so the player
    -- should not see them on the HUD denominator.
    local activeCanonicals = 0
    local seen = {}
    if scope and scope.hostIds then
        for _, id in ipairs(scope.hostIds) do
            local k = tostring(id)
            if not seen[k] then
                seen[k] = true
                activeCanonicals = activeCanonicals + 1
            end
        end
    end
    if scope and scope.spawnIds then
        for _, id in ipairs(scope.spawnIds) do
            local canon = tostring(SFV2.ResolveCanonicalIncidentId(id) or id)
            if not seen[canon] then
                local ok, status = pcall(function()
                    return exports['SmartFires']:GetIncidentStatus(canon)
                end)
                if ok and type(status) == 'table' and status.state == 'active' then
                    seen[canon] = true
                    activeCanonicals = activeCanonicals + 1
                end
            end
        end
    end
    if scope and scope.vehicleFires then
        for _, vrow in ipairs(scope.vehicleFires) do
            local vkey = 'veh:' .. tostring(vrow.vehNet)
            if not seen[vkey] then
                seen[vkey] = true
                activeCanonicals = activeCanonicals + 1
            end
        end
    end

    -- Numerator = canonical active fronts (matches blips). Previously this was
    -- `liveIncidents` (hosts with live flame nodes), which produced "1/N" on
    -- the HUD while the player could still see N blips for incidents that had
    -- registered but lost their flame nodes (or hadn't seeded any yet).
    local current = activeCanonicals

    callout.sfHudAttachAt = callout.sfHudAttachAt or GetGameTimer()
    local elapsed = GetGameTimer() - callout.sfHudAttachAt
    local windowMs = settleWindowMs(spawnN)
    local settling = elapsed < windowMs

    local baseline
    if settling then
        -- Window: baseline tracks active canonicals without locking. As
        -- merges resolve and particle-failed spawns drop out, the count
        -- shrinks in step. Player driving to the scene typically arrives
        -- after this window so they never see the transient.
        baseline = math.max(activeCanonicals, current, 1)
        callout.sfHudPeak = baseline
    else
        -- Post-settle: protect against shrink. Extinguishing must not move
        -- the goal posts; new spread hosts still grow it via the
        -- AppendSpreadHostsToCallout path (canonical to themselves).
        local peak = math.max(tonumber(callout.sfHudPeak) or 0, activeCanonicals)
        callout.sfHudPeak = peak
        baseline = math.max(peak, 1)
    end

    callout.sfFireHudCurrent = current
    callout.sfFireHudBaseline = baseline
    callout.sfFirePendingSeedTickets = pending

    logHud(callout, current, pending, baseline, liveNodes, spawnN, activeCanonicals, liveIncidents, vehicleFireN, settling)
    return current, baseline, pending
end
