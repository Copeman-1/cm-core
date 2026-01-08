Config = {}

-- ════════════════════════════════════════════════════════════
-- CORE SETTINGS
-- ════════════════════════════════════════════════════════════
Config.Core = {
    Name = "CM-Core",
    Version = "1.0.0",
    UpdateCheck = true,              -- Check for framework updates on startup
    DebugMode = false,               -- Enable debug logging
}

-- ════════════════════════════════════════════════════════════
-- DATABASE SETTINGS
-- ════════════════════════════════════════════════════════════
Config.Database = {
    ConnectionPool = 5,              -- Number of MySQL connection pool
    SlowQueryThreshold = 100,        -- Log queries slower than this (milliseconds)
    AutoCreateTables = true,         -- Automatically create tables on startup
}

-- ════════════════════════════════════════════════════════════
-- PLAYER SETTINGS
-- ════════════════════════════════════════════════════════════
Config.Player = {
    AutoSaveInterval = 5,            -- Auto-save interval in minutes
    StartingMoney = {
        cash = 5000,
        bank = 25000
    },
    MaxPlayers = 128,
    
    -- Starting position
    DefaultSpawn = {
        x = -269.4,
        y = -955.3,
        z = 31.2,
        heading = 205.8
    },
    
    -- Player identifiers (priority order)
    Identifiers = {
        'license',
        'discord',
        'steam'
    },
}

-- ════════════════════════════════════════════════════════════
-- PERFORMANCE SETTINGS
-- ════════════════════════════════════════════════════════════
Config.Performance = {
    -- Caching
    CacheEnabled = true,
    CacheTTL = 300,                  -- Cache time-to-live in seconds
    
    -- Rate limiting
    RateLimitEnabled = true,
    RateLimitMax = 10,               -- Max events per second per player
    
    -- Threading
    MaxThreads = 50,                 -- Maximum concurrent threads
}

-- ════════════════════════════════════════════════════════════
-- MODULE SETTINGS
-- ════════════════════════════════════════════════════════════
Config.Modules = {
    Admin = true,                    -- Enable admin tools module
    Editor = true,                   -- Enable config editor module
}

-- ════════════════════════════════════════════════════════════
-- ADMIN MODULE SETTINGS
-- ════════════════════════════════════════════════════════════
Config.Admin = {
    -- Discord webhook for admin logs
    DiscordWebhook = '',
    
    -- Log actions
    LogActions = {
        kick = true,
        ban = true,
        unban = true,
        teleport = true,
        givemoney = true,
        giveitem = true,
        setjob = true,
        revive = true,
        godmode = true,
        noclip = true,
    },
    
    -- Ban settings
    BanReasons = {
        'Cheating/Hacking',
        'Exploiting',
        'Trolling',
        'Harassment',
        'RDM/VDM',
        'Fail RP',
        'Breaking server rules',
        'Other'
    },
    
    DefaultBanDuration = 7,          -- Days
    MaxBanDuration = 365,            -- Days
    PermanentBan = -1,               -- Value for permanent ban
}

-- ════════════════════════════════════════════════════════════
-- EDITOR MODULE SETTINGS
-- ════════════════════════════════════════════════════════════
Config.Editor = {
    -- Config file paths
    ItemsConfig = 'config/items.json',
    VehiclesConfig = 'config/vehicles.json',
    JobsConfig = 'config/jobs.json',
    GangsConfig = 'config/gangs.json',
    WeaponsConfig = 'config/weapons.json',
    
    -- Editor permissions
    RequirePermission = true,
    Permission = 'admin.editor',
    
    -- Auto-save
    AutoSave = true,
    AutoSaveInterval = 60,           -- Seconds
    
    -- Backup
    CreateBackup = true,
    BackupFolder = 'config/backups/',
}

-- ════════════════════════════════════════════════════════════
-- QBCORE COMPATIBILITY
-- ════════════════════════════════════════════════════════════
Config.QBCoreCompatibility = true   -- Enable QBCore compatibility bridge

-- ════════════════════════════════════════════════════════════
-- LOCALE SETTINGS
-- ════════════════════════════════════════════════════════════
Config.Locale = 'en'                 -- Default language (en, es, fr, de, etc.)

-- ════════════════════════════════════════════════════════════
-- NOTIFICATION SETTINGS
-- ════════════════════════════════════════════════════════════
Config.Notifications = {
    Type = 'native',                 -- native, custom, ox_lib, qb-core
    Position = 'top-right',          -- For custom notifications
    Duration = 5000,                 -- Default duration in milliseconds
}

