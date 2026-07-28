fx_version 'cerulean'
game 'gta5'

lua54 'yes'

author 'SimuvicioPD'
description 'Sistema de vestuarios'
version '1.0.0'

dependency 'ox_lib'
dependency 'smvlpd-ranks'

client_scripts {
    '@ox_lib/init.lua',
    'config.lua',
    'client.lua'
}

server_scripts {
    'server.lua'
}