--============================== BUILD CALLOUTS =================================--

local BuildCalloutQueue = {}
local processingBuildCalloutQueue = false

RegisterServerEvent(Config.EventPrefix..':buildCallout')
AddEventHandler(Config.EventPrefix..':buildCallout', function(calloutData)
    local src = source
    table.insert(BuildCalloutQueue, {src = src, calloutData = calloutData})
    processBuildCalloutQueue()
end)

-- Surface a clearer remediation hint when a build error mentions a missing
-- export. The most common cause is "SmartFires"/"SmartFiresLite" not started
-- (or installed under a different folder name); the callout's server function
-- — directly or via a pack — calls into the resource and throws. We pcall the
-- build below and key off the error string here.
local function ERS_PrintBuildErrorRemediation(err)
    if type(err) ~= 'string' then return end
    local lower = err:lower()
    local mentionsSmartFires = lower:find('smartfires', 1, true) ~= nil
    local mentionsExport = lower:find('export', 1, true) ~= nil or lower:find('attempt to call', 1, true) ~= nil
    if mentionsSmartFires or mentionsExport then
        print("^1[night_ers] Hint^7: a callout's server function called an export that is not available.")
        if mentionsSmartFires then
            local sf = GetResourceState('SmartFires')
            local sfl = GetResourceState('SmartFiresLite')
            print(("^1[night_ers] Hint^7: SmartFires state=^3%s^7  SmartFiresLite state=^3%s^7"):format(tostring(sf), tostring(sfl)))
            print("^1[night_ers] Hint^7: install one of SmartFires (full/v2) or SmartFiresLite, named EXACTLY ^2SmartFires^7 or ^2SmartFiresLite^7 (case-sensitive folder name) and ensure it is started.")
        end
    end
end

-- Best-effort cleanup of entities/fires/smokes that were partially spawned by
-- a callout server function which errored mid-build. Without this, the world
-- accumulates orphan peds/vehicles/objects on every failed build because the
-- normal cleanup path (ActiveCalloutsList -> processCalloutCancelQueue) never
-- gets to register them.
local function ERS_CleanupPartialBuild(pedList, vehicleList, objectList, propList, evidenceList, ambientList, fireList, smokeList)
    local function deleteEntities(list)
        if type(list) ~= 'table' then return end
        for _, netId in ipairs(list) do
            if netId ~= nil then
                local ent = NetworkGetEntityFromNetworkId(netId)
                if ent and ent ~= 0 and DoesEntityExist(ent) then
                    pcall(DeleteEntity, ent)
                end
            end
        end
    end
    deleteEntities(pedList)
    deleteEntities(vehicleList)
    deleteEntities(objectList)
    deleteEntities(propList)
    deleteEntities(evidenceList)
    deleteEntities(ambientList)
    if type(fireList) == 'table' then
        for _, id in ipairs(fireList) do
            if id ~= nil and ERS_SmartFires_StopFire then
                pcall(ERS_SmartFires_StopFire, id)
            end
        end
    end
    if type(smokeList) == 'table' then
        for _, id in ipairs(smokeList) do
            if id ~= nil and ERS_SmartFires_StopSmoke then
                pcall(ERS_SmartFires_StopSmoke, id)
            end
        end
    end
end

