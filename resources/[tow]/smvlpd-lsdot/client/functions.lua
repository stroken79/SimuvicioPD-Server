function LsdotIsOnDuty()
    return exports['night_ers']:getIsPlayerOnShift() == true
        and exports['night_ers']:getPlayerActiveServiceType() == Config.ServiceType
end

function LsdotNotify(message, notifyType)
    lib.notify({ description = message, type = notifyType or 'inform' })
end

function LsdotDrawMarker(coords, markerType)
    DrawMarker(
        markerType or Config.Marker.type,
        coords.x, coords.y, coords.z + 0.10,
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        Config.Marker.scale.x, Config.Marker.scale.y, Config.Marker.scale.z,
        Config.Marker.color.r, Config.Marker.color.g, Config.Marker.color.b, Config.Marker.color.a,
        false, true, 2, false, nil, nil, false
    )
end
