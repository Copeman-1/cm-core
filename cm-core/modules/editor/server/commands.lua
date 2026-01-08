if not Config.Modules.Editor then return end

-- ════════════════════════════════════════════════════════════
-- EDITOR COMMANDS
-- ════════════════════════════════════════════════════════════

-- Open editor panel
CMCore.Commands.Register('editor', 'admin.editor', function(source, args)
    TriggerClientEvent('CMCore:Editor:Client:OpenPanel', source)
end, {
    help = 'Open configuration editor panel'
})

-- Quick add item command
CMCore.Commands.Register('additem', 'admin.editor', function(source, args)
    local itemName = args[1]
    local itemLabel = table.concat(args, ' ', 2)
    
    if not itemName or not itemLabel then
        TriggerClientEvent('CMCore:Client:Notify', source, 'Usage: /additem [name] [label]', 'error')
        return
    end
    
    TriggerClientEvent('CMCore:Editor:Client:QuickAddItem', source, itemName, itemLabel)
end, {
    help = 'Quick add item to config',
    params = {
        {name = 'name', help = 'Item spawn name'},
        {name = 'label', help = 'Item display name'}
    }
})

-- Quick add vehicle command
CMCore.Commands.Register('addvehicle', 'admin.editor', function(source, args)
    local vehicleModel = args[1]
    local vehicleName = table.concat(args, ' ', 2)
    
    if not vehicleModel or not vehicleName then
        TriggerClientEvent('CMCore:Client:Notify', source, 'Usage: /addvehicle [model] [name]', 'error')
        return
    end
    
    TriggerClientEvent('CMCore:Editor:Client:QuickAddVehicle', source, vehicleModel, vehicleName)
end, {
    help = 'Quick add vehicle to config',
    params = {
        {name = 'model', help = 'Vehicle spawn name'},
        {name = 'name', help = 'Vehicle display name'}
    }
})

-- Reload configs
CMCore.Commands.Register('reloadconfigs', 'admin.editor', function(source, args)
    -- Reload items
    local itemsFile = LoadResourceFile(GetCurrentResourceName(), Config.Editor.ItemsConfig)
    if itemsFile then
        CMCore.Shared.Items = json.decode(itemsFile)
    end
    
    -- Reload vehicles
    local vehiclesFile = LoadResourceFile(GetCurrentResourceName(), Config.Editor.VehiclesConfig)
    if vehiclesFile then
        CMCore.Shared.Vehicles = json.decode(vehiclesFile)
    end
    
    -- Reload jobs
    local jobsFile = LoadResourceFile(GetCurrentResourceName(), Config.Editor.JobsConfig)
    if jobsFile then
        CMCore.Shared.Jobs = json.decode(jobsFile)
    end
    
    -- Reload gangs
    local gangsFile = LoadResourceFile(GetCurrentResourceName(), Config.Editor.GangsConfig)
    if gangsFile then
        CMCore.Shared.Gangs = json.decode(gangsFile)
    end
    
    -- Notify all clients
    TriggerClientEvent('CMCore:Client:Notify', -1, 'Configurations reloaded', 'success')
    
    local Player = CMCore.Player.GetPlayer(source)
    if Player then
        CMCore.Logger.Info('Editor', string.format('%s reloaded all configurations', Player.PlayerData.name))
    end
end, {
    help = 'Reload all configuration files'
})

print('^2[CM-Core Editor]^7 Commands loaded')