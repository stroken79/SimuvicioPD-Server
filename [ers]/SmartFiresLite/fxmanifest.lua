fx_version 'bodacious'

games { 'gta5' }

author 'London Studios'
description 'Create and fight realistic fires with a host of features'
version '1.0.0'
lua54 'yes'

client_scripts {
	'shared.lua',
	'cl_smartfires.lua',
}

server_scripts {
	'shared.lua',
	'sv_smartfires.lua',
}

escrow_ignore {
	'shared.lua'
}
dependency '/assetpacks'