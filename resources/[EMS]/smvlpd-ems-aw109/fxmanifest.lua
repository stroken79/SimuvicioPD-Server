fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Simuvicio'
description 'AW109 Medical standalone para FiveM'
version '1.0.0'

files {
    'data/vehicles.meta',
    'data/handling.meta',
    'data/carcols.meta',
    'data/carvariations.meta',
    'data/vehiclelayouts.meta'
}

data_file 'VEHICLE_METADATA_FILE' 'data/vehicles.meta'
data_file 'HANDLING_FILE' 'data/handling.meta'
data_file 'CARCOLS_FILE' 'data/carcols.meta'
data_file 'VEHICLE_VARIATION_FILE' 'data/carvariations.meta'
data_file 'VEHICLE_LAYOUTS_FILE' 'data/vehiclelayouts.meta'

client_script 'client.lua'
