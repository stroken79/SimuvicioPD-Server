Config = Config or {}

Config.Spikestrips = {
    Enabled = true,                     -- Set to false to disable the spikestrip system.
    EnableSpikestripMarkers = false,    -- Set to true to enable the spikestrip marker at the vehicle's trunk.

    -- Spikestrip model and animations
    SpikestripModel = "p_ld_stinger_s",
    SpikestripDeployedAnimationDictionary = "p_ld_stinger_s",
    SpikestripDeployedAnimationName = "p_stinger_s_deploy",
    SpikestripRetractAnimationName = "p_stinger_s_idle_undeployed",

    -- Player animations
    PlayerOpenTrunkAnimationDictionary = "mini@repair",
    PlayerOpenTrunkAnimationName = "fixing_a_ped",

    PlayerDeployAnimationDictionary = "pickup_object",
    PlayerDeployAnimationName = "pickup_low",

    PlayerPickupAnimationDictionary = "pickup_object",
    PlayerPickupAnimationName = "pickup_low",

    -- Settings
    DistanceToDeleteSpikestrips = 150,   -- Distance in meters the initial creator of the spikestrips has to be to automatically delete the spikestrips.
    DoSpikesBlowNPCTires = true,         -- If true, the NPCs will blow their tires when they hit a spikestrip.
    
    -- Vehicle equiped with spikestrips
    VehiclesEquipedWithSpikestrips = {
        -- Default vehicles
        "police",
        "police2",
        "police3",
        "policet",
        "fbi",

        -- Custom vehicles
        "tskodae",
    },

    -- This marker appears near the vehicle's trunk position when the player is near a vehicle with spikestrips. (https://docs.fivem.net/docs/game-references/markers/)
    SpikestripMarker = {                
        Type = 6,
        Offset = {x = 0.0, y = 0.0, z = 0.0},
        Direction = {x = 0.0, y = 0.0, z = 0.0},
        Rotation = {x = 0.0, y = 0.0, z = 0.0},
        Scale = {x = 0.15, y = 0.15, z = 0.15},
        Color = {r = 255, g = 193, b = 7, a = 155},
        BobUpAndDown = false,
        FaceCamera = true,
        P19 = false,
        Rotate = false,
        TextureDict = nil,
        TextureName = nil,
        DrawOnEnts = false
    },

}