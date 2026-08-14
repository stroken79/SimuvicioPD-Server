fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Simuvicio'
description 'Capa de integracion Bomberos: ERS, SmartFiresLite, SmartHoseLite y ox_target'
version '1.0.0'

shared_script 'config.lua'

client_scripts {
    'client/main.lua',
    'client/hose.lua',
    'client/waterCannon.lua',
    'client/fireDetection.lua',
    'client/ersIntegration.lua'
}

server_script 'server/main.lua'

dependencies {
    'ox_target',
    'night_ers',
    'SmartFiresLite',
    'SmartHoseLite'
}
