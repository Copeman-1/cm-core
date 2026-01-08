if not Config.Modules.Admin then return end

CMCore.Admin = {}
CMCore.Admin.BanCache = {}

print('^3[CM-Core]^7 Loading Admin module...')

-- ════════════════════════════════════════════════════════════
-- DATABASE TABLES
-- ════════════════════════════════════════════════════════════

CreateThread(function()
    -- Bans table
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS bans (
            id INT AUTO_INCREMENT PRIMARY KEY,
            license VARCHAR(50) NOT NULL,
            name VARCHAR(255) NOT NULL,
            reason TEXT NOT NULL,
            bannedby VARCHAR(255) NOT NULL,
            bannedby_license VARCHAR(50),
            expire BIGINT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_license (license),
            INDEX idx_expire (expire)
        )
    ]])
    
    -- Warnings table
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS warnings (
            id INT AUTO_INCREMENT PRIMARY KEY,
            license VARCHAR(50) NOT NULL,
            name VARCHAR(255) NOT NULL,
            reason TEXT NOT NULL,
            warnedby VARCHAR(255) NOT NULL,
            warnedby_license VARCHAR(50),
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_license (license)
        )
    ]])
    
    -- Admin logs table
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS admin_logs (
            id INT AUTO_INCREMENT PRIMARY KEY,
            admin_license VARCHAR(50) NOT NULL,
            admin_name VARCHAR(255) NOT NULL,
            action VARCHAR(50) NOT NULL,
            target_license VARCHAR(50),
            target_name VARCHAR(255),
            details TEXT,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
            INDEX idx_admin (admin_license),
            INDEX idx_action (action),
            INDEX idx_created (created_at)
        )
    ]])
    
    CMCore.Logger.Success('Admin', 'Admin module tables created/verified')
end)

-- ════════════════════════════════════════════════════════════
-- BAN FUNCTIONS
-- ════════════════════════════════════════════════════════════

-- Check if player is banned
function CMCore.Admin.IsPlayerBanned(license)
    -- Check cache first
    if CMCore.Admin.BanCache[license] then
        local ban = CMCore.Admin.BanCache[license]
        local timeLeft = os.difftime(ban.expire, os.time())
        
        if timeLeft > 0 or ban.expire == -1 then
            return true, ban.reason, timeLeft
        else
            -- Ban expired, remove from cache and database
            CMCore.Admin.BanCache[license] = nil
            MySQL.query('DELETE FROM bans WHERE license = ?', {license})
            return false
        end
    end
    
    -- Check database
    local result = MySQL.single.await('SELECT * FROM bans WHERE license = ?', {license})
    
    if result then
        local timeLeft = os.difftime(result.expire, os.time())
        
        if timeLeft > 0 or result.expire == -1 then
            -- Cache the ban
            CMCore.Admin.BanCache[license] = result
            return true, result.reason, timeLeft
        else
            -- Ban expired
            MySQL.query('DELETE FROM bans WHERE license = ?', {license})
            return false
        end
    end
    
    return false
end

-- Ban player
function CMCore.Admin.BanPlayer(source, license, name, reason, bannedBy, bannedByLicense, duration)
    local expire = duration == -1 and -1 or (os.time() + (duration * 86400))
    
    MySQL.insert('INSERT INTO bans (license, name, reason, bannedby, bannedby_license, expire) VALUES (?, ?, ?, ?, ?, ?)', {
        license,
        name,
        reason,
        bannedBy,
        bannedByLicense,
        expire
    })
    
    -- Cache the ban
    CMCore.Admin.BanCache[license] = {
        license = license,
        name = name,
        reason = reason,
        bannedby = bannedBy,
        expire = expire
    }
    
    -- Log action
    CMCore.Admin.LogAction(bannedByLicense, bannedBy, 'ban', license, name, {
        reason = reason,
        duration = duration == -1 and 'permanent' or duration .. ' days'
    })
    
    -- Kick if online
    if source then
        local banMessage = duration == -1 
            and string.format('You have been permanently banned.\nReason: %s\nBanned by: %s', reason, bannedBy)
            or string.format('You have been banned for %d days.\nReason: %s\nBanned by: %s', duration, reason, bannedBy)
        
        DropPlayer(source, banMessage)
    end
    
    CMCore.Logger.Info('Admin', string.format('%s banned %s (%s) for %s. Reason: %s', 
        bannedBy, name, license, duration == -1 and 'permanent' or duration .. ' days', reason))
