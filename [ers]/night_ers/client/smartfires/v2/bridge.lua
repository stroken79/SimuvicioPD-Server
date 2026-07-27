-- ============================================================================
--  SFV2 client bridge — version detection + active flag for the contract.
-- ============================================================================
--  Listens for the server's `syncSmartFiresIntegrationFlags` event and sets
--  `SFV2._active` so `SFV2.IsActive()` is true on v2 sessions only. Phase 4
--  call-sites in `client.lua` and `npcbackup_client.lua` switch on this.
-- ============================================================================

if IsDuplicityVersion() then return end

SFV2 = SFV2 or {}

RegisterNetEvent(Config.EventPrefix .. ':syncSmartFiresIntegrationFlags')
AddEventHandler(Config.EventPrefix .. ':syncSmartFiresIntegrationFlags', function(v2, full, lite)
    SFV2._setActive(v2 == true)
end)

--- Convar fallback so early callers don't get a false negative before the
--- first server sync arrives.
Citizen.CreateThread(function()
    local v = GetConvar('SmartFiresV2', 'false')
    if type(v) == 'string' then
        v = string.lower(v:gsub('^%s+', ''):gsub('%s+$', ''))
        if v == 'true' or v == '1' or v == 'yes' then
            SFV2._setActive(true)
        end
    end
end)
