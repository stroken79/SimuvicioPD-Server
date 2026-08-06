fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'smvlpd-ems-ranks'
author 'SMVLPD'
description 'Rangos EMS persistentes y equipamiento por rango'

dependencies {
    'oxmysql',
    'ox_lib',
    'smvlpd-character'
}

shared_scripts {
    '@ox_lib/init.lua',

    'config.lua',
    'config/weapons.lua',
    'config/vehicles.lua',
    'config/functions.lua'
}


server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

client_scripts {
    'client/main.lua'
}


ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js',
    'html/img/*.png'
}
