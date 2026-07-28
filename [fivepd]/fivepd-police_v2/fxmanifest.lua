fx_version 'cerulean'
game 'gta5'

dependency 'smvlpd-ranks'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js'
}

client_script 'config.lua'
server_script 'callouts/support_sv.lua'
client_script 'uniforms/patrol.lua'
client_script 'client/main.lua'
client_script 'client/nui.lua'
client_script 'client/wardrobe.lua'
client_script 'callouts/callout_manager.lua'
client_script 'callouts/abandonedvehicle.lua'
client_script 'callouts/carcallouts.lua'
client_script 'callouts/drunkcallouts.lua'
client_script 'callouts/beachcallouts.lua'
client_script 'callouts/groupcallouts.lua'
client_script 'callouts/kidnappingcallouts.lua'
client_script 'callouts/wildernesscallouts.lua'
client_script 'callouts/deadbodycallouts.lua'
client_script 'callouts/heavyshootingcallouts.lua'
client_script 'callouts/animalcallouts.lua'
