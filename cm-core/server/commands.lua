CMCore.Commands = {}
CMCore.Commands.List = {}

-- Register a command
function CMCore.Commands.Register(name, permission, callback, options)
    options = options or {}
    
    CMCore.Commands.List[name] = {
        permission = permission,
        callback = callback,
        help = options.help or 'No description',
        params = options.params or {}
    }
    
    RegisterCommand(name, function(source, args, rawCommand)
        -- Permission check
        if permission and not CMCore.Permissions.HasPermission(source, permission) then
            TriggerClientEvent('CMCore:Client:Notify', source, 'You don\'t have permission to use this command', 'error')
            return
        end
        
        -- Rate limit
        if not CMCore.RateLimit.Check(source, 'command:' .. name) then
            TriggerClientEvent('CMCore:Client:Notify', source, 'You\'re using commands too fast', 'error')
            return
        end
        
        callback(source, args, rawCommand)
    end, false)
    
    CMCore.Logger.Debug('Commands', string.format('Registered command: /%s', name))
end

-- Example commands
CMCore.Commands.Register('saveall', 'admin.saveall', function(source, args)
    for id, player in pairs(CMCore.Players) do
        player:Save()
    end
    
    TriggerClientEvent('CMCore:Client:Notify', source, 'All players saved!', 'success')
    CMCore.Logger.Info('Commands', string.format('Player %s saved all players', source))
end, {
    help = 'Save all player data'
})

CMCore.Commands.Register('givemoney', 'admin.givemoney', function(source, args)
    local targetId = tonumber(args[1])
    local moneyType = args[2] or 'cash'
    local amount = tonumber(args[3])
    
    if not targetId or not amount then
        TriggerClientEvent('CMCore:Client:Notify', source, 'Usage: /givemoney [id] [cash/bank] [amount]', 'error')
        return
    end
    
    local targetPlayer = CMCore.Player.GetPlayer(targetId)
    if not targetPlayer then
        TriggerClientEvent('CMCore:Client:Notify', source, 'Player not found', 'error')
        return
    end
    
    targetPlayer:AddMoney(moneyType, amount, 'Admin gave money')
    
    TriggerClientEvent('CMCore:Client:Notify', source, string.format('Gave $%d %s to %s', amount, moneyType, targetPlayer.PlayerData.name), 'success')
    TriggerClientEvent('CMCore:Client:Notify', targetId, string.format('You received $%d %s from admin', amount, moneyType), 'success')
end, {
    help = 'Give money to a player',
    params = {
        {name = 'id', help = 'Player server ID'},
        {name = 'type', help = 'Money type (cash/bank)'},
        {name = 'amount', help = 'Amount to give'}
    }
})

CMCore.Commands.Register('setjob', 'admin.setjob', function(source, args)
    local targetId = tonumber(args[1])
    local jobName = args[2]
    local grade = tonumber(args[3]) or 0
    
    if not targetId or not jobName then
        TriggerClientEvent('CMCore:Client:Notify', source, 'Usage: /setjob [id] [job] [grade]', 'error')
        return
    end
    
    local targetPlayer = CMCore.Player.GetPlayer(targetId)
    if not targetPlayer then
        TriggerClientEvent('CMCore:Client:Notify', source, 'Player not found', 'error')
        return
    end
    
    if targetPlayer:SetJob(jobName, grade) then
        TriggerClientEvent('CMCore:Client:Notify', source, string.format('Set %s\'s job to %s (grade %d)', targetPlayer.PlayerData.name, jobName, grade), 'success')
        TriggerClientEvent('CMCore:Client:Notify', targetId, string.format('Your job was set to %s (grade %d)', jobName, grade), 'success')
    else
        TriggerClientEvent('CMCore:Client:Notify', source, 'Invalid job or grade', 'error')
    end
end, {
    help = 'Set a player\'s job',
    params = {
        {name = 'id', help = 'Player server ID'},
        {name = 'job', help = 'Job name'},
        {name = 'grade', help = 'Job grade (optional)'}
    }
})