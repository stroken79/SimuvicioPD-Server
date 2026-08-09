-- Night ERS registers the stretcher interaction as the /vstretcher command.
-- Listen directly for H as a fallback when a player key mapping does not fire.
CreateThread(function()
    while true do
        Wait(0)

        if IsControlJustPressed(0, 74) or IsDisabledControlJustPressed(0, 74) then
            ExecuteCommand('vstretcher')
        end
    end
end)
