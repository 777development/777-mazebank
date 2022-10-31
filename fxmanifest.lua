fx_version 'cerulean'
game 'gta5'

description '777 Maze Bank for QB-Core'
version '1.0'

ui_page 'html/index.html'

shared_scripts {
    'sh_config.lua',
    '@qb-core/shared/locale.lua',
    'locales/en.lua',
    'locales/*.lua',
    'config_changable.lua',
    'config_progress.lua'
}

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    'cl_config.lua',
    'client/powerstation.lua',
    'client/doors.lua',
    'client/maze.lua',
    'client/reset.lua'
}

server_scripts {
    'sv_config.lua',
    'server/main.lua'
}

files {
    'html/*',
}

dependency 'PolyZone'

lua54 'yes'
use_fxv2_oal 'yes'
