local RankToUniform = {
    [1] = "cadete",
    [2] = "emt",
    [3] = "aemt",
    [4] = "paramedico",
    [5] = "paramedico_senior",
    [6] = "medico",
    [7] = "cirujano",
    [8] = "especialista",
    [9] = "supervisor",
    [10] = "director_adjunto",
    [11] = "director_ems",
    [12] = "director_general"
}

local function ApplyUniform(rank)

    local ped = PlayerPedId()

local hairDrawable = GetPedDrawableVariation(ped, 2)
local hairTexture = GetPedTextureVariation(ped, 2)

SetPedDefaultComponentVariation(ped)

local gender = "male"

    if IsPedModel(ped, `mp_f_freemode_01`) then
        gender = "female"
    end

    local uniformName = RankToUniform[rank] or rank
    local uniform = EMSUniforms[uniformName]

    if not uniform then
        print("^1[EMS]^7 Uniforme no encontrado: " .. tostring(rank))
        return
    end

    uniform = uniform[gender]

    if not uniform then
        print("^1[EMS]^7 No existe uniforme para " .. gender)
        return
    end

    if uniform.components then
        for component, data in pairs(uniform.components) do
            SetPedComponentVariation(
                ped,
                component,
                data[1],
                data[2],
                0
            )
        end
    end

    if uniform.collections then
        for component, data in pairs(uniform.collections) do
            SetPedCollectionComponentVariation(
                ped,
                component,
                data.collection,
                data.drawable,
                data.texture,
                0
            )
        end
    end
SetPedComponentVariation(
    ped,
    2,
    hairDrawable,
    hairTexture,
    0
)


end

function OpenEMSLocker()

    local onDuty = exports["night_ers"]:getIsPlayerOnShift(PlayerId())
    local service = exports["night_ers"]:getPlayerActiveServiceType(PlayerId())

    if not onDuty or service ~= "ambulance" then
        lib.notify({
            description = "Debes estar de servicio como EMS.",
            type = "error"
        })
        return
    end

    lib.registerContext({
        id = "ems_locker_menu",
        title = Config.MenuTitle,
        options = {

            {
                title = "👕 Uniforme reglamentario",
                description = "Equipar el uniforme correspondiente a tu rango.",
                icon = "shirt",
                onSelect = function()

                    local rank = lib.callback.await('smvlpd-ranks:server:getRank', false)

if not rank or rank.service ~= "ambulance" then
    lib.notify({
        description = "No se pudo obtener tu rango EMS.",
        type = "error"
    })
    return
end

ApplyUniform(rank.id)

                    lib.notify({
                        description = "Uniforme aplicado.",
                        type = "success"
                    })

                end
            },

            {
                title = "👤 Ropa de civil",
                description = "Disponible próximamente",
                icon = "user",
                disabled = true
            }

        }
    })

    lib.showContext("ems_locker_menu")

end

exports("OpenEMSLocker", OpenEMSLocker)
