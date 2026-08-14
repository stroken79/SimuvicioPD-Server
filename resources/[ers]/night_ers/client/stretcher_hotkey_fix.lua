-- Night ERS registers the stretcher interaction as the /vstretcher command.
-- Listen directly for H as a fallback when a player key mapping does not fire.
CreateThread(function()
    while true do
        Wait(0)

        -- Firefighters use H for the hose integration. Do not dispatch the
        -- ambulance stretcher command in that service context.
        local isFirefighter = exports['night_ers']:getIsPlayerOnShift()
            and exports['night_ers']:getPlayerActiveServiceType() == 'fire'
        if not isFirefighter and (IsControlJustPressed(0, 74) or IsDisabledControlJustPressed(0, 74)) then
            ExecuteCommand('vstretcher')
        end
    end
end)
