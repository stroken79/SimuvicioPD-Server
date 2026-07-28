local lightsOn = false
local sirenOn = false

CreateThread(function()
    while true do
        Wait(0)

        local ped = PlayerPedId()

        if IsPedInAnyVehicle(ped, false) then
            local veh = GetVehiclePedIsIn(ped, false)

            if GetPedInVehicleSeat(veh, -1) == ped then

                -- Q = Luces
                if IsControlJustPressed(0, 44) then -- INPUT_COVER (Q)

                    lightsOn = not lightsOn

                    SetVehicleSiren(veh, lightsOn)
                    DisableVehicleImpactExplosionActivation(veh, true)

                    if not lightsOn then
                        sirenOn = false
                        SetVehicleHasMutedSirens(veh, true)
                    end
                end

                -- E = Sirena
                if IsControlJustPressed(0, 38) then -- INPUT_CONTEXT (E)

                    if lightsOn then

                        sirenOn = not sirenOn

                        SetVehicleHasMutedSirens(veh, not sirenOn)

                    end
                end

            end
        else
            lightsOn = false
            sirenOn = false
        end
    end
end)