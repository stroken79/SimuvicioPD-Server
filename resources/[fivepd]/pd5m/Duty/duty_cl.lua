PlayerData = {}
PlayerData.job = {}
PlayerData.job.name = 'offduty'

RegisterNetEvent('pd5m:setDuty')
AddEventHandler('pd5m:setDuty', function(onDuty)
    if onDuty then
        PlayerData.job.name = 'police'
        print('^2[PD5M] EN SERVICIO^7')
    else
        PlayerData.job.name = 'offduty'
        print('^1[PD5M] FUERA DE SERVICIO^7')
    end
end)