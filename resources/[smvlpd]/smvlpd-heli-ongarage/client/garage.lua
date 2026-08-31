local contextId = 'smvlpd_heli_ongarage'

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
        notify('Debes estar de servicio para utilizar el garaje de helicópteros.', 'error')
        return nil
    end

    local serviceType = exports['night_ers']:getPlayerActiveServiceType()
    if not Config.ServiceLabels[serviceType] then
        notify('Tu servicio activo no tiene helicópteros configurados.', 'error')
        return nil
    end

    return serviceType
end

local function requestModel(hash)
    RequestModel(hash)

    local deadline = GetGameTimer() + Config.ModelLoadTimeout
    while not HasModelLoaded(hash) and GetGameTimer() < deadline do
        Wait(0)
    end

    return HasModelLoaded(hash)
end

local function applyColor(vehicle, color)
    if type(color) ~= 'table' then return end
    if type(color.r) ~= 'number' or type(color.g) ~= 'number' or type(color.b) ~= 'number' then return end

    SetVehicleCustomPrimaryColour(vehicle, color.r, color.g, color.b)
    SetVehicleCustomSecondaryColour(vehicle, color.r, color.g, color.b)
end

local function spawnHelicopter(entry, garage)
    if type(entry.model) ~= 'string' or entry.model == '' then
        return notify('El helicóptero no tiene un modelo configurado.', 'error')
    end

    local hash = joaat(entry.model)
    if not IsModelInCdimage(hash) or not IsModelAVehicle(hash) or not IsThisModelAHeli(hash) then
        return notify(('El modelo "%s" no existe o no es un helicóptero.'):format(entry.model), 'error')
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
        return notify('No se pudo crear el helicóptero.', 'error')
    end

    SetEntityAsMissionEntity(vehicle, true, true)
    applyColor(vehicle, entry.color)
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
    for _, entry in ipairs(Config.HeliVehicles[serviceType] or {}) do
        if rankId >= (tonumber(entry.minRank) or 1) then
            options[#options + 1] = {
                title = ('🚁 %s'):format(entry.label or entry.model),
                description = 'Sacar helicóptero',
                icon = 'helicopter',
                onSelect = function()
                    spawnHelicopter(entry, garage)
                end
            }
        end
    end

    if #options == 0 then
        return notify('No hay helicópteros configurados para tu rango.', 'error')
    end

    lib.registerContext({
        id = contextId,
        title = ('Garaje de Helicópteros - %s'):format(Config.ServiceLabels[serviceType]),
        options = options
    })
    lib.showContext(contextId)
end

local function isAllowedHelicopter(model)
    for _, vehicles in pairs(Config.HeliVehicles) do
        for _, entry in ipairs(vehicles) do
            if type(entry.model) == 'string' and joaat(entry.model) == model then
                return true
            end
        end
    end

    return false
end

local function storeHelicopter()
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if vehicle == 0 then
        return notify('No estás dentro de ningún helicóptero.', 'error')
    end

    local model = GetEntityModel(vehicle)
    local service = getCurrentService()
    local rank = getPlayerRank()
    if not service or (service ~= 'police' and service ~= 'ambulance') then
        return notify('Debes estar de servicio como LSPD o EMS.', 'error')
    end

    local allowed, minRank = isAllowedHelicopterForService(model, service)
    if not allowed then
        return notify('Este helicóptero no está autorizado para tu servicio.', 'error')
    end

    if rank < minRank then
        return notify('No tienes rango suficiente para guardar este helicóptero.', 'error')
    end
    if not IsThisModelAHeli(model) then
        return notify('Solo puedes guardar helicópteros aquí.', 'error')
    end

    if not isAllowedHelicopter(model) then
        return notify('Este helicóptero no está permitido en este garaje.', 'error')
    end

    TaskLeaveVehicle(PlayerPedId(), vehicle, 16)
    Wait(500)
    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)
end
end

local function horizontalDistance(a, b)
    local x = a.x - b.x
    local y = a.y - b.y
    return math.sqrt(x * x + y * y)
end

CreateThread(function()
    for _, garage in ipairs(Config.HeliGarages) do
        local garagePoint = lib.points.new({ coords = garage.marker, distance = Config.PointDrawDistance })
        function garagePoint:nearby()
            drawMarker(self.coords)
            if self.currentDistance < Config.InteractionDistance then
                lib.showTextUI(Config.Text.Garage)
                if IsControlJustReleased(0, 38) then
                    openGarage(garage)
                end
            elseif lib.isTextUIOpen() then
                lib.hideTextUI()
            end
        end

        local storePoint = lib.points.new({ coords = garage.store, distance = Config.PointDrawDistance })
        function storePoint:nearby()
            drawMarker(self.coords)
            if horizontalDistance(GetEntityCoords(PlayerPedId()), self.coords) < Config.StoreInteractionDistance then
                lib.showTextUI(Config.Text.Store)
                if IsControlJustReleased(0, 38) then
                    storeHelicopter()
                end
            elseif lib.isTextUIOpen() then
                lib.hideTextUI()
            end
        end
    end
end)
