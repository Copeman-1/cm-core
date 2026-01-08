-- Export core object
exports('GetCoreObject', function()
    return {
        Functions = {
            -- Player functions
            GetPlayer = CMCore.Player.GetPlayer,
            GetPlayerByCitizenId = CMCore.Player.GetPlayerByCitizenId,
            GetAllPlayers = CMCore.Player.GetAllPlayers,
            CreateCitizenId = CMCore.Player.CreateCitizenId,
            
            -- Callback functions
            CreateCallback = CMCore.Callbacks.Register,
            TriggerClientCallback = CMCore.Callbacks.TriggerClient,
            
            -- Database functions
            ExecuteSql = CMCore.Database.Execute,
            InsertSql = CMCore.Database.Insert,
            UpdateSql = CMCore.Database.Update,
            FetchSingle = CMCore.Database.FetchSingle,
            FetchAll = CMCore.Database.FetchAll,
            
            -- Permission functions
            HasPermission = CMCore.Permissions.HasPermission,
            GetGroup = CMCore.Permissions.GetGroup,
            SetGroup = CMCore.Permissions.SetGroup,
            
            -- Command functions
            RegisterCommand = CMCore.Commands.Register,
            
            -- Cache functions
            CacheSet = CMCore.Cache.Set,
            CacheGet = CMCore.Cache.Get,
            CacheDelete = CMCore.Cache.Delete,
            CacheClear = CMCore.Cache.Clear,
            
            -- Logger functions
            LogInfo = CMCore.Logger.Info,
            LogSuccess = CMCore.Logger.Success,
            LogWarn = CMCore.Logger.Warn,
            LogError = CMCore.Logger.Error,
            LogDebug = CMCore.Logger.Debug,
            LogDiscord = CMCore.Logger.Discord,
        },
        
        Config = CMCore.Config,
        Shared = CMCore.Shared,
    }
end)

-- Individual exports for cleaner access
exports('GetPlayer', function(source)
    return CMCore.Player.GetPlayer(source)
end)

exports('GetPlayerByCitizenId', function(citizenid)
    return CMCore.Player.GetPlayerByCitizenId(citizenid)
end)

exports('CreateCallback', function(name, cb)
    return CMCore.Callbacks.Register(name, cb)
end)

exports('HasPermission', function(source, permission)
    return CMCore.Permissions.HasPermission(source, permission)
end)

exports('ExecuteSql', function(query, parameters, cb)
    return CMCore.Database.Execute(query, parameters, cb)
end)