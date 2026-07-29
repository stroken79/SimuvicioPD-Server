--============================== BUILD CALLOUTS =================================--

function ERS_BuildCallout(pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient, evidenceList, ambientList)
    local plyPed = PlayerPedId()
    local calloutId = calloutDataClient and calloutDataClient.calloutId
    local callout = calloutId and Config.Callouts and Config.Callouts[calloutId]
    if not callout then
        print("^1[night_ers] Callout not found: " .. tostring(calloutId) .. "^7")
        return
    end
    if callout.PackSource then
        local ok, err = pcall(function()
            exports[callout.PackSource]:ExecuteCalloutClient(callout.CalloutId, plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient, evidenceList, ambientList)
        end)
        if not ok then
            print("^1[night_ers] Pack " .. tostring(callout.PackSource) .. " ExecuteCalloutClient failed: " .. tostring(err) .. "^7")
        end
    elseif type(callout.client) ~= "function" then
        print("^1[night_ers] Callout " .. tostring(calloutId) .. " has no client function^7")
        return
    else
        callout.client(plyPed, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutDataClient, evidenceList, ambientList)
    end
end

--================ Open source functions (Edit these if you like.) =================--

function ERS_SetRandomDamageToVehicle(vehicle)
    ERS_RequestNetControlForEntity(vehicle) 
    if DoesEntityExist(vehicle) then
        SetVehicleBodyHealth(vehicle, math.random(0, 1000) + 0.0)
        SetVehicleEngineHealth(vehicle, math.random(0, 1000) + 0.0)

        -- Burst random tires
        for i = 0, GetVehicleNumberOfWheels(vehicle) - 1 do
            if math.random(100) < 10 then -- 10% chance to burst each tire
                SetVehicleTyreBurst(vehicle, i, true, 1000.0)
            end
        end

        -- Apply visual damage
        for i = 0, 5 do -- Randomly damage some parts of the vehicle
            if math.random(100) < 70 then -- 70% chance to apply damage to each part
                SetVehicleDamage(vehicle, 0.5 * i, 0.5 * i, 0.5 * i, 500.0, 100.0, true)
            end
        end
    else
        if Config.Debug then
            print("Vehicle does not exist.")
        end
    end
end

function ERS_CreateFlareAtCoordinate(coords)
    AddExplosion(coords.x, coords.y, coords.z-1.0, 22, 1.0, true, false, 1.0)
end

function ERS_GivePedParachute(ped) -- Does not work on every ped. 
    ERS_RequestNetControlForEntity(ped)

    if not DoesEntityExist(ped) then
        if Config.Debug then
            print("Ped does not exist.")
        end
        return
    end
    
    local weaponHash = GetHashKey("GADGET_PARACHUTE")
    GiveWeaponToPed(ped, weaponHash, 1, false, true)
    
    -- This sets the ped's parachute as visible if applicable to the model
    SetPedComponentVariation(ped, 5, 8, 0, 2)  
end

function ERS_SelectRandomPartyMusic()
    local files = {
        "party1",
        "party2",
        "party3",
    }
    local soundFile = files[math.random(#files)]
    if Config.Debug then
        print("Selected party music file: "..soundFile)
    end
    return soundFile
end

local calloutTemporaryEntityBlips = {}

function ERS_ClearCalloutTemporaryEntityBlips()
    for _, blipId in ipairs(calloutTemporaryEntityBlips) do
        if DoesBlipExist(blipId) then
            RemoveBlip(blipId)
        end
    end
    calloutTemporaryEntityBlips = {}
end

function ERS_CreateTemporaryBlipForEntities(entityList, timeoutInMs)
    if Config.ShowBlipsForEntitiesOnCallouts then
        local blipList = {}
        local blip = nil
        for index, entityNetId in pairs(entityList) do
            if not entityNetId or not NetworkDoesNetworkIdExist(entityNetId) then
                if Config.Debug then
                    print("Could not find entity with entityNetId "..tostring(entityNetId))
                end
                goto continue_callout_entity_blip
            end
            local ent = NetworkGetEntityFromNetworkId(entityNetId)
            if DoesEntityExist(ent) then
                ERS_RequestNetControlForEntity(ent)
                blip = AddBlipForEntity(ent)
                SetBlipSprite(blip, Config.CalloutEntityBlipSprite)
                SetBlipColour(blip, Config.CalloutEntityBlipColour)
                SetBlipScale(blip, Config.CalloutEntityBlipScale)
                SetBlipFlashes(blip, false)
                -- SetBlipShowCone(blip, true)
                table.insert(blipList, blip)
                table.insert(calloutTemporaryEntityBlips, blip)
            else
                if Config.Debug then
                    print("Could not find entity with entityNetId "..tostring(entityNetId))
                end
            end
            ::continue_callout_entity_blip::
        end

        Citizen.SetTimeout(timeoutInMs, function() 
            for index, blipId in ipairs(blipList) do
                if DoesBlipExist(blipId) then
                    RemoveBlip(blipId)
                else
                    if Config.Debug then
                        print("No se pudo encontrar el marcador con el blipId indicado"..blipId)
                    end
                end
            end
        end)
    else
        if Config.Debug then
            print("La visualizacion de marcadores para las entidades de los avisos esta desactivada. El script no creara ningun marcador para las entidades.")
        end
    end
end