fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Simuvicio'
description 'Servicio LSDOT - Grua integrado con ERS'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'uniforms.lua'
}

client_scripts {
    'client/functions.lua',
    'client/service.lua',
    'client/garage.lua',
    'client/clothing.lua'
}

server_scripts {
    'server/main.lua'
}

dependencies {
    'ox_lib',
    'night_ers',
    'smvlpd-ranks'
}
