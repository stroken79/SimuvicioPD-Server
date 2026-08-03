fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'SMVLPD'
description 'Standalone character selection and appearance'
version '1.0.0'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/camera.lua',
    'client/creator.lua',
    'client/main.lua',
    'client/duty.lua',
    'client/menu.lua'
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
