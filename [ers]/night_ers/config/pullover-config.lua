Config = Config or {}

--====================== Pullover Settings ======================--

Config.EnablePulloverDriverBlip = true
Config.PulloverDriverBlipData = {
    -- UseConfigSprite = true,  -- Optional (uncomment). When true, always use Sprite below. When omitted/false, sprite auto: on foot 458, car 225, motorbike 226, van 853, industrial/utility/commercial 477.
    Sprite = 225,
    Category = 2,
    Display = 4,
    Scale = 0.85,
    Colour = 33,
    ShortRange = false,
    Flashes = false,
    Cone = false,
}

-- Weights for the suspect's reaction after the officer signals (locked phase ends).
-- Values are RELATIVE (they do not need to sum to 100); higher = more likely. Leave any entry at 0 to disable that branch.
-- Defaults below sum to 100, so each weight reads directly as a percentage:
-- 80% comply / 8% flee in vehicle / 6% flee on foot / 6% hostile. Most non-compliance
-- is "drives off" with a smaller share of bails and weapon draws, which matches
-- how traffic stops feel in practice.
Config.PulloverReactionWeights = {
    comply       = 80,  -- comply with the officer's instructions
    flee_vehicle = 8,   -- flee in the vehicle
    flee_foot    = 6,   -- flee on foot
    hostile      = 6,   -- hostile towards the officer
}

-- Modifiers applied on top of PulloverReactionWeights when the MDT identity
-- flags the vehicle as stolen and/or matching an active BOLO.  Keep these
-- conservative — they stack with the base weights, not replace them.
Config.PulloverReactionMdtBumps = {
    stolen_bolo_comply_drop = 25,  -- subtracted from comply weight
    hostile_gain            = 10,  -- added to hostile weight
    flee_vehicle_gain       = 20,  -- added to flee_vehicle weight
}

-- `flee_foot` + `hostile`: TaskLeaveVehicle flag. Default is calm exit with door left open (256).
-- A rolled “dramatic” bail uses 4160 (jump/eject). Set chance to 0 to disable jumps entirely.
Config.PulloverLeaveVehicleDramaticBailChancePercent = 6

-- `hostile` only: weapon loadout. FirearmChancePercent 0–100 = roll for firearm vs melee branch.
-- FirearmWeapons: pool of spawn names — one is picked at random when the firearm branch wins.
-- Legacy single strings `FirearmWeapon` / `MeleeWeapon` still work if the pools are omitted or empty.
Config.PulloverHostileWeapons = {
    FirearmChancePercent = 25,
    FirearmWeapons = {
        "WEAPON_PISTOL",
        "WEAPON_COMBATPISTOL",
        "WEAPON_SNSPISTOL",
    },
    FirearmAmmo = 120,
    MeleeWeapons = {
        "WEAPON_KNIFE",
        "WEAPON_BAT",
        "WEAPON_MACHETE",
    },
}

Config.PulloverDistanceToCheckInFront = 10.0    -- Distance in GTA meters to check in front of the player.
Config.PulloverDistanceToCheckBehind = 10.0     -- Distance in GTA meters to check behind the player.

Config.EnablePulloverLightShade = true          -- Shows a sphere of light where the target vehicle must be to pull them over.
Config.RequireKeyboardInputToPullover = false   -- If true, the player will need to press a key on the keyboard to pull them over instead of using a controller input for example.
Config.PulloverLightShadeData = {
    red = 200, 
    green = 245, 
    blue = 38, 
    range = 2.5, 
    intensity = 10.0,
    shadow = 1.0
}

Config.EnablePulloverMarker = false -- Shows a marker where the target vehicle must be to pull them over.
Config.PulloverMarkerData = {
    MarkerId = 30 --[[ integer ]], 
    dirX = 0 --[[ number ]], 
    dirY = 0 --[[ number ]], 
    dirZ = 0 --[[ number ]], 
    rotX = 90.0 --[[ number ]], 
    rotY = 0.0 --[[ number ]], -- Unused, entity heading used.
    rotZ = 0 --[[ number ]], 
    scaleX = 2.0 --[[ number ]], 
    scaleY = 2.0 --[[ number ]], 
    scaleZ = 5.0 --[[ number ]], 
    red = 200 --[[ integer ]], 
    green = 245 --[[ integer ]], 
    blue = 38 --[[ integer ]], 
    alpha = 225 --[[ integer ]], 
    bobUpAndDown = false --[[ boolean ]], 
    faceCamera = false --[[ boolean ]], 
    p19 = 0 --[[ integer ]], 
    rotate = false --[[ boolean ]], 
    textureDict = 0 --[[ string ]], 
    textureName = 0 --[[ string ]], 
    drawOnEnts = 0 --[[ boolean ]]
}
