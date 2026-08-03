RegisterNetEvent("smvlpd_dev:spawnVehicle", function(modelName)

    if not modelName then
        TriggerEvent('chat:addMessage', {
            color = {255,0,0},
            args = {"DEV", "Uso: /spawnpd <modelo>"}
        })
        return
    end

    local model = GetHashKey(modelName)
    print("[SPAWNPD] IsModelInCdimage:", IsModelInCdimage(model))
    print("[SPAWNPD] IsModelValid:", IsModelValid(model))

    if not IsModelInCdimage(model) then
        TriggerEvent('chat:addMessage', {
            color = {255,0,0},
            args = {"DEV", "Modelo inexistente: "..modelName}
        })
        return
    end

    RequestModel(model)

    while not HasModelLoaded(model) do
        Wait(0)
    end
    print("[SPAWNPD] HasModelLoaded:", HasModelLoaded(model))

    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    local vehicle = CreateVehicle(
        model,
        coords.x + 3.0,
        coords.y,
        coords.z,
        heading,
        true,
        false
    )

    SetPedIntoVehicle(ped, vehicle, -1)
    for i = 0, 20 do
    if DoesExtraExist(vehicle, i) then
        SetVehicleExtra(vehicle, i, false)
    end
end

    SetVehicleOnGroundProperly(vehicle)

    SetModelAsNoLongerNeeded(model)

    TriggerEvent('chat:addMessage', {
        color = {0,255,0},
        args = {"DEV", "Vehículo creado: "..modelName}
    })

end)
RegisterCommand("coords", function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    print(("vec3(%.2f, %.2f, %.2f)"):format(
        coords.x, coords.y, coords.z
    ))

    print(("vec4(%.2f, %.2f, %.2f, %.2f)"):format(
        coords.x, coords.y, coords.z, heading
    ))
end, false)
RegisterCommand("dv", function()

    local ped = PlayerPedId()

    if IsPedInAnyVehicle(ped, false) then

        local vehicle = GetVehiclePedIsIn(ped, false)

        SetEntityAsMissionEntity(vehicle, true, true)
        DeleteVehicle(vehicle)

        return

    end

    local coords = GetEntityCoords(ped)

    local vehicle = GetClosestVehicle(
        coords.x,
        coords.y,
        coords.z,
        5.0,
        0,
        71
    )

    if vehicle ~= 0 then

        SetEntityAsMissionEntity(vehicle, true, true)
        DeleteVehicle(vehicle)

    end

end, false)
--========================================================
-- TEST WEAPONS
--========================================================

RegisterCommand("testweapons", function()

    local ped = PlayerPedId()

    GiveWeaponToPed(ped, `WEAPON_FLASHLIGHT`, 1, false, false)
    GiveWeaponToPed(ped, `WEAPON_STUNGUN`, 999, false, false)
    GiveWeaponToPed(ped, `WEAPON_COMBATPISTOL`, 999, false, true)
    GiveWeaponToPed(ped, `WEAPON_PUMPSHOTGUN`, 999, false, false)
    GiveWeaponToPed(ped, `WEAPON_CARBINERIFLE`, 999, false, false)

    SetCurrentPedWeapon(ped, `WEAPON_COMBATPISTOL`, true)

    TriggerEvent('chat:addMessage', {
        color = {0,255,0},
        args = {"DEV", "Armas añadidas."}
    })

end, false)

--========================================================
-- HEAL
--========================================================

RegisterCommand("heal", function()

    local ped = PlayerPedId()

    SetEntityHealth(ped, GetEntityMaxHealth(ped))

    TriggerEvent('chat:addMessage', {
        color = {0,255,0},
        args = {"DEV", "Vida restaurada."}
    })

end, false)

--========================================================
-- ARMOR
--========================================================

RegisterCommand("armor", function()

    SetPedArmour(PlayerPedId(), 100)

    TriggerEvent('chat:addMessage', {
        color = {0,255,0},
        args = {"DEV", "Chaleco al 100%."}
    })

end, false)

--========================================================
-- FIX
--========================================================

RegisterCommand("fix", function()

    local ped = PlayerPedId()

    if IsPedInAnyVehicle(ped, false) then

        local veh = GetVehiclePedIsIn(ped, false)

        SetVehicleFixed(veh)
        SetVehicleDeformationFixed(veh)
        SetVehicleEngineHealth(veh, 1000.0)
        SetVehicleBodyHealth(veh, 1000.0)

    end

end, false)

--========================================================
-- FLIP
--========================================================

RegisterCommand("flip", function()

    local ped = PlayerPedId()

    if IsPedInAnyVehicle(ped, false) then

        local veh = GetVehiclePedIsIn(ped, false)

        SetVehicleOnGroundProperly(veh)

    end

end, false)

--========================================================
-- FUEL
--========================================================

RegisterCommand("fuel", function()

    local ped = PlayerPedId()

    if IsPedInAnyVehicle(ped, false) then

        local veh = GetVehiclePedIsIn(ped, false)

        SetVehicleFuelLevel(veh, 100.0)

    end

end, false)

--========================================================
-- DAY
--========================================================

RegisterCommand("day", function()

    NetworkOverrideClockTime(12,0,0)

end, false)

--========================================================
-- NIGHT
--========================================================

RegisterCommand("night", function()

    NetworkOverrideClockTime(0,0,0)

end, false)

--========================================================
-- CLEAR WEATHER
--========================================================

RegisterCommand("clear", function()

    ClearOverrideWeather()
    ClearWeatherTypePersist()
    SetWeatherTypePersist("CLEAR")
    SetWeatherTypeNow("CLEAR")
    SetWeatherTypeNowPersist("CLEAR")

end, false)