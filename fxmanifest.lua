fx_version 'cerulean'
game 'gta5'
use_experimental_fxv2_oal 'yes'
lua54 'yes'

author "Asgaard Developments | s4t4n667"
description 'Criminal moneywash system'
version '1.1.0'

shared_script {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'resource/client.lua'
}

server_scripts {
    'resource/server.lua'
}

files {
    'locales/*.json'
}

dependencies {
    'ox_lib',
    'ox_target',
    'ox_inventory'
}
