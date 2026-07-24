fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'smvlpd-ranks'
author 'SMVLPD'
description 'Rangos policiales persistentes y armeria por rango para PD5M'
version '1.0.0'

dependencies {
    'oxmysql',
    'ox_lib',
    'smvlpd-character'
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

client_scripts {
    'client/main.lua'
}
