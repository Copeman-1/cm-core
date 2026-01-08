fx_version 'cerulean'
game 'gta5'

description 'CM-Core - Lightweight FiveM Framework'
version '1.0.0'
author 'Cope'
repository 'https://github.com/yourusername/cm-core'

lua54 'yes'

-- ════════════════════════════════════════════════════════════
-- SHARED SCRIPTS (Both Client & Server)
-- ════════════════════════════════════════════════════════════
shared_scripts {
    'config.lua',
    'shared/constants.lua',
    'shared/config.lua',
    'shared/utils.lua',
    'shared/locale.lua',
}

-- ════════════════════════════════════════════════════════════
-- SERVER SCRIPTS
-- ════════════════════════════════════════════════════════════
server_scripts {
    -- Database (oxmysql)
    '@oxmysql/lib/MySQL.lua',
    
    -- Core systems
    'server/main.lua',
    'server/database.lua',
    'server/cache.lua',
    'server/logger.lua',
    'server/ratelimit.lua',
    'server/permissions.lua',
    'server/callbacks.lua',
    'server/player.lua',
    'server/commands.lua',
    'server/events.lua',
    
    -- Modules
    'modules/admin/server/*.lua',
    'modules/editor/server/*.lua',
    
    -- Exports (must be last)
    'server/exports.lua',
    
    -- Compatibility bridge (must be after exports)
    'bridge/qb-compat.lua',
}

-- ════════════════════════════════════════════════════════════
-- CLIENT SCRIPTS
-- ════════════════════════════════════════════════════════════
client_scripts {
    -- Core systems
    'client/main.lua',
    'client/utils.lua',
    'client/nui.lua',
    'client/callbacks.lua',
    'client/player.lua',
    'client/events.lua',
    
    -- Modules
    'modules/admin/client/*.lua',
    'modules/editor/client/*.lua',
    
    -- Exports (must be last)
    'client/exports.lua',
    
    -- Compatibility bridge (must be after exports)
    'bridge/qb-compat.lua',
}

-- ════════════════════════════════════════════════════════════
-- UI FILES
-- ════════════════════════════════════════════════════════════
ui_page 'html/index.html'

files {
    'html/index.html',
    'html/css/*.css',
    'html/js/*.js',
    'html/img/**/*',
    'html/fonts/**/*',
	
	 -- Admin module UI
    'modules/admin/html/index.html',
    'modules/admin/html/css/*.css',
    'modules/admin/html/js/*.js',
    
    -- Config files (for editor module)
    'config/*.json',
    
    -- Locale files
    'locales/*.lua',
}
  ui_page 'modules/admin/html/index.html'
-- ════════════════════════════════════════════════════════════
-- DEPENDENCIES
-- ════════════════════════════════════════════════════════════
dependencies {
    'oxmysql',  -- Required for database operations
}

-- ════════════════════════════════════════════════════════════
-- ESCROW (if you plan to encrypt/protect certain files)
-- ════════════════════════════════════════════════════════════
-- escrow_ignore {
--     'config.lua',
--     'bridge/qb-compat.lua',
--     'locales/*.lua',
-- }

-- ════════════════════════════════════════════════════════════
-- CONVARS (Server Configuration Variables)
-- ════════════════════════════════════════════════════════════
-- Add these to your server.cfg:
-- setr cm_core:debug "false"
-- setr cm_core:qb_compat "true"
-- setr cm_core:locale "en"

-- ════════════════════════════════════════════════════════════
-- PROVIDE EXPORTS FOR OTHER RESOURCES
-- ════════════════════════════════════════════════════════════
-- Resources can access CM-Core with:
-- local CMCore = exports['cm-core']:GetCoreObject()
-- Or for QBCore compatibility:
-- local QBCore = exports['cm-core']:GetCoreObject()

-- ════════════════════════════════════════════════════════════
-- VERSION CHECK
-- ════════════════════════════════════════════════════════════
-- Automatically checks for updates on GitHub