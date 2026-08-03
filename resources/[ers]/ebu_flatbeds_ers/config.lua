Config = {}

Config.Debug                    = false -- Used for support

Config.InteractDistance         = 2.0   -- Distance to check if near a truck on foot
Config.CloseVehiclesDistance    = 10.0  -- Distance to check for nearby vehicles
Config.GetInDistance            = 3.5

Config.AutoAttach               = true  --Automatically attach a vehicle when it reaches the min winch length
Config.Doublecheck              = true  -- Double locks the vehicle onto the bed to try and ensure its touching the bed

--Ctrl + Shift Control
Config.DisableCabControl        = true  -- Disables Left Stick Control and Ctrl + Shift while driving.
Config.DisableSpeed             = 3.0   -- Speed at which the controls get disabled

--Rope/Winch Config
Config.EnableRopes              = true  -- if disabled, ALL rope / winching is disabled
Config.WinchSpeed               = 0.11   -- Winch Speed. HIGHLY suggest adjusting in 0.1 increments
Config.MaxWinchLength           = 50
Config.MinWindDistance          = 2.6
Config.AutoWinchOnDetach        = true  -- Automatically attach winch rope when detaching from bed

--Bed Movement                  
Config.BedSpeed                 = 0.0003 -- Speed of the bed movement
Config.DisableUnloadOnUp        = true   --Prevent Unloading car when bed is up
--NOTIFICATIONS--
Config.Notifications            = true  -- See utils.lua for functions

--TRANSLATIONS More customization in utils.lua including key controls
Config.NotiUnLoadCompleteMessage    = "Unload Complete"
Config.NotiLoadCompleteMessage      = "Loading Complete"
Config.NotiBlockedMessage           = "Unloading zone blocked"
Config.NotiFBBlockedMessage         = "Flatbed blocked or occupied"

--========Target System========--
Config.UseTarget                    = false          --Enable Target system. Set up in utils.lua. Supports qb-target by default

--If the below are disabled, it is recommened to set Config.ShowMarkers and Config.ShowHelp to false
Config.DisableExtKeyControls        = false          --Disable key controls for bed control. Attach/Detach from inside vehicle separate
Config.DisableInVehControl          = false         --Disable key controls for in vehicle.

--========Markers & Prompts=======--
--Increases tick rate from 0.01 to 0.08 - 0.1 when in range
Config.ShowMarkers = true           -- Display markers at interaction points
Config.ShowHelp = true              -- Display help prompts

Config.MarkerDistance   = 5.0       -- Distance from point to see marker
Config.WaitTimer = 3000             -- Update rate to check for nearby trailer seconds * 1000 (Default 3000)

Config.MessageDistance = 2.0        -- Distance from point to display message (Default 2.0)
Config.Marker = {
    type = 1,                      -- marker shape: https://docs.fivem.net/docs/game-references/markers/ (Default 27)

    Size = 1.0,                     -- marker size (Default 2.0)

    Color = {                       -- RGBA color
        red = 100,
        green = 200,
        blue = 200,
        alpha = 150
    },
    heightOffset = 0.0,             -- Height from ground for marker. Marker at ground Z (Default 0.0)
    Bob = false,                    -- Marker bobbing up and down (Default false)
    faceCamera = false,             -- Marker always faces camera (Default false)
    rotate = false                  -- Marker rotates (Default false)
}

Config.Controlmessages = {
    LowerBed = "Lower",
    RaiseBed = "Raise bed",
    AttachVehicle = "Attach/Detach",
    WindWinch = "Wind",
    ExtendWinch = "Unwind",
    DetachWinch = "Detach Winch",
    WheelLift = "WheelLift"
}

--========Trucks========--              -- Only the following trucks are supported for the ERS Lite version

Config.flatbed = "flatbed"              -- Base game flatbed
Config.flatbedm2 = "flatbedm2"          -- https://www.gta5-mods.com/vehicles/freightliner-m2-crew-cab-flatbed-add-on-script-beta
Config.lgc19flatbed = "lgc19flatbed"    -- https://forum.cfx.re/t/2019-peterbilt-flatbed/4783413
Config.biftowmfd2 = "biftowmfd2"        -- https://mfd.tebex.io/package/6281210
Config.Gtow = "Gtow"                    -- https://www.gta5-mods.com/vehicles/peterbilt-337-tuning-by-mfd-fivem


-- List any vehicle models here you do not want to be able to be towed
Config.BlacklistedVehs = {
    'kamacho'
}