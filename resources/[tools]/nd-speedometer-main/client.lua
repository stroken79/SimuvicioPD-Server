local showHUD = true
local unit = Config.DefaultUnit -- 'mph' or 'kmh'

RegisterCommand('hud', function()
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "openMenu", unit = unit, hud = showHUD })
end)

RegisterNUICallback('closeMenu', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('toggleHUD', function(_, cb)
    showHUD = not showHUD
    SendNUIMessage({ action = "updateHUDStatus", hud = showHUD })
    cb('ok')
end)

RegisterNUICallback('toggleUnit', function(_, cb)
    if unit == 'mph' then
        unit = 'kmh'
    else
        unit = 'mph'
    end
    SendNUIMessage({ action = "updateUnit", unit = unit })
    cb('ok')
end)

CreateThread(function()
    while true do
        Wait(Config.UpdateInterval)

        local ped = PlayerPedId()

        if IsPedInAnyVehicle(ped, false) and showHUD then
            local veh = GetVehiclePedIsIn(ped, false)
            local speed = GetEntitySpeed(veh)
            local fuel = GetVehicleFuelLevel(veh)
            local gear = GetVehicleCurrentGear(veh)

            -- Correct conversion:
            if unit == 'kmh' then
                speed = speed * 3.6
            else
                speed = speed * 2.236936
            end

            local gearText = 'N'
            if gear == 0 then
                gearText = 'R'
            elseif gear == 1 then
                gearText = 'D'
            elseif gear >= 2 then
                gearText = tostring(gear - 1)
            end

            if GetVehicleCurrentRpm(veh) < 0.1 then
                gearText = 'P'
            end

            SendNUIMessage({
                action = "updateSpeedometer",
                speed = math.floor(speed),
                fuel = math.floor(fuel),
                unit = unit:upper(),
                gear = gearText
            })
        else
            SendNUIMessage({ action = "hideSpeedometer" })
        end
    end
end)
