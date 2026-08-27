local attachedVehicle = 0
local towVehicle = 0

local function notify(type, description)
    lib.notify({
        type = type,
        description = description
    })
end

local function getTowVehicle()
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then
        return 0
    end

    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 then
        return 0
    end

    local model = GetEntityModel(veh)
    for name, data in pairs(Config.TowVehicles) do
        if model == joaat(name) then
            return veh, name, data
        end
    end

    return 0
end

local function getClosestTarget(towVeh, maxDistance)
    local coords = GetEntityCoords(towVeh)
    local target = GetClosestVehicle(coords.x, coords.y, coords.z, maxDistance or Config.TargetDistance, 0, 70)

    if target == 0 or target == towVeh then
        return 0
    end

    if not DoesEntityExist(target) then
        return 0
    end

    -- No permitir remolcar otra grua autorizada.
    local targetModel = GetEntityModel(target)
    for name, _ in pairs(Config.TowVehicles) do
        if targetModel == joaat(name) then
            return 0
        end
    end

    -- Evitar enganchar vehiculos con ocupantes.
    local seats = GetVehicleModelNumberOfSeats(targetModel)
    for seat = -1, seats - 2 do
        if not IsVehicleSeatFree(target, seat) then
            return 0
        end
    end

    return target
end

local function detach()
    if towVehicle == 0 or not DoesEntityExist(towVehicle) then
        attachedVehicle = 0
        towVehicle = 0
        notify('error', 'No hay una grua activa.')
        return
    end

    if attachedVehicle ~= 0 and DoesEntityExist(attachedVehicle) then
        local wasT440 = GetEntityModel(towVehicle) == joaat('hvywrecker')

        DetachVehicleFromTowTruck(towVehicle, attachedVehicle)

        if wasT440 then
            SetEntityNoCollisionEntity(towVehicle, attachedVehicle, false)
            SetEntityNoCollisionEntity(attachedVehicle, towVehicle, false)
            SetVehicleCollision(towVehicle, true)
        end

        SetVehicleCollision(attachedVehicle, true)
        SetEntityCollision(attachedVehicle, true, true)
        notify('success', 'Vehiculo desenganchado.')
    else
        notify('inform', 'No hay ningun vehiculo enganchado.')
    end

    attachedVehicle = 0
end

local function attach()
    local veh, modelName, data = getTowVehicle()
    if veh == 0 then
        notify('error', 'Debes estar conduciendo una grua LSDOT autorizada.')
        return
    end

    towVehicle = veh

    if attachedVehicle ~= 0 and DoesEntityExist(attachedVehicle) then
        notify('inform', 'Ya tienes un vehiculo enganchado.')
        return
    end

    local target = getClosestTarget(veh, data.maxDistance)
    if target == 0 then
        notify('error', 'No hay ningun vehiculo remolcable suficientemente cerca.')
        return
    end

    if not NetworkHasControlOfEntity(target) then
        NetworkRequestControlOfEntity(target)
        local timeout = GetGameTimer() + 1500
        while not NetworkHasControlOfEntity(target) and GetGameTimer() < timeout do
            Wait(0)
            NetworkRequestControlOfEntity(target)
        end
    end

    -- El T440 tiene una estructura trasera que puede impedir que el vehiculo
    -- llegue fisicamente al punto de enganche. Para ESTE modelo solamente,
    -- desactivamos temporalmente la colision entre ambos vehiculos y dejamos
    -- que el native de tow coloque el objetivo en su punto de remolque.
    local isT440 = modelName == 'hvywrecker'

    if isT440 then
        SetEntityNoCollisionEntity(veh, target, true)
        SetEntityNoCollisionEntity(target, veh, true)
        SetVehicleCollision(veh, false)
        SetVehicleCollision(target, false)
        Wait(100)
    end

    AttachVehicleToTowTruck(veh, target, data.rear, 0.0, 0.0, 0.0)

    Wait(300)

    if isT440 then
        -- Mantenemos la no-colision mientras el vehiculo esta remolcado.
        SetEntityNoCollisionEntity(veh, target, true)
        SetEntityNoCollisionEntity(target, veh, true)
    end

    attachedVehicle = target
    notify('success', ('Vehiculo enganchado a %s.'):format(data.label))
end



local preparedT440 = {}

local function prepareT440(veh)
    if not Config.AutoPrepareT440 or veh == 0 then return end
    if GetEntityModel(veh) ~= joaat('hvywrecker') then return end
    if preparedT440[veh] then return end

    -- El carvariations del T440 referencia 0_default_no_lower.
    -- SetVehicleModKit(veh, 0) intenta dejar el vehículo en su kit base,
    -- sin forzar extras ni alterar el modelo.
    SetVehicleModKit(veh, 0)
    preparedT440[veh] = true
end

local function openMenu()
    local veh, _, data = getTowVehicle()
    if veh == 0 then
        notify('error', 'Debes estar conduciendo una grua LSDOT autorizada.')
        return
    end

    prepareT440(veh)

    local options = {
        {
            title = 'Enganchar vehiculo',
            description = 'Engancha el vehiculo mas cercano.',
            icon = 'truck-pickup',
            onSelect = attach
        },
        {
            title = 'Desenganchar vehiculo',
            description = 'Suelta el vehiculo actualmente remolcado.',
            icon = 'unlink',
            onSelect = detach
        }
    }

    lib.registerContext({
        id = 'smvlpd_tow_menu',
        title = '🚛 Grúa LSDOT',
        options = options
    })

    lib.showContext('smvlpd_tow_menu')
end

RegisterCommand('towmenu', openMenu, false)
RegisterKeyMapping('towmenu', 'Abrir menu de grua LSDOT', 'keyboard', Config.MenuKey)

RegisterCommand('towdetach', detach, false)
RegisterKeyMapping('towdetach', 'Desenganchar vehiculo LSDOT', 'keyboard', Config.DetachKey)

CreateThread(function()
    while true do
        Wait(1000)

        if towVehicle ~= 0 and not DoesEntityExist(towVehicle) then
            towVehicle = 0
            attachedVehicle = 0
        end

        local currentVeh = GetVehiclePedIsIn(PlayerPedId(), false)
        if currentVeh ~= 0 then
            prepareT440(currentVeh)
        end

        if attachedVehicle ~= 0 and not DoesEntityExist(attachedVehicle) then
            attachedVehicle = 0
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then
        return
    end

    if towVehicle ~= 0 and attachedVehicle ~= 0
        and DoesEntityExist(towVehicle)
        and DoesEntityExist(attachedVehicle) then
        DetachVehicleFromTowTruck(towVehicle, attachedVehicle)
    end
end)
