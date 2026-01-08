CMCore.Permissions = {}

local permissions = {}
local groups = {}

function CMCore.Permissions.Init()
    CMCore.Logger.Info('Permissions', 'Loading permissions...')
    
    -- Load groups from database or config
    groups = {
        ['superadmin'] = {
            label = 'Super Admin',
            permissions = {'*'}, -- All permissions
            inherits = {}
        },
        ['admin'] = {
            label = 'Admin',
            permissions = {
                'admin.kick',
                'admin.ban',
                'admin.teleport',
                'admin.noclip',
                'admin.revive',
                'admin.giveitem',
            },
            inherits = {'moderator'}
        },
        ['moderator'] = {
            label = 'Moderator',
            permissions = {
                'mod.kick',
                'mod.warn',
                'mod.freeze',
            },
            inherits = {}
        },
        ['user'] = {
            label = 'User',
            permissions = {},
            inherits = {}
        }
    }
    
    CMCore.Logger.Success('Permissions', 'Permissions loaded')
end

-- Check if player has permission
function CMCore.Permissions.HasPermission(source, permission)
    local identifier = GetPlayerIdentifierByType(source, 'license')
    if not identifier then return false end
    
    -- Check cache first
    local cacheKey = string.format('permission:%s:%s', identifier, permission)
    local cached = CMCore.Cache.Get(cacheKey)
    if cached ~= nil then return cached end
    
    local playerGroup = CMCore.Permissions.GetGroup(source)
    if not playerGroup then
        CMCore.Cache.Set(cacheKey, false, 300)
        return false
    end
    
    -- Superadmin check
    if playerGroup == 'superadmin' then
        CMCore.Cache.Set(cacheKey, true, 300)
        return true
    end
    
    -- Check group permissions
    local hasPermission = CMCore.Permissions.GroupHasPermission(playerGroup, permission)
    
    CMCore.Cache.Set(cacheKey, hasPermission, 300)
    return hasPermission
end

-- Check if group has permission (with inheritance)
function CMCore.Permissions.GroupHasPermission(groupName, permission)
    local group = groups[groupName]
    if not group then return false end
    
    -- Check for wildcard
    for _, perm in ipairs(group.permissions) do
        if perm == '*' then return true end
        if perm == permission then return true end
        
        -- Check wildcard patterns
        if string.match(permission, '^' .. perm:gsub('%*', '.*') .. '$') then
            return true
        end
    end
    
    -- Check inherited groups
    for _, inheritedGroup in ipairs(group.inherits) do
        if CMCore.Permissions.GroupHasPermission(inheritedGroup, permission) then
            return true
        end
    end
    
    return false
end

-- Get player's group
function CMCore.Permissions.GetGroup(source)
    local identifier = GetPlayerIdentifierByType(source, 'license')
    if not identifier then return 'user' end
    
    -- Check ace permissions first
    if IsPlayerAceAllowed(source, 'cmcore.superadmin') then
        return 'superadmin'
    elseif IsPlayerAceAllowed(source, 'cmcore.admin') then
        return 'admin'
    elseif IsPlayerAceAllowed(source, 'cmcore.moderator') then
        return 'moderator'
    end
    
    -- Check database
    local result = MySQL.single.await('SELECT `group` FROM user_permissions WHERE license = ?', {identifier})
    
    if result then
        return result.group
    end
    
    return 'user'
end

-- Set player's group
function CMCore.Permissions.SetGroup(source, groupName)
    if not groups[groupName] then return false end
    
    local identifier = GetPlayerIdentifierByType(source, 'license')
    if not identifier then return false end
    
    MySQL.insert('INSERT INTO user_permissions (license, `group`) VALUES (?, ?) ON DUPLICATE KEY UPDATE `group` = ?', {
        identifier,
        groupName,
        groupName
    })
    
    -- Clear permission cache for this player
    CMCore.Cache.Delete('permission:' .. identifier)
    
    CMCore.Logger.Info('Permissions', string.format('Set player %s to group %s', source, groupName))
    return true
end

-- Add permission to group
function CMCore.Permissions.AddPermissionToGroup(groupName, permission)
    if not groups[groupName] then return false end
    
    table.insert(groups[groupName].permissions, permission)
    
    -- Clear all permission caches
    CMCore.Cache.Clear()
    
    return true
end