end

-- Unban player
function CMCore.Admin.UnbanPlayer(license, unbannedBy, unbannedByLicense)
    local result = MySQL.query.await('DELETE FROM bans WHERE license = ?', {license})
    
    if result.affectedRows > 0 then
        -- Remove from cache
        CMCore.Admin.BanCache[license] = nil
        
        -- Log action
        CMCore.Admin.LogAction(unbannedByLicense, unbannedBy, 'unban', license, nil, {})
        
        CMCore.Logger.Info('Admin', string.format('%s unbanned player with license: %s', unbannedBy, license))
        return true
    end
    
    return false
end

-- Get all bans
function CMCore.Admin.GetAllBans()
    return MySQL.query.await('SELECT * FROM bans ORDER BY created_at DESC')
end

-- ════════════════════════════════════════════════════════════
-- WARNING FUNCTIONS
-- ════════════════════════════════════════════════════════════

-- Warn player
function CMCore.Admin.WarnPlayer(source, license, name, reason, warnedBy, warnedByLicense)
    MySQL.insert('INSERT INTO warnings (license, name, reason, warnedby, warnedby_license) VALUES (?, ?, ?, ?, ?)', {
        license,
        name,
        reason,
        warnedBy,
        warnedByLicense
    })
    
    -- Log action
    CMCore.Admin.LogAction(warnedByLicense, warnedBy, 'warn', license, name, {reason = reason})
    
    -- Notify player
    TriggerClientEvent('CMCore:Client:Notify', source, 
        string.format('You have been warned by %s.\nReason: %s', warnedBy, reason), 'error', 10000)
    
    CMCore.Logger.Info('Admin', string.format('%s warned %s (%s). Reason: %s', warnedBy, name, license, reason))
end

-- Get player warnings
function CMCore.Admin.GetPlayerWarnings(license)
    return MySQL.query.await('SELECT * FROM warnings WHERE license = ? ORDER BY created_at DESC', {license})
end

-- Get all warnings
function CMCore.Admin.GetAllWarnings()
    return MySQL.query.await('SELECT * FROM warnings ORDER BY created_at DESC LIMIT 100')
end

-- ════════════════════════════════════════════════════════════
-- LOGGING FUNCTIONS
-- ════════════════════════════════════════════════════════════

-- Log admin action
function CMCore.Admin.LogAction(adminLicense, adminName, action, targetLicense, targetName, details)
    if not Config.Admin.LogActions[action] then return end
    
    MySQL.insert('INSERT INTO admin_logs (admin_license, admin_name, action, target_license, target_name, details) VALUES (?, ?, ?, ?, ?, ?)', {
        adminLicense,
        adminName,
        action,
        targetLicense,
        targetName,
        json.encode(details)
    })
    
    -- Discord webhook
    if Config.Admin.DiscordWebhook ~= '' then
        local color = 3447003 -- Blue
        
        if action == 'ban' then color = 15158332 -- Red
        elseif action == 'kick' then color = 15105570 -- Orange
        elseif action == 'warn' then color = 16776960 -- Yellow
        elseif action == 'unban' then color = 3066993 -- Green
        end
        
        local description = string.format('**Admin:** %s (%s)\n**Action:** %s', 
            adminName, adminLicense, action:upper())
        
        if targetName then
            description = description .. string.format('\n**Target:** %s (%s)', targetName, targetLicense)
        end
        
        if details.reason then
            description = description .. string.format('\n**Reason:** %s', details.reason)
        end
        
        if details.duration then
            description = description .. string.format('\n**Duration:** %s', details.duration)
        end
        
        CMCore.Logger.Discord(Config.Admin.DiscordWebhook, 'Admin Action', description, color)
    end
end

-- Get admin logs
function CMCore.Admin.GetAdminLogs(limit)
    limit = limit or 50
    return MySQL.query.await('SELECT * FROM admin_logs ORDER BY created_at DESC LIMIT ?', {limit})
end

-- ════════════════════════════════════════════════════════════
-- PLAYER MANAGEMENT FUNCTIONS
-- ════════════════════════════════════════════════════════════

