-- Framework globals (ESX, QBCore, QBox are frameworks — not inventory). Inventory is handled by resources like ox_inventory or qb-inventory.
QBCore = nil
ESX = nil
-- QBox framework: qbx_core uses the same qb-core bridge object as QBCore — https://docs.qbox.re/faq ("No such export GetCoreObject in resource qbx_core"). For qbx-only exports (e.g. GetJobs) use exports.qbx_core.
QBox = nil

local function tryInitESX()
    if GetResourceState("es_extended") ~= "started" then return end
    local ok, obj = pcall(function()
        return exports["es_extended"]:getSharedObject()
    end)
    if ok and obj then ESX = obj end
end

local function tryInitQBCore()
    if GetResourceState("qb-core") ~= "started" then return end
    local ok, obj = pcall(function()
        return exports["qb-core"]:GetCoreObject()
    end)
    if ok and obj then QBCore = obj end
end

local function tryInitQBox()
    if GetResourceState("qbx_core") ~= "started" then return end
    local ok, obj = pcall(function()
        return exports["qb-core"]:GetCoreObject()
    end)
    if ok and obj then QBox = obj end
end

Citizen.CreateThread(function()
    Wait(0)
    tryInitESX()
    tryInitQBCore()
    tryInitQBox()
end)

--- Add one gear item via inventory: ox_inventory if started, else qb-inventory. Not used for bare ESX weapon APIs.
--- metadata: optional; ox_inventory only (e.g. { ammo = n }, { components = { "at_flashlight", ... } } per ox item names).
--- @param src number
--- @param itemName string
--- @param count number
--- @param metadata table|nil
--- @return boolean
local function AddGearInventoryItem(src, itemName, count, metadata)
    count = count or 1

    local function tryOx()
        local okCan, canCarry = pcall(function()
            return exports.ox_inventory:CanCarryItem(src, itemName, count)
        end)
        if not okCan or not canCarry then return false end
        local okAdd, addRes = pcall(function()
            if metadata then
                return exports.ox_inventory:AddItem(src, itemName, count, metadata)
            end
            return exports.ox_inventory:AddItem(src, itemName, count)
        end)
        return okAdd and addRes ~= false
    end

    local function tryQb()
        local okCan, canAdd = pcall(function()
            return exports["qb-inventory"]:CanAddItem(src, itemName, count)
        end)
        if not okCan or not canAdd then return false end
        local okAdd = pcall(function()
            exports["qb-inventory"]:AddItem(src, itemName, count)
        end)
        return okAdd
    end

    if GetResourceState("ox_inventory") == "started" then
        return tryOx()
    end
    if GetResourceState("qb-inventory") == "started" then
        return tryQb()
    end
    return false
end

--- Remove gear items previously issued by ERS (ox_inventory or qb-inventory). Ignores missing stacks.
--- @param src number
--- @param itemName string
--- @param count number
local function RemoveGearInventoryItem(src, itemName, count)
    count = count or 1
    if count < 1 then return end

    if GetResourceState("ox_inventory") == "started" then
        local okSearch, have = pcall(function()
            return exports.ox_inventory:Search(src, "count", itemName) or 0
        end)
        if not okSearch or not have or have < 1 then return end
        pcall(function()
            exports.ox_inventory:RemoveItem(src, itemName, math.min(count, have))
        end)
        return
    end

    if GetResourceState("qb-inventory") == "started" then
        pcall(function()
            exports["qb-inventory"]:RemoveItem(src, itemName, count)
        end)
    end
end

-- Ledger of inventory items ERS issued per player (cleared on disconnect). Used to replace loadouts without duplicates.
local PlayerIssuedGearItems = {}

local function StripIssuedGearInventory(src)
    local prev = PlayerIssuedGearItems[src]
    if not prev then return end
    for i = 1, #prev do
        local entry = prev[i]
        RemoveGearInventoryItem(src, entry.itemName, entry.count)
    end
    PlayerIssuedGearItems[src] = nil
end

AddEventHandler("playerDropped", function()
    PlayerIssuedGearItems[source] = nil
end)

-- qb-inventory ammo item names for each GTA ammotype; source table is QBCore/QBox.Shared.Weapons (qb-core resource). Used when ox_inventory is off or the weapon has no ammoname in ox data.
local QB_AMMOTYPE_TO_ITEM_NAME = {
    AMMO_PISTOL = "pistol_ammo",
    AMMO_SMG = "smg_ammo",
    AMMO_SHOTGUN = "shotgun_ammo",
    AMMO_RIFLE = "rifle_ammo",
    AMMO_MG = "mg_ammo",
    AMMO_SNIPER = "snp_ammo",
    AMMO_SNIPER_REMOTE = "snp_ammo",
    AMMO_EMPLAUNCHER = "emp_ammo",
}

local function LookupQbSharedWeapon(weaponName)
    local qbCore = QBCore or QBox
    if not qbCore or not qbCore.Shared or not qbCore.Shared.Weapons or not weaponName then return nil end
    local weapons = qbCore.Shared.Weapons
    local w = weapons[GetHashKey(weaponName)]
    if w then return w end
    local low = weaponName:lower()
    if low ~= weaponName then
        w = weapons[GetHashKey(low)]
        if w then return w end
    end
    local up = weaponName:upper()
    if up ~= weaponName then
        w = weapons[GetHashKey(up)]
        if w then return w end
    end
    return nil
end

--- Resolves ammo item name: prefer ox_inventory weapon data (ammoname), else QBCore/QBox Shared.Weapons ammotype → qb-inventory item. nil = no separate ammo stack (use weapon metadata if needed).
--- @param weaponName string
--- @return string|nil
local function ResolveGearAmmoItemName(weaponName)
    if not weaponName or type(weaponName) ~= "string" then return nil end
    if GetResourceState("ox_inventory") == "started" then
        local ok, item = pcall(function()
            return exports.ox_inventory:Items(weaponName)
        end)
        if ok and type(item) == "table" and item.weapon and item.ammoname and item.ammoname ~= "" then
            return item.ammoname
        end
    end
    local w = LookupQbSharedWeapon(weaponName)
    if w and w.ammotype and type(w.ammotype) == "string" then
        return QB_AMMOTYPE_TO_ITEM_NAME[w.ammotype]
    end
    return nil
