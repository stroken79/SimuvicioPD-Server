-- ============================================================================
--  SFV2 client net event handlers.
-- ============================================================================
--  `sfv2_calloutScope` — server pushes the canonical callout list with the
--  per-callout `sfAllSpawnIds`/`sfSpawnCoordsById` registries populated. We
--  just refresh the local mirror so HUD / NPC code reads the same shape.
-- ============================================================================

if IsDuplicityVersion() then return end

SFV2 = SFV2 or {}

RegisterNetEvent(Config.EventPrefix .. ':sfv2_calloutScope')
AddEventHandler(Config.EventPrefix .. ':sfv2_calloutScope', function(calloutList)
    if type(calloutList) ~= 'table' then return end
    ActiveCalloutsList_client = calloutList
end)
