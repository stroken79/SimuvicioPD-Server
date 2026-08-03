Config = Config or {}

function GetRankWeapons(rankId)
    return Config.Weapons[rankId] or {}
end

function GetRankVehicles(rankId)
    return Config.Vehicles[rankId] or {}
end

function HasWeaponAccess(rankId, weapon)
    local weapons = GetRankWeapons(rankId)

    weapon = string.lower(weapon)

    for _, w in ipairs(weapons) do
        if w == "ALL" then
            return true
        end

        if string.lower(w) == weapon then
            return true
        end
    end

    return false
end

function HasVehicleAccess(rankId, vehicle)
    local vehicles = GetRankVehicles(rankId)

    for _, v in ipairs(vehicles) do
        if v == "ALL" or v == vehicle then
            return true
        end
    end

    return false
end
function ExportHasWeaponAccess(rankId, weapon)
    return HasWeaponAccess(rankId, weapon)
end
function ExportHasVehicleAccess(rankId, vehicle)
    return HasVehicleAccess(rankId, vehicle)
end