end

--- ox_inventory Weapon.Equip indexes Items[name].client.component for each metadata.components entry; unknown names crash the client. Server Items() strips client but marks data/weapons Components with component = true.
--- @param names string[]
--- @return string[]
local function FilterOxGearComponentItemNames(names)
    if GetResourceState("ox_inventory") ~= "started" or type(names) ~= "table" or #names == 0 then
        return names
    end
    local out = {}
    local resName = GetCurrentResourceName()
    for i = 1, #names do
        local name = names[i]
        if type(name) == "string" and name ~= "" then
            local ok, item = pcall(function()
                return exports.ox_inventory:Items(name)
            end)
            if ok and type(item) == "table" and item.component == true then
                out[#out + 1] = name
            else
                print(("^3[%s]^7 gear: skipped componentList entry %q — not an ox_inventory attachment item (use names from ox_inventory data/weapons.lua Components, e.g. at_flashlight, at_clip_extended_pistol)."):format(resName, name))
            end
        end
    end
    return out
end

--- ammoType: omit or nil → auto-resolve (ox ammoname, else QBCore/QBox Shared.Weapons); non-empty string → force that ammo item; false → clip metadata only (ammoCount). Same for ESXWeaponData and QBCoreWeaponData inventory rows.
--- ox_inventory: componentList → weapon metadata.components (ox attachment item names). qb-inventory: componentList still added as separate items.
--- @param issuedLedger table|nil When set, records each item successfully added so a later loadout can strip ERS-issued gear first.
local function DistributeGearInventoryRow(src, v, issuedLedger)
    local function recordIssued(itemName, itemCount)
        if not issuedLedger or not itemName or not itemCount or itemCount < 1 then return end
        issuedLedger[#issuedLedger + 1] = { itemName = itemName, count = itemCount }
    end
    local ammoItem
    if v.ammoType == false then
        ammoItem = nil
    elseif type(v.ammoType) == "string" and v.ammoType ~= "" then
        ammoItem = v.ammoType
    else
        ammoItem = ResolveGearAmmoItemName(v.weaponName)
    end
    local n = v.ammoCount and tonumber(v.ammoCount)
    local oxStarted = GetResourceState("ox_inventory") == "started"

    local compArray = {}
    for _, c in ipairs(v.componentList or {}) do
        if type(c) == "string" and c ~= "" then
            compArray[#compArray + 1] = c
        end
    end

    local wMeta = nil
    if n and n > 0 and not ammoItem then
        wMeta = { ammo = math.floor(n) }
    end
    if oxStarted and #compArray > 0 then
        wMeta = wMeta or {}
        local oxComponents = FilterOxGearComponentItemNames(compArray)
        if #oxComponents > 0 then
            wMeta.components = oxComponents
        end
    end

    if AddGearInventoryItem(src, v.weaponName, 1, wMeta) then
        recordIssued(v.weaponName, 1)
        if ammoItem and n and n > 0 then
            local ammoCount = math.floor(n)
            if AddGearInventoryItem(src, ammoItem, ammoCount) then
                recordIssued(ammoItem, ammoCount)
            end
        end
        if not oxStarted then
            for _, component in pairs(v.componentList or {}) do
                if type(component) == "string" and component ~= "" then
                    if AddGearInventoryItem(src, component, 1) then
                        recordIssued(component, 1)
                    end
                end
            end
        end
    end
end

-- ============================================
-- ERS INTEGRATION (For developers only, no customization support will be provided for this by Nights Software)
-- ============================================

--- Handles user shift toggle events.
-- @param src number The source ID of the user who toggled shift.
-- @param isOnShift boolean Whether the user is now on shift or off shift.
-- @param serviceType string The service type of the shift (police, fire, ambulance, tow).
RegisterServerEvent("ErsIntegration::OnToggleShift")
AddEventHandler("ErsIntegration::OnToggleShift", function(reportedSource, isOnShift, serviceType)
    local playerSource = source

    -- ERS es la unica autoridad para el turno. PD5M recibe el estado para que
    -- los avisos, garajes y armerias propias sigan comprobando el servicio.
    if isOnShift == true and serviceType == 'police' then
        TriggerClientEvent('pd5m:setDuty', playerSource, true)
    elseif isOnShift == false then
        TriggerClientEvent('pd5m:setDuty', playerSource, false)
    end
end)

--- Handles first-time NPC interaction events.
-- @param src number The source ID of the user who interacted with the NPC.
-- @param pedData table The complete data table of the NPC being interacted with.
-- @param context string The interaction context:
--
-- Timing & data source:
-- ─────────────────────
--   • When night_shifts_mdt is NOT running, this event fires immediately with
--     ERS-generated random identity data, exactly as it always has
--     (mode tag: "mdt-disabled").
--   • When night_shifts_mdt IS running, the client resolves the MDT identity
--     up-front via ERS_FetchPedDataWithMDT BEFORE asking the server for
--     pedData.  The server merges the identity synchronously and fires this
--     event in the same tick (mode tag: "mdt-merged").  Identity fields
--     (FirstName, LastName, DOB, Gender, Address, City, etc.) come from the
--     MDT's persistent civilian record — the same values the officer sees in
--     the MDT UI.  No more deferred firing, no more 5s watchdog.
--   • License_* on pedData are filled from nsmdt_licences when the MDT merge
--     runs (same ERS field names as RNG mode). FlagsOrMarkers are filled from
--     active PNC flags via MdtFlagRowsToErsFlagsOrMarkers (see mdt_bridge.lua);
--     use GetCivilianIntegrationSnapshot when you need raw flag rows / full PNC.
--   • If the MDT can't resolve a civilian record (animal ped, freshly-spawned
--     NPC, MDT filter rejection) or the client-side MDT lookup times out
--     (2s hard cap), the event still fires once with the partial pedData and
--     identity fields stay nil (mode tag: "mdt-no-civilian").
RegisterServerEvent("ErsIntegration::OnFirstNPCInteraction")
AddEventHandler("ErsIntegration::OnFirstNPCInteraction", function(source, pedData, context)
    -- Add your custom NPC interaction logic here
    --[[
        Context frequency analysis:
        -- Explained: "First interaction with this specific NPC instance in current session, unless the network ID was replaced. Then it can be an other instance for the same NPC."

        - "on_interaction": Very common (normal ped interactions)
        - "on_aiming_at_ped": Common (when aiming at peds and ordering them to kneel)
        - "on_pullover": Common (traffic stops)
        - "on_pursuit_start": Uncommon (callout/world event peds fleeing, regular peds are usually interacted with first)
        - "on_pursuit_end": Very rare (edge cases only)
        - "on_pullover_end": Very rare (edge cases only)
    ]]
    -- print(source, json.encode(pedData, { indent = true }), context)
end)

-- Handles first vehicle interaction events.
-- @param src number The source ID of the user who interacted with the vehicle.
-- @param vehicleData table The complete data table of the vehicle being interacted with.
-- @param context string The interaction context:
--
-- Timing & data source:
-- ─────────────────────
--   • When night_shifts_mdt is NOT running, this event fires immediately with
--     ERS-rolled random compliance data (tax / mot / insurance / stolen / bolo),
--     exactly as it always has (mode tag: "mdt-disabled").
--   • When night_shifts_mdt IS running, the client resolves the MDT vehicle
--     identity up-front via ERS_FetchVehicleDataWithMDT BEFORE asking the
--     server for vehicleData.  The server merges compliance + owner_name
--     synchronously and fires this event in the same tick (mode tag:
--     "mdt-merged").  Compliance fields and owner_name come from the MDT's
--     persistent vehicle record — the same values the officer sees in the
--     MDT UI.  For stolen vehicles, owner_name is the victim's name (taken
--     from identity.owner) rather than the driver.
--   • If the MDT has no record for the vehicle (unregistered plate, filter
--     rejection) or the client-side MDT lookup times out (2s hard cap), the
--     event still fires once with the partial vehicleData (compliance fields
--     stay nil — mode tag: "mdt-no-vehicle").
RegisterServerEvent("ErsIntegration::OnFirstVehicleInteraction")
AddEventHandler("ErsIntegration::OnFirstVehicleInteraction", function(source, vehicleData, context)
    -- Add your custom vehicle interaction logic here
    --[[
        Context frequency analysis:
        -- Explained: "First interaction with this specific vehicle instance in current session, unless the network ID was replaced. Then it can be an other instance for the same vehicle."

        - "on_pullover": Very common (traffic stops)
        - "on_vehicle_search": Common (when searching for vehicles)
        - "on_pursuit_start": Uncommon (callout/world event peds fleeing whilst in a vehicle and not interacted with yet)
        - "on_pullover_end": Very rare (edge cases only)
    ]]
    -- print(source, json.encode(vehicleData, { indent = true }), context)
end)

--- Handles when a callout is offered.
-- @param calloutData table The data of the callout.
RegisterServerEvent("ErsIntegration::OnIsOfferedCallout")
AddEventHandler("ErsIntegration::OnIsOfferedCallout", function(calloutData)
    local src = source
    -- Add your custom callout offered logic here
    -- print(src, calloutData)
end)

--- Handles when a callout is accepted.
-- @param calloutData table The data of the callout.
RegisterServerEvent("ErsIntegration::OnAcceptedCalloutOffer")
AddEventHandler("ErsIntegration::OnAcceptedCalloutOffer", function(calloutData)
    local src = source
    if GetResourceState('smvlpd-ranks') ~= 'started' or type(calloutData) ~= 'table' then return end
    exports['smvlpd-ranks']:BeginExternalPoliceCallout(src, calloutData.calloutId)
end)

--- Handles when a callout is arrived at.
-- @param calloutData table The data of the callout.
RegisterServerEvent("ErsIntegration::OnArrivedAtCallout")
AddEventHandler("ErsIntegration::OnArrivedAtCallout", function(calloutData)
    local src = source
    -- Add your custom callout arrived at logic here
    -- print(src, calloutData)
end)

--- Handles when a callout is ended.
RegisterServerEvent("ErsIntegration::OnEndedACallout")
AddEventHandler("ErsIntegration::OnEndedACallout", function()
    local src = source
    -- Add your custom callout ended logic here
    -- print(src)
end)

--- Handles when a callout is completed successfully.
-- @param calloutData table The data of the callout.
RegisterServerEvent("ErsIntegration::OnCalloutCompletedSuccesfully")
AddEventHandler("ErsIntegration::OnCalloutCompletedSuccesfully", function(calloutData)
    local src = source
    if GetResourceState('smvlpd-ranks') ~= 'started' then return end

    calloutData = type(calloutData) == 'table' and calloutData or {}
    exports['smvlpd-ranks']:AwardExternalPoliceCallout(src, calloutData.calloutId, calloutData.CalloutName)
end)

--- Handles when a pullover is initiated.
-- @param pedData table The data of the ped.
-- @param vehicleData table The data of the vehicle.
RegisterServerEvent("ErsIntegration::OnPullover")
AddEventHandler("ErsIntegration::OnPullover", function(pedData, vehicleData)
    local src = source
    -- Add your custom pullover logic here
    -- print(src, pedData, vehicleData)
end)

--- Handles when a pullover is ended.
-- @param pedData table The data of the ped.
-- @param vehicleData table The data of the vehicle.
RegisterServerEvent("ErsIntegration::OnPulloverEnded")
AddEventHandler("ErsIntegration::OnPulloverEnded", function(pedData, vehicleData)
    local src = source
    -- Add your custom pullover ended logic here
    -- print(src, pedData, vehicleData)
end)

--- Handles when a pursuit is started.
-- @param pedNetId number The network ID of the ped.
RegisterServerEvent("ErsIntegration::OnPursuitStarted")
AddEventHandler("ErsIntegration::OnPursuitStarted", function(pedData)
    local src = source
    -- Add your custom pursuit started logic here
    -- print(src, pedData)
end)

--- Handles when a pursuit is ended.
-- @param pedData table The data of the ped.
RegisterServerEvent("ErsIntegration::OnPursuitEnded")
AddEventHandler("ErsIntegration::OnPursuitEnded", function(pedData)
    local src = source
    -- Add your custom pursuit ended logic here, note that it's possible that the ped is being deleted on losing the target.
    -- print(src, pedData)
end)

--- Handles when an AI person is delivered to hospital.
-- @param src number|table The source ID of the medic, or pedData when fired from a legacy client path.
-- @param pedData table|nil The data of the ped when fired from validated hospital delivery.
RegisterServerEvent("ErsIntegration::OnPersonDeliveredToHospital")
AddEventHandler("ErsIntegration::OnPersonDeliveredToHospital", function(src, pedData)
    if type(src) == "table" and pedData == nil then
        pedData = src
        src = source
    end
    -- Add your custom hospital delivery logic here (third-party stretcher integrations, rewards, logging, etc.).
    -- print(src, pedData)
end)

-- ============================================
-- GEAR SYSTEM
-- ============================================

--- Handles weapon, ammo, and component distribution to players.
-- Frameworks: QBCore or QBox (player from qb-core bridge), ESX (xPlayer APIs), or neither (native GTA only).
-- Inventory: ox_inventory if started, else qb-inventory; ESX without ox uses es_extended; QBCore without either uses native GTA weapons.
-- @param weaponData table The weapon data containing weapons, ammo, and components.
RegisterServerEvent(Config.EventPrefix..":setWeaponsAmmoComponents")
AddEventHandler(Config.EventPrefix..":setWeaponsAmmoComponents", function(weaponData)
    local src = source

    local qbCore = QBCore or QBox
    if qbCore then
        local Player = qbCore.Functions.GetPlayer(src)
        if not Player then
            DebugPrint("ERROR: Could not find QBCore/QBox player with ID: "..src)
            return
        end
        if weaponData then
            local hasInv = GetResourceState("ox_inventory") == "started" or GetResourceState("qb-inventory") == "started"
            if not hasInv then
                DebugPrint("ERS: No supported inventory script for QBCore/QBox gear — falling back to native GTA weapons (start ox_inventory or qb-inventory to give items).")
                for k, v in pairs(weaponData) do
                    local playerPed = GetPlayerPed(src)
                    GiveWeaponToPed(playerPed, GetHashKey(v.weaponName), v.ammoCount, false, true)
                    if v.componentList and #v.componentList > 0 then
                        for _, component in pairs(v.componentList) do
                            GiveWeaponComponentToPed(playerPed, GetHashKey(v.weaponName), GetHashKey(component))
                            DebugPrint("[^4DEBUG ^7] Set component "..component.." to given weapon "..v.weaponName)
                        end
                    end
                end
            else
                StripIssuedGearInventory(src)
                local issuedLedger = {}
                for k, v in pairs(weaponData) do
                    DistributeGearInventoryRow(src, v, issuedLedger)
                end
                if #issuedLedger > 0 then
                    PlayerIssuedGearItems[src] = issuedLedger
                end
            end
        end
    elseif ESX then
        local xPlayer = ESX.GetPlayerFromId(src)
        if not xPlayer then
            DebugPrint("ERROR: Could not find xPlayer with ID: "..src)
            return
        end
        if weaponData then
            local useOxInventory = GetResourceState("ox_inventory") == "started"

            if useOxInventory then
                StripIssuedGearInventory(src)
                local issuedLedger = {}
                for k, v in pairs(weaponData) do
                    DistributeGearInventoryRow(src, v, issuedLedger)
                end
                if #issuedLedger > 0 then
                    PlayerIssuedGearItems[src] = issuedLedger
                end
            else
                for k, v in pairs(weaponData) do
                    if xPlayer.hasWeapon(v.weaponName) then
                        xPlayer.removeWeapon(v.weaponName)
                        xPlayer.addWeapon(v.weaponName, v.ammoCount)
                        xPlayer.addWeaponAmmo(v.weaponName, v.ammoCount)
                    else
                        xPlayer.addWeapon(v.weaponName, v.ammoCount)
                    end

                    for _, component in pairs(v.componentList or {}) do
                        if xPlayer.hasWeaponComponent(v.weaponName, component) then
                            xPlayer.removeWeaponComponent(v.weaponName, component)
                            xPlayer.addWeaponComponent(v.weaponName, component)
                        else
                            xPlayer.addWeaponComponent(v.weaponName, component)
                        end
                    end
                end
            end
        end
    else
        -- Default GTA V Weapons
        for k, v in pairs(weaponData) do
            local playerPed = GetPlayerPed(src)
            GiveWeaponToPed(playerPed, GetHashKey(v.weaponName), v.ammoCount, false, true)
            if #v.componentList > 0 then
                for i, component in pairs(v.componentList) do
                    GiveWeaponComponentToPed(playerPed, GetHashKey(v.weaponName), GetHashKey(component))
                    DebugPrint("[^4DEBUG ^7] Set component "..component.." to given weapon "..v.weaponName)
                end
            end
        end
    end
    -- Add other or more logic here...
end)

-- ============================================
-- SERVICE PERMISSION MANAGEMENT
-- ============================================

-- Checks if a player is authorized to access a specific service.
-- Supports multiple permission systems: Discord API, Ace, ESX, QBCore.
-- @param source number The player's source ID.
-- @param rolesOrGroups table Array of roles or groups to check against.
-- @return boolean True if player has permission, false otherwise.
function CheckIsPlayerAllowedToPlayServiceByRoleOrGroups(source, rolesOrGroups)
    local permission = false

    -- If this is enabled, everyone can play any service at any time.
    if Config.EveryoneHasPermission then
        return true
    end

    -- Discord API Permissions
    if Config.Enable_Night_DiscordApi_Permissions then
        local isPermitted = exports.night_discordapi:IsMemberPartOfAnyOfTheseRoles(source, rolesOrGroups)
        if isPermitted then
            permission = true
        end
    end

    -- Ace Permissions
    if Config.Enable_Ace_Permissions then
        for _, roleOrGroup in pairs(rolesOrGroups) do
            if IsPlayerAceAllowed(source, roleOrGroup) then
                permission = true
                break
            end
        end
    end

    -- ESX Job Permissions
    if Config.Enable_ESX_Permissions.Check_By_Job then
        if ESX == nil then return print("You've enabled ESX job permissions, but the ESX framework has not been found...") end
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            for _, job in pairs(rolesOrGroups) do
                if xPlayer.job.name == job then
                    permission = true
                    break
                end
            end
        end
    end

    -- ESX Permission Based
    if Config.Enable_ESX_Permissions.Check_By_Permissions then
        if ESX == nil then return print("You've enabled ESX group permissions, but the ESX framework has not been found...") end
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            for _, group in pairs(rolesOrGroups) do
                if xPlayer.getGroup() == group then
                    permission = true
                    break
                end
            end
        end
    end

    -- QBCore Job Based
    if Config.Enable_QBCore_Permissions.Check_By_Job then
        if QBCore == nil then return print("You've enabled QBCore job permissions, but the QBCore framework has not been found...") end
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            for _, job in pairs(rolesOrGroups) do
                if Player.PlayerData.job.name == job then
                    permission = true
                    break
                end
            end
        end
    end

    -- QBCore Permission based
    if Config.Enable_QBCore_Permissions.Check_By_Permissions then
        if QBCore == nil then return print("You've enabled QBCore group permissions, but the QBCore framework has not been found...") end
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            for _, perm in pairs(rolesOrGroups) do
                if QBCore.Functions.HasPermission(source, perm) then
                    permission = true
                end
            end
        end
    end
    return permission
end

-- ============================================
-- GEAR LOADOUT PERMISSION MANAGEMENT
-- ============================================

-- Checks if a player is authorized to select specific gear loadouts.
-- Supports multiple permission systems: Discord API, Ace, ESX, QBCore.
-- @param source number The player's source ID.
-- @param rolesOrGroups table Array of roles or groups to check against.
-- @return boolean True if player has permission, false otherwise.
function CheckIsPlayerAllowedToSelectGearByRoleOrGroups(source, rolesOrGroups)
    local permission = false

    -- If this is enabled, everyone can select any gear loadout/uniform.
    if not Config.GearData.Enable_Gear_Permissions then
        return true
    end

    -- Discord API Permissions
    if Config.GearData.Enable_Night_DiscordApi_Permissions then
        local isPermitted = exports.night_discordapi:IsMemberPartOfAnyOfTheseRoles(source, rolesOrGroups)
        if isPermitted then
            permission = true
        end
    end

    -- Ace Permissions
    if Config.GearData.Enable_Ace_Permissions then
        for _, roleOrGroup in pairs(rolesOrGroups) do
            if IsPlayerAceAllowed(source, roleOrGroup) then
                permission = true
                break
            end
        end
    end

    -- ESX Job Permissions
    if Config.GearData.Enable_ESX_Permissions.Check_By_Job then
        if ESX == nil then return print("You've enabled ESX job permissions, but the ESX framework has not been found...") end
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            for _, job in pairs(rolesOrGroups) do
                if xPlayer.job.name == job then
                    permission = true
                    break
                end
            end
        end
    end

    -- ESX Permission Based
    if Config.GearData.Enable_ESX_Permissions.Check_By_Permissions then
        if ESX == nil then return print("You've enabled ESX group permissions, but the ESX framework has not been found...") end
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            for _, group in pairs(rolesOrGroups) do
                if xPlayer.getGroup() == group then
                    permission = true
                    break
                end
            end
        end
    end

    -- QBCore Job Based
    if Config.GearData.Enable_QBCore_Permissions.Check_By_Job then
        if QBCore == nil then return print("You've enabled QBCore job permissions, but the QBCore framework has not been found...") end
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            for _, job in pairs(rolesOrGroups) do
                if Player.PlayerData.job.name == job then
                    permission = true
                    break
                end
            end
        end
    end

    -- QBCore Permission based
    if Config.GearData.Enable_QBCore_Permissions.Check_By_Permissions then
        if QBCore == nil then return print("You've enabled QBCore group permissions, but the QBCore framework has not been found...") end
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            for _, perm in pairs(rolesOrGroups) do
                if QBCore.Functions.HasPermission(source, perm) then
                    permission = true
                end
            end
        end
    end
    return permission
end

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

-- Retrieves custom player name for shift management integration.
-- Integrates with night_shifts_mdt MDT system if enabled.
-- @param id number|string The player's source ID.
-- @return string The player's callsign or display name.
function GetCustomPlayerName(id)
    local src = tonumber(id)
    local srcName = GetPlayerName(src)

    if ERS_IsNightShiftsManageShiftsByMDTActive() then
        -- New MDT (night_shifts_mdt): flat table, callsign field
        local data = exports['night_shifts_mdt']:GetUserShiftData(src)
        if data and data.isOnShift and data.callsign then
            srcName = data.callsign
        end
    end

    return srcName
end

--- Capitalizes the first letter of a string.
-- @param str string The input string.
-- @return string String with first letter capitalized.
function firstToUpper(str)
    return (str:gsub("^%l", string.upper))
end

--- Converts entire string to uppercase.
-- @param str string The input string.
-- @return string Fully uppercase string.
function allToUpper(str)
    return (string.upper(str))
end

-- ============================================
-- RANDOM DATA GENERATION FUNCTIONS
-- ============================================

--- Generates a random license status result based on configured probabilities.
-- @return string, boolean, string, string | Status, validity, color, icon.
function GenerateRandomLicenseResult()
    -- Calculate total weight
    local totalWeight = 0
    for _, result in pairs(Config.RandomLicenseResults) do
        totalWeight = totalWeight + result.Chance
    end

    -- Generate random number based on total weight
    local chance = math.random(1, totalWeight)
    local runningTotal = 0

    -- Check each result against its proportional range
    for _, result in pairs(Config.RandomLicenseResults) do
        runningTotal = runningTotal + result.Chance
        if chance <= runningTotal then
            return result.Status, result.IsStatusValid, result.Colour, result.Icon
        end
    end

    -- If no license result is found (shouldn't happen), return nil
    return nil, nil, nil, nil
end

--- Generates random criminal flags and markers for NPCs.
-- Uses configured probability to determine if NPC has criminal history.
-- @return table Table containing all flag states and descriptions.
function GenerateRandomFlagsOrMarkers()
    local FlagsOrMarkers = {}
    local FLAG_OR_MARKER_CHANCE = Config.ChanceToHaveRecords

    -- Initial check if person should have any flags or markers at all
    if math.random(1, 100) > FLAG_OR_MARKER_CHANCE then
        return {
            armed_and_dangerous = false,
            assault = false,
            burglary = false,
            drug_related = false,
            gang_affiliation = false,
            homicide = false,
            kidnapping = false,
            mental_health_issues = false,
            sex_offense = false,
            terrorism = false,
            theft = false,
            traffic_violation = false,
            wanted_person = false,
            other = false,
            active_warrant = false,
        }
    end

    -- Helper function to determine if warrant should be active
    local function shouldHaveFlagOrMarker()
        return math.random(1, 100) <= FLAG_OR_MARKER_CHANCE
    end

    -- Generate a suitable flag_description based off the flag or marker which is true
    local function GenerateFlagDescription(flagsOrMarkers)
        local descriptions = {}
        for flag, isTrue in pairs(flagsOrMarkers) do
            if isTrue and Config.RandomFlagsOrMarkersDescriptions[flag] then
                local descriptionsList = Config.RandomFlagsOrMarkersDescriptions[flag]
                local randomIndex = math.random(#descriptionsList)
                table.insert(descriptions, descriptionsList[randomIndex])
            end
        end
        if #descriptions == 0 then
            return "None"
        else
            return table.concat(descriptions, ", ")
        end
    end

    FlagsOrMarkers = {
        armed_and_dangerous = shouldHaveFlagOrMarker(),
        assault = shouldHaveFlagOrMarker(),
        burglary = shouldHaveFlagOrMarker(),
        drug_related = shouldHaveFlagOrMarker(),
        gang_affiliation = shouldHaveFlagOrMarker(),
        homicide = shouldHaveFlagOrMarker(),
        kidnapping = shouldHaveFlagOrMarker(),
        mental_health_issues = shouldHaveFlagOrMarker(),
        sex_offense = shouldHaveFlagOrMarker(),
        terrorism = shouldHaveFlagOrMarker(),
        theft = shouldHaveFlagOrMarker(),
        traffic_violation = shouldHaveFlagOrMarker(),
        wanted_person = shouldHaveFlagOrMarker(),
        other = shouldHaveFlagOrMarker(),
        active_warrant = shouldHaveFlagOrMarker(),
    }

    local flag_description = GenerateFlagDescription(FlagsOrMarkers)
    FlagsOrMarkers.flag_description = flag_description

    return FlagsOrMarkers
end

--- Selects a random home address from the configured address list.
-- @return string A randomly selected home address.
function GenerateRandomHomeAddress()
    local library = Config.RandomHomeAddressList
    local randomIndex = math.random(#library)
    return library[randomIndex]
end

--- Generates a random date of birth within realistic age ranges (1970-2005).
-- Handles leap years and month-specific day limits.
-- @return string Formatted date string based on Config.DOBFormat.
function GenerateRandomDOB()
    -- Define the range of years
    local minYear = 1970
    local maxYear = 2005

    -- Generate a random year within the range
    local year = math.random(minYear, maxYear)

    -- Generate a random month (1-12)
    local month = math.random(1, 12)

    -- Generate a random day within the month
    local maxDay
    if month == 2 then
        -- Check for February
        if year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0) then
            -- Leap year
            maxDay = 29
        else
            maxDay = 28
        end
    elseif month == 4 or month == 6 or month == 9 or month == 11 then
        -- Months with 30 days
        maxDay = 30
    else
        -- Months with 31 days
        maxDay = 31
    end

    -- Generate a random day
    local day = math.random(1, maxDay)

    -- Determine the format and return the generated date of birth
    if Config.DOBFormat == "en" then
        return string.format("%02d-%02d-%04d", day, month, year)
    elseif Config.DOBFormat == "us" then
        return string.format("%02d-%02d-%04d", month, day, year)
    else
        return "Unknown"
    end
end

--- Selects a random nationality from the configured nationality list.
-- @return string A randomly selected nationality.
function GenerateRandomNationality()
    local randomIndex = math.random(1, #Config.RandomNationalities)
    local nationality = Config.RandomNationalities[randomIndex]
    return nationality
end

--- Generates a random phone number in UK format.
-- Format can be changed by modifying the function logic.
-- @return string A randomly generated phone number.
function GenerateRandomPhoneNumber()
    -- UK format
    local phoneNumber = "07" .. math.random(10000000, 99999999)
    return phoneNumber

    -- -- US format
    -- local phoneNumber = "1" .. math.random(2000000000, 9999999999)
    -- return phoneNumber

    -- -- NL format
    -- local phoneNumber = "06" .. math.random(10000000, 99999999)
    -- return phoneNumber
end

--- Generates complete address information including country, state, city, postal code, and address.
-- Handles error checking for empty configuration tables.
-- @return string, string, string, string, string, string Country, state, city, postal code, address, property type.
function GenerateRandomStateCityPostalCodeRangeAndAddress()
    -- Error handling for empty/nil tables
    if not Config.RandomStates or #Config.RandomStates == 0 then
        DebugPrint("^1ERROR ^7Config.RandomStates is empty or nil")
        return nil, nil, nil, nil, nil, nil
    end

    local country = Config.RandomStates[math.random(#Config.RandomStates)]
    if not country or not country.States or #country.States == 0 then
        DebugPrint("^1ERROR ^7Country or States table is empty or nil")
        return nil, nil, nil, nil, nil, nil
    end

    local randomState = country.States[math.random(#country.States)]
    if not randomState or not randomState.Cities or #randomState.Cities == 0 then
        DebugPrint("^1ERROR ^7RandomState or Cities table is empty or nil")
        return nil, nil, nil, nil, nil, nil
    end

    local randomCity = randomState.Cities[math.random(#randomState.Cities)]
    if not randomCity or not randomCity.Addresses or #randomCity.Addresses == 0 then
        DebugPrint("^1ERROR ^7RandomCity or Addresses table is empty or nil")
        return nil, nil, nil, nil, nil, nil
    end

    -- Generate postal code with proper formatting
    local randomPostalCode = math.random(randomCity.PostalCodeRange[1], randomCity.PostalCodeRange[2])
    local randomAddress = randomCity.Addresses[math.random(#randomCity.Addresses)]
    local randomAddressType = GenerateRandomAdressType()

    -- Remove debug prints or make them conditional
    if Config.Debug then
        print(country.Country or "not found")
        print(randomState.State or "not found")
        print(randomCity.City or "not found")
        print(randomPostalCode or "not found")
        print(randomAddress.Address or "not found")
        print(randomAddressType or "not found")
    end

    -- Make sure we're returning the actual country name and address type in the correct order
    return country.Country or "USA",
           randomState.State or "San Andreas",
           randomCity.City or "Los Santos",
           tostring(randomPostalCode) or "12345",
           randomAddress.Address or "123 Night St",
           randomAddressType -- This should be the property type, not the country
end

--- Selects a random property type from the configured property types list.
-- @return string A randomly selected property type (e.g., "Apartment", "House").
function GenerateRandomAdressType()
    return Config.RandomPropertyTypes[math.random(#Config.RandomPropertyTypes)]
end

--- Generates a fictitious email address using provided names.
-- @param first_name string The first name for the email.
-- @param last_name string The last name for the email.
-- @return string A generated email address using a random domain.
function GenerateRandomEmail(first_name, last_name)
    local randomDomain = Config.FictiveEmailDomains[math.random(#Config.FictiveEmailDomains)]
    return first_name .. "." .. last_name .. randomDomain
end

--- Generates a random inventory list for NPCs.
-- Shuffles available items and selects up to 8 random items.
-- @return table Array of inventory items with name and illegal status.
function GenerateListOfRandomInventoryItems()
    local inventory = {}

    local itemsPool = Config.NPCInventory

    -- Generate a random number of items (between 0 and the total number of items).
    local numItems = math.random(#itemsPool)

    -- Shuffle the items pool.
    for i = #itemsPool, 2, -1 do
        local j = math.random(i)
        itemsPool[i], itemsPool[j] = itemsPool[j], itemsPool[i]
    end

    -- Add random items to the inventory, limited to a maximum of 8 items.
    for i = 1, math.min(#itemsPool, 8) do
        local item = itemsPool[i]
        table.insert(inventory, {name = item.name, illegal = item.illegal})
    end

    return inventory
end

-- ============================================
-- DISCORD WEBHOOK INTEGRATION
-- ============================================

--- Server event handler for Discord webhook messages.
RegisterServerEvent(Config.EventPrefix..':sendDiscordEmbedMessage')
AddEventHandler(Config.EventPrefix..':sendDiscordEmbedMessage', function(data)
    local src = source
    SendDiscordEmbedMessage(src, data)
end)

--- Sends formatted embed messages to Discord webhooks.
-- Supports different webhook types and rich embed formatting.
-- Available as export: exports['night_ers']:SendDiscordEmbedMessage(source, messageData).
-- @param src number The source ID of the player.
-- @param data table Table containing embed data (title, description, color, etc.).
function SendDiscordEmbedMessage(src, data)
    if Config.Enable_Discord_Webhooks then
        local webhookURL = "https://discord.com/api/webhooks/964210045220958251/2qzKEBdUceFxJ1Wt3OhmL6WbqP9AUJqrJjbtd0U31MFV8l9uOODvn7mfmsm5I3wxzE1d"
        local webhooKType = data.discordwebhookurltype
        if webhooKType == nil then webhooKType = '' end
        if webhooKType == 'dispatch' then
            webhookURL = "https://discord.com/api/webhooks/964210045220958251/2qzKEBdUceFxJ1Wt3OhmL6WbqP9AUJqrJjbtd0U31MFV8l9uOODvn7mfmsm5I3wxzE1d"
        else
            webhookURL = "https://discord.com/api/webhooks/964210045220958251/2qzKEBdUceFxJ1Wt3OhmL6WbqP9AUJqrJjbtd0U31MFV8l9uOODvn7mfmsm5I3wxzE1d"
        end

        local discordId = getDiscordIdFromSource(src) or 0
        local embed = {
            {
                ["title"] = "**"..(data.title or "DISPATCH MESSAGE SYSTEM").."**" ,
                ["description"] = data.description or "",
                ["color"] = data.color or 11876095,
                ["author"] = {
                    ["name"] = data.authorname or "",
                    -- ["icon_url"] = data.authoravatarurl or ""
                },
                ["fields"] = {
                    {
                        ["name"] = data.sender or "",
                        ["value"] = "<@"..(discordId or "Unknown")..">",
                        ["inline"] = true
                    },
                    {
                        ["name"] = "Get the Emergency Response Simulator",
                        ["value"] = "[Nights Software](https://store.nights-software.com)",
                        ["inline"] = false
                    },
                    {
                        ["name"] = "Go for the full experience and expand your options",
                        ["value"] = "[London Studios](https://londonstudios.net)",
                        ["inline"] = false
                    }
                },
                ["footer"] = {
                    ["text"] = data.footer or "".." "..os.date("%Y").." | "..os.date("%d-%m-%Y at %H:%M:%S"),
                    ["icon_url"] = data.footericon or "https://assets.ea-rp.com/img/ERS_Logo.png"
                },
                ["thumbnail"] = {
                    ["url"] = data.thumbnail or "https://assets.ea-rp.com/img/ERS_Logo_Sq.png",
                },
                ["image"] = {
                    ["url"] = data.image or "" -- No url is no image, which is fine as well
                },
                ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%SZ") -- UTC timestamp
            }
        }
        PerformHttpRequest(webhookURL, function(err, text, headers) end, 'POST', json.encode({data.systemname or "NS - ERS System", embeds = embed}), { ['Content-Type'] = 'application/json' })
    end
end

exports('SendDiscordEmbedMessage', SendDiscordEmbedMessage)

-- ============================================
-- DEBUG UTILITIES
-- ============================================

--- Conditional debug print function.
-- Only prints messages when Config.Debug is enabled.
-- @param msg string The debug message to print.
function DebugPrint(msg)
    if Config.Debug then
        if msg ~= nil then
            print("["..GetCurrentResourceName().."] "..msg)
        end
    end
end

-- ============================================
-- POSTAL (server): auto-detect 2D X/Y from postal resources — no bridge
-- ============================================

local ERS_POSTAL_HINTS = {
    'mnr_postals',
    'nearest-postal',
}

local ersServerPostalData = nil

local function ersPostalSrvStarted(name)
    return name and GetResourceState(name) == 'started'
end

local function ersTryLoadMnrPostalLua(res)
    if not ersPostalSrvStarted(res) then return false end
    local cfgRaw = LoadResourceFile(res, 'config/config.lua')
    if not cfgRaw or cfgRaw == '' then return false end
    local cfgFn = load(cfgRaw, '@' .. res .. '/config', 't', {})
    if not cfgFn then return false end
    local okCfg, cfg = pcall(cfgFn)
    if not okCfg or type(cfg) ~= 'table' then return false end
    local path = cfg.PostalFilePath or cfg.path or 'data.ocrp'
    if type(path) ~= 'string' or path == '' then return false end
    local rel = path:gsub('^data%.', 'data/') .. '.lua'
    local dataRaw = LoadResourceFile(res, rel)
    if not dataRaw or dataRaw == '' then return false end
    local v2 = vec2 or vector2
    local env = { vec2 = v2, vector2 = vector2 }
    setmetatable(env, { __index = _G })
    local dataFn = load(dataRaw, '@' .. res .. '/data', 't', env)
    if not dataFn then return false end
    local okData, postals = pcall(dataFn)
    if not okData or type(postals) ~= 'table' then return false end
    local list = {}
    for code, v in pairs(postals) do
        local px, py = tonumber(v and v.x), tonumber(v and v.y)
        if px and py then
            list[#list + 1] = { code = code, x = px, y = py }
        end
    end
    if #list == 0 then return false end
    ersServerPostalData = list
    return true
end

local function ersTryLoadPostalJson(res)
    local fname = GetResourceMetadata(res, 'postal_file', 0)
    if not fname or fname == '' then return false end
    local raw = LoadResourceFile(res, fname)
    if not raw then return false end
    local ok, decoded = pcall(json.decode, raw)
    if not ok or type(decoded) ~= 'table' or #decoded == 0 then return false end
    local first = decoded[1]
    if type(first) ~= 'table' or first.x == nil or first.y == nil or first.code == nil then return false end
    ersServerPostalData = decoded
    return true
end

local function ersDiscoverServerPostal()
    if ersServerPostalData then return end
    for _, res in ipairs(ERS_POSTAL_HINTS) do
        if ersTryLoadMnrPostalLua(res) then return end
        if ersPostalSrvStarted(res) and ersTryLoadPostalJson(res) then return end
    end
end

local function ersNearestPostalCode(xf, yf)
    local ndm, ni = -1, -1
    for i, p in ipairs(ersServerPostalData) do
        local px, py = tonumber(p.x), tonumber(p.y)
        if px and py then
            local dm = (xf - px) ^ 2 + (yf - py) ^ 2
            if ni == -1 or dm < ndm then
                ni, ndm = i, dm
            end
        end
    end
    if ni ~= -1 then
        local c = ersServerPostalData[ni].code
        if c ~= nil then return tostring(c) end
    end
    return nil
end

local function ersRhudCodeFromResult(postal)
    if postal == nil then return nil end
    if type(postal) == 'string' and postal ~= '' then return postal end
    if type(postal) == 'number' and postal ~= 0 then return tostring(math.floor(postal + 0.5)) end
    if type(postal) == 'table' and postal.code ~= nil then
        local c = postal.code
        if type(c) == 'string' and c ~= '' then return c end
        if type(c) == 'number' and c ~= 0 then return tostring(math.floor(c + 0.5)) end
    end
    return nil
end

local function ersTryRhudServerPostal(xf, yf)
    if not ersPostalSrvStarted('rhud') then return nil end
    local ok, postal = pcall(function()
        return exports.rhud:get_postal(vector2(xf, yf))
    end)
    if not ok then return nil end
    return ersRhudCodeFromResult(postal)
end

--- Nearest postal from world X/Y: (1) rHUD get_postal(vector2), (2) static postal_file / mnr data. Returns nil if none.
-- @param x number
-- @param y number
-- @return string|nil
function getPostal(x, y)
    local xf = tonumber(x) or 0.0
    local yf = tonumber(y) or 0.0
    local rhud = ersTryRhudServerPostal(xf, yf)
    if rhud and rhud ~= '' then
        return rhud
    end
    ersDiscoverServerPostal()
    if ersServerPostalData then
        return ersNearestPostalCode(xf, yf)
    end
    return nil
end

local ERS_HUD_POSTAL_RESOURCES = { 'SimpleHUD', 'ModernHUD' }

--- (1) rHUD at ped X/Y, (2) SimpleHUD / ModernHUD getPostal(source), (3) getPostal(ped coords) for static fallback.
-- @param source number
-- @return string|nil
function getPostalForPlayer(source)
    local src = tonumber(source)
    if not src then return nil end
    local ped = GetPlayerPed(src)
    if ped and ped ~= 0 then
        local c = GetEntityCoords(ped)
        local rhud = ersTryRhudServerPostal(c.x, c.y)
        if rhud and rhud ~= '' then
            return rhud
        end
    end
    for i = 1, #ERS_HUD_POSTAL_RESOURCES do
        local res = ERS_HUD_POSTAL_RESOURCES[i]
        if ersPostalSrvStarted(res) then
            local ok, result = pcall(function()
                return exports[res]:getPostal(src)
            end)
            if ok and result ~= nil and tostring(result) ~= '' then
                return tostring(result)
            end
        end
    end
    if ped and ped ~= 0 then
        local c = GetEntityCoords(ped)
        return getPostal(c.x, c.y)
    end
    return nil
end

-- Client → server postal lookup.
-- Used by the client `getPostal(x, y, z)` fallback in c_functions.lua when no client-side
-- static postal backend is available. The server can use rHUD's *server* `get_postal(vector2)`
-- (which DOES accept coordinates, unlike rHUD's client `get_postal()` which ignores args and
-- always returns the local player's postal), so installs that only have rHUD still resolve
-- correct postals for arbitrary world coordinates such as callout locations.
RegisterServerEvent(Config.EventPrefix..':requestPostal')
AddEventHandler(Config.EventPrefix..':requestPostal', function(requestId, x, y)
    local src = source
    local code = nil
    if type(getPostal) == 'function' then
        local ok, result = pcall(getPostal, x, y)
        if ok and result ~= nil and tostring(result) ~= '' then
            code = tostring(result)
        end
    end
    TriggerClientEvent(Config.EventPrefix..':postalResult', src, requestId, code)
end)
