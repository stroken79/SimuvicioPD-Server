RegisterNetEvent('pd5m:hud:UpdateMissionInformation')
AddEventHandler('pd5m:hud:UpdateMissionInformation', function(AmbientInfo)
  MssAmbientEventTriggered = AmbientInfo
end)

local ShowMissionMenu = false

CreateThread(function()
  while true do
    ShowMissionMenu = (
      PlayerData ~= nil
      and PlayerData.job ~= nil
      and PlayerData.job.name == 'police'
    )

    Wait(500)
  end
end)



CreateThread(function()
  while true do
    if ShowMissionMenu then
      BeginTextCommandDisplayText("STRING")
      AddTextComponentSubstringPlayerName('Ambient')
      SetTextCentre(true)
      SetTextColour(255, 255, 255, 255)
      SetTextScale(0.5, 0.35)
      SetTextOutline()
      EndTextCommandDisplayText(0.1908, 0.881)
      if MssAmbientEventTriggered then
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName('running')
        SetTextColour(255, 0, 0, 255)
        SetTextScale(0.5, 0.35)
        SetTextOutline()
        EndTextCommandDisplayText(0.2155, 0.881)
      else
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName('available')
        SetTextColour(0, 255, 0, 255)
        SetTextScale(0.5, 0.35)
        SetTextOutline()
        EndTextCommandDisplayText(0.2155, 0.881)
      end
    end
    Wait(0)
  end
end)
