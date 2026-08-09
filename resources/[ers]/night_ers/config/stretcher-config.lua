Config = Config or {}

--====================== Stretcher Settings ======================--

Config.EnableStretcherSpawnEverywhere = false -- Limita la camilla a los vehículos configurados abajo.
Config.PlayerLayDownOnStretcherBedAnimDict = "switch@trevor@annoys_sunbathers"
Config.PlayerLayDownOnStretcherBedAnim = "trev_annoys_sunbathers_loop_girl"
Config.RangeToCheckNearbyAmbulance = 10.0      -- Distance to check for nearby ambulances.    
Config.RangeToCheckForStretcherPoint = 3.0     -- Distance (radius) from the ambulance stretcher point (behindVehicle) to get a prompt saying you can put/take stretcher from it.
Config.VehiclesWithStretchers = {
    -- INFO: behindVehicle is how far behind the ambulance the stretcher is, depth is how deep into the ambulance the stretcher is, height is the offset height of the stretcher inside the ambulance.
    {hash = "ambulance", behindVehicle = -6.0, sideways = 0.1, depth = -1.25, height = 0.65}, -- Default setting. 
}

Config.ShowSavedScreen = true           -- Shows victim saved in GTA style, when dropping off a victim.
Config.StretcherDropOffRadius = 15.0
Config.StretcherDropOffBlipData = {     -- https://docs.fivem.net/docs/game-references/blips/
    Enabled = true,                     -- Set to false to disable blips for the strecher dropoff locations.
    Name = "Medical Center",
    Sprite = 153,
    Display = 2, 
    ShortRange = true,
    Colour = 1, 
    Scale = 0.75,
    Alpha = 200, 
}
Config.StretcherDropOffLocations = {        -- Drop off for stretchers with victims on it. Basically a transfer to hospital personel.
    vector3(358.6897, -591.0747, 28.7968),  -- Pillbox Hill
    vector3(1827.6267, 3692.5576, 34.2244), -- Sandy Shores
    vector3(-246.6335, 6330.6113, 32.4262), -- Paleto Bay
    -- Add more here.
}

Config.StretcherSoundSettings = {
    Raise = {FileName = "stryker_raise", SoundVolume = 0.25},
    Lower = {FileName = "stryker_lower", SoundVolume = 0.25},
    Vehicle = {FileName = "stryker_vehicle", SoundVolume = 0.25},
}

Config.EnableDropOffMarker = true    -- Shows a marker where the target on the stretcher must be to drop them off.
Config.DropOffMarkerData = {
    MarkerId = 30 --[[ integer ]], 
    dirX = 0 --[[ number ]], 
    dirY = 0 --[[ number ]], 
    dirZ = 0 --[[ number ]], 
    rotX = 90.0 --[[ number ]], 
    rotY = 0.0 --[[ number ]], -- Unused, entity heading used.
    rotZ = 0 --[[ number ]], 
    scaleX = 1.0 --[[ number ]], 
    scaleY = 1.0 --[[ number ]], 
    scaleZ = 2.0 --[[ number ]], 
    red = 255 --[[ integer ]], 
    green = 165 --[[ integer ]], 
    blue = 0 --[[ integer ]], 
    alpha = 225 --[[ integer ]], 
    bobUpAndDown = false --[[ boolean ]], 
    faceCamera = false --[[ boolean ]], 
    p19 = 0 --[[ integer ]], 
    rotate = false --[[ boolean ]], 
    textureDict = 0 --[[ string ]], 
    textureName = 0 --[[ string ]], 
    drawOnEnts = 0 --[[ boolean ]]
}
