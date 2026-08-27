local contextId = 'smvlpd_boatgarage'

local function notify(message, notifyType)
    lib.notify({ description = message, type = notifyType or 'inform' })
end

local function drawMarker(coords)
    local marker = Config.Marker
    local color = marker.color
    local scale = marker.scale
    DrawMarker(marker.type, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        scale.x, scale.y, scale.z, color.r, color.g, color.b, color.a,
        false, false, 2, false, nil, nil, false)
end

local function getRank(serviceType)
    local rank = lib.callback.await('smvlpd-ranks:server:getRank', false)
    if not rank or rank.service ~= serviceType then return nil end
    return tonumber(rank.id)
end

local function getActiveService()
    if not exports['night_ers']:getIsPlayerOnShift() then
        notify('Debes estar de servicio para utilizar el garaje marítimo.', 'error')
        return nil
    end

    local serviceType = exports['night_ers']:getPlayerActiveServiceType()
    if not Config.ServiceLabels[serviceType] then
        notify('Tu servicio activo no tiene embarcaciones configuradas.', 'error')
        return nil
    end

    return serviceType
end

local function requestModel(hash)
    RequestModel(hash)
    local deadline = GetGameTimer() + Config.ModelLoadTimeout
    while not HasModelLoaded(hash) and GetGameTimer() < deadline do Wait(0) end
    return HasModelLoaded(hash)
end

local function spawnBoat(entry, garage)
    if type(entry.model) ~= 'string' or entry.model == '' then
        return notify('La embarcación no tiene un modelo configurado.', 'error')
    end

    local hash = joaat(entry.model)
    if not IsModelInCdimage(hash) or not IsModelAVehicle(hash) or not IsThisModelABoat(hash) then
        return notify(('El modelo "%s" no existe o no es una embarcación.'):format(entry.model), 'error')
    end

    local spawn = garage.spawn
    if IsAnyVehicleNearPoint(spawn.x, spawn.y, spawn.z, 3.0) then
        return notify('El punto de salida está ocupado.', 'error')
    end

    if not requestModel(hash) then
        SetModelAsNoLongerNeeded(hash)
        return notify(('No se pudo cargar el modelo "%s".'):format(entry.model), 'error')
    end

    local vehicle = CreateVehicle(hash, spawn.x, spawn.y, spawn.z, spawn.w, true, false)
    if vehicle == 0 then
        SetModelAsNoLongerNeeded(hash)
        return notify('No se pudo crear la embarcación.', 'error')
    end

    SetEntityAsMissionEntity(vehicle, true, true)
    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
    SetModelAsNoLongerNeeded(hash)
end

local function openGarage(garage)
    local serviceType = getActiveService()
    if not serviceType then return end

    local rankId = getRank(serviceType)
    if not rankId then
        return notify('No se pudo obtener tu rango para el servicio activo.', 'error')
    end

    local options = {}
    for _, entry in ipairs(Config.BoatVehicles[serviceType] or {}) do
        if rankId >= (tonumber(entry.minRank) or 1) then
            options[#options + 1] = {
                title = ('🚤 %s'):format(entry.label or entry.model),
                description = 'Sacar embarcación',
                icon = 'ship',
                onSelect = function() spawnBoat(entry, garage) end
            }
        end
    end

    if #options == 0 then
        return notify('No hay embarcaciones configuradas para tu rango.', 'error')
    end

    lib.registerContext({
        id = contextId,
        title = ('Garaje Marítimo - %s'):format(Config.ServiceLabels[serviceType]),
        options = options
    })
    lib.showContext(contextId)
end

local function storeBoat()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then return notify('No estás dentro de ninguna embarcación.', 'error') end
    if not IsThisModelABoat(GetEntityModel(vehicle)) then
        return notify('Solo puedes guardar embarcaciones aquí.', 'error')
    end

    TaskLeaveVehicle(PlayerPedId(), vehicle, 16)
    Wait(500)
    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)
end

CreateThread(function()
    for _, garage in ipairs(Config.BoatGarages) do
        local garagePoint = lib.points.new({ coords = garage.marker, distance = Config.PointDrawDistance })
        function garagePoint:nearby()
            drawMarker(self.coords)
            if self.currentDistance < Config.InteractionDistance then
                lib.showTextUI(Config.Text.Garage)
                if IsControlJustReleased(0, 38) then openGarage(garage) end
            elseif lib.isTextUIOpen() then
                lib.hideTextUI()
            end
        end

        local storePoint = lib.points.new({ coords = garage.store, distance = Config.PointDrawDistance })
        function storePoint:nearby()
            drawMarker(self.coords)
            if self.currentDistance < Config.InteractionDistance then
                lib.showTextUI(Config.Text.Store)
                if IsControlJustReleased(0, 38) then storeBoat() end
            elseif lib.isTextUIOpen() then
                lib.hideTextUI()
            end
        end
    end
end)
