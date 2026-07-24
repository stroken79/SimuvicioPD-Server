local VALID_MODES = {
    open = true,
    ace = true,
    custom = true,
}

---@param source number
---@return boolean
function CustomCanUseBreathalyzer(source)
    -- Edit when Config.Permissions.Mode is 'custom'.
    -- Example (QBCore): return exports.qbx_core:GetPlayer(source)?.PlayerData.job.name == 'police'
    return false
end

function GetPermissionModeLabel()
    local mode = Config.Permissions.Mode

    if mode == 'ace' then
        return ('ACE (%s)'):format(Config.Permissions.AcePermission)
    end

    if mode == 'custom' then
        return 'Custom (server/permissions.lua)'
    end

    if mode == 'open' then
        return 'Open (everyone)'
    end

    return ('Unknown ("%s")'):format(tostring(mode))
end

---@param source number
---@return boolean
function CanUseBreathalyzer(source)
    local mode = Config.Permissions.Mode

    if not VALID_MODES[mode] then
        print(('[sstudios-breathalyzer] Invalid Permissions.Mode "%s", defaulting to open.'):format(tostring(mode)))
        return true
    end

    if mode == 'open' then
        return true
    end

    if mode == 'ace' then
        return IsPlayerAceAllowed(source, Config.Permissions.AcePermission)
    end

    return CustomCanUseBreathalyzer(source)
end

exports('CanUseBreathalyzer', CanUseBreathalyzer)
