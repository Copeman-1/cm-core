-- ════════════════════════════════════════════════════════════
-- CONSTANTS
-- ════════════════════════════════════════════════════════════

CMCore = CMCore or {}
CMCore.Constants = {}

-- Money types
CMCore.Constants.MoneyTypes = {
    CASH = 'cash',
    BANK = 'bank',
    CRYPTO = 'crypto'
}

-- Permission levels
CMCore.Constants.PermissionLevels = {
    USER = 'user',
    MODERATOR = 'moderator',
    ADMIN = 'admin',
    SUPERADMIN = 'superadmin'
}

-- Log types
CMCore.Constants.LogTypes = {
    INFO = 'INFO',
    SUCCESS = 'SUCCESS',
    WARN = 'WARN',
    ERROR = 'ERROR',
    DEBUG = 'DEBUG'
}

-- Notification types
CMCore.Constants.NotificationTypes = {
    SUCCESS = 'success',
    ERROR = 'error',
    INFO = 'info',
    WARNING = 'warning'
}

-- Vehicle classes
CMCore.Constants.VehicleClasses = {
    [0] = 'Compacts',
    [1] = 'Sedans',
    [2] = 'SUVs',
    [3] = 'Coupes',
    [4] = 'Muscle',
    [5] = 'Sports Classics',
    [6] = 'Sports',
    [7] = 'Super',
    [8] = 'Motorcycles',
    [9] = 'Off-road',
    [10] = 'Industrial',
    [11] = 'Utility',
    [12] = 'Vans',
    [13] = 'Cycles',
    [14] = 'Boats',
    [15] = 'Helicopters',
    [16] = 'Planes',
    [17] = 'Service',
    [18] = 'Emergency',
    [19] = 'Military',
    [20] = 'Commercial',
    [21] = 'Trains',
    [22] = 'Open Wheel'
}

-- Weapon types
CMCore.Constants.WeaponTypes = {
    MELEE = 'melee',
    HANDGUN = 'handgun',
    SMG = 'smg',
    SHOTGUN = 'shotgun',
    ASSAULT_RIFLE = 'assault_rifle',
    SNIPER = 'sniper',
    HEAVY = 'heavy',
    THROWABLE = 'throwable'
}

-- Item types
CMCore.Constants.ItemTypes = {
    WEAPON = 'weapon',
    FOOD = 'food',
    DRINK = 'drink',
    TOOL = 'tool',
    MATERIAL = 'material',
    CLOTHING = 'clothing',
    MISC = 'misc'
}

-- Action types
CMCore.Constants.ActionTypes = {
    ADD = 'add',
    REMOVE = 'remove',
    SET = 'set',
    UPDATE = 'update'
}

-- Database table names
CMCore.Constants.Tables = {
    PLAYERS = 'players',
    BANS = 'bans',
    VEHICLES = 'player_vehicles',
    INVENTORY = 'player_inventory',
    PERMISSIONS = 'user_permissions',
    LOGS = 'server_logs'
}

-- Status codes
CMCore.Constants.StatusCodes = {
    SUCCESS = 200,
    CREATED = 201,
    BAD_REQUEST = 400,
    UNAUTHORIZED = 401,
    FORBIDDEN = 403,
    NOT_FOUND = 404,
    INTERNAL_ERROR = 500
}

-- Ban types
CMCore.Constants.BanTypes = {
    TEMPORARY = 0,
    PERMANENT = -1
}

-- Event priorities
CMCore.Constants.EventPriority = {
    LOW = 0,
    NORMAL = 1,
    HIGH = 2,
    CRITICAL = 3
}