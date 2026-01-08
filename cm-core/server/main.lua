CMCore = {}
CMCore.Players = {}
CMCore.PlayersByIdentifier = {}
CMCore.Config = Config
CMCore.Shared = {}

-- Core object that gets exported
local CoreObject = {
    Functions = {},
    Player = {},
    Commands = {},
    UseableItems = {},
}

-- Initialize the framework
CreateThread(function()
    -- Wait for database
    while GetResourceState('oxmysql') ~= 'started' do
        Wait(100)
    end
    
    CMCore.Logger.Info('CM-Core', 'Initializing framework...')
    
    -- Initialize systems
    CMCore.Database.Init()
    CMCore.Cache.Init()
    CMCore.Permissions.Init()
    
    -- Load modules
    if Config.Modules.Admin then
        CMCore.Logger.Info('CM-Core', 'Loading Admin module...')
        -- Load admin module
    end
    
    if Config.Modules.Editor then
        CMCore.Logger.Info('CM-Core', 'Loading Editor module...')
        -- Load editor module
    end
    
    -- Check for updates
    if Config.Core.UpdateCheck then
        -- Version check logic
    end
    
    CMCore.Logger.Success('CM-Core', 'Framework initialized successfully!')
end)

-- Export core object
exports('GetCoreObject', function()
    return CoreObject
end)