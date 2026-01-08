-- Resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        -- Request player data from server
        TriggerServerEvent('CMCore:Server:OnPlayerLoaded')
    end
end)

-- Resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        -- Cleanup
        CMCore.PlayerData = {}
    end
end)

-- Player death
AddEventHandler('gameEventTriggered', function(name, args)
    if name == 'CEventNetworkEntityDamage' then
        local victim = args[1]
        local attacker = args[2]
        local fatal = args[4]
        
        if victim == PlayerPedId() and fatal then
            TriggerEvent('CMCore:Client:OnPlayerDeath')
            TriggerServerEvent('CMCore:Server:OnPlayerDeath')
        end
    end
end)

-- Notification event
RegisterNetEvent('CMCore:Client:Notify', function(message, type, duration)
    CMCore.Functions.Notify(message, type, duration)
end)