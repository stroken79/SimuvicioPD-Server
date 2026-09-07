-- Puente de servidor entre los avisos de fivepd-police_v2 y smvlpd-ranks.
-- No acepta importes del cliente: el baremo vive exclusivamente en ranks/config.lua.

local function ranksReady()
    return GetResourceState('smvlpd-ranks') == 'started'
end

RegisterNetEvent('fivepd-police:pointsStart', function(title)
    local playerSource = source
    if not ranksReady() or type(title) ~= 'string' or title == '' then return end
    exports['smvlpd-ranks']:BeginFivePDCallout(playerSource, title)
end)

RegisterNetEvent('fivepd-police:pointsComplete', function()
    if not ranksReady() then return end
    exports['smvlpd-ranks']:CompleteFivePDCallout(source)
end)

RegisterNetEvent('fivepd-police:pointsCancel', function()
    if not ranksReady() then return end
    exports['smvlpd-ranks']:CancelFivePDCallout(source)
end)

AddEventHandler('fivepd-police:serverSupportJoined', function(request, playerSource)
    if not ranksReady() or type(request) ~= 'table' then return end
    exports['smvlpd-ranks']:BeginFivePDCallout(playerSource, request.title)
end)

AddEventHandler('fivepd-police:serverSupportFinished', function(request)
    if not ranksReady() or type(request) ~= 'table' then return end

    -- El propietario puede haber terminado ya su propio aviso; el export evita
    -- el duplicado. Cada apoyo que siga activo recibe el aviso una sola vez.
    exports['smvlpd-ranks']:CompleteFivePDCallout(request.owner)
    for playerSource in pairs(request.joined or {}) do
        exports['smvlpd-ranks']:CompleteFivePDCallout(playerSource)
    end
end)

AddEventHandler('fivepd-police:serverSupportCancelled', function(request)
    if not ranksReady() or type(request) ~= 'table' then return end
    exports['smvlpd-ranks']:CancelFivePDCallout(request.owner)
    for playerSource in pairs(request.joined or {}) do
        exports['smvlpd-ranks']:CancelFivePDCallout(playerSource)
    end
end)
