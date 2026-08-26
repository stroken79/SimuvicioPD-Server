local function toggleLsdotDuty()
    local activeService = exports['night_ers']:getPlayerActiveServiceType()
    if exports['night_ers']:getIsPlayerOnShift() and activeService ~= Config.ServiceType then
        LsdotNotify('Debes salir de tu servicio actual antes de entrar como LSDOT - Grúa.', 'error')
        return
    end

    exports['night_ers']:toggleShift(Config.ServiceType)
end

CreateThread(function()
    for _, servicePoint in ipairs(Config.ServicePoints) do
        local point = lib.points.new({ coords = servicePoint.coords, distance = Config.PointDrawDistance })
        function point:nearby()
            LsdotDrawMarker(self.coords)
            if self.currentDistance < Config.InteractionDistance then
                lib.showTextUI(LsdotIsOnDuty() and Config.Text.ServiceOff or Config.Text.ServiceOn)
                if IsControlJustReleased(0, 38) then toggleLsdotDuty() end
            elseif lib.isTextUIOpen() then
                lib.hideTextUI()
            end
        end
    end
end)

exports('IsPlayerOnDuty', LsdotIsOnDuty)
