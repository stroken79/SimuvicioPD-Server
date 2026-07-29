local partner = nil

RegisterCommand("partner", function()

    if DoesEntityExist(partner) then
        DeletePed(partner)
        partner = nil

        TriggerEvent('chat:addMessage', {
            args = {"^1Compañero eliminado."}
        })

        return
    end

    local playerPed = PlayerPedId()
    local coords = GetEntityCoords(playerPed)
    local forward = GetEntityForwardVector(playerPed)

    local spawnPos = vector3(
        coords.x + (forward.x * Config.SpawnDistance),
        coords.y + (forward.y * Config.SpawnDistance),
        coords.z
    )

    local model = joaat(Config.PartnerModel)

    RequestModel(model)

    while not HasModelLoaded(model) do
        Wait(0)
    end

    partner = CreatePed(
        4,
        model,
        spawnPos.x,
        spawnPos.y,
        spawnPos.z,
        GetEntityHeading(playerPed),
        true,
        false
    )

    SetEntityAsMissionEntity(partner, true, true)

    SetBlockingOfNonTemporaryEvents(partner, true)
    SetPedCanRagdoll(partner, false)
    SetPedDiesWhenInjured(partner, false)
    SetPedKeepTask(partner, true)

    GiveWeaponToPed(
        partner,
        `WEAPON_COMBATPISTOL`,
        255,
        false,
        true
    )

    CreateThread(function()

        while DoesEntityExist(partner) do

            Wait(250)

            local playerPed = PlayerPedId()

            if IsPedInAnyVehicle(playerPed, false) then

                local veh = GetVehiclePedIsIn(playerPed, false)

                if GetPedInVehicleSeat(veh, -1) == playerPed then

                    if not IsPedInAnyVehicle(partner, false) then

                        ClearPedTasks(partner)

                        TaskGoToEntity(
                            partner,
                            veh,
                            -1,
                            2.0,
                            2.0,
                            0.0,
                            0
                        )
                                                CreateThread(function()

                            while DoesEntityExist(partner) do

                                Wait(200)

                                if IsPedInAnyVehicle(partner, false) then
                                    break
                                end

                                local pedCoords = GetEntityCoords(partner)
                                local vehCoords = GetEntityCoords(veh)

                                if #(pedCoords - vehCoords) < 3.0 then

                                    SetPedIntoVehicle(partner, veh, 0)

                                    break

                                end

                            end

                        end)

                    end

                end

            else

                if IsPedInAnyVehicle(partner, false) then

                    TaskLeaveVehicle(
                        partner,
                        GetVehiclePedIsIn(partner, false),
                        0
                    )

                end

                TaskFollowToOffsetOfEntity(
                    partner,
                    playerPed,
                    0.0,
                    -1.5,
                    0.0,
                    2.0,
                    -1,
                    2.0,
                    true
                )

                SetPedKeepTask(partner, true)

                TaskLookAtEntity(
                    partner,
                    playerPed,
                    1000,
                    2048,
                    3
                )

                local playerWeapon = GetSelectedPedWeapon(playerPed)

                if playerWeapon == `WEAPON_UNARMED` then

                    SetCurrentPedWeapon(
                        partner,
                        `WEAPON_UNARMED`,
                        true
                    )

                else

                    SetCurrentPedWeapon(
                        partner,
                        `WEAPON_COMBATPISTOL`,
                        true
                    )

                end
                local aiming, entity = GetEntityPlayerIsFreeAimingAt(PlayerId())

if aiming
and entity ~= 0
and DoesEntityExist(entity)
and IsEntityAPed(entity)
and not IsPedAPlayer(entity)
then

    SetPedAsEnemy(entity, true)

    SetPedCombatAttributes(partner, 46, true)
    SetPedCombatAttributes(partner, 5, true)
    SetPedCombatAbility(partner, 2)
    SetPedCombatRange(partner, 2)
    SetPedAccuracy(partner, 65)

    TaskShootAtEntity(partner, entity, 3000, `FIRING_PATTERN_FULL_AUTO`)

end
            end

        end

    end)

    TriggerEvent('chat:addMessage', {
        args = {"^2Compañero desplegado."}
    })

end, false)