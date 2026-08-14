local function notify(message, notifyType)
    lib.notify({
        description = message,
        type = notifyType or 'inform'
    })
end

local function applyUniform(rankId)
    local rankConfig = Config.Ranks[rankId]
    local uniform = rankConfig and FireUniforms[rankConfig.name]

    if not uniform then
        FireNotify('No hay uniforme configurado para este rango.', 'error')
        return
    end

    local ped = PlayerPedId()
    local gender = IsPedModel(ped, `mp_f_freemode_01`) and 'female' or 'male'

    uniform = uniform[gender]

    if not uniform then
        FireNotify('No existe uniforme para este personaje.', 'error')
        return
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

    FireNotify('Uniforme aplicado.', 'success')
end


-- =========================================================
-- ACCESORIOS
-- =========================================================

local function getAccessoryGenderData(data)
    local ped = PlayerPedId()

    if IsPedModel(ped, `mp_f_freemode_01`) then
        return data.female
    end

    return data.male
end


local function applyAccessory(accessoryType, data)
    local accessory = getAccessoryGenderData(data)

    if not accessory then
        FireNotify('Este accesorio no está disponible para este personaje.', 'error')
        return
    end

    local ped = PlayerPedId()

    if accessoryType == 'glasses' then
        SetPedPropIndex(
            ped,
            1,
            accessory.drawable,
            accessory.texture,
            true
        )

        FireNotify('Gafas aplicadas.', 'success')

    elseif accessoryType == 'hats' then
        SetPedPropIndex(
            ped,
            0,
            accessory.drawable,
            accessory.texture,
            true
        )

        FireNotify('Gorra / casco aplicado.', 'success')

    elseif accessoryType == 'watches' then
        SetPedPropIndex(
            ped,
            6,
            accessory.drawable,
            accessory.texture,
            true
        )

        FireNotify('Reloj aplicado.', 'success')
    end
end


local function clearAccessory(accessoryType)
    local ped = PlayerPedId()

    if accessoryType == 'glasses' then
        ClearPedProp(ped, 1)

    elseif accessoryType == 'hats' then
        ClearPedProp(ped, 0)

    elseif accessoryType == 'watches' then
        ClearPedProp(ped, 6)
    end

    FireNotify('Accesorio retirado.', 'success')
end


-- =========================================================
-- MENÚ DE ACCESORIOS
-- =========================================================

local function OpenFireAccessoryMenu(accessoryType, title)
    local accessories = Config.Accessories
        and Config.Accessories.fire
        and Config.Accessories.fire[accessoryType]

    if not accessories then
        FireNotify('No hay accesorios configurados.', 'error')
        return
    end

    local options = {
        {
            title = '❌ Quitar',
            description = 'Retirar el accesorio actual.',
            onSelect = function()
                clearAccessory(accessoryType)
            end
        }
    }

    for index, accessory in ipairs(accessories) do
        local accessoryData = accessory

        options[#options + 1] = {
            title = accessoryData.label,
            onSelect = function()
                applyAccessory(accessoryType, accessoryData)
            end
        }
    end

    local menuId = 'smvlpd_fire_accessories_' .. accessoryType

    lib.registerContext({
        id = menuId,
        title = title,
        menu = 'smvlpd_fire_accessories',
        options = options
    })

    lib.showContext(menuId)
end


local function OpenFireAccessories()
    if not Config.Accessories
        or not Config.Accessories.fire then

        FireNotify('No hay accesorios de Bomberos configurados.', 'error')
        return
    end

    lib.registerContext({
        id = 'smvlpd_fire_accessories',
        title = 'Accesorios de Bomberos',
        menu = 'smvlpd_fire_locker',

        options = {
            {
                title = 'Gafas',
                description = 'Seleccionar gafas.',
                icon = 'glasses',
                onSelect = function()
                    OpenFireAccessoryMenu(
                        'glasses',
                        'Gafas de Bomberos'
                    )
                end
            },

            {
                title = 'Gorras / Cascos',
                description = 'Seleccionar gorra o casco.',
                icon = 'hard-hat',
                onSelect = function()
                    OpenFireAccessoryMenu(
                        'hats',
                        'Gorras y Cascos'
                    )
                end
            },

            {
                title = 'Relojes',
                description = 'Seleccionar reloj.',
                icon = 'clock',
                onSelect = function()
                    OpenFireAccessoryMenu(
                        'watches',
                        'Relojes'
                    )
                end
            }
        }
    })

    lib.showContext('smvlpd_fire_accessories')
end


-- =========================================================
-- ARMARIO DE BOMBEROS
-- =========================================================

function OpenFireLocker()
    if not FireIsOnDuty() then
        FireNotify('Debes estar de servicio como Bombero.', 'error')
        return
    end

    local rank = lib.callback.await(
        'smvlpd-ranks:server:getRank',
        false
    )

    if not rank or rank.service ~= Config.ServiceType then
        FireNotify('No se pudo obtener tu rango de Bomberos.', 'error')
        return
    end

    lib.registerContext({
        id = 'smvlpd_fire_locker',
        title = 'Vestuario de Bomberos',

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
                description = 'Gafas, gorras, cascos y relojes.',
                icon = 'toolbox',
                onSelect = function()
                    OpenFireAccessories()
                end
            }
        }
    })

    lib.showContext('smvlpd_fire_locker')
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
            FireDrawMarker(self.coords)

            if self.currentDistance < Config.InteractionDistance then
                lib.showTextUI(Config.Text.Locker)

                if IsControlJustReleased(0, 38) then
                    OpenFireLocker()
                end

            elseif lib.isTextUIOpen() then
                lib.hideTextUI()
            end
        end
    end
end)


exports('OpenFireLocker', OpenFireLocker)