function processBuildCalloutQueue()
    if processingBuildCalloutQueue or #BuildCalloutQueue == 0 then
        return
    end
    
    processingBuildCalloutQueue = true

    local request      = table.remove(BuildCalloutQueue, 1)
    local src          = request.src
    local calloutData  = request.calloutData
    local calloutBuilt = false
    local pedList      = {}
    local vehicleList  = {}
    local objectList   = {}
    local propList     = {}
    local evidenceList = {}
    local ambientList  = {}
    local playersList  = {}
    local fireList     = {}
    local smokeList    = {}

    -- Always clear the queue lock and chain the next build, even if the work
    -- below errors out. Without this, a single throwing callout (most often a
    -- pack export when SmartFires is misnamed/missing) leaves the queue
    -- "processing" forever — every player who accepts a callout afterwards
    -- sees the spawn-in-progress lock perpetually because no `:startCallout`
    -- and no `:buildCalloutFailed` is ever broadcast.
    local function chainNextBuild()
        Citizen.SetTimeout(1000, function()
            processingBuildCalloutQueue = false
            processBuildCalloutQueue()
        end)
    end

    DebugPrint("Attempting to build callout: "..calloutData.CalloutName)
    local callout = Config.Callouts[calloutData.calloutId]
    local buildOk, buildErr = true, nil
    if not callout then
        DebugPrint("^1Callout not found: " .. tostring(calloutData.calloutId) .. "^7")
    elseif callout.PackSource then
        -- Mirror the pcall pattern used on the client side for ExecuteCalloutClient.
        -- A throw here (resource not started, export missing, error inside the
        -- pack) used to escape the function, leaving the queue stuck and the
        -- player's `spawn_in_progress` lock permanent.
        buildOk, buildErr = pcall(function()
            calloutBuilt, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList, evidenceList, ambientList = exports[callout.PackSource]:ExecuteCalloutServer(callout.CalloutId, request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList, evidenceList, ambientList)
        end)
    else
        -- Same protection for the in-tree callout case: a Lua error in the
        -- callout's server function should not poison the queue.
        buildOk, buildErr = pcall(function()
            calloutBuilt = callout.server(request, src, calloutData, pedList, vehicleList, objectList, propList, playersList, fireList, smokeList, evidenceList, ambientList)
        end)
    end

    if not buildOk then
        print(("^1[night_ers] Callout build threw^7: %s -> %s"):format(tostring(calloutData.CalloutName), tostring(buildErr)))
        ERS_PrintBuildErrorRemediation(buildErr)
        ERS_CleanupPartialBuild(pedList, vehicleList, objectList, propList, evidenceList, ambientList, fireList, smokeList)
        local failMsg = Config.Messages[Config.Language].ServerCouldNotBuildCalloutError
        TriggerClientEvent(Config.EventPrefix..':notificationMessage', src, failMsg)
        TriggerClientEvent(Config.EventPrefix..':buildCalloutFailed', src)
        chainNextBuild()
        return
    end

    -- Check if callout was built
    if calloutBuilt then
        ERS_InsertEntitiesIntoCalloutList(src, pedList, vehicleList, objectList, fireList, smokeList, evidenceList, ambientList)

        QueueUpdateRequest(function(success)
            -- pcall the entire callback body so a throw inside (e.g. a UI
            -- helper or external integration that errors) cannot prevent
            -- `:startCallout` from firing, AND cannot prevent
            -- ProcessUpdateQueue from resetting `isProcessingQueue`.
            local cbOk, cbErr = pcall(function()
                if success then
                    DebugPrint("[processBuildCalloutQueue] Update completed successfully.")

                    -- Update callout UI for the owner & attached players of the callout
                    DebugPrint("[processBuildCalloutQueue] Updating callout user interface for hostId "..src)
                    if UsingSmartFiresV2 then
                        ERS_TriggerCalloutUserInterfaceForHost(src)
                    else
                        TriggerClientEvent(Config.EventPrefix..':updateCalloutUserInterface', src, src)
                        for _, c in ipairs(ActiveCalloutsList) do
                            if c.hostId == src then
                                for _, userServerId in pairs(c.playersList) do
                                    DebugPrint("[processBuildCalloutQueue] Updating callout user interface for attached playerId "..userServerId)
                                    TriggerClientEvent(Config.EventPrefix..':updateCalloutUserInterface', userServerId, src)
                                end
                                break
                            end
                        end
                    end

                    TriggerClientEvent(Config.EventPrefix..':startCallout', src, pedList, vehicleList, playersList, objectList, propList, fireList, smokeList, calloutData, evidenceList, ambientList)

                    DebugPrint("Successfully built callout: "..calloutData.CalloutName)
                else
                    DebugPrint("[processBuildCalloutQueue] Update failed or was skipped.")
                end
            end)
            if not cbOk then
                print(("^1[night_ers] Build post-update callback threw^7: %s"):format(tostring(cbErr)))
                -- Best-effort: still tell the client the build "failed" so it
                -- releases the spawn-in-progress lock (entities exist server
                -- side; CancelCallout on the client will sweep them via the
                -- normal cancel path).
                TriggerClientEvent(Config.EventPrefix..':buildCalloutFailed', src)
            end
        end)
    else
        local message = Config.Messages[Config.Language].ServerCouldNotBuildCalloutError
        TriggerClientEvent(Config.EventPrefix..':notificationMessage', src, message)
        -- Inform the client to re-enable cancel and detach since build failed
        TriggerClientEvent(Config.EventPrefix..':buildCalloutFailed', src)
        print("^1ERROR^7 It is possible you forgot to return true at the end of your callout server function OR:")
        print("^1ERROR^7 None of the enabled callouts could be built, please make sure you have at least 1 callout enabled.")
    end

    chainNextBuild()
end

--================ Open source functions =================--

--