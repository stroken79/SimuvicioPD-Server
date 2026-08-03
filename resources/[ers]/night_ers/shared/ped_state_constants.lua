--====================== PED STATE MANAGER — SHARED CONSTANTS ======================--
--
-- Canonical "base state" enum + state-bag key names used by both the server-side
-- writer (`server/ped_state_manager.lua`) and the client-side wrapper / watchdog
-- (`client/ped_state_manager.lua`).
--
-- The base state is the *persistent posture* a ped should hold between
-- interactions: cuffed standing, kneeling, attached for escort, in a back seat,
-- etc. It lives on the ped's state bag (entity-scoped, replicated, survives
-- ownership migration) so any client that becomes the owner of a tracked ped
-- can read the bag and re-apply the matching task tree without depending on a
-- broadcast having landed.
--
-- Decors registered in `client/client.lua` (PED_IS_CUFFED etc.) stay readable
-- for backward-compat consumers (callout packs, MDT, third-party plugins). The
-- client manager mirrors `ers:base` → decor on every change, so existing decor
-- readers keep working without source edits.

--- Base-state enum. Stringly-typed on purpose — state bags serialise table
--- values fine, but a flat string keeps the bag payload tiny and prevents
--- accidental "value drift" (e.g. nested struct version mismatches between
--- server / client builds during a rolling restart).
ERS_PedBaseState = {
    Free          = 'free',          -- Ambient / wander; watchdog does not enforce.
    Waiting       = 'waiting',       -- Just standing on the spot facing the officer (e.g. asked to wait, ID stop).
    HandsUp       = 'handsUp',       -- TaskHandsUp facing officer (e.g. handsupped, mid-search).
    Kneeling      = 'kneeling',      -- random@arrests@busted/idle_a kneel pose facing officer.
    Detained      = 'handsUp',       -- Legacy alias for HandsUp; kept so old callers keep working.
    Cuffed        = 'cuffed',        -- Standing cuffed (mp_arresting/idle + cuff config flags).
    Escorted      = 'escorted',      -- Cuffed + attached to officer, walking/running with them.
    Dragged       = 'dragged',       -- Medical drag (combat@drag_ped@ + bone 11816 attach).
    Following     = 'following',     -- TaskFollowToOffsetOfEntity to officer.
    VehDriver     = 'vehDriver',     -- Seated as driver (post-pullover).
    VehPassenger  = 'vehPassenger',  -- Seated as passenger (post put-in-vehicle).
    Frisked       = 'handsUp',       -- Legacy alias for HandsUp; the search ceremony is on the officer side.
    Busy          = 'busy',          -- Interaction in progress; watchdog backs off.
}

--- State-bag keys on the ped entity. Always written by the server; clients
--- read-only. See server/ped_state_manager.lua for the write event contract.
ERS_PedStateBagKeys = {
    Base           = 'ers:base',           -- { kind, since, byNetId, payload }
    Lock           = 'ers:lock',           -- { ownerSrc } (interaction in progress; expiry tracked server-side)
    FleeRolls      = 'ers:fleeRolls',      -- per-action flee roll cache (see shared/interaction_flee_rolls.lua)
    HasSurrendered = 'ers:hasSurrendered', -- boolean; true once ped surrendered this encounter (server write-only)
}

--- Per-kind decor mirror map. The client manager uses this on every state-bag
--- change to keep the legacy `PED_IS_*` decors in sync with the canonical
--- `ers:base`. Anything not in this map drops to 0 on a transition (i.e. a
--- ped that goes from `cuffed` to `free` will have `PED_IS_CUFFED` cleared).
---
--- Each entry is `{ decorKey = intValue }`. Multiple decors per kind are
--- supported (see `escorted` carrying both `PED_IS_CUFFED` and `PLAYER_ESCORT`).
-- Note: keys are stringly-typed kind values (not the enum *labels*), so
-- aliased entries like `Detained = 'handsUp'` resolve to the same row as
-- `HandsUp = 'handsUp'` and don't need duplicating.
ERS_PedStateLegacyDecors = {
    [ERS_PedBaseState.Free]         = {},
    [ERS_PedBaseState.Waiting]      = {}, -- no surrender flag; ped is just standing
    [ERS_PedBaseState.HandsUp]      = { PED_IS_SURRENDERING = 1 },
    [ERS_PedBaseState.Kneeling]     = { PED_IS_SURRENDERING = 1 },
    [ERS_PedBaseState.Cuffed]       = { PED_IS_CUFFED = 1, PED_IS_SURRENDERING = 1 },
    [ERS_PedBaseState.Escorted]     = { PED_IS_CUFFED = 1, PED_IS_SURRENDERING = 1, PLAYER_ESCORT = 1 },
    [ERS_PedBaseState.Dragged]      = { PLAYER_ESCORT = 1 },
    [ERS_PedBaseState.Following]    = { PED_IS_FOLLOWING = 1 },
    [ERS_PedBaseState.VehDriver]    = {},
    [ERS_PedBaseState.VehPassenger] = {},
    [ERS_PedBaseState.Busy]         = {}, -- decors untouched; previous decor wins
}

--- Decor keys the manager owns and may reset on a state transition. We do NOT
--- touch `PED_IS_FLEEING` (state machine for flee/pursuit lives in pursuit code)
--- or `PED_IS_INTERACTING` (radial menu open/close gate, unrelated to base state).
ERS_PedStateManagedDecors = {
    'PED_IS_CUFFED',
    'PED_IS_SURRENDERING',
    'PED_IS_FOLLOWING',
    'PLAYER_ESCORT',
}

--- Returns true when `kind` is a recognised `ERS_PedBaseState` value. Used to
--- gate server-side writes against malformed / spoofed client requests.
--- @param kind any
--- @return boolean
function ERS_PedStateIsValidKind(kind)
    if type(kind) ~= 'string' then return false end
    for _, v in pairs(ERS_PedBaseState) do
        if v == kind then return true end
    end
    return false
end

--- Returns true when this kind represents a posture the watchdog should
--- actively enforce. `free` and `busy` are intentionally excluded — `free`
--- means "let ambient AI run", `busy` means "an interaction is mid-flight".
--- @param kind string
--- @return boolean
function ERS_PedStateIsEnforced(kind)
    return kind ~= nil
        and kind ~= ERS_PedBaseState.Free
        and kind ~= ERS_PedBaseState.Busy
end

--- Returns true when `kind` is a posture that counts as surrendered (hands up, kneel, cuffed, escorted).
--- @param kind any
--- @return boolean
function ERS_PedBaseKindIsSurrenderPosture(kind)
    return kind == ERS_PedBaseState.HandsUp
        or kind == ERS_PedBaseState.Kneeling
        or kind == ERS_PedBaseState.Cuffed
        or kind == ERS_PedBaseState.Escorted
end
