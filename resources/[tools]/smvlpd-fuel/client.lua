local refueling = false
local fuelCache = {}

-- Crea los blips de todas las gasolineras configuradas.
CreateThread(function()
    if not Config.ShowGasStationBlips then return end

    for _, station in ipairs(Config.GasStations) do
        local blip = AddBlipForCoord(station.x, station.y, station.z)
        SetBlipSprite(blip, Config.GasStationBlip.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, Config.GasStationBlip.scale)
        SetBlipColour(blip, Config.GasStationBlip.color)
        SetBlipAsShortRange(blip, Config.GasStationBlip.shortRange)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(Config.GasStationBlip.name)
        EndTextCommandSetBlipName(blip)
    end
end)

local function Notify(msg)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandThefeedPostTicker(false, false)
end

local function IsEmergencyVehicle(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return false end

    local model = string.lower(GetDisplayNameFromVehicleModel(GetEntityModel(vehicle)) or '')
    for _, allowed in ipairs(Config.EmergencyModels) do
        if model == string.lower(allowed) then
            return true
        end
    end

    return false
end

local function GetEmergencyService()
    if not Config.RequireEmergencyDuty then return true, nil end
    if GetResourceState('night_ers') ~= 'started' then return false, nil end

    local ok, onDuty, service = pcall(function()
        return exports['night_ers']:getIsPlayerOnShift(), exports['night_ers']:getPlayerActiveServiceType()
    end)

    if ok and onDuty and service and Config.EmergencyServices[service] then
        return true, service
    end

    return false, service
end

local function GetFuel(vehicle)
    if vehicle == 0 or not DoesEntityExist(vehicle) then return 0.0 end

    local stateFuel = Entity(vehicle).state.smvlpd_fuel
    if type(stateFuel) == 'number' then
        return stateFuel
    end

    local nativeFuel = GetVehicleFuelLevel(vehicle) + 0.0
    if nativeFuel <= 0.0 then
        nativeFuel = fuelCache[vehicle] or Config.StartingFuel
        SetVehicleFuelLevel(vehicle, nativeFuel)
    end

    fuelCache[vehicle] = nativeFuel
    return nativeFuel
end

local function SetFuel(vehicle, fuel)
    fuel = math.max(0.0, math.min(Config.MaxFuel, fuel))
    SetVehicleFuelLevel(vehicle, fuel + 0.0)
    fuelCache[vehicle] = fuel
    Entity(vehicle).state:set('smvlpd_fuel', fuel, false)
end

local PumpModels = {
    `prop_gas_pump_1a`,
    `prop_gas_pump_1b`,
    `prop_gas_pump_1c`,
    `prop_gas_pump_1d`,
    `prop_gas_pump_old2`,
    `prop_gas_pump_old3`,
    `prop_vintage_pump`,
}

local function GetNearbyStation()
    local playerCoords = GetEntityCoords(PlayerPedId())
    local closest, closestDistance

    -- Detectamos el surtidor real de GTA, no una coordenada fija de la gasolinera.
    -- Esto evita que el jugador tenga que colocarse exactamente en el centro de la estación.
    for _, model in ipairs(PumpModels) do
        local pump = GetClosestObjectOfType(
            playerCoords.x, playerCoords.y, playerCoords.z,
            Config.PumpDetectionRadius,
            model,
            false, false, false
        )

        if pump ~= 0 and DoesEntityExist(pump) then
            local pumpCoords = GetEntityCoords(pump)
            local distance = #(playerCoords - pumpCoords)
            if not closestDistance or distance < closestDistance then
                closest = pumpCoords
                closestDistance = distance
            end
        end
    end

    return closest, closestDistance
end

local function CanRefuel()
    local ped = PlayerPedId()
    if IsEntityDead(ped) then return false, 'No puedes repostar estando incapacitado.' end
    if not IsPedInAnyVehicle(ped, false) then return false, 'Debes estar en un vehiculo de emergencias.' end

    local vehicle = GetVehiclePedIsIn(ped, false)
    if Config.RequireDriverSeat and GetPedInVehicleSeat(vehicle, -1) ~= ped then
        return false, 'Debes estar en el asiento del conductor.'
    end

    if not IsEmergencyVehicle(vehicle) then
        return false, 'Este vehiculo no esta autorizado para repostaje.'
    end

    local onDuty = GetEmergencyService()
    if not onDuty then
        return false, 'Debes estar de servicio para repostar.'
    end

    local station = GetNearbyStation()
    if not station then
        return false, 'Debes estar junto a una gasolinera publica.'
    end

    return true, nil, vehicle, station
end

local function DrawText3D(coords, text)
    local onScreen, x, y = World3dToScreen2d(coords.x, coords.y, coords.z)
    if not onScreen then return end

    SetTextScale(0.32, 0.32)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextCentre(true)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry('STRING')
    AddTextComponentString(text)
    DrawText(x, y)
end

local function StartRefuel(vehicle, station)
    if refueling then return end
    refueling = true

    SetVehicleEngineOn(vehicle, false, true, true)
    SetVehicleUndriveable(vehicle, true)

    local fuel = GetFuel(vehicle)
    if fuel >= Config.MaxFuel - 0.1 then
        Notify('~b~Emergencias~s~: el deposito ya esta lleno.')
        SetVehicleUndriveable(vehicle, false)
        refueling = false
        return
    end

    Notify('~b~Emergencias~s~: repostaje gratuito iniciado.')

    while refueling do
        Wait(Config.FuelTick)

        if not DoesEntityExist(vehicle) or GetVehiclePedIsIn(PlayerPedId(), false) ~= vehicle then
            break
        end

        local currentStation = GetNearbyStation()
        if not currentStation then
            break
        end

        fuel = math.min(Config.MaxFuel, fuel + (Config.RefuelRate * (Config.FuelTick / 1000.0)))
        SetFuel(vehicle, fuel)
        DrawText3D(station + vec3(0.0, 0.0, 1.0), ('REPOSTANDO  %.0f%%'):format(fuel))

        if fuel >= Config.MaxFuel - 0.01 then
            SetFuel(vehicle, Config.MaxFuel)
            Notify('~b~Emergencias~s~: repostaje completado.')
            break
        end
    end

    SetVehicleUndriveable(vehicle, false)
    refueling = false
end

-- Consumo de combustible. Se gestiona aqui porque no usamos ningun recurso externo de fuel.
-- El consumo aumenta con la velocidad y las RPM para que el deposito no se quede estatico.
CreateThread(function()
    while true do
        Wait(Config.ConsumptionTick)

        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)

        if vehicle ~= 0 and DoesEntityExist(vehicle) and GetPedInVehicleSeat(vehicle, -1) == ped
            and IsEmergencyVehicle(vehicle) and GetIsVehicleEngineRunning(vehicle) then

            local fuel = GetFuel(vehicle)
            if fuel > 0.0 then
                local speedKmh = GetEntitySpeed(vehicle) * 3.6
                local rpm = GetVehicleCurrentRpm(vehicle)

                local consumption = Config.BaseConsumptionPerSecond
                    + (speedKmh * Config.SpeedConsumptionPerKmH)
                    + (rpm * Config.RpmConsumptionPerUnit)

                local newFuel = math.max(0.0, fuel - consumption * (Config.ConsumptionTick / 1000.0))
                SetFuel(vehicle, newFuel)
            end
        end
    end
end)

