-- Resource Metadata
fx_version 'cerulean'
games { 'gta5' }

author 'Nights Software'
description 'Subtitles for FiveM'
version '1.0.0'
lua54 'yes'

client_scripts {
    'client/*.lua'
}

server_scripts {
    'server/*.lua'
}

shared_scripts {
    'config/*.lua'
}

export 'DisplaySubtitle'

ui_page "index.html"
files {
    "index.html",
    'NUI/*.js',
    'NUI/*.css'
}

escrow_ignore {
    'config/*.lua',
    'client/c_functions.lua',
    'server/s_functions.lua'
}

dependency '/assetpacks'