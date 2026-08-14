-- ERS stores SmartFires ids in each callout's fireList/smokeList and polls
-- their active state. Stopping only confirmed SmartFiresLite ids therefore
-- updates the existing ERS objectives without modifying night_ers.

RegisterNetEvent('smvlpd-firefighter:client:extinguished', function(kind, count)
    FirefighterDebug(('%s extinguished targets: %s'):format(kind, count))
end)

-- ERS's person/vehicle/animal fire callouts use the GTA native
-- StartEntityFire rather than SmartFiresLite. The entity is networked by ERS,
-- so every client removes the same native fire once the server confirms the
-- continuous water exposure.
RegisterNetEvent('smvlpd-firefighter:client:stopEntityFire', function(netId)
    local entity = NetToEnt(netId)
    if entity ~= 0 and DoesEntityExist(entity) then
        StopEntityFire(entity)
        FirefighterDebug(('Native entity fire stopped for net id %s.'):format(netId))
    end
end)
