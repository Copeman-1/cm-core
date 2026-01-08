-- Export core object
exports('GetCoreObject', function()
    return {
        Functions = {
            -- Notification
            Notify = CMCore.Functions.Notify,
            
            -- Drawing functions
            DrawText3D = CMCore.Functions.DrawText3D,
            ShowHelpNotification = CMCore.Functions.ShowHelpNotification,
            DrawMarker = CMCore.Functions.DrawMarker,
            
            -- Progressbar
            Progressbar = CMCore.Functions.Progressbar,
            
            -- Player functions
            GetClosestPlayer = CMCore.Functions.GetClosestPlayer,
            GetPlayersInArea = CMCore.Functions.GetPlayersInArea,
            
            -- Vehicle functions
            GetClosestVehicle = CMCore.Functions.GetClosestVehicle,
            GetVehiclesInArea = CMCore.Functions.GetVehiclesInArea,
            SpawnVehicle = CMCore.Functions.SpawnVehicle,
            DeleteVehicle = CMCore.Functions.DeleteVehicle,
            
            -- Object functions
            GetClosestObject = CMCore.Functions.GetClosestObject,
            
            -- Model/Animation functions
            LoadModel = CMCore.Functions.LoadModel,
            LoadAnimDict = CMCore.Functions.LoadAnimDict,
            PlayAnim = CMCore.Functions.PlayAnim,
            
            -- Location functions
            GetStreetName = CMCore.Functions.GetStreetName,
            GetZoneName = CMCore.Functions.GetZoneName,
            GetCardinalDirection = CMCore.Functions.GetCardinalDirection,
            
            -- Callback functions
            CreateCallback = CMCore.Callbacks.Register,
            TriggerServerCallback = CMCore.Callbacks.TriggerServer,
            
            -- Login check
            IsLoggedIn = CMCore.Functions.IsLoggedIn,
            GetPlayerData = CMCore.Functions.GetPlayerData,
        },
        
        Player = {
            GetData = CMCore.Player.GetData,
            Get = CMCore.Player.Get,
            GetMoney = CMCore.Player.GetMoney,
            GetJob = CMCore.Player.GetJob,
            GetGang = CMCore.Player.GetGang,
            IsDead = CMCore.Player.IsDead,
            GetCoords = CMCore.Player.GetCoords,
            GetHeading = CMCore.Player.GetHeading,
            IsInVehicle = CMCore.Player.IsInVehicle,
            GetVehicle = CMCore.Player.GetVehicle,
            IsDriver = CMCore.Player.IsDriver,
            Teleport = CMCore.Player.Teleport,
            Freeze = CMCore.Player.Freeze,
            SetInvincible = CMCore.Player.SetInvincible,
            SetHealth = CMCore.Player.SetHealth,
            GetHealth = CMCore.Player.GetHealth,
            SetArmor = CMCore.Player.SetArmor,
            GetArmor = CMCore.Player.GetArmor,
            GiveWeapon = CMCore.Player.GiveWeapon,
            RemoveWeapon = CMCore.Player.RemoveWeapon,
            RemoveAllWeapons = CMCore.Player.RemoveAllWeapons,
            GetCurrentWeapon = CMCore.Player.GetCurrentWeapon,
            SetMetadata = CMCore.Player.SetMetadata,
        },
        
        NUI = {
            Send = CMCore.NUI.Send,
            RegisterCallback = CMCore.NUI.RegisterCallback,
            OpenFrame = CMCore.NUI.OpenFrame,
            CloseFrame = CMCore.NUI.CloseFrame,
            SetFocus = CMCore.NUI.SetFocus,
        },
        
        Config = CMCore.Config,
        PlayerData = CMCore.PlayerData,
    }
end)

-- Individual exports
exports('Notify', function(message, type, duration)
    return CMCore.Functions.Notify(message, type, duration)
end)

exports('GetPlayerData', function()
    return CMCore.PlayerData
end)

exports('IsLoggedIn', function()
    return CMCore.Functions.IsLoggedIn()
end)

exports('TriggerServerCallback', function(name, cb, ...)
    return CMCore.Callbacks.TriggerServer(name, cb, ...)
end)