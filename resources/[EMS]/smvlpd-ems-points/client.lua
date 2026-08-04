local function OpenGarage()

    lib.registerContext({
        id = "smvlpd_ems_garage",
        title = "Garaje EMS",
        options = {
    {
        title = "Ambulancia",
        description = "Sacar una ambulancia",
        icon = "truck-medical",
        onSelect = function()
            -- Aquí aparecerá la ambulancia
        end
    }
}
    })

    lib.showContext("smvlpd_ems_garage")

end
CreateThread(function()

    for _, locker in pairs(Config.LockerLocations) do

        local point = lib.points.new({
            coords = locker.coords,
            distance = 50
        })

        function point:nearby()

            DrawMarker(
                Config.LockerMarker.Type,
                self.coords.x,
                self.coords.y,
                self.coords.z + 0.10,
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                Config.LockerMarker.Scale.x,
                Config.LockerMarker.Scale.y,
                Config.LockerMarker.Scale.z,
                Config.LockerMarker.Color.r,
                Config.LockerMarker.Color.g,
                Config.LockerMarker.Color.b,
                Config.LockerMarker.Color.a,
                false,
                true,
                2,
                false,
                nil,
                nil,
                false
            )

            if self.currentDistance < Config.InteractionDistance then

                lib.showTextUI(Config.Text.Locker)

                if IsControlJustReleased(0, 38) then
                    -- Aquí irá el menú del vestuario
                end

            else
                lib.hideTextUI()
            end

        end

    end

end)

CreateThread(function()

    for _, garage in pairs(Config.GarageLocations) do

        local point = lib.points.new({
            coords = garage.marker,
            distance = 50
        })

        function point:nearby()

            DrawMarker(
                Config.GarageMarker.Type,
                self.coords.x,
                self.coords.y,
                self.coords.z + 0.10,
                0.0, 0.0, 0.0,
                0.0, 0.0, 0.0,
                Config.GarageMarker.Scale.x,
                Config.GarageMarker.Scale.y,
                Config.GarageMarker.Scale.z,
                Config.GarageMarker.Color.r,
                Config.GarageMarker.Color.g,
                Config.GarageMarker.Color.b,
                Config.GarageMarker.Color.a,
                false,
                true,
                2,
                false,
                nil,
                nil,
                false
            )

            if self.currentDistance < 3.0 then

                lib.showTextUI(Config.Text.Garage)

                if IsControlJustReleased(0, 38) then
                   OpenGarage()
                end

            else

                lib.hideTextUI()

            end

        end

    end

end)