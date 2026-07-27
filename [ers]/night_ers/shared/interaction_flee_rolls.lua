-- Per-action NPC flee roll — shared constants and chance math (server + client).

ERS_InteractionFleeReason = {
    FirstInteraction = 'first_interaction',
    Warn             = 'warn',
    Fine             = 'fine',
    Search           = 'search',
    Breathalyzer     = 'breathalyzer',
    DrugTest         = 'drug_test',
    ExitVehicle      = 'exit_vehicle',
    AimOrder         = 'aim_order',
}

ERS_InteractionFleeMoodCategory = {
    normal   = 0,
    positive = -5,
    negative = 10,
    unusual  = 15,
}

ERS_InteractionFleeMoodState = {
    paranoid = 20,
}

ERS_InteractionFleeModifier = {
    Drunk            = 15,
    Drugged          = 15,
    IllegalItemEach  = 10,
}

ERS_InteractionFleeExitVehicleStylePercent = 50

local VALID_REASONS = {}
for _, reason in pairs(ERS_InteractionFleeReason) do
    VALID_REASONS[reason] = true
end

--- @param reason any
--- @return boolean
function ERS_InteractionFleeReasonIsValid(reason)
    return type(reason) == 'string' and VALID_REASONS[reason] == true
end

--- Radial interaction flee rolls (first E, warn, search, etc.) are police-only.
--- Callout/script flee uses ERS_SetPedToFleeFromPlayer separately.
--- @param serviceType string|nil
--- @return boolean
function ERS_ServiceAllowsInteractionFlee(serviceType)
    return serviceType == 'police'
end

--- @param inventory table|nil
--- @return number
function ERS_CountIllegalInventoryItems(inventory)
    local count = 0
    if type(inventory) ~= 'table' then
        return count
    end
    for _, item in pairs(inventory) do
        if type(item) == 'table' and item.illegal then
            count = count + 1
        end
    end
    return count
end

--- @param chance number
--- @return number
local function clampFleeChance(chance)
    if chance <= 0 then return 0 end
    if chance >= 100 then return 100 end
    return chance
end

--- @param pedEntry table|nil
--- @return number categoryMod, number stateMod
function ERS_ComputeInteractionFleeMoodModifiers(pedEntry)
    local categoryMod, stateMod = 0, 0
    if type(pedEntry) ~= 'table' then
        return categoryMod, stateMod
    end
    local behaviourState = pedEntry.BehaviourState
    if type(behaviourState) ~= 'table' then
        return categoryMod, stateMod
    end
    local category = behaviourState.category
    if type(category) == 'string' and ERS_InteractionFleeMoodCategory[category] ~= nil then
        categoryMod = ERS_InteractionFleeMoodCategory[category]
    end
    local state = behaviourState.state
    if type(state) == 'string' and ERS_InteractionFleeMoodState[state] ~= nil then
        stateMod = ERS_InteractionFleeMoodState[state]
    end
    return categoryMod, stateMod
end

--- Compute effective flee % for a ped entry and action reason.
--- @param pedEntry table|nil
--- @param reason string
--- @return number effectiveChance 0-100
--- @return boolean shouldSkipRoll when true, caller should not roll or store (e.g. sober breath test)
function ERS_ComputeInteractionFleeChance(pedEntry, reason)
    if not ERS_InteractionFleeReasonIsValid(reason) then
        return 0, true
    end

    if reason == ERS_InteractionFleeReason.Breathalyzer then
        if not pedEntry or not pedEntry.isDrunk then
            return 0, true
        end
    elseif reason == ERS_InteractionFleeReason.DrugTest then
        if not pedEntry or not pedEntry.isDrugged then
            return 0, true
        end
    end

    local base = tonumber(Config and Config.NPCChanceToFleeDuringInteraction) or 0
    local categoryMod, stateMod = ERS_ComputeInteractionFleeMoodModifiers(pedEntry)
    local extra = categoryMod + stateMod

    if reason == ERS_InteractionFleeReason.Breathalyzer then
        extra = extra + ERS_InteractionFleeModifier.Drunk
    elseif reason == ERS_InteractionFleeReason.DrugTest then
        extra = extra + ERS_InteractionFleeModifier.Drugged
    elseif reason == ERS_InteractionFleeReason.Search then
        extra = extra + (ERS_CountIllegalInventoryItems(pedEntry and pedEntry.Inventory) * ERS_InteractionFleeModifier.IllegalItemEach)
    end

    return clampFleeChance(base + extra), false
end

--- @param effectiveChance number
--- @return boolean
function ERS_RollInteractionFleePercent(effectiveChance)
    local chance = clampFleeChance(tonumber(effectiveChance) or 0)
    if chance <= 0 then return false end
    if chance >= 100 then return true end
    return math.random(1, 100) <= chance
end

--- True when interaction flee rolls must not run (surrendered this encounter or live surrender posture).
--- Reads state bags + list mirror only — not legacy decors.
--- @param entry table|nil interactionPedsList row or client pedData mirror
--- @param entityHandle number entity handle (0 to skip live bag read)
--- @return boolean
function ERS_PedShouldSkipFleeRoll(entry, entityHandle)
    local ent = tonumber(entityHandle) or 0
    if ent ~= 0 and DoesEntityExist(ent) then
        local state = Entity(ent).state
        if state[ERS_PedStateBagKeys.HasSurrendered] == true then
            return true
        end
        local base = state[ERS_PedStateBagKeys.Base]
        if type(base) == 'table' and ERS_PedBaseKindIsSurrenderPosture(base.kind) then
            return true
        end
    end
    if type(entry) == 'table' then
        if entry.HasSurrenderedThisEncounter == true then
            return true
        end
        if type(entry.PedBaseState) == 'table'
            and ERS_PedBaseKindIsSurrenderPosture(entry.PedBaseState.kind) then
            return true
        end
    end
    return false
end

--- @return string "in_vehicle"|"on_foot"
function ERS_PickExitVehicleFleeStyle()
    local pct = ERS_InteractionFleeExitVehicleStylePercent or 50
    pct = math.max(0, math.min(100, pct))
    if pct <= 0 then return 'on_foot' end
    if pct >= 100 then return 'in_vehicle' end
    if math.random(1, 100) <= pct then
        return 'in_vehicle'
    end
    return 'on_foot'
end
