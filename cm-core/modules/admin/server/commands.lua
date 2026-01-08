if not Config.Modules.Admin then return end

-- ════════════════════════════════════════════════════════════
-- ADMIN COMMANDS
-- ════════════════════════════════════════════════════════════

-- Admin Panel
CMCore.Commands.Register('admin', 'admin.panel', function(source, args)
    TriggerClientEvent('CMCore:Admin:Client:OpenPanel', source)
end, {
    help = 'Open admin panel'
})

-- Noclip
CMCore.Commands.Register('noclip', 'admin.noclip', function(source, args)
    TriggerClientEvent('CMCore:Admin:Client:ToggleNoclip', source)
end, {
    help = 'Toggle noclip'
})

-- God Mode
CMCore.Commands.Register('godmode', 'admin.godmode', function(source, args)
    TriggerClientEvent('CMCore:Admin:Client:ToggleGodmode', source)
end, {
    help = 'Toggle god mode'
})

-- Kick
CMCore.Commands.Register('kick', 'admin.kick', function(source, args)
    local targetId = tonumber(args[1])
    local reason = table.concat(args, ' ', 2) or 'No reason specified'
    
    if not targetId then
        TriggerClientEvent('CMCore:Client:Notify', source, 'Invalid player ID', 'error')
        return
    end
    
    local Admin = CMCore.Player.GetPlayer(source)
    if not Admin then return end
    
    CMCore.Admin.KickPlayer(targetId, reason, Admin.PlayerData.name, Admin.PlayerData.license)
    TriggerClientEvent('CMCore:Client:Notify', source, 'Player kicked', 'success')
end, {
    help = 'Kick a player',
    params = {
        {name = 'id', help = 'Player ID'},
        {name = 'reason', help = 'Kick reason'}
    }
})

-- Ban
CMCore.Commands.Register('ban', 'admin.ban', function(source, args)
    local targetId = tonumber(args[1])
    local duration = tonumber(args[2]) or 7
    local reason = table.concat(args, ' ', 3) or 'No reason specified'
    
    if not targetId then
        TriggerClientEvent('CMCore:Client:Notify', source, 'Invalid player ID', 'error')
        return
    end
    
    local Admin = CMCore.Player.GetPlayer(source)
    local Target = CMCore.Player.GetPlayer(targetId)
    
    if not Admin or not Target then return end
    
    CMCore.Admin.BanPlayer(
        targetId,
        Target.PlayerData.license,
        Target.PlayerData.name,
        reason,
        Admin.PlayerData.name,
        Admin.PlayerData.license,
        duration
    )
    
    TriggerClientEvent('CMCore:Client:Notify', source, 'Player banned', 'success')
end, {
    help = 'Ban a player',
    params = {
        {name = 'id', help = 'Player ID'},
        {name = 'days', help = 'Duration in days (-1 for permanent)'},
        {name = 'reason', help = 'Ban reason'}
    }
})

-- Unban
CMCore.Commands.Register('unban', 'admin.ban', function(source, args)
    local license = args[1]
    
    if not license then
        TriggerClientEvent('CMCore:Client:Notify', source, 'Usage: /unban [license]', 'error')
        return
    end
    
    local Admin = CMCore.Player.GetPlayer(source)
    if not Admin then return end
    
    local success = CMCore.Admin.UnbanPlayer(license, Admin.PlayerData.name, Admin.PlayerData.license)
    
    if success then
        TriggerClientEvent('CMCore:Client:Notify', source, 'Player unbanned', 'success')
    else
        TriggerClientEvent('CMCore:Client:Notify', source, 'No ban found with that license', 'error')
    end
end, {
    help = 'Unban a player',
    params = {
        {name = 'license', help = 'Player license'}
    }
})

