-- Player connecting
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    local source = source
    deferrals.defer()
    
    Wait(0)
    deferrals.update('Checking license...')
    
    local identifier = GetPlayerIdentifierByType(source, 'license')
    
    if not identifier then
        deferrals.done('Could not retrieve your license. Please restart FiveM.')
        return
    end
    
    Wait(100)
    deferrals.update('Loading player data...')
    
    -- Additional checks here (ban check, whitelist, etc.)
    
    deferrals.done()
end)

-- Player joined
AddEventHandler('playerJoined', function()
    local source = source
    CMCore.Logger.Info('Player', string.format('Player %s joined the server', GetPlayerName(source)))
end)

-- Player loading
RegisterNetEvent('CMCore:Server:OnPlayerLoaded', function()
    local source = source
    local identifier = GetPlayerIdentifierByType(source, 'license')
    
    if not identifier then
        DropPlayer(source, 'Could not retrieve your license')
        return
    end
    
    -- Load player
    local player = CMCore.Player.LoadPlayer(source, identifier)
    
    CMCore.Logger.Info('Player', string.format('%s (%s) loaded successfully', player.PlayerData.name, player.PlayerData.citizenid))
end)

-- Player dropped
AddEventHandler('playerDropped', function(reason)
    local source = source
    local player = CMCore.Player.GetPlayer(source)
    
    if player then
        CMCore.Logger.Info('Player', string.format('%s (%s) disconnected: %s', player.PlayerData.name, player.PlayerData.citizenid, reason))
        CMCore.Player.UnloadPlayer(source)
    end
end)

-- Resource stop - save all players
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        CMCore.Logger.Info('CM-Core', 'Saving all players before shutdown...')
        
        for source, player in pairs(CMCore.Players) do
            player:Save()
        end
        
        CMCore.Logger.Success('CM-Core', 'All players saved!')
    end
end)