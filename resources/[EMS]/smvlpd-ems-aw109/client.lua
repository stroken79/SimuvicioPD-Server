-- Fuerza permanentemente la livery 4 (aw109_sign_4) del AW109 EMS.
-- El índice de la livery 4 es 3 porque SetVehicleLivery utiliza índices desde 0.

local MODEL = joaat('aw109')
local LIVERY_INDEX = 3

local function forceAw109Livery(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return end
    if GetEntityModel(vehicle) ~= MODEL then return end

    -- Aplicamos la livery real del YTD: aw109_sign_4.
    SetVehicleLivery(vehicle, LIVERY_INDEX)

    -- Algunos vehículos importados exponen la livery como mod 48.
    -- Solo usamos este fallback si el native de livery no ha quedado aplicado.
    if GetVehicleLivery(vehicle) ~= LIVERY_INDEX then
        SetVehicleModKit(vehicle, 0)
        SetVehicleMod(vehicle, 48, LIVERY_INDEX, false)
    end
end

CreateThread(function()
    while true do
        Wait(500)

        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        if vehicle ~= 0 then
            forceAw109Livery(vehicle)
        end

        -- También fuerza la livery en AW109 cercanos, para que el vehículo
        -- aparezca correctamente incluso antes de que el jugador entre.
        local coords = GetEntityCoords(ped)
        local vehicles = GetGamePool('CVehicle')
        for _, veh in ipairs(vehicles) do
            if DoesEntityExist(veh) and #(GetEntityCoords(veh) - coords) < 120.0 then
                forceAw109Livery(veh)
            end
        end
    end
end)