-- Warn
CMCore.Commands.Register('warn', 'admin.warn', function(source, args)
    local targetId = tonumber(args[1])
    local reason = table.concat(args, ' ', 2) or 'No reason specified'
    
    if not targetId then
        TriggerClientEvent('CMCore:Client:Notify', source, 'Invalid player ID', 'error')
        return
    end
    
    local Admin = CMCore.Player.GetPlayer(source)
    local Target = CMCore.Player.GetPlayer(targetId)
    
    if not Admin or not Target then return end
    
    CMCore.Admin.WarnPlayer(
        targetId,
        Target.PlayerData.license,
        Target.PlayerData.name,
        reason,
        Admin.PlayerData.name,
        Admin.PlayerData.license
    )
    
    TriggerClientEvent('CMCore:Client:Notify', source, 'Player warned', 'success')
end, {
    help = 'Warn a player',
    params = {
        {name = 'id', help = 'Player ID'},
        {name = 'reason', help = 'Warning reason'}
    }
})

-- Teleport
CMCore.Commands.Register('tp', 'admin.teleport', function(source, args)
    if #args == 0 then
        -- Teleport to waypoint
        TriggerClientEvent('CMCore:Admin:Client:TeleportToWaypoint', source)
    elseif #args == 1 then
        -- Teleport to player
        local targetId = tonumber(args[1])
        if targetId then
            CMCore.Admin.GotoPlayer(source, targetId)
        end
    elseif #args == 3 then
        -- Teleport to coords
        local x, y, z = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])
        if x and y and z then
            CMCore.Admin.TeleportPlayer(source, vector3(x, y, z))
        end
    end
end, {
    help = 'Teleport (no args = waypoint, 1 arg = player, 3 args = coords)',
    params = {
        {name = 'target/x', help = 'Player ID or X coord'},
        {name = 'y', help = 'Y coord (optional)'},
        {name = 'z', help = 'Z coord (optional)'}
    }
})

-- Teleport to marker
CMCore.Commands.Register('tpm', 'admin.teleport', function(source, args)
    TriggerClientEvent('CMCore:Admin:Client:TeleportToWaypoint', source)
end, {
    help = 'Teleport to waypoint/marker'
})

-- Bring player
CMCore.Commands.Register('bring', 'admin.teleport', function(source, args)
    local targetId = tonumber(args[1])
    
    if not targetId then
        TriggerClientEvent('CMCore:Client:Notify', source, 'Invalid player ID', 'error')
        return
    end
    
    CMCore.Admin.BringPlayer(source, targetId)
    TriggerClientEvent('CMCore:Client:Notify', source, 'Player brought to you', 'success')
end, {
    help = 'Bring a player to you',
    params = {
        {name = 'id', help = 'Player ID'}
    }
})

-- Goto player
CMCore.Commands.Register('goto', 'admin.teleport', function(source, args)
    local targetId = tonumber(args[1])
    
    if not targetId then
        TriggerClientEvent('CMCore:Client:Notify', source, 'Invalid player ID', 'error')
        return
    end
    
    CMCore.Admin.GotoPlayer(source, targetId)
    TriggerClientEvent('CMCore:Client:Notify', source, 'Teleported to player', 'success')
end, {
    help = 'Teleport to a player',
    params = {
        {name = 'id', help = 'Player ID'}
    }
})

-- Freeze
CMCore.Commands.Register('freeze', 'admin.freeze', function(source, args)
    local targetId = tonumber(args[1])
    
    if not targetId then
        TriggerClientEvent('CMCore:Client:Notify', source, 'Invalid player ID', 'error')
        return
    end
    
    CMCore.Admin.FreezePlayer(targetId, true)
    TriggerClientEvent('CMCore:Client:Notify', source, 'Player frozen', 'success')
end, {
    help = 'Freeze a player',
    params = {
        {name = 'id', help = 'Player ID'}
    }
})

-- Unfreeze
CMCore.Commands.Register('unfreeze', 'admin.freeze', function(source, args)
    local targetId = tonumber(args[1])
    
    if not targetId then
        TriggerClientEvent('CMCore:Client:Notify', source, 'Invalid player ID', 'error')
        return
    end
    
    CMCore.Admin.FreezePlayer(targetId, false)
    TriggerClientEvent('CMCore:Client:Notify', source, 'Player unfrozen', 'success')
end, {
    help = 'Unfreeze a player',
    params = {
        {name = 'id', help = 'Player ID'}
    }
})

