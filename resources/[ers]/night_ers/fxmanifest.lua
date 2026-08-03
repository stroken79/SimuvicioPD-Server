-- Resource Metadata
fx_version 'cerulean'
games { 'gta5' }

author 'Nights Software'
description 'Emergency Response Simulator'
version '1.8.15'
lua54 'yes'

dependency 'smvlpd-ranks'

shared_scripts {
    'shared/ers_server_globals.lua',
    'shared/debug_helpers.lua',
    'config/config.lua',
    'config/*.lua',
    'config/translations/*.lua',
    'callouts/plugins/*.lua',
    'callouts/callout_pack_import.lua',
    'shared/ers_night_shifts_mdt.lua',
    'shared/ped_state_constants.lua',
    'shared/interaction_flee_rolls.lua',
    'shared/smartfires_v2_contract.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua',
    'server/smartfires/v1/bridge.lua',
    'server/smartfires/lite/bridge.lua',
    'server/smartfires/v2/bridge.lua',
    'server/smartfires/v2/scope.lua',
    'server/smartfires/v2/hud.lua',
    'server/smartfires/v2/spawn.lua',
    'server/smartfires/v2/npc.lua',
    'server/smartfires/v2/teardown.lua',
    'server/smartfires/v2/events.lua',
    'server/smartfires/bridge.lua',
    'callouts/callouts_server.lua'
}

client_scripts {
    'client/*.lua',
    'client/smartfires/v2/bridge.lua',
    'client/smartfires/v2/scope.lua',
    'client/smartfires/v2/events.lua',
    'callouts/callouts_client.lua'
}

ui_page "index.html"
files {
    "index.html",
    'NUI/fonts/*.ttf',
    'NUI/images/*.jpg',
    'NUI/images/*.png',
    'NUI/sounds/generic-sounds/*.ogg',
    'NUI/sounds/en/*.ogg',
    'NUI/sounds/us/*.ogg',
    'NUI/sounds/fr/*.ogg',
    'NUI/sounds/de/*.ogg',
    -- 'NUI/sounds/nl/*.ogg',
    -- 'NUI/sounds/cs/*.ogg',
    -- 'NUI/sounds/he/*.ogg',
    'NUI/vendor/tailwind-2.2.19.min.css',
    'NUI/css/*.css',
    'NUI/js/ers_theme.js',
    'NUI/js/ers_theme_legend.js',
    'NUI/js/ers_hud_stage.js',
    'NUI/js/ers_hud_layout_defaults.js',
    'NUI/js/ers_drag.js',
    'NUI/main.js',
    'NUI/*.css',
    'data/stretcher/*.meta',
    'data/hose/*.meta',
    'stream/*.ytyp'
}

data_file 'DLC_ITYP_REQUEST' 'stream/neko_night_barrier_assets.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/cages/v_storage_2.ytyp'
data_file 'DLC_ITYP_REQUEST' 'stream/prop_alcotest.ytyp'

data_file 'HANDLING_FILE' 'data/stretcher/handling.meta'
data_file 'VEHICLE_METADATA_FILE' 'data/stretcher/vehicles.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/stretcher/carvariations.meta'

data_file 'WEAPONINFO_FILE' 'data/hose/weapons.meta'
data_file 'WEAPON_METADATA_FILE' 'data/hose/weaponarchetypes.meta'
data_file 'WEAPON_ANIMATIONS_FILE' 'data/hose/weaponanimations.meta'
data_file 'PED_PERSONALITY_FILE' 'data/hose/pedpersonality.meta'

escrow_ignore {
    'shared/*.lua',
    'config/*.lua',
    'config/translations/*.lua',
    'callouts/*.lua',
    'callouts/plugins/*.lua',
    'client/c_functions.lua',
    'client/exports_client.lua',
    'client/exports_patrol_squad_client.lua',
    'client/smartfires/v2/bridge.lua',
    'client/smartfires/v2/scope.lua',
    'client/smartfires/v2/events.lua',
    'server/s_functions.lua',
    'server/exports_server.lua',
    'server/smartfires/bridge.lua',
    'server/smartfires/v1/bridge.lua',
    'server/smartfires/lite/bridge.lua',
    'server/smartfires/v2/bridge.lua',
    'server/smartfires/v2/scope.lua',
    'server/smartfires/v2/hud.lua',
    'server/smartfires/v2/spawn.lua',
    'server/smartfires/v2/npc.lua',
    'server/smartfires/v2/teardown.lua',
    'server/smartfires/v2/events.lua'
}
dependency '/assetpacks'
