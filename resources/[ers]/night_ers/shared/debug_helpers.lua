-- Internal-only verbose trace toggle. Hardcoded; do not expose via config.lua.
-- Flip to true in source when actively debugging high-volume logs (75m queues,
-- callout JSON dumps, entity-load waits, Smart Fires HUD ticks, etc.).
-- Requires Config.Debug = true to take effect.
local INTERNAL_DEBUG_VERBOSE = false

--- True when periodic / high-volume trace logging is allowed (F8 stays readable with Debug alone).
function ERS_IsDebugVerbose()
    if INTERNAL_DEBUG_VERBOSE ~= true then
        return false
    end
    return type(Config) == 'table' and Config.Debug == true
end
