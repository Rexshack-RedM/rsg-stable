fx_version 'cerulean'
game 'rdr3'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

-- rexshack version
description 'qr-stable' 

shared_scripts {
	'@qr-core/shared/locale.lua',
	'locale/en.lua',
	'config.lua'
}
client_scripts {
	'horse_comp.lua',
	'client/main.lua'
}
server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/main.lua'
}

ui_page 'html/index.html'

files {
	'html/*',
	'html/css/*',
	'html/fonts/*',
	'html/img/*'
}

dependencies {
	'qr-core'
}

lua54 'yes'