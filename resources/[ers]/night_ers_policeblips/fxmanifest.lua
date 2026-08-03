fx_version 'cerulean'
game 'gta5'

author 'Sergi'
description 'Blips de policias de servicio y solicitudes de ayuda para night_ers'
version '1.0.0'

lua54 'yes'

dependencies {
    'night_ers',
    'oxmysql'
}

shared_script 'config.lua'

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

client_script 'client.lua'
