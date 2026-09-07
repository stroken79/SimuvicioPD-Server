CreateThread(function()
    local blips = {
        { name = 'Embarcadero  - Los Santos', coords = vec3(-1793.0677, -1198.0619, 13.0174) },
        { name = 'Embarcadero  - Paleto Bay', coords = vec3(-188.3088, 6549.5571, 11.0978) },
		{ name = 'Embarcadero  - Base Maritima', coords = vec3(-760.0477, -1514.2179, 4.9751) },
    }

    for _, data in ipairs(blips) do
        local blip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
        SetBlipSprite(blip, 427)
        SetBlipColour(blip, 3)
        SetBlipScale(blip, 0.75)
        SetBlipAsShortRange(blip, true)

        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(data.name)
        EndTextCommandSetBlipName(blip)
    end
end)
