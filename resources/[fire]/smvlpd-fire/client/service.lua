local function toggleFireDuty()
    local activeService = exports['night_ers']:getPlayerActiveServiceType()
    if exports['night_ers']:getIsPlayerOnShift() and activeService ~= Config.ServiceType then
        FireNotify('Debes salir de tu servicio actual antes de entrar como Bombero.', 'error')
        return
    end

    exports['night_ers']:toggleShift(Config.ServiceType)
end

CreateThread(function()
    for _, servicePoint in ipairs(Config.ServicePoints) do
        local point = lib.points.new({ coords = servicePoint.coords, distance = Config.PointDrawDistance })

        function point:nearby()
            FireDrawMarker(self.coords)
            if self.currentDistance < Config.InteractionDistance then
                lib.showTextUI(FireIsOnDuty() and Config.Text.ServiceOff or Config.Text.ServiceOn)
                if IsControlJustReleased(0, 38) then toggleFireDuty() end
            elseif lib.isTextUIOpen() then
                lib.hideTextUI()
            end
        end
    end
end)

exports('IsPlayerOnDuty', FireIsOnDuty)
