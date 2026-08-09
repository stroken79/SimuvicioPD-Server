fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'Simuvicio'
description 'SimuvicioPD EMS Clothing'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'uniforms.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

dependencies {
    'ox_lib',
    'ox_target',
    'smvlpd-ranks',
    'smvlpd-accessories'
}
