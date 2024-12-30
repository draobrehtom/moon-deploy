fx_version 'cerulean'
games { 'rdr3' }
author 'draobrehtom'
rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'
lua54 'yes'

client_scripts {
    'client/dataview.lua',
    'client/functions.lua',
    'client/component.lua',
    'client/camera.lua',
    'client/main.lua',
    'client/spawn.lua',
}
server_scripts {
    'server/main.lua',
}

-- a_c_lumandragon_01
file 'metapeds.ymt'
data_file 'PED_METADATA_FILE' 'metapeds.ymt'