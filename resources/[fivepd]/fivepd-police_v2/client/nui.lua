RegisterNUICallback("close", function(data, cb)

    SetNuiFocus(false, false)

    SendNUIMessage({
        action = "close"
    })

    cb("ok")

end)

RegisterNUICallback("patrol", function(data, cb)
    print("^2[FivePD] Callback PATROL recibido^7")

    EquipPatrolUniform()

    SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNUICallback("civil", function(data, cb)
    RestoreCivilianClothes()

    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })
    cb("ok")
end)

RegisterNUICallback("wardrobe", function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = "close" })

    ExecuteCommand("eup")

    cb("ok")
end)