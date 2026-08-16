-- Funciones compartidas del recurso smvlpd-fire.
-- Se carga antes de service.lua, garage.lua y clothing.lua.

local function notify(message, notifyType)
    lib.notify({ description = message, type = notifyType or 'inform' })
end

function FireIsOnDuty()
    return exports['night_ers']:getIsPlayerOnShift() == true
        and exports['night_ers']:getPlayerActiveServiceType() == Config.ServiceType
end

function FireNotify(message, notifyType)
    notify(message, notifyType)
end

function FireDrawMarker(coords)
    DrawMarker(
        Config.Marker.type,
        coords.x, coords.y, coords.z + 0.10,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        Config.Marker.scale.x,
        Config.Marker.scale.y,
        Config.Marker.scale.z,
        Config.Marker.color.r,
        Config.Marker.color.g,
        Config.Marker.color.b,
        Config.Marker.color.a,
        false, true, 2, false, nil, nil, false
    )
end

function FireDrawGarageMarker(coords)
    DrawMarker(
        36,
        coords.x, coords.y, coords.z + 0.10,
        0.0, 0.0, 0.0,
        0.0, 0.0, 0.0,
        0.45, 0.45, 0.45,
        220, 45, 35, 190,
        false, true, 2, false, nil, nil, false
    )
end
