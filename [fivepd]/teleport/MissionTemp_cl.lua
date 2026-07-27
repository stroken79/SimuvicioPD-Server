RegisterNetEvent('pd5m:hud:UpdateMissionInformation')
AddEventHandler('pd5m:hud:UpdateMissionInformation', function(AmbientInfo)
  MssAmbientEventTriggered = AmbientInfo
end)

local ShowMissionMenu = true
local PoliceCalloutBusy = false
local PoliceOnDuty = false
local HudX = 0.75
local HudY = 0.86
local HudLineGap = 0.025

RegisterNetEvent('pd5m:hud:SetPoliceCalloutState')
AddEventHandler('pd5m:hud:SetPoliceCalloutState', function(isBusy)
  PoliceCalloutBusy = isBusy == true
end)

RegisterNetEvent('pd5m:setDuty')
AddEventHandler('pd5m:setDuty', function(onDuty)
  PoliceOnDuty = onDuty == true
end)

CreateThread(function()
  while true do
    ShowMissionMenu = (
      PlayerData ~= nil
      and PlayerData.job ~= nil
      and (PlayerData.job.name == 'police' or PlayerData.job.name == 'offduty')
    )

    if PlayerData ~= nil and PlayerData.job ~= nil then
      PoliceOnDuty = PlayerData.job.name == 'police'
    end

    Wait(500)
  end
end)



CreateThread(function()
  while true do
    if ShowMissionMenu then
      BeginTextCommandDisplayText("STRING")
      AddTextComponentSubstringPlayerName('Estado: ' .. (PoliceCalloutBusy and 'Ocupado' or 'Libre'))
      SetTextCentre(false)
      if PoliceCalloutBusy then
        SetTextColour(255, 70, 70, 255)
      else
        SetTextColour(70, 255, 110, 255)
      end
      SetTextScale(0.5, 0.35)
      SetTextOutline()
      EndTextCommandDisplayText(HudX, HudY)

      BeginTextCommandDisplayText("STRING")
      AddTextComponentSubstringPlayerName('En Servicio: ' .. (PoliceOnDuty and 'Si' or 'No'))
      SetTextCentre(false)
      if PoliceOnDuty then
        SetTextColour(70, 255, 110, 255)
      else
        SetTextColour(255, 70, 70, 255)
      end
      SetTextScale(0.5, 0.35)
      SetTextOutline()
      EndTextCommandDisplayText(HudX, HudY + HudLineGap)
    end
    Wait(0)
  end
end)
