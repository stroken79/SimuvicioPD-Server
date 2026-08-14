-- Integracion con ERS.
-- Las tareas que ERS resuelve mediante unidades de apoyo no se fuerzan
-- desde este recurso: se informa al bombero para que solicite el apoyo
-- desde el menu de ERS.

local lastSupportNotice = 0

local function showSupportNotice(reason)
    local now = GetGameTimer()
    if now - lastSupportNotice < (Config.SupportNoticeCooldown or 15000) then
        return
    end

    lastSupportNotice = now

    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(
        ('~y~Se requiere una unidad de apoyo~s~\\n%s\\nSolicita otra unidad desde el ~b~menu ERS~s~.'):format(
            reason or 'Esta intervención no puede completarse con la unidad actual.'
        )
    )
    EndTextCommandDisplayHelp(0, false, true, 8000)

    NotifyFirefighter(
        'Se requiere una unidad de apoyo. Solicítala desde el menú ERS.',
        'warning'
    )
end

RegisterNetEvent('smvlpd-firefighter:client:requestSupport', function(reason)
    if IsFirefighterOnDuty() then
        showSupportNotice(reason)
    end
end)

RegisterNetEvent('smvlpd-firefighter:client:extinguished', function(kind, count)
    FirefighterDebug(('%s extinguished targets: %s'):format(kind, count))
end)

RegisterNetEvent('smvlpd-firefighter:client:stopEntityFire', function(netId)
    local entity = NetToEnt(netId)
    if entity ~= 0 and DoesEntityExist(entity) then
        StopEntityFire(entity)
        FirefighterDebug(('Native entity fire stopped for net id %s.'):format(netId))
    end
end)
