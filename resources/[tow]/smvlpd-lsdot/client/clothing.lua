local function applyUniform(rankId)
    local rankConfig = Config.Ranks[rankId]
    local uniform = rankConfig and LsdotUniforms[rankConfig.name]
    local ped = PlayerPedId()
    local gender = IsPedModel(ped, `mp_f_freemode_01`) and 'female' or 'male'

    uniform = uniform and uniform[gender]

    if not uniform then
        return LsdotNotify('No hay uniforme LSDOT configurado para este rango.', 'error')
    end

    local hairDrawable, hairTexture = GetPedDrawableVariation(ped, 2), GetPedTextureVariation(ped, 2)

    SetPedDefaultComponentVariation(ped)

    for component, data in pairs(uniform.components or {}) do
        SetPedComponentVariation(ped, component, data[1], data[2], 0)
    end

    for component, data in pairs(uniform.collections or {}) do
        SetPedCollectionComponentVariation(
            ped,
            component,
            data.collection,
            data.drawable,
            data.texture,
            0
        )
    end

    for prop, data in pairs(uniform.props or {}) do
        if data == false then
            ClearPedProp(ped, prop)
        else
            SetPedPropIndex(ped, prop, data[1], data[2], true)
        end
    end

    SetPedComponentVariation(ped, 2, hairDrawable, hairTexture, 0)

    LsdotNotify('Uniforme LSDOT aplicado.', 'success')
end


-- =========================================================
-- ACCESORIOS LSDOT - GORRAS
-- =========================================================

local function applyTowHat(hat)
    local ped = PlayerPedId()
    local gender = IsPedModel(ped, `mp_f_freemode_01`) and 'female' or 'male'
    local data = hat and hat[gender]

    if not data then
        return LsdotNotify('No hay una gorra configurada para este modelo.', 'error')
    end

    if data.collection and data.collection ~= 'NONE' then
        SetPedCollectionPropIndex(
            ped,
            0,
            data.collection,
            data.drawable,
            data.texture,
            true
        )
    else
        SetPedPropIndex(
            ped,
            0,
            data.drawable,
            data.texture,
            true
        )
    end

    LsdotNotify('Gorra LSDOT equipada.', 'success')
end


local function removeTowHat()
    local ped = PlayerPedId()

    ClearPedProp(ped, 0)

    LsdotNotify('Gorra retirada.', 'success')
end


local function OpenLsdotHats()
    local hats = Config.Accessories
        and Config.Accessories.tow
        and Config.Accessories.tow.hats

    if not hats or #hats == 0 then
        return LsdotNotify('No hay gorras LSDOT configuradas.', 'error')
    end

    local options = {
        {
            title = 'Quitar gorra',
            description = 'Retirar la gorra actual.',
            icon = 'ban',
            onSelect = function()
                removeTowHat()
            end
        }
    }

    for _, hat in ipairs(hats) do
        options[#options + 1] = {
            title = hat.label or 'Gorra LSDOT',
            description = 'Equipar esta gorra.',
            icon = 'hat-cowboy',
            onSelect = function()
                applyTowHat(hat)
            end
        }
    end

    lib.registerContext({
        id = 'smvlpd_lsdot_hats',
        title = 'Gorras LSDOT',
        menu = 'smvlpd_lsdot_accessories',
        options = options
    })

    lib.showContext('smvlpd_lsdot_hats')
end


-- =========================================================
-- ACCESORIOS LSDOT - GAFAS
-- =========================================================

local function applyTowGlasses(glasses)
    local ped = PlayerPedId()
    local gender = IsPedModel(ped, `mp_f_freemode_01`) and 'female' or 'male'
    local data = glasses and glasses[gender]

    if not data then
        return LsdotNotify('No hay unas gafas configuradas para este modelo.', 'error')
    end

    SetPedPropIndex(
        ped,
        1,
        data.drawable,
        data.texture,
        true
    )

    LsdotNotify('Gafas LSDOT equipadas.', 'success')
