local blipsCreated = false

CreateThread(function()
    while true do
        local wait = 500
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        local closest = nil
        local closestDistance = nil

        for k, v in pairs(PL.Locations) do
            local from = v.location.from
            local distance = #(coords - from)

            if not closestDistance or distance < closestDistance then
                closest = k
                closestDistance = distance
            end
        end

        if not blipsCreated and PL.UseBlips then
            CreateTeleportBlips()
            blipsCreated = true
        end

        if closest and closestDistance <= PL.DisplayTextDistance then
            wait = 0

            local location = PL.Locations[closest].location
            local text = location.text or "Teletransportarse"

            DrawText3D(
                location.from.x,
                location.from.y,
                location.from.z + 0.5,
                GetTextColor(location.textColor) .. text
            )

            if closestDistance <= PL.UseTeleportDistance and IsControlJustReleased(0, 38) then
                TeleportPlayer(closest)
            end
        end

        Wait(wait)
    end
end)

function TeleportPlayer(index)
    local location = PL.Locations[index].location
    local ped = PlayerPedId()

    if IsPedInAnyVehicle(ped, false) and not PL.TeleportInVehicle then
        return
    end

    local destination = location.to
    local heading = location.toHeading or GetEntityHeading(ped)

    DoScreenFadeOut(250)

    local timeout = GetGameTimer() + 3000
    while not IsScreenFadedOut() and GetGameTimer() < timeout do
        Wait(0)
    end

    -- Coloca al jugador exactamente en el destino.
    RequestCollisionAtCoord(destination.x, destination.y, destination.z)

    SetEntityCoords(
        ped,
        destination.x,
        destination.y,
        destination.z,
        false,
        false,
        false,
        true
    )

    SetEntityHeading(ped, heading)
    ClearPedTasksImmediately(ped)

    -- Espera a que GTA cargue la colisión del destino.
    local collisionTimeout = GetGameTimer() + 2000
    while not HasCollisionLoadedAroundEntity(ped) and GetGameTimer() < collisionTimeout do
        RequestCollisionAtCoord(destination.x, destination.y, destination.z)
        Wait(0)
    end

    DoScreenFadeIn(250)
end

function CreateTeleportBlips()
    for _, v in pairs(PL.Locations) do
        if v.location.showBlip then
            local coords = v.location.from
            local blip = AddBlipForCoord(coords.x, coords.y, coords.z)

            SetBlipDisplay(blip, 4)
            SetBlipSprite(blip, PL.BlipSprite)
            SetBlipColour(blip, PL.BlipColor)
            SetBlipScale(blip, PL.BlipScale)
            SetBlipAsShortRange(blip, true)

            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(v.location.blipText or "Teletransporte")
            EndTextCommandSetBlipName(blip)
        end
    end
end

function GetTextColor(color)
    if color == "Red" then return "~r~" end
    if color == "Blue" then return "~b~" end
    if color == "Green" then return "~g~" end
    if color == "Yellow" then return "~y~" end
    if color == "Purple" then return "~p~" end
    if color == "Black" then return "~u~" end
    if color == "Orange" then return "~o~" end
    return "~s~"
end

function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)

    local factor = string.len(text) / 370
    DrawRect(0.0, 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)

    ClearDrawOrigin()
end
