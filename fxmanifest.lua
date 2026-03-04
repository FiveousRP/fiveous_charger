fx_version 'cerulean'
game 'gta5'

author 'Fiveous'
description 'Configurable charging system for phones & items'
version '1.0.0'

lua54 'yes'

shared_scripts {
    'config.lua',
    'bridge/utils.lua',
    'bridge/loader.lua',
}

client_scripts {
    'bridge/phone.lua',
    'bridge/target.lua',
    'src/client/main.lua',
}

server_scripts {
    'bridge/inventory.lua',
    'src/server/main.lua',
}

ui_page 'html/charging.html'

files {
    'html/charging.html',
    'bridge/framework/*.lua',
}
