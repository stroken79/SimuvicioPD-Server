local function getRank()
    local rank = lib.callback.await('smvlpd-ranks:server:getRank', false)
    if not rank or rank.service ~= Config.ServiceType then return nil end
    return tonumber(rank.id)
end

local function spawnVehicle(entry, garage)
    local model = entry.model
    if type(model) ~= 'string' or model == '' then return end
    local hash = joaat(model)
    if not IsModelInCdimage(hash) or not IsModelAVehicle(hash) then
        FireNotify(('El modelo "%s" no existe o no es un vehículo.'):format(model), 'error')
        return
    end

    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(0) end

    local spawn = garage.spawn
    if not IsAnyVehicleNearPoint(spawn.x, spawn.y, spawn.z, 3.0) then
        local vehicle = CreateVehicle(hash, spawn.x, spawn.y, spawn.z, spawn.w, true, false)
        SetVehicleOnGroundProperly(vehicle)
        if entry.livery ~= nil then SetVehicleLivery(vehicle, entry.livery) end
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
    else
        FireNotify('El punto de salida está ocupado.', 'error')
    end
    SetModelAsNoLongerNeeded(hash)
end

local function openGarage(garage)
    if not FireIsOnDuty() then
        FireNotify('Debes estar de servicio como Bombero.', 'error')
        return
    end

    local rankId = getRank()
    local vehicles = rankId and Config.VehiclesByRank[rankId] or nil
    if not vehicles or #vehicles == 0 then
        FireNotify('No tienes vehículos configurados para tu rango.', 'error')
        return
    end

    -- Vehículos especiales por estación. El GMC solo se añade en
    -- Paleto y Sandy Shores y únicamente desde rango 4 (Ingeniero).
    local extraByGarage = Config.GarageExtraVehicles
        and Config.GarageExtraVehicles[garage.name]
        and Config.GarageExtraVehicles[garage.name][rankId]

    local garageVehicles = {}
    for _, entry in ipairs(vehicles) do
        garageVehicles[#garageVehicles + 1] = entry
    end

    if extraByGarage then
        for _, entry in ipairs(extraByGarage) do
            garageVehicles[#garageVehicles + 1] = entry
        end
    end

    local options = {}
    for _, entry in ipairs(garageVehicles) do
        options[#options + 1] = {
            title = entry.label or entry.model,
            description = 'Sacar vehículo',
            icon = 'truck-fire',
            onSelect = function() spawnVehicle(entry, garage) end
        }
    end
    lib.registerContext({ id = 'smvlpd_fire_garage', title = ('Garaje de Bomberos - %s'):format(garage.name), options = options })
    lib.showContext('smvlpd_fire_garage')
end

CreateThread(function()
    for _, garage in ipairs(Config.Garages) do
        local garagePoint = lib.points.new({ coords = garage.marker, distance = Config.PointDrawDistance })
        function garagePoint:nearby()
            FireDrawGarageMarker(self.coords)
            if self.currentDistance < Config.InteractionDistance then
                lib.showTextUI(Config.Text.Garage)
                if IsControlJustReleased(0, 38) then openGarage(garage) end
            elseif lib.isTextUIOpen() then lib.hideTextUI() end
        end

        local storePoint = lib.points.new({ coords = garage.store, distance = Config.PointDrawDistance })
        function storePoint:nearby()
            FireDrawGarageMarker(self.coords)
            if self.currentDistance < Config.InteractionDistance then
                lib.showTextUI(Config.Text.Store)
                if IsControlJustReleased(0, 38) then
                    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
                    if vehicle == 0 then FireNotify('No estás dentro de ningún vehículo.', 'error') return end
                    TaskLeaveVehicle(PlayerPedId(), vehicle, 16)
                    Wait(500)
                    SetEntityAsMissionEntity(vehicle, true, true)
                    DeleteVehicle(vehicle)
                end
            elseif lib.isTextUIOpen() then lib.hideTextUI() end
        end
    end
end)
