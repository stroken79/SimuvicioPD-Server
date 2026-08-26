local function getRank()
    local rank = lib.callback.await('smvlpd-ranks:server:getRank', false)
    if not rank or rank.service ~= Config.ServiceType then return nil end
    return tonumber(rank.id)
end

local function spawnVehicle(entry, garage)
    local hash = joaat(entry.model)
    if not IsModelInCdimage(hash) or not IsModelAVehicle(hash) then
        return LsdotNotify(('El modelo "%s" no existe o no es un vehiculo.'):format(entry.model), 'error')
    end

    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(0) end
    local spawn = garage.spawn
    if IsAnyVehicleNearPoint(spawn.x, spawn.y, spawn.z, 3.0) then
        SetModelAsNoLongerNeeded(hash)
        return LsdotNotify('El punto de salida esta ocupado.', 'error')
    end

    local vehicle = CreateVehicle(hash, spawn.x, spawn.y, spawn.z, spawn.w, true, false)
    SetVehicleOnGroundProperly(vehicle)
    if entry.livery ~= nil then SetVehicleLivery(vehicle, entry.livery) end
    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
    SetModelAsNoLongerNeeded(hash)
end

local function openGarage(garage)
    if not LsdotIsOnDuty() then return LsdotNotify('Debes estar de servicio como LSDOT - Grúa.', 'error') end
    local rankId = getRank()
    local vehicles = rankId and Config.VehiclesByRank[rankId] or nil
    if not vehicles or #vehicles == 0 then return LsdotNotify('No hay vehiculos LSDOT configurados para tu rango.', 'error') end

    local options = {}
    for _, entry in ipairs(vehicles) do
        options[#options + 1] = {
            title = entry.label or entry.model,
            description = 'Sacar vehiculo LSDOT',
            icon = 'truck',
            onSelect = function() spawnVehicle(entry, garage) end
        }
    end
    lib.registerContext({ id = 'smvlpd_lsdot_garage', title = ('Garaje LSDOT - %s'):format(garage.name), options = options })
    lib.showContext('smvlpd_lsdot_garage')
end

CreateThread(function()
    for _, garage in ipairs(Config.Garages) do
        local garagePoint = lib.points.new({ coords = garage.marker, distance = Config.PointDrawDistance })
        function garagePoint:nearby()
            LsdotDrawMarker(self.coords, 36)
            if self.currentDistance < Config.InteractionDistance then
                lib.showTextUI(Config.Text.Garage)
                if IsControlJustReleased(0, 38) then openGarage(garage) end
            elseif lib.isTextUIOpen() then lib.hideTextUI() end
        end

        local storePoint = lib.points.new({ coords = garage.store, distance = Config.PointDrawDistance })
        function storePoint:nearby()
            LsdotDrawMarker(self.coords, 36)
            if self.currentDistance < Config.InteractionDistance then
                lib.showTextUI(Config.Text.Store)
                if IsControlJustReleased(0, 38) then
                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                    if vehicle == 0 then return LsdotNotify('No estas dentro de ningun vehiculo.', 'error') end
                    TaskLeaveVehicle(PlayerPedId(), vehicle, 16)
                    Wait(500)
                    SetEntityAsMissionEntity(vehicle, true, true)
                    DeleteVehicle(vehicle)
                end
            elseif lib.isTextUIOpen() then lib.hideTextUI() end
        end
    end
end)
