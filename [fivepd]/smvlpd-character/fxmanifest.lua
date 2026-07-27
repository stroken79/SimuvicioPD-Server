fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'SMVLPD'
description 'Standalone character selection and appearance for FivePD'
version '1.0.0'

shared_script 'config.lua'

client_scripts {
    'client/camera.lua',
    'client/creator.lua',
    'client/main.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
}
