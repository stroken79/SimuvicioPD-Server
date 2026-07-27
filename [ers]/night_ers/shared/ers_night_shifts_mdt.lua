function ERS_IsNightShiftsMDTResourceStarted()
    return GetResourceState('night_shifts_mdt') == 'started'
end

function ERS_IsNightShiftsMDTActive()
    return Config.Enable_Night_Shifts.UseNightShiftsMDT and ERS_IsNightShiftsMDTResourceStarted()
end

function ERS_IsNightShiftsSendCalloutsToMDTActive()
    return Config.Enable_Night_Shifts.SendCalloutsToMDT and ERS_IsNightShiftsMDTResourceStarted()
end

function ERS_IsNightShiftsSendPulloversToMDTActive()
    return Config.Enable_Night_Shifts.SendPulloversToMDT and ERS_IsNightShiftsMDTResourceStarted()
end

function ERS_IsNightShiftsManageShiftsByMDTActive()
    return Config.Enable_Night_Shifts.ManageShiftsByMDT and ERS_IsNightShiftsMDTResourceStarted()
end

-- ===== Version helpers ======================================================
-- Lets ERS guard new MDT exports behind a minimum night_shifts_mdt build, so
-- servers running an outdated MDT see a clear "you need to update" line in
-- the console instead of a silent no-op (or a hard crash on a missing export).

--- Returns the version string from night_shifts_mdt's fxmanifest, or nil if
--- the resource isn't installed / metadata can't be read.
--- @return string|nil
function ERS_GetNightShiftsMDTResourceVersion()
    local ok, v = pcall(GetResourceMetadata, 'night_shifts_mdt', 'version', 0)
    if not ok then return nil end
    if type(v) ~= 'string' or v == '' then return nil end
    return v
end

--- Compares two dotted version strings (e.g. "1.4.1" vs "1.4.0"). Non-numeric
--- segments are ignored — we only consider the numeric components in order.
--- Returns true when `actual` >= `minimum`. Missing trailing components are
--- treated as 0 (so "1.4" >= "1.4.0").
--- @param actual  string
--- @param minimum string
--- @return boolean
local function versionAtLeast(actual, minimum)
    local function parts(v)
        local out = {}
        for n in tostring(v or ''):gmatch('(%d+)') do
            out[#out + 1] = tonumber(n)
        end
        return out
    end
    local a, m = parts(actual), parts(minimum)
    for i = 1, math.max(#a, #m) do
        local av, mv = a[i] or 0, m[i] or 0
        if av > mv then return true end
        if av < mv then return false end
    end
    return true
end

--- Returns true when the installed night_shifts_mdt is >= `minVersion`.
--- When the resource isn't installed / version unreadable, returns false.
--- @param minVersion string e.g. "1.4.1"
--- @return boolean
function ERS_IsNightShiftsMDTVersionAtLeast(minVersion)
    local v = ERS_GetNightShiftsMDTResourceVersion()
    if not v then return false end
    return versionAtLeast(v, minVersion)
end
