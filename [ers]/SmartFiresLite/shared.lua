function tableHas(data, value)
    for k in pairs(data) do
        if data[k] == value then return true end
    end
    return false
end

function tableLength(T)
    local count = 0
    if T ~= nil then
        for _ in pairs(T) do count = count + 1 end
    end
    return count
end

-- This generates a random UUID (function taken from Stack Overflow)
-- New math.random seed generated each time ensures it is random
function createFireId()
    local random = math.random
    local template ='xxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(8, 0xb)
        return string.format('%x', v)
    end)
end

function roundNumber(num, numDecimalPlaces)
    local mult = 10^(numDecimalPlaces or 0)
    return math.floor(num * mult + 0.5) / mult
end

main = {
    fireSpawnDistance = 200.0,
    smokeSpawnDistance = 500.0,
    usingHoseLS = true,
    distanceToSpawnFiresInFront = 4.0,
    maxWidthOfFiresMultipler = 1.2,
    maximumFinalWidth = 20.0,
    minimumSizeToExtinguish = 0.5,

    debugMode = false,

    distanceToExtinguish = 8.0,
}

-- This configures the weapons used to put out either fires requiring water, or those requiring an extinguisher
weapons = {
    water = {
        model = `weapon_hose`, -- If you are using HoseLS, we do not recommend changing this
        name = "Hose",
        reduceBy = 0.45, -- This is how powerful it is, lower the number the better
        increaseBy = 1.3, --  This is how powerful it is against the wrong fire type, higher the number the more powerful
    },
    extinguisher = {
        model = `weapon_fireextinguisher`,
        name = "Fire Extinguisher",
        reduceBy = 0.56,  -- This is how powerful it is, lower the number the better
        increaseBy = 1.6, --  This is how powerful it is against the wrong fire type, higher the number the more powerful
    }
}

smokeTypes = {
    ["normal"] = {
        dict = "core",
        name = "ent_amb_smoke_foundry",
        maximumSizeManual = 20.0,
        minimumSizeManual = 1.0,
        offSet = {
            x = 0.0,
            y = 0.0,
            z = 0.0,
        },
    }
}

fireTypes = {
    ["normal"] = {
        dict = "core",
        name = "fire_wrecked_truck_vent",
        smoke = {
            enabled = true,
            type = "normal",
            sizeMultiplier = 0.1, -- This is the size of smoke compared to the size of the fire
            keepAfterFire = true,
            keepAfterFireDuration = 30, -- This keeps smoke in the area for x seconds after the fire
            keepAfterFireSize = 0.1, -- This is the size of smoke after the fire compared to the initial size
        },
        toPutOut = { weapons.water, weapons.extinguisher },
        toIncrease = {},
        multiFlamesAllowed = true, -- This defines if multiple flames are allowed for this fire type
        maximumMultipleFlames = 16, -- This defines the maximum flames allowed for this fire type
        difficulty = 20, -- This is how difficult the fire is to put out (out of 50)
        maximumFireSizeManual = 10.0, -- This is the maximum fire size that can be created using the create fire command
        minimumFireSizeAutomatic = 1.5, -- This is the minimum fire size that is started automatically (if automatic fires are enabled)
        maximumFireSizeAutomatic = 4.5, -- This is the minimum fire size that is started automatically (if automatic fires are enabled)
        maximumFireSizeWhenExtinguishing = 10.0, -- This is the maximum fire size that can be created automatically (such as using the wrong weapon to increase the size, such as water on an electrical fire)
        minimumFireSizeManual = 0.5, -- This is the minimum fire size that can be created using the create fire command
        damageDistance = 1.5, -- The distance a player must be nearby to be damaged by the fire
        -- We do not recommend editing the offSet section. This is used to adjust the offset of fires when spawning, for example they may be spawning too low below the player.
        offSet = {
            x = 0.0,
            y = 0.0,
            z = -0.4,
        }
    }
}