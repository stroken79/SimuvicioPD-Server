local hoseEquipped = false

local function canUseHose(vehicle)
    return IsFirefighterOnDuty() and IsCompatibleFireVehicle(vehicle, 'hose')
end

local function getNearbyHoseVehicle()
    local ped = PlayerPedId()
    if IsPedInAnyVehicle(ped, false) then return nil end
    local coords = GetEntityCoords(ped)
    local vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, Config.InteractionDistance, 0, 70)
    return canUseHose(vehicle) and vehicle or nil
end

local function toggleHose(vehicle)
    if not canUseHose(vehicle) then
        NotifyFirefighter('Debes estar de servicio como Bombero junto a un vehiculo compatible.', 'error')
        return
    end

    ExecuteCommand(Config.SmartHoseCommand)
    hoseEquipped = not hoseEquipped
    FirefighterDebug(hoseEquipped and 'Manguera solicitada a SmartHoseLite.' or 'Manguera guardada.')
end

function IsFireHoseEquipped()
    return hoseEquipped or GetSelectedPedWeapon(PlayerPedId()) == Config.HoseWeapon
end

function StoreFireHose(silent)
    if not IsFireHoseEquipped() then return end
    ExecuteCommand(Config.SmartHoseCommand)
    hoseEquipped = false
    if not silent then NotifyFirefighter('Manguera guardada.', 'success') end
end

CreateThread(function()
    local models = {}
    for model, data in pairs(Config.FireVehicles) do
        if data.hose then models[#models + 1] = model end
    end

    exports.ox_target:addModel(models, {
        {
            name = 'smvlpd_firefighter_take_hose',
            icon = 'fas fa-fire-hose',
            label = 'Sacar manguera',
            distance = Config.InteractionDistance,
            canInteract = function(entity)
                return not IsFireHoseEquipped() and canUseHose(entity)
            end,
            onSelect = function(data) toggleHose(data.entity) end
        },
        {
            name = 'smvlpd_firefighter_store_hose',
            icon = 'fas fa-fire-extinguisher',
            label = 'Guardar manguera',
            distance = Config.InteractionDistance,
            canInteract = function(entity)
                return IsFireHoseEquipped() and canUseHose(entity)
            end,
            onSelect = function(data) StoreFireHose(false) end
        }
    })
end)

-- H is intentionally context-gated. ERS's stretcher fallback can still see
-- the same key, but its own ambulance-only checks remain responsible for EMS;
-- this handler only runs for an on-duty firefighter beside a hose vehicle.
CreateThread(function()
    while true do
        Wait(0)
        if (IsControlJustPressed(0, Config.HoseInteractionControl)
            or IsDisabledControlJustPressed(0, Config.HoseInteractionControl)) then
            local vehicle = getNearbyHoseVehicle()
            if vehicle then
                if IsFireHoseEquipped() then
                    StoreFireHose(false)
                else
                    toggleHose(vehicle)
                end
            end
        end
    end
end)

CreateThread(function()
    while true do
        Wait(1000)
        if IsFireHoseEquipped() and (not IsFirefighterOnDuty() or IsEntityDead(PlayerPedId())) then
            StoreFireHose(true)
        end
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then StoreFireHose(true) end
end)