-- Kick player
function CMCore.Admin.KickPlayer(source, reason, kickedBy, kickedByLicense)
    local Player = CMCore.Player.GetPlayer(source)
    
    if not Player then return false end
    
    -- Log action
    CMCore.Admin.LogAction(kickedByLicense, kickedBy, 'kick', Player.PlayerData.license, Player.PlayerData.name, {reason = reason})
    
    -- Kick
    DropPlayer(source, string.format('You have been kicked.\nReason: %s\nKicked by: %s', reason, kickedBy))
    
    CMCore.Logger.Info('Admin', string.format('%s kicked %s (%s). Reason: %s', 
        kickedBy, Player.PlayerData.name, source, reason))
    
    return true
end

-- Freeze player
function CMCore.Admin.FreezePlayer(source, toggle)
    TriggerClientEvent('CMCore:Admin:Client:Freeze', source, toggle)
end

-- Spectate player
function CMCore.Admin.SpectatePlayer(adminSource, targetSource)
    TriggerClientEvent('CMCore:Admin:Client:Spectate', adminSource, targetSource)
end

-- Teleport player
function CMCore.Admin.TeleportPlayer(source, coords)
    TriggerClientEvent('CMCore:Admin:Client:Teleport', source, coords)
end

-- Bring player
function CMCore.Admin.BringPlayer(adminSource, targetSource)
    local adminPlayer = CMCore.Player.GetPlayer(adminSource)
    if not adminPlayer then return end
    
    TriggerClientEvent('CMCore:Admin:Client:GetCoords', adminSource, function(coords)
        CMCore.Admin.TeleportPlayer(targetSource, coords)
    end)
end

-- Goto player
function CMCore.Admin.GotoPlayer(adminSource, targetSource)
    TriggerClientEvent('CMCore:Admin:Client:GetCoords', targetSource, function(coords)
        CMCore.Admin.TeleportPlayer(adminSource, coords)
    end)
end

-- Revive player
function CMCore.Admin.RevivePlayer(source)
    TriggerClientEvent('CMCore:Admin:Client:Revive', source)
end

-- Heal player
function CMCore.Admin.HealPlayer(source)
    TriggerClientEvent('CMCore:Admin:Client:Heal', source)
end

-- Give armor
function CMCore.Admin.GiveArmor(source, amount)
    TriggerClientEvent('CMCore:Admin:Client:GiveArmor', source, amount or 100)
end

-- ════════════════════════════════════════════════════════════
-- CALLBACKS
-- ════════════════════════════════════════════════════════════

-- Get all online players
CMCore.Callbacks.Register('CMCore:Admin:GetOnlinePlayers', function(source, cb)
    local players = {}
    
    for id, player in pairs(CMCore.Player.GetAllPlayers()) do
        table.insert(players, {
            source = id,
            name = player.PlayerData.name,
            citizenid = player.PlayerData.citizenid,
            job = player.PlayerData.job,
            gang = player.PlayerData.gang,
            money = player.PlayerData.money,
        })
    end
    
    cb(players)
end)

-- Get player details
CMCore.Callbacks.Register('CMCore:Admin:GetPlayerDetails', function(source, cb, targetSource)
    local Player = CMCore.Player.GetPlayer(targetSource)
    
    if not Player then
        cb(nil)
        return
    end
    
    local warnings = CMCore.Admin.GetPlayerWarnings(Player.PlayerData.license)
    
    cb({
        playerData = Player.PlayerData,
        warnings = warnings,
        ping = GetPlayerPing(targetSource),
    })
end)

-- Ban player
CMCore.Callbacks.Register('CMCore:Admin:BanPlayer', function(source, cb, data)
    local Admin = CMCore.Player.GetPlayer(source)
    if not Admin then cb(false) return end
    
    if not CMCore.Permissions.HasPermission(source, 'admin.ban') then
        cb(false)
        return
    end
    
    local targetLicense = data.license or GetPlayerIdentifierByType(data.source, 'license')
    local targetName = data.name
    
    if data.source then
        local Target = CMCore.Player.GetPlayer(data.source)
        if Target then
            targetName = Target.PlayerData.name
        end
    end
    
    CMCore.Admin.BanPlayer(
        data.source,
        targetLicense,
        targetName,
        data.reason,
        Admin.PlayerData.name,
        Admin.PlayerData.license,
        data.duration
    )
    
    cb(true)
end)

