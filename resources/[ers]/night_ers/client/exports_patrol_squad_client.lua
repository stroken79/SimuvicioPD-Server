--====================== EXTERNAL: PATROL SQUAD (night_ers_ps) ======================--
-- Public client exports for third-party resources (primarily night_ers_ps person orders).
-- Requires night_ers as a dependency. Call from client scripts only.
--
-- ERS_ShowPedInventory(itemList)              — ERS frisk inventory NUI popup
-- ERS_FetchPedDataForExternal(netId, ped, ctx) — ped data + inventory (MDT-aware)
-- ERS_CuffSuspectAsNpcPedTowards(officer, suspect)
-- ERS_SetPedToSurrenderTowardsOfficerPed(suspect, officer, suppressNotify)
-- ERS_OrderPedToTheirKneesTowardsOfficer(officer, suspect)
-- ERS_RollInteractionFlee(ped, reason)        — reason: ERS_InteractionFleeReason value
-- ERS_SetPedToFleeFromPlayer(ped, suppressNotify)
-- ERS_ApplyAimOrderPreamble(suspectPed, suspectNetId) — clear tasks + block events before ceremony
-- ERS_SetPedToAttackPlayer(ped)               — suspect fights local player

exports('ERS_ShowPedInventory', function(itemList)
    ToggleInventoryDisplay(true, itemList)
end)

exports('ERS_FetchPedDataForExternal', function(pedNetId, pedEntity, context)
    return ERS_FetchPedDataWithMDT(pedNetId, pedEntity, nil, context or "on_ps_search")
end)

exports('ERS_CuffSuspectAsNpcPedTowards', function(officerPed, suspectPed)
    ERS_CuffSuspectAsNpcPedTowards(officerPed, suspectPed)
end)

exports('ERS_SetPedToSurrenderTowardsOfficerPed', function(suspectPed, officerPed, suppressNotify)
    ERS_SetPedToSurrenderTowardsOfficerPed(suspectPed, officerPed, suppressNotify)
end)

exports('ERS_OrderPedToTheirKneesTowardsOfficer', function(officerPed, suspectPed)
    return ERS_OrderPedToTheirKneesTowardsOfficer(officerPed, suspectPed)
end)

exports('ERS_RollInteractionFlee', function(pedEntityId, reason)
    return ERS_RollInteractionFlee(pedEntityId, reason)
end)

exports('ERS_SetPedToFleeFromPlayer', function(pedEntityId, suppressNotify)
    ERS_SetPedToFleeFromPlayer(pedEntityId, suppressNotify)
end)

exports('ERS_ApplyAimOrderPreamble', function(suspectPed, suspectNetId)
    return ERS_ApplyAimOrderPreamble(suspectPed, suspectNetId)
end)

exports('ERS_SetPedToAttackPlayer', function(pedEntityId)
    ERS_SetPedToAttackPlayer(pedEntityId)
end)