-- Revive
CMCore.Commands.Register('revive', 'admin.revive', function(source, args)
    local targetId = tonumber(args[1]) or source
    
    CMCore.Admin.RevivePlayer(targetId)
    TriggerClientEvent('CMCore:Client:Notify', source, 'Player revived', 'success')
end, {
    help = 'Revive a player (or yourself)',
    params = {
        {name = 'id', help = 'Player ID (optional)'}
    }
})

-- Heal
CMCore.Commands.Register('heal', 'admin.heal', function(source, args)
    local targetId = tonumber(args[1]) or source
    
    CMCore.Admin.HealPlayer(targetId)
    TriggerClientEvent('CMCore:Client:Notify', source, 'Player healed', 'success')
end, {
    help = 'Heal a player (or yourself)',
    params = {
        {name = 'id', help = 'Player ID (optional)'}
    }
})

-- Armor
CMCore.Commands.Register('armor', 'admin.armor', function(source, args)
    local targetId = tonumber(args[1]) or source
    local amount = tonumber(args[2]) or 100
    
    CMCore.Admin.GiveArmor(targetId, amount)
    TriggerClientEvent('CMCore:Client:Notify', source, 'Armor given', 'success')
end, {
    help = 'Give armor to a player',
    params = {
        {name = 'id', help = 'Player ID (optional)'},
        {name = 'amount', help = 'Armor amount (default 100)'}
    }
})

-- Spectate
CMCore.Commands.Register('spectate', 'admin.spectate', function(source, args)
    local targetId = tonumber(args[1])
    
    if not targetId then
        TriggerClientEvent('CMCore:Client:Notify', source, 'Invalid player ID', 'error')
        return
    end
    
    CMCore.Admin.SpectatePlayer(source, targetId)
end, {
    help = 'Spectate a player',
    params = {
        {name = 'id', help = 'Player ID'}
    }
})

-- Spawn vehicle
CMCore.Commands.Register('car', 'admin.vehicle', function(source, args)
    local model = args[1]
    
    if not model then
        TriggerClientEvent('CMCore:Client:Notify', source, 'Usage: /car [model]', 'error')
        return
    end
    
    TriggerClientEvent('CMCore:Admin:Client:SpawnVehicle', source, model)
end, {
    help = 'Spawn a vehicle',
    params = {
        {name = 'model', help = 'Vehicle model name'}
    }
})

-- Delete vehicle
CMCore.Commands.Register('dv', 'admin.vehicle', function(source, args)
    TriggerClientEvent('CMCore:Admin:Client:DeleteVehicle', source)
end, {
    help = 'Delete nearby vehicle'
})

-- Clear area
CMCore.Commands.Register('cleararea', 'admin.cleararea', function(source, args)
    local radius = tonumber(args[1]) or 100
    
    TriggerClientEvent('CMCore:Admin:Client:ClearArea', -1, source, radius)
    TriggerClientEvent('CMCore:Client:Notify', source, string.format('Area cleared (radius: %dm)', radius), 'success')
end, {
    help = 'Clear vehicles and peds in area',
    params = {
        {name = 'radius', help = 'Radius in meters (default 100)'}
    }
})

-- Announce
CMCore.Commands.Register('announce', 'admin.announce', function(source, args)
    local message = table.concat(args, ' ')
    
    if not message or message == '' then
        TriggerClientEvent('CMCore:Client:Notify', source, 'Usage: /announce [message]', 'error')
        return
    end
    
    TriggerClientEvent('CMCore:Client:Notify', -1, message, 'info', 10000)
    
    local Admin = CMCore.Player.GetPlayer(source)
    if Admin then
        CMCore.Admin.LogAction(Admin.PlayerData.license, Admin.PlayerData.name, 'announce', nil, nil, {message = message})
    end
end, {
    help = 'Send server-wide announcement',
    params = {
        {name = 'message', help = 'Announcement message'}
    }
})

print('^2[CM-Core Admin]^7 Commands loaded')