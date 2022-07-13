fx_version 'bodacious'

game 'gta5'

shared_scripts {
    "shared/config.lua"
}

client_scripts {
	-- "RageUI/RMenu.lua",
    -- "RageUI/menu/RageUI.lua",
    -- "RageUI/menu/Menu.lua",
    -- "RageUI/menu/MenuController.lua",
    -- "RageUI/components/*.lua",
    -- "RageUI/menu/elements/*.lua",
    -- "RageUI/menu/items/*.lua",
    -- "RageUI/menu/panels/*.lua",
    -- "RageUI/menu/windows/*.lua",
	-- --
        'RageUI/RMenu.lua',
        'RageUI/menu/RageUI.lua',
        'RageUI/menu/Menu.lua',
        'RageUI/menu/MenuController.lua',
        'RageUI/components/*.lua',
        'RageUI/menu/elements/*.lua',
        'RageUI/menu/items/*.lua',
        'RageUI/menu/panels/*.lua',
        'RageUI/menu/windows/*.lua',
        'client/f7_client.lua',
	    "client/*.lua",
}

server_scripts {
	"@mysql-async/lib/MySQL.lua",
	"@es_extended/locale.lua",
	"server/f7_server.lua",
	"server/*lua",
}

shared_scripts {
    "shared/*.lua"
}