CreateThread(function()
    while true do
        local wait = 1000
        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)

        if vehicle ~= 0 and IsEmergencyVehicle(vehicle) then
            local station, distance = GetNearbyStation()

            if station and distance <= Config.DrawDistance then
                wait = 0

                local marker = Config.Marker
                DrawMarker(marker.type, station.x, station.y, station.z - 0.25,
                    0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                    marker.scale.x, marker.scale.y, marker.scale.z,
                    marker.color.r, marker.color.g, marker.color.b, marker.color.a,
                    false, true, 2, false, nil, nil, false)

                if distance <= Config.RefuelDistance and not refueling then
                    if Config.ShowHelp then
                        DrawText3D(station + vec3(0.0, 0.0, 1.0), '~b~[E]~s~ Repostar vehiculo de emergencias')
                    end

                    if IsControlJustReleased(0, Config.RefuelKey) then
                        local allowed, reason, checkedVehicle, checkedStation = CanRefuel()
                        if allowed then
                            StartRefuel(checkedVehicle, checkedStation)
                        else
                            Notify('~r~Emergencias~s~: ' .. reason)
                        end
                    end
                end
            end
        end

        Wait(wait)
    end
end)

RegisterCommand('emfuel', function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle ~= 0 then
        Notify(('Combustible: %.1f%%'):format(GetFuel(vehicle)))
    end
end, false)