-- Unban player
CMCore.Callbacks.Register('CMCore:Admin:UnbanPlayer', function(source, cb, license)
    local Admin = CMCore.Player.GetPlayer(source)
    if not Admin then cb(false) return end
    
    if not CMCore.Permissions.HasPermission(source, 'admin.ban') then
        cb(false)
        return
    end
    
    local success = CMCore.Admin.UnbanPlayer(license, Admin.PlayerData.name, Admin.PlayerData.license)
    cb(success)
end)

-- Kick player
CMCore.Callbacks.Register('CMCore:Admin:KickPlayer', function(source, cb, targetSource, reason)
    local Admin = CMCore.Player.GetPlayer(source)
    if not Admin then cb(false) return end
    
    if not CMCore.Permissions.HasPermission(source, 'admin.kick') then
        cb(false)
        return
    end
    
    local success = CMCore.Admin.KickPlayer(targetSource, reason, Admin.PlayerData.name, Admin.PlayerData.license)
    cb(success)
end)

-- Warn player
CMCore.Callbacks.Register('CMCore:Admin:WarnPlayer', function(source, cb, targetSource, reason)
    local Admin = CMCore.Player.GetPlayer(source)
    local Target = CMCore.Player.GetPlayer(targetSource)
    
    if not Admin or not Target then cb(false) return end
    
    if not CMCore.Permissions.HasPermission(source, 'admin.warn') then
        cb(false)
        return
    end
    
    CMCore.Admin.WarnPlayer(
        targetSource,
        Target.PlayerData.license,
        Target.PlayerData.name,
        reason,
        Admin.PlayerData.name,
        Admin.PlayerData.license
    )
    
    cb(true)
end)

-- Get all bans
CMCore.Callbacks.Register('CMCore:Admin:GetBans', function(source, cb)
    if not CMCore.Permissions.HasPermission(source, 'admin.ban') then
        cb({})
        return
    end
    
    local bans = CMCore.Admin.GetAllBans()
    cb(bans)
end)

-- Get admin logs
CMCore.Callbacks.Register('CMCore:Admin:GetLogs', function(source, cb, limit)
    if not CMCore.Permissions.HasPermission(source, 'admin.logs') then
        cb({})
        return
    end
    
    local logs = CMCore.Admin.GetAdminLogs(limit)
    cb(logs)
end)

-- Get server stats
CMCore.Callbacks.Register('CMCore:Admin:GetServerStats', function(source, cb)
    if not CMCore.Permissions.HasPermission(source, 'admin.panel') then
        cb(nil)
        return
    end
    
    local playerCount = 0
    for _ in pairs(CMCore.Player.GetAllPlayers()) do
        playerCount = playerCount + 1
    end
    
    local cacheStats = CMCore.Cache.GetStats()
    
    cb({
        players = playerCount,
        maxPlayers = Config.Server.MaxPlayers,
        uptime = os.time() - GetGameTimer() / 1000,
        cache = cacheStats,
        version = Config.Core.Version,
    })
end)

-- ════════════════════════════════════════════════════════════
-- EVENTS
-- ════════════════════════════════════════════════════════════

-- Check ban on connection
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local source = source
    deferrals.defer()
    
    Wait(0)
    deferrals.update('Checking ban status...')
    
    local license = GetPlayerIdentifierByType(source, 'license')
    
    if not license then
        deferrals.done('Could not retrieve your license.')
        return
    end
    
    local isBanned, reason, timeLeft = CMCore.Admin.IsPlayerBanned(license)
    
    if isBanned then
        local banMessage
        
        if timeLeft == -1 then
            banMessage = string.format('You are permanently banned from this server.\n\nReason: %s', reason)
        else
            local days = math.floor(timeLeft / 86400)
            local hours = math.floor((timeLeft % 86400) / 3600)
            local minutes = math.floor((timeLeft % 3600) / 60)
            
            banMessage = string.format('You are banned from this server.\n\nReason: %s\nTime remaining: %d days, %d hours, %d minutes', 
                reason, days, hours, minutes)
        end
        
        deferrals.done(banMessage)
        return
    end
    
    deferrals.done()
end)

CMCore.Logger.Success('Admin', 'Admin module loaded successfully')