end


local function removeTowGlasses()
    local ped = PlayerPedId()

    ClearPedProp(ped, 1)

    LsdotNotify('Gafas retiradas.', 'success')
end


local function OpenLsdotGlasses()
    local glasses = Config.Accessories
        and Config.Accessories.tow
        and Config.Accessories.tow.glasses

    if not glasses or #glasses == 0 then
        return LsdotNotify('No hay gafas LSDOT configuradas.', 'error')
    end

    local options = {
        {
            title = 'Quitar gafas',
            description = 'Retirar las gafas actuales.',
            icon = 'ban',
            onSelect = function()
                removeTowGlasses()
            end
        }
    }

    for _, glassesItem in ipairs(glasses) do
        options[#options + 1] = {
            title = glassesItem.label or 'Gafas',
            description = 'Equipar estas gafas.',
            icon = 'glasses',
            onSelect = function()
                applyTowGlasses(glassesItem)
            end
        }
    end

    lib.registerContext({
        id = 'smvlpd_lsdot_glasses',
        title = 'Gafas LSDOT',
        menu = 'smvlpd_lsdot_accessories',
        options = options
    })

    lib.showContext('smvlpd_lsdot_glasses')
end


-- =========================================================
-- MENU ACCESORIOS LSDOT
-- =========================================================

local function OpenLsdotAccessories()
    lib.registerContext({
        id = 'smvlpd_lsdot_accessories',
        title = 'Accesorios LSDOT',
        menu = 'smvlpd_lsdot_locker',
        options = {
            {
                title = 'Gorras',
                description = 'Seleccionar una gorra LSDOT.',
                icon = 'hat-cowboy',
                onSelect = function()
                    OpenLsdotHats()
                end
            },

            {
                title = 'Gafas',
                description = 'Seleccionar unas gafas.',
                icon = 'glasses',
                onSelect = function()
                    OpenLsdotGlasses()
                end
            }
        }
    })

    lib.showContext('smvlpd_lsdot_accessories')
end


-- =========================================================
-- ARMARIO LSDOT
-- =========================================================

function OpenLsdotLocker()
    if not LsdotIsOnDuty() then
        return LsdotNotify('Debes estar de servicio como LSDOT - Grúa.', 'error')
    end

    local rank = lib.callback.await('smvlpd-ranks:server:getRank', false)

    if not rank or rank.service ~= Config.ServiceType then
        return LsdotNotify('No se pudo obtener tu rango de LSDOT.', 'error')
    end

    lib.registerContext({
        id = 'smvlpd_lsdot_locker',
        title = 'Vestuario LSDOT - Grúa',
        options = {

            {
                title = 'Uniforme reglamentario',
                description = 'Equipar el uniforme de tu rango.',
                icon = 'shirt',
                onSelect = function()
                    applyUniform(tonumber(rank.id))
                end
            },

            {
                title = 'Accesorios',
                description = 'Gorras y gafas.',
                icon = 'toolbox',
                onSelect = function()
                    OpenLsdotAccessories()
                end
            }

        }
    })

    lib.showContext('smvlpd_lsdot_locker')
end


-- =========================================================
-- PUNTOS DE VESTUARIO
-- =========================================================

CreateThread(function()
    for _, locker in ipairs(Config.LockerRooms) do

        local point = lib.points.new({
            coords = locker.coords,
            distance = Config.PointDrawDistance
        })

        function point:nearby()
            LsdotDrawMarker(self.coords)

            if self.currentDistance < Config.InteractionDistance then
                lib.showTextUI(Config.Text.Locker)

                if IsControlJustReleased(0, 38) then
                    OpenLsdotLocker()
                end

            elseif lib.isTextUIOpen() then
                lib.hideTextUI()
            end
        end
    end
end)


exports('OpenLsdotLocker', OpenLsdotLocker)