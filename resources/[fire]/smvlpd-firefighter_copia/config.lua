Config = {}

Config.Debug = false
Config.HoseRange = 25.0
Config.WaterDamageInterval = 250
Config.ExtinguishTime = 3000
-- Smoke is a clearance objective, not a flame health pool. A short, continuous
-- water application clears it while still requiring the firefighter to act.
Config.SmokeClearTime = 750
Config.InteractionDistance = 3.0
Config.HoseInteractionControl = 74 -- H, matching the ERS stretcher interaction.

-- SmartHoseLite owns the visual stream, weapon and animation. This resource
-- activates/deactivates that existing command from ox_target.
Config.SmartHoseCommand = 'hose'
Config.HoseWeapon = `weapon_hose`

Config.FireVehicles = {
    [`firetruk`] = { hose = true, waterCannon = true },
    [`spartan`] = { hose = true, waterCannon = true },
    [`ferrara`] = { hose = true, waterCannon = true },
    [`pumper`] = { hose = true, waterCannon = true },
    [`gmc`] = { hose = true, waterCannon = true }
}

Config.WaterCannonVehicles = {
    [`firetruk`] = true,
    [`spartan`] = true,
    [`ferrara`] = true,
    [`pumper`] = true,
    [`gmc`] = true
}

Config.CannonControl = 24 -- INPUT_ATTACK; only sampled while driving a configured apparatus.
Config.CannonMaxDistance = 45.0
