Config  = Config or {}

Config = {

   ConfigVersion    = "1.8.8",

    Debug           = false,                -- Useful debug (errors, one-shot events). Still increases resmon — set false for normal play.
    EventPrefix     = "ERS",          -- Leave this be.
    Language        = "es",                 -- Available languages: en | us | nl | de | fr | he | cs | pt-br | sv | ua | ru | zh-cn (Ajust text in config/translations.lua)
    SoundLanguage   = "en",                 -- Available languages: en | us | fr | de | (Ajust text in config/sound-config.lua) 
    DOBFormat       = "en",                 -- Options: en | us
    UseImperial     = false,                -- Options: true = feet (mi) | false = meters (km) (Determines whether to display distances in feet (true) or meters (false))
    Timezone        = "Europe/London",      -- Set the timezone which the script uses. https://en.wikipedia.org/wiki/List_of_tz_database_time_zones

    --[[ IMPORTANT: https://docs.fivem.net/natives/?_0xA0F2201F
        [OPTIONS FOR ServerLockDownMode (below)]
        "strict"     No entities can be created by clients at all.
        "relaxed"	 Only script-owned entities created by clients are blocked.
        "inactive"   Clients can create any entity they want.
    ]] 
    ServerLockDownModeRoutingBucketList = {
        {routingBucketId = 0, lockDownMode = "inactive"}, -- Default routing bucket when loading into the server as a player.
        {routingBucketId = 1, lockDownMode = "inactive"},
        {routingBucketId = 2, lockDownMode = "relaxed"},
        {routingBucketId = 3, lockDownMode = "strict"},
    },

    --====================== OPTIONAL INTEGRATIONS ======================--

    Enable_Night_Shifts = { -- Optional PAID: https://store.nights-software.com/package/5667103 (Enables call forwarding to the MDT & Shift toggle via MDT, which itself offers loads of more features)
        UseNightShiftsMDT  = true,      -- Master MDT integration toggle. When true: ped/vehicle identity comes from MDT, AND ERS callout lifecycle (accept / arrive / cancel) drives the matching MDT shift status binding (responding / on_scene / available) — departments without a status configured for a binding are silently skipped. Auto-detects whether the night_shifts_mdt resource is started; harmless if absent.
        ManageShiftsByMDT  = true,      -- If true, Night Shifts MDT will manage shift toggles instead of the ERS (auto-detects the resource; ERS handles shifts internally if absent). MDT Service type 'council' will NOT trigger an ERS shift.
        SendCalloutsToMDT  = true,      -- If true, callouts will be sent to the MDT as calls (auto-detects the resource; harmless if absent).
        SendPulloversToMDT = true,      -- If true, pullovers will be sent to the MDT as calls.
    },
    Enable_Night_Subtitles  = true,    -- Optional PAID (Included with ERS): https://store.nights-software.com/package/6043540 (Enables good looking subtitles instead of FiveM native mission text)
    Enable_Discord_Webhooks = false,    -- Set your webhook URL in server/s_functions.lua.
    Enable_Z_ELS = false,              -- Optional z_els integration for NPC Backup (set true if you run z_els).

    --====================== DISCORD RICH PRESENCE ======================--
    
    Enable_Discord_Presence = false,                                                                     -- Gives users a rich presence on Discord.
    Discord_Presence_Data = {
        AppId = '1314195524915691581',                                                                  -- Your Discord application ID.
        RichPresenceAsset = "big",                                                                      -- Your Discord rich presence asset name.
        RichPresenceAssetText = "Emergency Response Simulator",                                         -- Your Discord rich presence asset text.
        RichPresenceAssetSmall = {                                                                      -- Your Discord rich presence small asset name used for each service.
            ["offduty"] = "small",
            ["police"] = "police",
            ["fire"] = "fire",
            ["ambulance"] = "ambulance",
            ["tow"] = "tow",
        },
        RichPresenceAssetSmallText = {                                                                  -- Your Discord rich presence small asset text used for each service.
            ["offduty"] = "Off Duty",
            ["police"] = "Police",
            ["fire"] = "Fire",
            ["ambulance"] = "Ambulance",
            ["tow"] = "Tow",
        },
        RichPresenceButton = {                                                                          -- Your Discord rich presence buttons - up to 2 buttons.
            [0] = { enabled = true, label = "Join Server", url = "fivem://connect/YOURSERVERHASH" },
        }
    },
    
    --====================== PERMISSIONS FOR SHIFT ACCESS ======================--

    -- IMPORTANT WHEN USING NIGHT SHIFTS MDT: Set every permission to false if Enable_Night_Shifts is true. That will determine your shift type instead of these permissions.

    EveryoneHasPermission = true,                  -- Anyone can go on shift for any service and can get any callout offered. If you use permissions and disable this, callouts are offered based on PermissionRoles.
    IgnoreUnitRequirement = false,                 -- true = Any unit can receive callouts for any service. | false = Callouts are offered by service type (Police, fire, ambulance, tow).
    DisplayUnitWaypoints = true,                   -- true = Display unit waypoints on screen. | false = Do not display unit waypoints on screen. (enabled is higher resmon)

    Enable_Night_DiscordApi_Permissions = false,   -- server/s_functions.lua
    Enable_Ace_Permissions = false,                -- server/s_functions.lua
    Enable_ESX_Permissions = {
        Check_By_Job = false,                      -- server/s_functions.lua
        Check_By_Permissions = false,              -- server/s_functions.lua
    },
    -- QBox: use this block too — qbx_core uses the qb-core bridge (GetCoreObject), same job / HasPermission checks as QBCore.
    Enable_QBCore_Permissions = {
        Check_By_Job = false,                      -- server/s_functions.lua
        Check_By_Permissions = false,              -- server/s_functions.lua
    },

    -- If you are using Night Shifts MDT, duty will be managed by the MDT. Roles defined here will not be relevant in that case. 
    PermissionRoles = {
        PoliceRoles     = {"Essex_Police_Force", "police"}, -- Example of two roles (you can add more.)
        AmbulanceRoles  = {"Ambulance_Service", "ambulance"},
        FireRoles       = {"Fire_Service", "fire"},
        TowRoles        = {"AA_Recovery", "tow"},
    },
    
    --====================== GENERAL SETTINGS ======================--

    Callouts = {},                              -- Do not change this.
    EnableRadialMenu = true,                    -- Disabling this forces your players to use commands and/or hotkeys only. The radial menu offers several handy options during gameplay.
    RadialMenuRollOverButtonSound = "rollover", -- NUI/sounds/rollover.ogg

    CalloutBlipData = {     -- https://docs.fivem.net/docs/game-references/blips/
        DisplayId = 2,      -- On map & on legend.
        SpriteId = 9,       -- Sprite type
        Scale = 0.5,        -- Scale
        Alpha = 150,        -- Transparency 0/255 
        ColourId = 47,      -- Colour
        RouteColourId = 47, -- Route color
    },

    TrackedUnitBlipData = { -- https://docs.fivem.net/docs/game-references/blips/
        DisplayId = 2,      -- On map & on legend.
        SpriteId = 1,       -- Sprite type
        Scale = 0.5,        -- Scale
        Alpha = 225,        -- Transparency 0/255 
        ColourId = 30,      -- Colour
        RouteColourId = 30, -- Route color
    },

    -- Callout Offers
    OfferCalloutsWithinRangeOf = 3000,      -- Distance in GTA meters between player and callouts, as the crow flies (lineair dist).
    OfferCalloutInterval = {120, 300},      -- Seconds inbetween which a callout is offered. (3-5 minutes by default) (Minimum 60 seconds, maximum no limit)
    OfferedCalloutTimeout = 15,             -- Seconds after which the callout offer is expired. (15 seconds by default)
    EnableOnScreenCalloutWaypoint = true,   -- true: Shows an on-screen waypoint towards the callout. false: Doesn't.

    -- Dispatch messages
    DispatchResponseMessageTimeout = 15,    -- Seconds after the next dispatch message is displayed (Goes for response dispatch messages on which units can track the responding unit).
    DispatchArrivalMessageTimeout = 5,      -- Seconds after the next dispatch message is displayed (Goes for arrival dispatch messages).
    DispatchStatusMessageTimeout = 3,       -- Seconds after the next dispatch message is displayed (Goes for status dispatch messages).
    DispatchMessageBackupRequestsTimeout = 3, -- Seconds after the next dispatch message is displayed (Goes for backup request notifications)

    -- Information prompts
    EnableVehicleInformationPrompt = true,  -- If true, vehicle information will be displayed in a UI, otherwise you'll have to use Night Shifts MDT or an external integration to get vehicle information.
    EnableIDCardInformationPrompt = true,   -- If true, ID card information will be displayed in a UI, otherwise you'll have to use Night Shifts MDT or an external integration to look up more information about the person by their name and DOB.

    -- Other
    DistanceToAimAndOrderPeds = 25.0,       -- Distance in GTA meters between you and the ped you desire to order something whilst aiming at them.
    TimeToAutoStopTrackingUnit = 360,       -- Seconds after which the blip route to the tracked unit is removed automatically by the system. (6 minutes by default)
    EnableRenderedTextDrawingOnAim = true,  -- false = less resmon, true = 3D text drawing & more resmon.
    ShowBlipsForEntitiesOnCallouts = true,  -- false = show no blips for entities, true = show blips for entites on callouts.
    NPCChanceToFleeDuringInteraction = 20,  -- 0-100: base flee chance per action type (first E, warn, fine, search, etc.). Each action rolls once per ped; mood/drunk/items modify in-code.
    NPCChanceToBeDrunkAtInteraction = 15,   -- Percentage of chance to be drunk of a total of 100%.
    NPCChanceToBeDruggedAtInteraction = 15, -- Percentage of chance to be drugged of a total of 100%.
    ShowHintPopupByDefault = true,          -- If the hints popup (on callouts for example) should be shown by default

    EnableCalloutEntityMarkers = false,     -- If enabled, callout entities will have markers drawn above their head, this helps identify your targets, but uses more resmon.
    DisableSubtitlesEntirely = false,       -- Disable subtitles / mission text entirely.
    DisableStunGunKills = true,             -- If stun gun kills are disabled.

    -- Behaviour State (Mood)
    EnableBehaviourState3DLabels = true,    -- If 3D labels should be shown above NPC's when they are in a specific behaviour state.
    BehaviourState3DLabelsDuration = 5000,  -- Duration of the 3D labels in milliseconds.

    -- Radio Animation
    RadioAnimationDictionary = "random@arrests",
    RadioAnimationName = "generic_radio_enter",
    RadioAnimationDuration = 3000,

    -- Important gameplay settings
    DisablePvP = true,                     -- Disable PvP. (True = Player killing disabled. | False = Player killing enabled.)
    DisableWantedLevel = true,              -- Disable wanted level.
    DisableEngineDispatchServices = true,   -- Disable NPC's spawned by the base game engine to respond to incidents (Ambulance, fire etc.).
    DisableBaseGameCopSpawn = false,         -- Disable base game engine spawned police officers (at stations for example).
    DisableWeaponDrops = true,              -- Disable weapon drops.
    DisableWeaponsFromVehicles = true,      -- Disable spawning weapons from vehicles.
    DisableStamina = true,                  -- Disable using stamina.

    --====================== TARGET INTEGRATION ======================--

    Target = {
        Enabled = false,                        -- Use target system instead of text prompt. Disabling this disables all target interactions
        System = "ox-target",                   -- Options: "ox-target" | "qb-target"

        PedInteract = {
            Enabled = true,                     -- Use for ped interaction menu
            Icon = "fa-solid fa-hand",          -- Font awesome icon https://fontawesome.com/icons
            Label = "Interact with person",     -- Label displayed for interaction

            --For injured Peds
            InjuredIcon = "fa-solid fa-heart-pulse",
            InjuredLabel = "Interact with injured person",
        },
        GearInteract = {
            Enabled = true,                     -- Use for gear ped interaction menu
            Icon = "fa-solid fa-hand",          -- Font awesome icon https://fontawesome.com/icons
            Label = "Collect gear",             -- Label displayed for interaction
        },
        ObjInteract = {
            Enabled = true,                     -- Use for object cleanup interaction
            Icon = "fa-regular fa-trash-can",   -- Font awesome icon https://fontawesome.com/icons
            Label = "Clean-up object",          -- Label displayed for interaction
        },
        StretcherInteract = {
            Enabled = true,                     -- Use for stretcher interaction
            --Putting stretcher into ambulance
            AmbulanceInIcon = "fa-solid fa-arrow-left",
AmbulanceInLabel = "Introducir la camilla en la ambulancia",
-- Sacar la camilla de la ambulancia
AmbulanceOutIcon = "fa-solid fa-arrow-right",
AmbulanceOutLabel = "Sacar la camilla de la ambulancia",
-- Acciones de la camilla
StretcherGrabIcon = "fa-solid fa-hand",
StretcherGrabLabel = "Agarrar la camilla",
LowerStretcherIcon = "fa-solid fa-arrow-down",
LowerStretcherLabel = "Bajar la camilla",
RaiseStretcherIcon = "fa-solid fa-arrow-up",
RaiseStretcherLabel = "Subir la camilla",
GetOnStretcherIcon = "fa-solid fa-bed-pulse",
GetOnStretcherLabel = "Subir o bajar de la camilla",
        },  
        SpikestripInteract = {
    Enabled = true,                         -- Usar para la interaccion con bandas de clavos
    Icon = "fa-solid fa-road-spikes",       -- Icono de Font Awesome https://fontawesome.com/icons
    Label = "Sacar o guardar la banda de clavos", -- Etiqueta mostrada al interactuar con el vehiculo
    GroundLabel = "Recoger la banda de clavos",   -- Etiqueta mostrada al interactuar con el suelo
},
ImpoundInteract = {
    Enabled = true,                         -- Usar para la interaccion con el deposito
    Icon = "fa-solid fa-car",               -- Icono de Font Awesome https://fontawesome.com/icons
    Label = "Incautar vehiculo",            -- Etiqueta mostrada durante la interaccion
},
VehicleSearchInteract = {
    Enabled = true,                         -- Usar para la interaccion de registro del vehiculo
    Icon = "fa-solid fa-magnifying-glass",  -- Icono de Font Awesome https://fontawesome.com/icons
    Label = "Registrar seccion del vehiculo", -- Etiqueta mostrada durante la interaccion
        },
    },

    --====================== HOTKEYS & COMMANDS ======================--

    HotKeys = {                         -- https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/keyboard/

            -- Shift
        ToggleShift = "F11",            -- Button to toggle shift on/off.

        -- Callouts
        AcceptCallout = "Y",            -- Button to accept an offered callout.
        CompleteCallout = "X",          -- Declines an offered callout, or opens cancel for an attached callout (ends early—not “complete via tasks”).
        TrackUnit = "E",                -- Button to track a unit responding to a callout when offered by the system to track.
        RadialMenu = "Z",               -- Button to open radial menu for NPC backup requests.
        PullOver = "LSHIFT",            -- Button to attempt to pull someone over.
        PullOverMode = "U",             -- Button to change pull over mode (when a vehicle has stopped for pullover).

        -- User Interface
        ToggleCalloutInfo = "PAGEDOWN", -- Toggles the callout interface on/off screen, when attached to a callout.
        ToggleDispatchMessages = "",    -- Toggles dispatch messages when on shift.

        -- Ped Interaction              -- "" to use no default hotkey and let clients set it themselves if they like. Otherwise use the command.
        InteractWithPed = "E",          -- Button to interact with a ped.
        OrderOnKneesOrStandUp = "E",    -- Button to order a ped to knees/stand up whilst aiming at the ped or stop / release an animal.
        CleanupObject = "E",            -- Button to clean up nearby callout spawned objects.
        ImpoundInteract = "E",          -- Button to interact with the impound ped.
        GearInteract = "E",             -- Button to interact with the gear ped.

        -- Stretcher Interaction
        GrabStretcher = "E",            -- Button to grab and release a stretcher (E by default).
        LowerStretcher = "DOWN",        -- Button to lower the stretcher you're using (ARROW DOWN by default).
        RaiseStretcher = "UP",          -- Button to raise the stretcher you're close to (ARROW DOWN by default).
        InteractWithStretcherAndVeh = "H", -- Button to take/put stretcher from/into vehicle. (H by default.)
        DropOffPedAtHospital = "RETURN",-- Button to drop off a ped at a hospital when on a stretcher being strolled. (ENTER by default)
        GetOnOrOffStretcher = "L",      -- Button to get on or off a stretcher. (L by default.)

        -- Spikestrips
        TakeOutOrPutAwaySpikestripFromVehicle = "E",    -- Button to take out or put away a spikestrip from a vehicle.
        DeployOrPickupSpikestrip = "UP",                -- Button to deploy or pickup a spikestrip.

        -- Vehicle Search
        SearchVehicle = "O",            -- Button to search a vehicle.

        -- Pursuit Mode
        CancelPursuit = "",             -- Button to cancel the pursuit. (Empty by default)
        PursuitRadialMenu = "B",        -- Button to open the pursuit backup radial menu.
        ZoomInOnPursuitTarget = "H",    -- Button to zoom in on the pursuit target.

        -- Tow Tools
        ConnectClosestVehicle = "",     -- Button to connect the closest vehicle to the towing vehicle. (None by default)

        -- Redisplay Last Module
        RedisplayLastModule = "TAB",    -- Button to redisplay the last shown module (ID card, vehicle info, or inventory).

        -- Night Shifts MDT
        OpenMDTProfile = "RSHIFT",      -- Button to open the current ped or vehicle profile in the MDT (requires night_shifts_mdt, police shift only).
    },

    Commands = {
        -- Callouts
        ToggleShift = "toggleshift",
        ToggleCallouts = "togglecallouts",
        AcceptCallout = "acceptcallout",
        RequestCalloutManually = "requestcallout",
        StopTrackingUnit = "stoptracking",
        CompleteCallout = "completecallout",
        RequestAmbulance = "requestambulance",
        CancelAmbulance = "cancelambulance",
        RequestPolice = "requestpolice",
        CancelPolice = "cancelpolice",
        RequestTaxi = "requesttaxi",
        CancelTaxi = "canceltaxi",
        RequestTow = "requesttow",
        CancelTow = "canceltow",
        RequestRoadService = "requestroadservice",
        CancelRoadService = "cancelroadservice",
        RequestCoroner = "requestcoroner",
        CancelCoroner = "cancelcoroner",
        RequestAnimalRescue = "requestanimalrescue",
        CancelAnimalRescue = "cancelanimalrescue",
        RequestMechanic = "requestmechanic",
        CancelMechanic = "cancelmechanic",
        RequestFire = "requestfire",
        CancelFire = "cancelfire",
        RadialMenu = "ersradialmenu",
        PullOver = "pullover",
        PullOverMode = "pullovermode",
        InteractWithPed = "interact",
        OrderOnKneesOrStandUp = "orderknees",
        CleanupObject = "broom",
        SpawnStretcher = "spawnstretcher",
        DeleteStretcher = "deletestretcher",
        GrabStretcher = "grabstretcher",
        LowerStretcher = "lowerstretcher",
        RaiseStretcher = "raisestretcher",
        InteractWithStretcherAndVeh = "vstretcher",
        DropOffPedAtHospital = "dropoffped",
        TrackUnit = "track", -- Syntax: /track [userServerId]
        TakeOutOrPutAwaySpikestripFromVehicle = "grabstinger",
        DeployOrPickupSpikestrip = "stinger",
        GetOnOrOffStretcher = "getonoroffstretcher",
        ImpoundInteract = "impound",
        GearInteract = "gear",
        SearchVehicle = "searchveh",
        ZoomInOnPursuitTarget = "zoompursuit",
        PursuitRadialMenu = "pursuitbackup",
        CancelPursuit = "cancelpursuit",

        -- User Interface
        ToggleCalloutInfo = "togglecalloutinfo",
        ToggleDispatchMessages = "toggledispatchmessages",
        ToggleUILayout = "toggleerslayout",

        -- Tow Tools
        ConnectClosestVehicle = "ccv",

        -- Redisplay Last Module
        RedisplayLastModule = "redisplaylastmodule",

        -- Night Shifts MDT
        OpenMDTProfile = "openmdtprofile",

        -- Hints
        ToggleHints = "togglehints",
    },

    CommandsHelpText = {
        ToggleShift = "Comando utilizado para entrar o salir de servicio.",
ToggleCallouts = "Comando utilizado para activar o desactivar las ofertas de avisos del ERS.",
AcceptCallout = "Comando utilizado para aceptar un aviso ofrecido.",
RequestCalloutManually = "Comando utilizado para solicitar un aviso manualmente.",
StopTrackingUnit = "Comando utilizado para dejar de rastrear manualmente una unidad.",
CompleteCallout = "Rechaza una oferta de aviso o cancela el aviso actual antes de completar todas las tareas. Para finalizarlo normalmente, debes resolver todas las tareas.",
RequestAmbulance = "Comando utilizado para solicitar una ambulancia para las personas cercanas.",
CancelAmbulance = "Comando utilizado para cancelar la solicitud de una ambulancia.",
RequestPolice = "Comando utilizado para solicitar transporte policial para la persona mas cercana.",
CancelPolice = "Comando utilizado para cancelar la solicitud de transporte policial.",
RequestTaxi = "Comando utilizado para solicitar un taxi para la persona mas cercana.",
CancelTaxi = "Comando utilizado para cancelar la solicitud de un taxi.",
RequestTow = "Comando utilizado para solicitar una grua que recoja el vehiculo mas cercano.",
CancelTow = "Comando utilizado para cancelar la solicitud de recogida del vehiculo.",
RequestRoadService = "Comando utilizado para solicitar asistencia vial.",
CancelRoadService = "Comando utilizado para cancelar la solicitud de asistencia vial.",
RequestCoroner = "Comando utilizado para solicitar un forense.",
CancelCoroner = "Comando utilizado para cancelar la solicitud del forense.",
RequestAnimalRescue = "Comando utilizado para solicitar un servicio de rescate de animales.",
CancelAnimalRescue = "Comando utilizado para cancelar la solicitud de rescate de animales.",
RequestMechanic = "Comando utilizado para solicitar un mecanico.",
CancelMechanic = "Comando utilizado para cancelar la solicitud del mecanico.",
RequestFire = "Comando utilizado para solicitar los servicios de bomberos.",
CancelFire = "Comando utilizado para cancelar la solicitud de los bomberos.",
InteractWithPed = "Comando utilizado para interactuar con una persona cercana.",
OrderOnKneesOrStandUp = "Comando utilizado para ordenar a una persona que se arrodille o se levante mientras le apuntas, o para detener o liberar a un animal.",
RadialMenu = "Comando utilizado para abrir el menu radial de solicitud de refuerzos.",
PullOver = "Comando utilizado para ordenar a un vehiculo que se detenga.",
CleanupObject = "Comando utilizado para retirar objetos cercanos.",
SpawnStretcher = "Comando utilizado para crear una camilla.",
DeleteStretcher = "Comando utilizado para eliminar una camilla cercana.",
GrabStretcher = "Comando utilizado para agarrar una camilla cercana.",
LowerStretcher = "Comando utilizado para bajar la camilla que estas utilizando.",
RaiseStretcher = "Comando utilizado para levantar una camilla cercana.",
InteractWithStretcherAndVeh = "Comando utilizado para interactuar con una camilla y un vehiculo.",
DropOffPedAtHospital = "Comando utilizado para dejar en el hospital a una persona transportada en una camilla.",
TrackUnit = "Comando utilizado para rastrear a otra unidad durante un aviso.",
TrackUnit2 = "id",
TrackUnit3 = "Introduce el ID de servidor del jugador.",
TakeOutOrPutAwaySpikestripFromVehicle = "Comando utilizado para sacar o guardar bandas de clavos en un vehiculo.",
DeployOrPickupSpikestrip = "Comando utilizado para desplegar o recoger una banda de clavos.",
ImpoundInteract = "Comando utilizado para interactuar con el encargado del deposito.",
GearInteract = "Comando utilizado para interactuar con el encargado del equipo.",
SearchVehicle = "Comando utilizado para registrar un vehiculo.",
ZoomInOnPursuitTarget = "Comando utilizado para acercar brevemente la vista al objetivo de la persecucion.",
PursuitRadialMenu = "Comando utilizado para abrir el menu radial de refuerzos para persecuciones.",
CancelPursuit = "Comando utilizado para cancelar la persecucion.",

        -- User Interface
        ToggleCalloutInfo = "Comando utilizado para mostrar u ocultar la informacion del aviso y las tareas.",
ToggleDispatchMessages = "Comando utilizado para activar o desactivar la recepcion de mensajes de la central.",
ToggleUILayout = "Abre la configuracion del HUD mientras estas de servicio. Pulsa Esc o Listo para guardar y salir.",

        -- Tow Tools
        ConnectClosestVehicle = "Comando utilizado para enganchar el vehiculo mas cercano a la grua.",

        -- Redisplay Last Module
        RedisplayLastModule = "Comando utilizado para volver a mostrar el ultimo modulo (documento de identificacion, informacion del vehiculo o inventario).",

        -- Hints
        ToggleHints = "Command used to toggle hints at certain events.",
    },

    --====================== CORONER BODY BAG SETTINGS ======================--

    BodyBagProp = "xm_prop_body_bag",
    BodyBagOffsetZ = 0.0, -- use -1.0 for example. For this prop 0.0 works.

    --====================== CALLOUT ENTITY BLIPS ======================--

    NPCFleeDrivingStyle     = 2884412,
    CalloutEntityBlipSprite = 14,
    CalloutEntityBlipColour = 50,
    CalloutEntityBlipScale  = 0.75,

    --====================== PROPS & ANIMATIONS ======================--

    FriskAnimationDictionary = "custom@police",                             -- Custom emote (credits to ultrahacx)
    FriskAnimation = "police",                                              -- Custom emote (credits to ultrahacx)

    --====================== PED CPR ======================--

    SurvivalChanceOnCPR = 80,   -- Precentage (of 100%) to survive.

    --====================== Fire Settings (SmartFires from LondonStudios https://store.londonstudios.net/category/fire-resources) ======================--
    -- IMPORTANT: The included lite resources only provide a minimum amount of variations for fire/smoke types. Consider getting the full experience at London Studios :)
    -- They offer more resources which are very usefull when playing ERS, discover them all via the link above.

    -- Size settings
    RandomHugeFireOrSmokeSize   = {8.0, 9.0, 10.0},
    RandomLargeFireOrSmokeSize  = {5.0, 6.0, 7.0},
    RandomMediumFireOrSmokeSize = {3.0, 4.0, 5.0},
    RandomSmallFireOrSmokeSize  = {1.0, 2.0, 3.0},

    -- Fire
    AllFireTypes = {"normal", "normal2", "normal3", "electrical", "bonfire", "chemical"},
    NormalFireTypes = {"normal", "normal2", "normal3"},
    ElectricalFire = "electrical",
    ChemicalFire = "chemical",
    BonFire = "bonfire",

    -- Smoke
    AllSmokeTypes = {"electrical", "normal", "white", "foggy", "normal2", "normal3", "normal4", "normal5", "normal6"},
    NormalSmokeTypes = {"normal", "normal2", "normal3", "normal4", "normal5", "normal6"},
    ElectricalSmoke = "electrical",
    FoggySmoke = "foggy",

    --====================== Suspect Arrest (Custody) Settings ======================--

    ShowBustedScreen = true,-- Shows Suspect Arrested in GTA style, when arresting a suspect.
    CustodyRadius = 50.0,   -- In which range must the player be to put an NPC into custody.
    CustodyBlipData = {     -- https://docs.fivem.net/docs/game-references/blips/
        Enabled = true,     -- Set to false to disable blips for the custody locations.
        Name = "Custody center",
        Sprite = 237,
        Display = 2, 
        ShortRange = true,
        Colour = 38, 
        Scale = 0.75,
        Alpha = 200, 
    },
    CustodyLocations = {
        vector3(533.8215, -12.1921, 70.6256),   -- Downtown Vinewood Police Station
        vector3(475.0804, -1021.3436, 28.0728), -- Mission Row Police Station
        vector3(-441.9879, 6017.8491, 31.6403), -- Paleto Bay Police Station
        vector3(1851.2694, 3692.9575, 34.2194), -- Sandy Shores Police Station
    },

    --====================== Incident Blip Settings ======================--

    EnableIncidentBlips = true,     -- Enables or disables the creation of blips for incidents.
    IncidentBlipsTimeout = 120,     -- Removes the blip automatically after x seconds.
    IncidentBlipsData = {
        DisplayId = 2,      -- On map & on legend.
        SpriteId = 468,     -- Sprite type
        Scale = 1.0,        -- Scale
        Alpha = 225,        -- Transparency 0/255 
        ColourId = 1,       -- Colour
    },

    --====================== Passenger Selector Settings on Interactions ======================--

    PassengerSelectorMarkerData = {
        MarkerId = 21 --[[ integer ]], 
        dirX = 0 --[[ number ]], 
        dirY = 0 --[[ number ]], 
        dirZ = 0 --[[ number ]], 
        rotX = 0 --[[ number ]], 
        rotY = 180.0 --[[ number ]], 
        rotZ = 0 --[[ number ]], 
        scaleX = 0.25 --[[ number ]], 
        scaleY = 0.25 --[[ number ]], 
        scaleZ = 0.25 --[[ number ]], 
        red = 255 --[[ integer ]], 
        green = 165 --[[ integer ]], 
        blue = 0 --[[ integer ]], 
        alpha = 100 --[[ integer ]], 
        bobUpAndDown = false --[[ boolean ]], 
        faceCamera = true --[[ boolean ]], 
        p19 = 0 --[[ integer ]], 
        rotate = false --[[ boolean ]], 
        textureDict = 0 --[[ string ]], 
        textureName = 0 --[[ string ]], 
        drawOnEnts = 0 --[[ boolean ]]
    },

    --====================== NPC License Settings ======================--
    -- These are random results when an NPC shows their license (Use AI to translate these, works fast if needed!)

    ChanceToHaveRecords = 15,   -- 15% chance of the person having records (flags, markers or warrants) in Police Database

    RandomLicenseResults = {
        -- Colour Options: text-danger, text-warning, text-success, text-info, text-muted 
        -- Chance is calculated as a percentage of the total chance to have records.
        {Status = "Revocada", IsStatusValid = false, Colour = "text-danger", Icon = "fas fa-ban", Chance = 10}, 
        {Status = "No valida", IsStatusValid = false, Colour = "text-danger", Icon = "fas fa-ban", Chance = 5},
        {Status = "Caducada", IsStatusValid = false, Colour = "text-danger", Icon = "fas fa-ban", Chance = 15},
        {Status = "Valida", IsStatusValid = true, Colour = "text-success", Icon = "fas fa-check", Chance = 30},
        {Status = "Denunciada como robada (valida)", IsStatusValid = true, Colour = "text-warning", Icon = "fas fa-exclamation-triangle", Chance = 5},
        {Status = "Licencia internacional (valida)", IsStatusValid = true, Colour = "text-success", Icon = "fas fa-globe", Chance = 15},
        {Status = "Sin licencia", IsStatusValid = false, Colour = "text-muted", Icon = "fas fa-ban", Chance = 20},
    },

    RandomFlagsOrMarkersDescriptions = {
        armed_and_dangerous = {
    "Agresion con un arma.",
    "Exhibicion de un arma de fuego en publico.",
    "Sospechoso de varios robos a mano armada.",
    "Portar un arma oculta sin permiso.",
    "Amenazar la seguridad publica con un arma de fuego.",
    "Implicado en un tiroteo con las fuerzas del orden."
},
assault = {
    "Comportamiento agresivo hacia un agente.",
    "Implicado en una pelea de bar que causo heridas graves.",
    "Incidentes reiterados de violencia domestica.",
    "Agresion a un funcionario publico.",
    "Altercado fisico en un lugar publico.",
    "Agresion con intencion de causar dano fisico."
},
burglary = {
    "Captado por las camaras mientras entraba por la fuerza en una joyeria.",
    "Relacionado con una serie de robos en viviendas.",
    "Intento de allanamiento en una propiedad comercial.",
    "Posesion de herramientas para cometer robos.",
    "Entrada por la fuerza en una vivienda.",
    "Robo en el interior de un vehiculo."
},
drug_related = {
    "Dirigir una red de distribucion de drogas a gran escala.",
    "Sorprendido fabricando sustancias ilegales.",
    "Posesion con intencion de distribuir.",
    "Trafico de sustancias controladas.",
    "Sorprendido con utensilios relacionados con drogas ilegales.",
    "Bajo los efectos de drogas ilegales en publico."
},
gang_affiliation = {
    "Lider de una conocida banda callejera.",
    "Implicado en tiroteos relacionados con bandas.",
    "Organizacion de actividades delictivas de una banda.",
    "Actividades de extorsion relacionadas con bandas.",
    "Participacion en una pelea entre bandas.",
    "Vandalismo relacionado con la actividad de una banda."
},
homicide = {
    "Principal sospechoso en un caso de asesinato de gran repercusion.",
    "Relacionado con varios homicidios sin resolver.",
    "Acusado de intento de asesinato.",
    "Implicado en una trama de asesinato por encargo.",
    "Complice de un homicidio.",
    "Homicidio involuntario durante un acto delictivo."
},
kidnapping = {
    "Secuestro de una persona conocida para pedir un rescate.",
    "Implicado en varios casos de secuestro.",
    "Intento de secuestro a punta de pistola.",
    "Retener a una persona contra su voluntad.",
    "Secuestro relacionado con el crimen organizado.",
    "Uso de un vehiculo para facilitar un secuestro."
},
mental_health_issues = {
    "Historial de arrebatos violentos en publico.",
    "Fugado de un centro de salud mental.",
    "Incumplimiento del tratamiento de salud mental.",
    "Comportamiento amenazante debido a inestabilidad mental.",
    "Detenido para una evaluacion psiquiatrica.",
    "Alteracion del orden publico relacionada con la salud mental."
},
sex_offense = {
    "Condenado por varias agresiones sexuales.",
    "Delincuente registrado que incumplio la libertad condicional.",
    "Varios cargos por agresion sexual.",
    "Sospechoso de agresiones sexuales en serie.",
    "Exhibicion indecente en un lugar publico.",
    "Acoso sexual con contacto fisico."
},
terrorism = {
    "Sospechoso de planear un atentado terrorista.",
    "Relacionado con una organizacion terrorista conocida.",
    "Posesion de materiales para fabricar explosivos.",
    "Amenazar la seguridad nacional.",
    "Implicado en una trama de ciberterrorismo.",
    "Financiacion de actividades terroristas."
},
theft = {
    "Miembro de una red de robo de vehiculos.",
    "Sorprendido robando objetos de gran valor en una tienda.",
    "Robo de carteras en una zona concurrida.",
    "Robo en el lugar de trabajo.",
    "Robo de identidad y fraude.",
    "Receptacion de bienes robados."
},
traffic_violation = {
    "Infracciones reiteradas por conducir bajo los efectos del alcohol.",
    "Huida de las fuerzas del orden durante un control de trafico.",
    "Conducir sin una licencia valida.",
    "Exceso de velocidad en una zona residencial.",
    "Conduccion temeraria que causo un accidente.",
    "Saltarse varios semaforos en rojo."
},
wanted_person = {
    "Reincidente",
    "No comparecio ante el tribunal",
    "No se presento al control de libertad condicional",
    "No se presento al control de la condena condicional",
    "Preso fugado",
    "Fugitivo",
    "Incumplimiento de la condena condicional",
    "Historial violento",
    "Riesgo de fuga",
    "Caso de gran repercusion",
    "Tratamiento por abuso de sustancias",
    "Disputas domesticas frecuentes"
},
other = {
    "Reincidente",
    "No comparecio ante el tribunal",
    "No se presento al control de libertad condicional",
    "No se presento al control de la condena condicional",
    "Preso fugado",
    "Fugitivo",
    "Incumplimiento de la condena condicional",
    "Historial violento",
    "Riesgo de fuga",
    "Caso de gran repercusion",
    "Tratamiento por abuso de sustancias",
    "Disputas domesticas frecuentes"
},
active_warrant = {
    "Reincidente",
    "No comparecio ante el tribunal",
    "No se presento al control de libertad condicional",
    "No se presento al control de la condena condicional",
    "Preso fugado",
    "Fugitivo",
    "Incumplimiento de la condena condicional",
    "Historial violento",
    "Riesgo de fuga",
    "Caso de gran repercusion",
    "Tratamiento por abuso de sustancias",
    "Disputas domesticas frecuentes"
        },
    },
    
    --====================== NPC Inventory Item Settings ======================--
    -- These items are randomly presented when searching an NPC. You can add or remove items and adjust legality.

    NPCInventory = {
        {name = "Cartera", illegal = false},
{name = "Rolex", illegal = false},
{name = "Telefono movil", illegal = false},
{name = "Cuchillo", illegal = true},
{name = "Drogas", illegal = true},
{name = "Pistola", illegal = true},
{name = "Linterna", illegal = false},
{name = "Llaves", illegal = false},
{name = "Reloj", illegal = false},
{name = "Botella de agua", illegal = false},
{name = "Mapa", illegal = false},
{name = "Botiquin de primeros auxilios", illegal = false},
{name = "Mechero", illegal = false},
{name = "Cerillas", illegal = false},
{name = "Gafas de sol", illegal = false},
{name = "Sombrero", illegal = false},
{name = "Mochila", illegal = false},
{name = "Aguja hipodermica", illegal = true},
{name = "Brujula", illegal = false},
{name = "Radio", illegal = false},
{name = "Camara", illegal = false},
{name = "Prismaticos", illegal = false},
{name = "Guantes", illegal = false},
{name = "Tijeras", illegal = false},
{name = "Cuerda", illegal = false},
{name = "Martillo", illegal = false},
{name = "Clavos", illegal = false},
{name = "Destornillador", illegal = false},
{name = "Bolsa de plastico", illegal = false},
{name = "Esposas", illegal = false},
{name = "Ganzua", illegal = true},
{name = "Palanca", illegal = false},
{name = "Dinero", illegal = false},
{name = "Pasaporte", illegal = false},
{name = "Documento de identificacion", illegal = false},
{name = "Tarjeta de credito", illegal = false},
{name = "Extracto bancario", illegal = false},
{name = "Permiso de conducir", illegal = false},
{name = "Licencia de armas", illegal = false},
{name = "Receta medica", illegal = false},
{name = "Porro", illegal = true},
{name = "Cigarrillos", illegal = false},
{name = "Liquido para mechero", illegal = false},
{name = "Guardapelo", illegal = false},
{name = "Collar", illegal = false},
{name = "Pulsera", illegal = false},
{name = "Anillo", illegal = false},
{name = "Reloj inteligente", illegal = false},
{name = "Libro", illegal = false},
{name = "Cuaderno", illegal = false},
{name = "Boligrafo", illegal = false},
{name = "Calcetines", illegal = false},
{name = "Zapatos", illegal = false},
{name = "Toalla", illegal = false},
{name = "Cepillo de dientes", illegal = false},
{name = "Pasta de dientes", illegal = false},
{name = "Champu", illegal = false},
{name = "Acondicionador", illegal = false},
{name = "Jabon", illegal = false},
{name = "Desodorante", illegal = false},
{name = "Balsamo labial", illegal = false},
{name = "Desinfectante de manos", illegal = false},
{name = "Panuelo de papel", illegal = false},
{name = "Gafas", illegal = false},
{name = "Lentillas", illegal = false},
{name = "Liquido para lentillas", illegal = false},
{name = "Cepillo para el pelo", illegal = false},
{name = "Cortauas", illegal = false},
{name = "Paraguas", illegal = false},
{name = "Cuaderno", illegal = false},
{name = "Auriculares", illegal = false},
{name = "Cargador", illegal = false},
{name = "Memoria USB", illegal = false},
{name = "Ordenador portatil", illegal = false},
{name = "Tableta", illegal = false},
{name = "Panuelo", illegal = false},
{name = "Cinturon", illegal = false},
{name = "Funda para gafas de sol", illegal = false},
{name = "Botella de agua", illegal = false},
{name = "Joyas robadas", illegal = true},
{name = "Documento de identificacion falso", illegal = true},
{name = "Explosivos", illegal = true},
{name = "Veneno", illegal = true},
{name = "Inhibidor de senal", illegal = true},
        -- Add more here in the same format, example:
        -- {name = "iFruit phone cover", illegal = false},
    },

    --====================== ZONE CHANGE UI ======================--

    EnableZoneChangeUI = true,
    Zones = { 
        ['AIRP'] = "Los Santos International Airport", ['ALAMO'] = "Alamo Sea", ['ALTA'] = "Alta", ['ARMYB'] = "Fort Zancudo", ['BANHAMC'] = "Banham Canyon Dr", ['BANNING'] = "Banning", 
        ['BEACH'] = "Vespucci Beach", ['BHAMCA'] = "Banham Canyon", ['BRADP'] = "Braddock Pass", ['BRADT'] = "Braddock Tunnel", ['BURTON'] = "Burton", ['CALAFB'] = "Calafia Bridge", ['CANNY'] = "Raton Canyon", 
        ['CCREAK'] = "Cassidy Creek", ['CHAMH'] = "Chamberlain Hills", ['CHIL'] = "Vinewood Hills", ['CHU'] = "Chumash", ['CMSW'] = "Chiliad Mountain State Wilderness", ['CYPRE'] = "Cypress Flats", ['DAVIS'] = "Davis", 
        ['DELBE'] = "Del Perro Beach", ['DELPE'] = "Del Perro", ['DELSOL'] = "La Puerta", ['DESRT'] = "Grand Senora Desert", ['DOWNT'] = "Downtown", ['DTVINE'] = "Downtown Vinewood", ['EAST_V'] = "East Vinewood", 
        ['EBURO'] = "El Burro Heights", ['ELGORL'] = "El Gordo Lighthouse", ['ELYSIAN'] = "Elysian Island", ['GALFISH'] = "Galilee", ['GOLF'] = "GWC and Golfing Society", ['GRAPES'] = "Grapeseed", 
        ['GREATC'] = "Great Chaparral", ['HARMO'] = "Harmony", ['HAWICK'] = "Hawick", ['HORS'] = "Vinewood Racetrack", ['HUMLAB'] = "Humane Labs and Research", ['JAIL'] = "Bolingbroke Penitentiary", 
        ['KOREAT'] = "Little Seoul", ['LACT'] = "Land Act Reservoir", ['LAGO'] = "Lago Zancudo", ['LDAM'] = "Land Act Dam", ['LEGSQU'] = "Legion Square", ['LMESA'] = "La Mesa", ['LOSPUER'] = "La Puerta", 
        ['MIRR'] = "Mirror Park", ['MORN'] = "Morningwood", ['MOVIE'] = "Richards Majestic", ['MTCHIL'] = "Mount Chiliad", ['MTGORDO'] = "Mount Gordo", ['MTJOSE'] = "Mount Josiah", ['MURRI'] = "Murrieta Heights", 
        ['NCHU'] = "North Chumash", ['NOOSE'] = "N.O.O.S.E", ['OCEANA'] = "Pacific Ocean", ['PALCOV'] = "Paleto Cove", ['PALETO'] = "Paleto Bay", ['PALFOR'] = "Paleto Forest", ['PALHIGH'] = "Palomino Highlands", 
        ['PALMPOW'] = "Palmer-Taylor Power Station", ['PBLUFF'] = "Pacific Bluffs", ['PBOX'] = "Pillbox Hill", ['PROCOB'] = "Procopio Beach", ['RANCHO'] = "Rancho", ['RGLEN'] = "Richman Glen", ['RICHM'] = "Richman", 
        ['ROCKF'] = "Rockford Hills", ['RTRAK'] = "Redwood Lights Track", ['SANAND'] = "San Andreas", ['SANCHIA'] = "San Chianski Mountain Range", ['SANDY'] = "Sandy Shores", ['SKID'] = "Mission Row", 
        ['SLAB'] = "Stab City", ['STAD'] = "Maze Bank Arena", ['STRAW'] = "Strawberry", ['TATAMO'] = "Tataviam Mountains", ['TERMINA'] = "Terminal", ['TEXTI'] = "Textile City", ['TONGVAH'] = "Tongva Hills", 
        ['TONGVAV'] = "Tongva Valley", ['VCANA'] = "Vespucci Canals", ['VESP'] = "Vespucci", ['VINE'] = "Vinewood", ['WINDF'] = "Ron Alternates Wind Farm", ['WVINE'] = "West Vinewood", ['ZANCUDO'] = "Zancudo River", 
        ['ZP_ORT'] = "Port of South Los Santos", ['ZQ_UAR'] = "Davis Quartz"
    },

    --====================== DEBUG ======================--
    -- Debug note: Resmon is very high during debug mode. This is in relation to all the rendering done for developer information.

    -- Marker which indicates the spawn position for NPC backup, can be handy when creating callouts making sure the location is reachable properly by NPC backup.
    EnabledDebugMarker = false,
    MarkerData = {
        MarkerId = 21 --[[ integer ]], 
        dirX = 0 --[[ number ]], 
        dirY = 0 --[[ number ]], 
        dirZ = 0 --[[ number ]], 
        rotX = 0 --[[ number ]], 
        rotY = 180.0 --[[ number ]], 
        rotZ = 0 --[[ number ]], 
        scaleX = 0.25 --[[ number ]], 
        scaleY = 0.25 --[[ number ]], 
        scaleZ = 0.25 --[[ number ]], 
        red = 255 --[[ integer ]], 
        green = 165 --[[ integer ]], 
        blue = 0 --[[ integer ]], 
        alpha = 75 --[[ integer ]], 
        bobUpAndDown = false --[[ boolean ]], 
        faceCamera = true --[[ boolean ]], 
        p19 = 0 --[[ integer ]], 
        rotate = false --[[ boolean ]], 
        textureDict = 0 --[[ string ]], 
        textureName = 0 --[[ string ]], 
        drawOnEnts = 0 --[[ boolean ]]
    },
}
