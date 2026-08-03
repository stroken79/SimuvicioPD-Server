local editing = false

local component = 11
local drawable = 0
local texture = 0

RegisterCommand("edituniform", function()

    editing = not editing

    if editing then
        print("[FivePD] Editor abierto")
    else
        print("[FivePD] Editor cerrado")
    end

end)

CreateThread(function()

    while true do

        if editing then

            Wait(0)

            local ped = PlayerPedId()

            BeginTextCommandDisplayHelp("STRING")
            AddTextComponentSubstringPlayerName(
                "~b~EDITOR DE UNIFORMES~n~~w~"..
                "Componente: "..component..
                "~n~Drawable: "..drawable..
                "~n~Texture: "..texture..
                "~n~~g~← → Drawable"..
                "~n~~y~↑ ↓ Texture"..
                "~n~~b~ENTER Cambiar componente"
            )
            EndTextCommandDisplayHelp(0,false,false,-1)

            if IsControlJustPressed(0,174) then
                drawable = math.max(drawable-1,0)
            end

            if IsControlJustPressed(0,175) then
                drawable = drawable+1
            end

            if IsControlJustPressed(0,172) then
                texture = texture+1
            end

            if IsControlJustPressed(0,173) then
                texture = math.max(texture-1,0)
            end

            if IsControlJustPressed(0,191) then

                component = component+1

                if component>11 then
                    component=0
                end

            end

            SetPedComponentVariation(
                ped,
                component,
                drawable,
                texture,
                0
            )

        else

            Wait(1000)

        end

    end

end)