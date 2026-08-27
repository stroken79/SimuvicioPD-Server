fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Simuvicio'
description 'Garaje maritimo compartido por servicio ERS y rango'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/garage.lua'
}

server_scripts {
    'server/main.lua'
}

dependencies {
    'ox_lib',
    'night_ers',
    'smvlpd-ranks'
}