-- ════════════════════════════════════════════════════════════
-- PERMISSION GROUPS
-- ════════════════════════════════════════════════════════════
Config.Permissions = {
    Groups = {
        ['superadmin'] = {
            label = 'Super Admin',
            permissions = {'*'},     -- All permissions
            inherits = {}
        },
        ['admin'] = {
            label = 'Admin',
            permissions = {
                'admin.*',           -- All admin commands
                'editor.*',          -- Access to editors
            },
            inherits = {'moderator'}
        },
        ['moderator'] = {
            label = 'Moderator',
            permissions = {
                'admin.kick',
                'admin.warn',
                'admin.freeze',
                'admin.spectate',
            },
            inherits = {}
        },
        ['user'] = {
            label = 'User',
            permissions = {},
            inherits = {}
        }
    },
    
    -- Default group for new players
    DefaultGroup = 'user',
}

-- ════════════════════════════════════════════════════════════
-- LOGGING SETTINGS
-- ════════════════════════════════════════════════════════════
Config.Logging = {
    Enabled = true,
    LogToFile = true,
    LogToConsole = true,
    LogToDiscord = false,
    
    -- Discord webhook
    DiscordWebhook = '',
    
    -- Log levels
    Levels = {
        Info = true,
        Success = true,
        Warn = true,
        Error = true,
        Debug = false,               -- Only if DebugMode is true
    },
    
    -- Categories to log
    Categories = {
        Player = true,
        Money = true,
        Job = true,
        Admin = true,
        Database = true,
        Callbacks = true,
        Commands = true,
        Performance = true,
    },
    
    -- File settings
    MaxLogSize = 10485760,           -- 10MB
    RotateOnSize = true,
}

-- ════════════════════════════════════════════════════════════
-- ANTI-CHEAT SETTINGS
-- ════════════════════════════════════════════════════════════
Config.AntiCheat = {
    Enabled = true,
    
    -- Detection modules
    Modules = {
        GodMode = true,
        SpeedHack = true,
        Teleport = true,
        WeaponSpawn = true,
        VehicleSpawn = true,
        Noclip = true,
        Spectate = true,
    },
    
    -- Actions
    LogDetections = true,
    NotifyAdmins = true,
    AutoKick = false,
    AutoBan = false,
    
    -- Thresholds
    MaxWarnings = 3,
    BanDuration = 0,                 -- 0 = permanent
}

-- ════════════════════════════════════════════════════════════
-- SERVER SETTINGS
-- ════════════════════════════════════════════════════════════
Config.Server = {
    -- Server name
    Name = 'My CM-Core Server',
    
    -- Max players
    MaxPlayers = 32,
    
    -- Whitelist
    UseWhitelist = false,
    
    -- Queue system
    UseQueue = false,
    QueuePriority = {
        ['license:xxxxx'] = 100,     -- Higher = more priority
    },
    
    -- Grace period (rejoin after disconnect)
    GracePeriod = 300,               -- Seconds
}

-- ════════════════════════════════════════════════════════════
-- COMMAND SETTINGS
-- ════════════════════════════════════════════════════════════
Config.Commands = {
    -- Command prefix (leave empty for none)
    Prefix = '',
    
    -- Enable/disable default commands
    EnableDefaultCommands = true,
    
    -- Default commands
    Commands = {
        ['admin'] = 'admin.panel',
        ['noclip'] = 'admin.noclip',
        ['godmode'] = 'admin.godmode',
        ['kick'] = 'admin.kick',
        ['ban'] = 'admin.ban',
        ['unban'] = 'admin.unban',
        ['warn'] = 'admin.warn',
        ['tp'] = 'admin.teleport',
        ['tpm'] = 'admin.teleport',
        ['bring'] = 'admin.teleport',
        ['goto'] = 'admin.teleport',
        ['freeze'] = 'admin.freeze',
        ['unfreeze'] = 'admin.freeze',
        ['revive'] = 'admin.revive',
        ['heal'] = 'admin.heal',
        ['armor'] = 'admin.armor',
        ['givemoney'] = 'admin.givemoney',
        ['setjob'] = 'admin.setjob',
        ['giveitem'] = 'admin.giveitem',
        ['car'] = 'admin.vehicle',
        ['dv'] = 'admin.vehicle',
        ['cleararea'] = 'admin.cleararea',
        ['announce'] = 'admin.announce',
        ['saveall'] = 'admin.saveall',
    }
}

-- ════════════════════════════════════════════════════════════
-- CALLBACK SETTINGS
-- ════════════════════════════════════════════════════════════
Config.Callbacks = {
    Timeout = 30000,                 -- Callback timeout in milliseconds
    MaxConcurrent = 100,             -- Max concurrent callbacks per player
}

