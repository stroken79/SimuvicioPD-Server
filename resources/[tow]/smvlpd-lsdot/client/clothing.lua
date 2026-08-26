local function applyUniform(rankId)
    local rankConfig = Config.Ranks[rankId]
    local uniform = rankConfig and LsdotUniforms[rankConfig.name]
    local ped = PlayerPedId()
    local gender = IsPedModel(ped, `mp_f_freemode_01`) and 'female' or 'male'
    uniform = uniform and uniform[gender]
    if not uniform then return LsdotNotify('No hay uniforme LSDOT configurado para este rango.', 'error') end

    local hairDrawable, hairTexture = GetPedDrawableVariation(ped, 2), GetPedTextureVariation(ped, 2)
    SetPedDefaultComponentVariation(ped)
    for component, data in pairs(uniform.components or {}) do SetPedComponentVariation(ped, component, data[1], data[2], 0) end
    for component, data in pairs(uniform.collections or {}) do
        SetPedCollectionComponentVariation(ped, component, data.collection, data.drawable, data.texture, 0)
    end
    for prop, data in pairs(uniform.props or {}) do
        if data == false then ClearPedProp(ped, prop) else SetPedPropIndex(ped, prop, data[1], data[2], true) end
    end
    SetPedComponentVariation(ped, 2, hairDrawable, hairTexture, 0)
    LsdotNotify('Uniforme LSDOT aplicado.', 'success')
end

function OpenLsdotLocker()
    if not LsdotIsOnDuty() then return LsdotNotify('Debes estar de servicio como LSDOT - Grúa.', 'error') end
    local rank = lib.callback.await('smvlpd-ranks:server:getRank', false)
    if not rank or rank.service ~= Config.ServiceType then return LsdotNotify('No se pudo obtener tu rango de LSDOT.', 'error') end
    lib.registerContext({
        id = 'smvlpd_lsdot_locker',
        title = 'Vestuario LSDOT - Grúa',
        options = {{
            title = 'Uniforme reglamentario',
            description = 'Equipar el uniforme de tu rango.',
            icon = 'shirt',
            onSelect = function() applyUniform(tonumber(rank.id)) end
        }}
    })
    lib.showContext('smvlpd_lsdot_locker')
end

CreateThread(function()
    for _, locker in ipairs(Config.LockerRooms) do
        local point = lib.points.new({ coords = locker.coords, distance = Config.PointDrawDistance })
        function point:nearby()
            LsdotDrawMarker(self.coords)
            if self.currentDistance < Config.InteractionDistance then
                lib.showTextUI(Config.Text.Locker)
                if IsControlJustReleased(0, 38) then OpenLsdotLocker() end
            elseif lib.isTextUIOpen() then lib.hideTextUI() end
        end
    end
end)

exports('OpenLsdotLocker', OpenLsdotLocker)
