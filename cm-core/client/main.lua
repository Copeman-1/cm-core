CMCore = {}
CMCore.PlayerData = {}
CMCore.Config = Config
CMCore.Shared = {}

local isLoggedIn = false

-- Core object that gets exported
local CoreObject = {
    Functions = {},
    Player = {},
}

-- Initialize client
CreateThread(function()
    while true do
        Wait(0)
        if NetworkIsPlayerActive(PlayerId()) then
            TriggerServerEvent('CMCore:Server:OnPlayerLoaded')
            break
        end
    end
end)

-- Player loaded event
RegisterNetEvent('CMCore:Client:PlayerLoaded', function(playerData)
    CMCore.PlayerData = playerData
    isLoggedIn = true
    
    print('^2[CM-Core]^7 Player loaded successfully!')
    
    -- Trigger local event for other resources
    TriggerEvent('CMCore:Client:OnPlayerLoaded')
end)

-- Player unloaded
RegisterNetEvent('CMCore:Client:PlayerUnloaded', function()
    CMCore.PlayerData = {}
    isLoggedIn = false
end)

-- Money change event
RegisterNetEvent('CMCore:Client:OnMoneyChange', function(moneyType, amount, changeType)
    if changeType == 'add' then
        CMCore.Functions.Notify(string.format('Received $%d %s', amount, moneyType), 'success')
    elseif changeType == 'remove' then
        CMCore.Functions.Notify(string.format('Paid $%d %s', amount, moneyType), 'error')
    end
    
    -- Update local player data
    Wait(100)
    CMCore.Callbacks.TriggerServer('CMCore:Server:GetPlayerData', function(playerData)
        CMCore.PlayerData = playerData
    end)
end)

-- Job update event
RegisterNetEvent('CMCore:Client:OnJobUpdate', function(job)
    CMCore.PlayerData.job = job
    CMCore.Functions.Notify(string.format('Job updated: %s - %s', job.label, job.gradeLabel), 'info')
    TriggerEvent('CMCore:Client:OnJobUpdate', job)
end)

-- Check if player is logged in
function CMCore.Functions.IsLoggedIn()
    return isLoggedIn
end

-- Get player data
function CMCore.Functions.GetPlayerData()
    return CMCore.PlayerData
end

-- Export core object
exports('GetCoreObject', function()
    return CoreObject
end)

-- Also set as global for easy access
_G.CMCore = CMCore