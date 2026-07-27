fx_version 'adamant'
game 'gta5'
lua54 'yes'

description 'Flatbeds ERS Lite'
author 'Theebu'

version '0.1.0'

shared_scripts {
	'config.lua',
}

client_scripts {
	'client/utils.lua',
	'client/client.lua'
}

server_scripts {
	'server/server.lua'
}

escrow_ignore {
	'config.lua',
	'client/utils.lua'
}
dependency '/assetpacks'