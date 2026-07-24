function ServerEvent(name)
    return ('%s:server:%s'):format(GetCurrentResourceName(), name)
end

function ClientEvent(name)
    return ('%s:client:%s'):format(GetCurrentResourceName(), name)
end
