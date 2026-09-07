CreateThread(function()
    local blips = {
        { name = 'Helipuerto LSPD - Mission Row', coords = vec3(458.1299, -985.6751, 30.6896) },
        { name = 'Helipuerto LSPD - Vespucci', coords = vec3(-1106.9956, -847.1813, 19.3169) },
        { name = 'Helipuerto LSPD - Vinewood', coords = vec3(644.5487, 10.6659, 82.7865) },
        { name = 'Helipuerto LSPD - Base Aérea', coords = vec3(-741.1767, -1505.2854, 5.0005) },
        { name = 'Helipuerto LSPD - Aeropuerto', coords = vec3(-1147.5956, -2826.5093, 13.9644) },
        { name = 'Helipuerto LSPD - Paleto Bay', coords = vec3(-452.1511, 6005.8232, 31.8409) },
        { name = 'Helipuerto LSPD - Sandy Shores', coords = vec3(1758.5129, 3298.0505, 41.1517) },
        { name = 'Helipuerto EMS - Pillbox', coords = vec3(319.2629, -573.5031, 43.3174) },
        { name = 'Helipuerto EMS - Davis', coords = vec3(293.7164, -1447.6224, 29.9666) },
    }

    for _, data in ipairs(blips) do
        local blip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
        SetBlipSprite(blip, 43)
        SetBlipColour(blip, 3)
        SetBlipScale(blip, 0.75)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(data.name)
        EndTextCommandSetBlipName(blip)
    end
end)
