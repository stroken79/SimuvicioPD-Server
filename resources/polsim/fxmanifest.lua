fx_version 'cerulean'
game 'gta5'

author 'Alex'
description 'POLSIM V'
version '0.3.1'

lua54 "yes"

ui_page {
    'NUI/nui.html'
}

files {
    'Client/*.dll',
    'Client/Newtonsoft.Json.dll',
    'Client/LemonUI.FiveM.dll',
	'outfits.json',
	'departments.json',
	'postals.json',
	'coordinates.json',
	'jails.json',
	'items.json',
	'client-settings.json',
	'server-settings.json',
	'NUI/**'
}

client_scripts {
    'Client/*.net.dll',
    'NUI/nuiHandler.lua'
}

server_scripts {
    'Server/*.net.dll'
}
