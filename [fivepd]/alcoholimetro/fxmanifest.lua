fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'SwiftDUI'
author 'Swift Studios'
description 'Alcotest 7510 breathalyzer'
version '1.0.0'

shared_scripts {
    'config.lua',
    'shared/events.lua',
}

ui_page 'html/index.html'

client_scripts {
    'client/main.lua',
}

server_scripts {
    'server/permissions.lua',
    'server/startup.lua',
    'server/main.lua',
}

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
    'html/breathalyzer_pas.png',
    'html/breathalyzer_evi.png',
    'html/audio/beep.wav',
    'html/audio/testing.wav',
}
