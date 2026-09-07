PL = {}
 
PL.Locations = {
    [1] = {
        location = {
            from = vector3(-516.84, 433.22, 97.81),     --Teleport from.
            to = vector3(-502.23, 429.55, 101.92),      --Teleport to.
           
            showBlip = true,                            --Show blip on from-marker.
            blipText = "Vespucci Central",              --Blip text on the blip, if showBlip is true.
            
            text = "Enter House",                       --Text to display on the from-marker.
            textColor = "Red",                          --Text Color. ONLY APPLIES IF EXPORT IS "DrawText". Options: "White", "Red", "Blue", "Green", "Yellow", "Purple", "Black", "Orange"
        },
    },
 
    [2] = {
        location = {
            from = vector3(-686.05, 223.41, 81.84),
            to = vector3(-937.38, 462.93, 98.16),
           
            showBlip = true,
            blipText = "Café Entrance",
            
            text = "Enter Café", 
            textColor = "White",
        },
    },
    [3] = {
        location = {
            from = vector3(338.9248, -583.9759, 74.1656),
            to = vector3(299.6251, -579.7481, 43.2608),
            toHeading = 35.3898,

            showBlip = false,
            blipText = "Pillbox Hill - Helipuerto",

            text = "Bajar a la calle",
            textColor = "Blue",
        },
    },
    [4] = {
        location = {
          from = vector3(334.6747, -1432.1895, 46.5117),
          to = vector3(296.2348, -1449.7047, 29.9666),
          toHeading = 297.9025,

          showBlip = false,
          blipText = "Davis EMS - Helipuerto",

          text = "Bajar a la calle",
          textColor = "Blue",
        },
    },
    [5] = {
    location = {
        from = vector3(-1106.9772, -832.6552, 37.6754),
        to = vector3(-1107.6895, -844.8572, 19.3170),
        toHeading = 140.7594,

        showBlip = false,
        blipText = "Vespucci LSPD - Helipuerto",

        text = "Bajar a la calle",
        textColor = "Blue",
    },
},
[6] = {
    location = {
        from = vector3(566.3610, 4.5882, 103.2336),
        to = vector3(638.1849, 1.7995, 82.7864),
        toHeading = 255.7661,

        showBlip = false,
        blipText = "Vinewood LSPD - Helipuerto",

        text = "Bajar a la calle",
        textColor = "Blue",
    },
},

}

-- Configuración general del recurso
PL.UseBlips = true
PL.BlipSprite = 43
PL.BlipColor = 3
PL.BlipScale = 0.75

PL.DisplayText = "DrawText"
PL.DisplayTextDistance = 10.0
PL.UseTeleportDistance = 2.0

PL.TeleportInVehicle = false
PL.FreezePlayerOnTeleport = false

PL.ScreenFadeOutTimer = 0.25
PL.ScreenFadeInTimer = 0.25

PL.LoopTimer = 0.5
PL.WaitTimer = 1.0
