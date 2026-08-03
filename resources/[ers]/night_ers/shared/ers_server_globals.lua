-- Server-side shared state. Loaded from shared_scripts before any server/*.lua so early files
-- (leaderboard_server, pullover_server, etc.) never iterate nil globals when server.lua fails to load.
if not IsDuplicityVersion() then
    return
end

CalloutId = CalloutId or 0
ActiveCalloutsList = ActiveCalloutsList or {}
cageObjectList = cageObjectList or {}
interactionPedsList = interactionPedsList or {}
interactionVehiclesList = interactionVehiclesList or {}
PlayersOnShift = PlayersOnShift or {}
bodybagPropList = bodybagPropList or {}