-- ════════════════════════════════════════════════════════════
-- NUI SETTINGS
-- ════════════════════════════════════════════════════════════
Config.NUI = {
    -- UI Theme
    Theme = 'dark',                  -- dark, light, custom
    
    -- Colors (if custom theme)
    CustomTheme = {
        primary = '#3b82f6',
        secondary = '#8b5cf6',
        success = '#10b981',
        danger = '#ef4444',
        warning = '#f59e0b',
        info = '#06b6d4',
    },
}

-- ════════════════════════════════════════════════════════════
-- ZONES SETTINGS
-- ════════════════════════════════════════════════════════════
Config.Zones = {
    -- Enable zone system
    Enabled = true,
    
    -- Draw zone borders (debug)
    DrawBorders = false,
    
    -- Update interval
    UpdateInterval = 500,            -- Milliseconds
}

-- ════════════════════════════════════════════════════════════
-- VEHICLE SETTINGS
-- ════════════════════════════════════════════════════════════
Config.Vehicles = {
    -- Fuel system (if no external fuel resource)
    FuelSystem = false,
    DefaultFuelLevel = 100,
    
    -- Keys system (if no external keys resource)
    KeysSystem = false,
    
    -- Persistent vehicles
    PersistentVehicles = true,
    
    -- Vehicle damage
    RealisticDamage = true,
}

-- ════════════════════════════════════════════════════════════
-- SHARED DATA
-- ════════════════════════════════════════════════════════════

-- Jobs (basic examples - more can be added via editor)
Config.Jobs = {
    ['unemployed'] = {
        label = 'Civilian',
        defaultDuty = true,
        grades = {
            [0] = { name = 'Freelancer', payment = 10 }
        }
    },
    ['police'] = {
        label = 'Police',
        defaultDuty = false,
        grades = {
            [0] = { name = 'Cadet', payment = 50 },
            [1] = { name = 'Officer', payment = 75 },
            [2] = { name = 'Sergeant', payment = 100 },
            [3] = { name = 'Lieutenant', payment = 125 },
            [4] = { name = 'Chief', payment = 150 }
        }
    },
    ['ambulance'] = {
        label = 'EMS',
        defaultDuty = false,
        grades = {
            [0] = { name = 'Trainee', payment = 50 },
            [1] = { name = 'Paramedic', payment = 75 },
            [2] = { name = 'Doctor', payment = 100 },
            [3] = { name = 'Surgeon', payment = 125 },
            [4] = { name = 'Chief', payment = 150 }
        }
    },
    ['mechanic'] = {
        label = 'Mechanic',
        defaultDuty = false,
        grades = {
            [0] = { name = 'Trainee', payment = 50 },
            [1] = { name = 'Mechanic', payment = 75 },
            [2] = { name = 'Manager', payment = 100 },
            [3] = { name = 'Owner', payment = 125 }
        }
    }
}

-- Gangs (basic examples)
Config.Gangs = {
    ['none'] = {
        label = 'No Gang',
        grades = {
            [0] = { name = 'No Affiliation' }
        }
    },
    ['ballas'] = {
        label = 'Ballas',
        grades = {
            [0] = { name = 'Recruit', payment = 25 },
            [1] = { name = 'Member', payment = 50 },
            [2] = { name = 'Leader', payment = 75 }
        }
    }
}

-- Money types
Config.MoneyTypes = {
    'cash',
    'bank',
    'crypto'
}


--# ════════════════════════════════════════════════════════════
--# CM-CORE CONFIGURATION
--# ════════════════════════════════════════════════════════════

--# Ensure cm-core starts before other resources
--ensure cm-core

--# CM-Core convars
--setr cm_core:debug "false"
--setr cm_core:qb_compat "true"
--setr cm_core:locale "en"
--setr cm_core:max_players "32"

--# Ace Permissions for CM-Core
--# Superadmin
--add_ace group.superadmin "cmcore.superadmin" allow
--add_principal identifier.license:xxxxxxxx group.superadmin

--# Admin
--add_ace group.admin "cmcore.admin" allow
--add_ace group.admin "admin.*" allow
--add_principal identifier.license:yyyyyyyy group.admin

--# Moderator
--add_ace group.moderator "cmcore.moderator" allow
--add_ace group.moderator "mod.*" allow
--add_principal identifier.license:zzzzzzzz group.moderator

--# ════════════════════════════════════════════════════════════
--# MYSQL CONFIGURATION (oxmysql)
--# ════════════════════════════════════════════════════════════
--set mysql_connection_string "mysql://username:password@localhost/database?charset=utf8mb4"
--set mysql_slow_query_warning 100
--set mysql_debug false