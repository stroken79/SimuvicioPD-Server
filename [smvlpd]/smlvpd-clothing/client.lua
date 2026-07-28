local function ApplyDutyUniform()

    local rank = exports["smvlpd-ranks"]:GetPlayerPoliceRank()

    if not rank then
        lib.notify({
            description = "No se pudo obtener tu rango.",
            type = "error"
        })
        return
    end

    local uniform = Config.Uniforms[rank.id]

    if not uniform then
        lib.notify({
            description = "No existe un uniforme para este rango.",
            type = "error"
        })
        return
    end

    exports["pd5m"]:ApplyUniform(uniform)

    lib.notify({
        description = "Uniforme aplicado.",
        type = "success"
    })

end

local function OpenLocker()

    lib.registerContext({
        id = "smvlpd_clothing",
        title = "Vestuario",
        options = {

            {
                title = "Uniforme reglamentario",
                description = "Equipar uniforme correspondiente a tu rango",
                icon = "shirt",
                onSelect = ApplyDutyUniform
            },

            {
                title = "Ropa de civil",
                description = "Disponible próximamente",
                icon = "user",
                disabled = true
            }

        }
    })

    lib.showContext("smvlpd_clothing")

end

for _, locker in ipairs(Config.Lockers) do

    local point = lib.points.new({
        coords = locker.coords,
        distance = 15
    })

    function point:nearby()

        DrawMarker(
            24,
            self.coords.x,
            self.coords.y,
            self.coords.z + 0.15,
            0.0,0.0,0.0,
            0.0,0.0,0.0,
            0.40, 0.40, 0.40,
            0,150,255,180,
            false,
            true,
            2,
            false,
            nil,
            nil,
            false
        )

        if self.currentDistance < 1.5 then

            lib.showTextUI('[E] Vestuario')

            if IsControlJustReleased(0, 38) then
                OpenLocker()
            end

        else
            lib.hideTextUI()
        end

    end

end