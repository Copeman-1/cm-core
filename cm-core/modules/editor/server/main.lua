if not Config.Modules.Editor then return end

CMCore.Editor = {}

print('^3[CM-Core]^7 Loading Editor module...')

-- ════════════════════════════════════════════════════════════
-- FILE UTILITIES
-- ════════════════════════════════════════════════════════════

-- Read config file
function CMCore.Editor.ReadConfig(configType)
    local configPath = Config.Editor[configType .. 'Config']
    if not configPath then
        CMCore.Logger.Error('Editor', 'Invalid config type: ' .. configType)
        return nil
    end
    
    local fileContent = LoadResourceFile(GetCurrentResourceName(), configPath)
    if not fileContent then
        CMCore.Logger.Error('Editor', 'Failed to read config: ' .. configPath)
        return nil
    end
    
    local success, data = pcall(json.decode, fileContent)
    if not success then
        CMCore.Logger.Error('Editor', 'Failed to parse JSON: ' .. configPath)
        return nil
    end
    
    return data
end

-- Write config file
function CMCore.Editor.WriteConfig(configType, data)
    local configPath = Config.Editor[configType .. 'Config']
    if not configPath then
        CMCore.Logger.Error('Editor', 'Invalid config type: ' .. configType)
        return false
    end
    
    -- Create backup if enabled
    if Config.Editor.CreateBackup then
        CMCore.Editor.CreateBackup(configType)
    end
    
    local success, jsonData = pcall(json.encode, data, {indent = true})
    if not success then
        CMCore.Logger.Error('Editor', 'Failed to encode JSON: ' .. configPath)
        return false
    end
    
    local saved = SaveResourceFile(GetCurrentResourceName(), configPath, jsonData, -1)
    if not saved then
        CMCore.Logger.Error('Editor', 'Failed to write config: ' .. configPath)
        return false
    end
    
    CMCore.Logger.Success('Editor', 'Config saved: ' .. configPath)
    return true
end

-- Create backup
function CMCore.Editor.CreateBackup(configType)
    local configPath = Config.Editor[configType .. 'Config']
    if not configPath then return false end
    
    local fileContent = LoadResourceFile(GetCurrentResourceName(), configPath)
    if not fileContent then return false end
    
    local timestamp = os.date('%Y%m%d_%H%M%S')
    local backupPath = Config.Editor.BackupFolder .. configType .. '_' .. timestamp .. '.json'
    
    local saved = SaveResourceFile(GetCurrentResourceName(), backupPath, fileContent, -1)
    if saved then
        CMCore.Logger.Info('Editor', 'Backup created: ' .. backupPath)
    end
    
    return saved
end

-- ════════════════════════════════════════════════════════════
-- ITEMS EDITOR
-- ════════════════════════════════════════════════════════════

-- Get all items
CMCore.Callbacks.Register('CMCore:Editor:GetItems', function(source, cb)
    if Config.Editor.RequirePermission and not CMCore.Permissions.HasPermission(source, Config.Editor.Permission) then
        cb(nil)
        return
    end
    
    local items = CMCore.Editor.ReadConfig('Items')
    cb(items)
end)

-- Add item
CMCore.Callbacks.Register('CMCore:Editor:AddItem', function(source, cb, itemData)
    if Config.Editor.RequirePermission and not CMCore.Permissions.HasPermission(source, Config.Editor.Permission) then
        cb({success = false, message = 'No permission'})
        return
    end
    
    local items = CMCore.Editor.ReadConfig('Items')
    if not items then
        cb({success = false, message = 'Failed to read items config'})
        return
    end
    
    -- Check if item already exists
    if items[itemData.name] then
        cb({success = false, message = 'Item already exists'})
        return
    end
    
    -- Add item
    items[itemData.name] = {
        name = itemData.name,
        label = itemData.label,
        weight = itemData.weight or 0,
        type = itemData.type or 'item',
        image = itemData.image or (itemData.name .. '.png'),
        unique = itemData.unique or false,
        useable = itemData.useable or false,
        shouldClose = itemData.shouldClose or true,
        combinable = itemData.combinable or nil,
        description = itemData.description or ''
    }
    
    -- Save config
    if CMCore.Editor.WriteConfig('Items', items) then
        -- Update shared data
        CMCore.Shared.Items = items
        
        -- Log action
        local Player = CMCore.Player.GetPlayer(source)
        if Player then
            CMCore.Logger.Info('Editor', string.format('%s added item: %s', Player.PlayerData.name, itemData.name))
        end
        
        cb({success = true, message = 'Item added successfully'})
    else
        cb({success = false, message = 'Failed to save config'})
    end
end)

-- Update item
CMCore.Callbacks.Register('CMCore:Editor:UpdateItem', function(source, cb, itemName, itemData)
    if Config.Editor.RequirePermission and not CMCore.Permissions.HasPermission(source, Config.Editor.Permission) then
        cb({success = false, message = 'No permission'})
        return
    end
    
    local items = CMCore.Editor.ReadConfig('Items')
    if not items then
        cb({success = false, message = 'Failed to read items config'})
        return
    end
    
    -- Check if item exists
    if not items[itemName] then
        cb({success = false, message = 'Item does not exist'})
        return
    end
    
    -- Update item
    items[itemName] = {
        name = itemData.name,
        label = itemData.label,
        weight = itemData.weight or 0,
        type = itemData.type or 'item',
        image = itemData.image or (itemData.name .. '.png'),
        unique = itemData.unique or false,
        useable = itemData.useable or false,
        shouldClose = itemData.shouldClose or true,
        combinable = itemData.combinable or nil,
        description = itemData.description or ''
    }
    
    -- Save config
    if CMCore.Editor.WriteConfig('Items', items) then
        -- Update shared data
        CMCore.Shared.Items = items
        
        -- Log action
        local Player = CMCore.Player.GetPlayer(source)
        if Player then
            CMCore.Logger.Info('Editor', string.format('%s updated item: %s', Player.PlayerData.name, itemName))
        end
        
        cb({success = true, message = 'Item updated successfully'})
    else
        cb({success = false, message = 'Failed to save config'})
    end
end)

-- Delete item
CMCore.Callbacks.Register('CMCore:Editor:DeleteItem', function(source, cb, itemName)
    if Config.Editor.RequirePermission and not CMCore.Permissions.HasPermission(source, Config.Editor.Permission) then
        cb({success = false, message = 'No permission'})
        return
    end
    
    local items = CMCore.Editor.ReadConfig('Items')
    if not items then
        cb({success = false, message = 'Failed to read items config'})
        return
    end
    
    -- Check if item exists
    if not items[itemName] then
        cb({success = false, message = 'Item does not exist'})
        return
    end
    
    -- Delete item
    items[itemName] = nil
    
    -- Save config
    if CMCore.Editor.WriteConfig('Items', items) then
        -- Update shared data
        CMCore.Shared.Items = items
        
        -- Log action
        local Player = CMCore.Player.GetPlayer(source)
        if Player then
            CMCore.Logger.Info('Editor', string.format('%s deleted item: %s', Player.PlayerData.name, itemName))
        end
        
        cb({success = true, message = 'Item deleted successfully'})
    else
        cb({success = false, message = 'Failed to save config'})
    end
end)

-- ════════════════════════════════════════════════════════════
-- VEHICLES EDITOR
-- ════════════════════════════════════════════════════════════

-- Get all vehicles
CMCore.Callbacks.Register('CMCore:Editor:GetVehicles', function(source, cb)
    if Config.Editor.RequirePermission and not CMCore.Permissions.HasPermission(source, Config.Editor.Permission) then
        cb(nil)
        return
    end
    
    local vehicles = CMCore.Editor.ReadConfig('Vehicles')
    cb(vehicles)
end)

-- Add vehicle
CMCore.Callbacks.Register('CMCore:Editor:AddVehicle', function(source, cb, vehicleData)
    if Config.Editor.RequirePermission and not CMCore.Permissions.HasPermission(source, Config.Editor.Permission) then
        cb({success = false, message = 'No permission'})
        return
    end
    
    local vehicles = CMCore.Editor.ReadConfig('Vehicles')
    if not vehicles then
        cb({success = false, message = 'Failed to read vehicles config'})
        return
    end
    
    -- Check if vehicle already exists
    if vehicles[vehicleData.model] then
        cb({success = false, message = 'Vehicle already exists'})
        return
    end
    
    -- Add vehicle
    vehicles[vehicleData.model] = {
        model = vehicleData.model,
        name = vehicleData.name,
        brand = vehicleData.brand,
        price = vehicleData.price or 0,
        category = vehicleData.category or 'sedans',
        shop = vehicleData.shop or 'pdm',
        stock = vehicleData.stock or -1,
        image = vehicleData.image or (vehicleData.model .. '.png')
    }
    
    -- Save config
    if CMCore.Editor.WriteConfig('Vehicles', vehicles) then
        -- Update shared data
        CMCore.Shared.Vehicles = vehicles
        
        -- Log action
        local Player = CMCore.Player.GetPlayer(source)
        if Player then
            CMCore.Logger.Info('Editor', string.format('%s added vehicle: %s', Player.PlayerData.name, vehicleData.model))
        end
        
        cb({success = true, message = 'Vehicle added successfully'})
    else
        cb({success = false, message = 'Failed to save config'})
    end
end)

-- Update vehicle
CMCore.Callbacks.Register('CMCore:Editor:UpdateVehicle', function(source, cb, vehicleModel, vehicleData)
    if Config.Editor.RequirePermission and not CMCore.Permissions.HasPermission(source, Config.Editor.Permission) then
        cb({success = false, message = 'No permission'})
        return
    end
    
    local vehicles = CMCore.Editor.ReadConfig('Vehicles')
    if not vehicles then
        cb({success = false, message = 'Failed to read vehicles config'})
        return
    end
    
    -- Check if vehicle exists
    if not vehicles[vehicleModel] then
        cb({success = false, message = 'Vehicle does not exist'})
        return
    end
    
    -- Update vehicle
    vehicles[vehicleModel] = {
        model = vehicleData.model,
        name = vehicleData.name,
        brand = vehicleData.brand,
        price = vehicleData.price or 0,
        category = vehicleData.category or 'sedans',
        shop = vehicleData.shop or 'pdm',
        stock = vehicleData.stock or -1,
        image = vehicleData.image or (vehicleData.model .. '.png')
    }
    
    -- Save config
    if CMCore.Editor.WriteConfig('Vehicles', vehicles) then
        -- Update shared data
        CMCore.Shared.Vehicles = vehicles
        
        -- Log action
        local Player = CMCore.Player.GetPlayer(source)
        if Player then
            CMCore.Logger.Info('Editor', string.format('%s updated vehicle: %s', Player.PlayerData.name, vehicleModel))
        end
        
        cb({success = true, message = 'Vehicle updated successfully'})
    else
        cb({success = false, message = 'Failed to save config'})
    end
end)

-- Delete vehicle
CMCore.Callbacks.Register('CMCore:Editor:DeleteVehicle', function(source, cb, vehicleModel)
    if Config.Editor.RequirePermission and not CMCore.Permissions.HasPermission(source, Config.Editor.Permission) then
        cb({success = false, message = 'No permission'})
        return
    end
    
    local vehicles = CMCore.Editor.ReadConfig('Vehicles')
    if not vehicles then
        cb({success = false, message = 'Failed to read vehicles config'})
        return
    end
    
    -- Check if vehicle exists
    if not vehicles[vehicleModel] then
        cb({success = false, message = 'Vehicle does not exist'})
        return
    end
    
    -- Delete vehicle
    vehicles[vehicleModel] = nil
    
    -- Save config
    if CMCore.Editor.WriteConfig('Vehicles', vehicles) then
        -- Update shared data
        CMCore.Shared.Vehicles = vehicles
        
        -- Log action
        local Player = CMCore.Player.GetPlayer(source)
        if Player then
            CMCore.Logger.Info('Editor', string.format('%s deleted vehicle: %s', Player.PlayerData.name, vehicleModel))
        end
        
        cb({success = true, message = 'Vehicle deleted successfully'})
    else
        cb({success = false, message = 'Failed to save config'})
    end
end)

-- ════════════════════════════════════════════════════════════
-- JOBS EDITOR
-- ════════════════════════════════════════════════════════════

-- Get all jobs
CMCore.Callbacks.Register('CMCore:Editor:GetJobs', function(source, cb)
    if Config.Editor.RequirePermission and not CMCore.Permissions.HasPermission(source, Config.Editor.Permission) then
        cb(nil)
        return
    end
    
    local jobs = CMCore.Editor.ReadConfig('Jobs')
    cb(jobs)
end)

-- Add job
CMCore.Callbacks.Register('CMCore:Editor:AddJob', function(source, cb, jobData)
    if Config.Editor.RequirePermission and not CMCore.Permissions.HasPermission(source, Config.Editor.Permission) then
        cb({success = false, message = 'No permission'})
        return
    end
    
    local jobs = CMCore.Editor.ReadConfig('Jobs')
    if not jobs then
        cb({success = false, message = 'Failed to read jobs config'})
        return
    end
    
    -- Check if job already exists
    if jobs[jobData.name] then
        cb({success = false, message = 'Job already exists'})
        return
    end
    
    -- Add job
    jobs[jobData.name] = {
        label = jobData.label,
        defaultDuty = jobData.defaultDuty or false,
        grades = jobData.grades or {
            [0] = { name = 'Employee', payment = 50 }
        }
    }
    
    -- Save config
    if CMCore.Editor.WriteConfig('Jobs', jobs) then
        -- Update shared data
        CMCore.Shared.Jobs = jobs
        
        -- Log action
        local Player = CMCore.Player.GetPlayer(source)
        if Player then
            CMCore.Logger.Info('Editor', string.format('%s added job: %s', Player.PlayerData.name, jobData.name))
        end
        
        cb({success = true, message = 'Job added successfully'})
    else
        cb({success = false, message = 'Failed to save config'})
    end
end)

-- Update job
CMCore.Callbacks.Register('CMCore:Editor:UpdateJob', function(source, cb, jobName, jobData)
    if Config.Editor.RequirePermission and not CMCore.Permissions.HasPermission(source, Config.Editor.Permission) then
        cb({success = false, message = 'No permission'})
        return
    end
    
    local jobs = CMCore.Editor.ReadConfig('Jobs')
    if not jobs then
        cb({success = false, message = 'Failed to read jobs config'})
        return
    end
    
    -- Check if job exists
    if not jobs[jobName] then
        cb({success = false, message = 'Job does not exist'})
        return
    end
    
    -- Update job
    jobs[jobName] = {
        label = jobData.label,
        defaultDuty = jobData.defaultDuty or false,
        grades = jobData.grades or jobs[jobName].grades
    }
    
    -- Save config
    if CMCore.Editor.WriteConfig('Jobs', jobs) then
        -- Update shared data
        CMCore.Shared.Jobs = jobs
        
        -- Log action
        local Player = CMCore.Player.GetPlayer(source)
        if Player then
            CMCore.Logger.Info('Editor', string.format('%s updated job: %s', Player.PlayerData.name, jobName))
        end
        
        cb({success = true, message = 'Job updated successfully'})
    else
        cb({success = false, message = 'Failed to save config'})
    end
end)

-- Delete job
CMCore.Callbacks.Register('CMCore:Editor:DeleteJob', function(source, cb, jobName)
    if Config.Editor.RequirePermission and not CMCore.Permissions.HasPermission(source, Config.Editor.Permission) then
        cb({success = false, message = 'No permission'})
        return
    end
    
    local jobs = CMCore.Editor.ReadConfig('Jobs')
    if not jobs then
        cb({success = false, message = 'Failed to read jobs config'})
        return
    end
    
    -- Prevent deleting unemployed
    if jobName == 'unemployed' then
        cb({success = false, message = 'Cannot delete unemployed job'})
        return
    end
    
    -- Check if job exists
    if not jobs[jobName] then
        cb({success = false, message = 'Job does not exist'})
        return
    end
    
    -- Delete job
    jobs[jobName] = nil
    
    -- Save config
    if CMCore.Editor.WriteConfig('Jobs', jobs) then
        -- Update shared data
        CMCore.Shared.Jobs = jobs
        
        -- Log action
        local Player = CMCore.Player.GetPlayer(source)
        if Player then
            CMCore.Logger.Info('Editor', string.format('%s deleted job: %s', Player.PlayerData.name, jobName))
        end
        
        cb({success = true, message = 'Job deleted successfully'})
    else
        cb({success = false, message = 'Failed to save config'})
    end
end)

-- ════════════════════════════════════════════════════════════
-- GANGS EDITOR
-- ════════════════════════════════════════════════════════════

-- Get all gangs
CMCore.Callbacks.Register('CMCore:Editor:GetGangs', function(source, cb)
    if Config.Editor.RequirePermission and not CMCore.Permissions.HasPermission(source, Config.Editor.Permission) then
        cb(nil)
        return
    end
    
    local gangs = CMCore.Editor.ReadConfig('Gangs')
    cb(gangs)
end)

-- Add gang
CMCore.Callbacks.Register('CMCore:Editor:AddGang', function(source, cb, gangData)
    if Config.Editor.RequirePermission and not CMCore.Permissions.HasPermission(source, Config.Editor.Permission) then
        cb({success = false, message = 'No permission'})
        return
    end
    
    local gangs = CMCore.Editor.ReadConfig('Gangs')
    if not gangs then
        cb({success = false, message = 'Failed to read gangs config'})
        return
    end
    
    -- Check if gang already exists
    if gangs[gangData.name] then
        cb({success = false, message = 'Gang already exists'})
        return
    end
    
    -- Add gang
    gangs[gangData.name] = {
        label = gangData.label,
        grades = gangData.grades or {
            [0] = { name = 'Member', payment = 25 }
        }
    }
    
    -- Save config
    if CMCore.Editor.WriteConfig('Gangs', gangs) then
        -- Update shared data
        CMCore.Shared.Gangs = gangs
        
        -- Log action
        local Player = CMCore.Player.GetPlayer(source)
        if Player then
            CMCore.Logger.Info('Editor', string.format('%s added gang: %s', Player.PlayerData.name, gangData.name))
        end
        
        cb({success = true, message = 'Gang added successfully'})
    else
        cb({success = false, message = 'Failed to save config'})
    end
end)

-- Update gang
CMCore.Callbacks.Register('CMCore:Editor:UpdateGang', function(source, cb, gangName, gangData)
    if Config.Editor.RequirePermission and not CMCore.Permissions.HasPermission(source, Config.Editor.Permission) then
        cb({success = false, message = 'No permission'})
        return
    end
    
    local gangs = CMCore.Editor.ReadConfig('Gangs')
    if not gangs then
        cb({success = false, message = 'Failed to read gangs config'})
        return
    end
    
    -- Check if gang exists
    if not gangs[gangName] then
        cb({success = false, message = 'Gang does not exist'})
        return
    end
    
    -- Update gang
    gangs[gangName] = {
        label = gangData.label,
        grades = gangData.grades or gangs[gangName].grades
    }
    
    -- Save config
    if CMCore.Editor.WriteConfig('Gangs', gangs) then
        -- Update shared data
        CMCore.Shared.Gangs = gangs
        
        -- Log action
        local Player = CMCore.Player.GetPlayer(source)
        if Player then
            CMCore.Logger.Info('Editor', string.format('%s updated gang: %s', Player.PlayerData.name, gangName))
        end
        
        cb({success = true, message = 'Gang updated successfully'})
    else
        cb({success = false, message = 'Failed to save config'})
    end
end)

-- Delete gang
CMCore.Callbacks.Register('CMCore:Editor:DeleteGang', function(source, cb, gangName)
    if Config.Editor.RequirePermission and not CMCore.Permissions.HasPermission(source, Config.Editor.Permission) then
        cb({success = false, message = 'No permission'})
        return
    end
    
    local gangs = CMCore.Editor.ReadConfig('Gangs')
    if not gangs then
        cb({success = false, message = 'Failed to read gangs config'})
        return
    end
    
    -- Prevent deleting none
    if gangName == 'none' then
        cb({success = false, message = 'Cannot delete none gang'})
        return
    end
    
    -- Check if gang exists
    if not gangs[gangName] then
        cb({success = false, message = 'Gang does not exist'})
        return
    end
    
    -- Delete gang
    gangs[gangName] = nil
    
    -- Save config
    if CMCore.Editor.WriteConfig('Gangs', gangs) then
        -- Update shared data
        CMCore.Shared.Gangs = gangs
        
        -- Log action
        local Player = CMCore.Player.GetPlayer(source)
        if Player then
            CMCore.Logger.Info('Editor', string.format('%s deleted gang: %s', Player.PlayerData.name, gangName))
        end
        
        cb({success = true, message = 'Gang deleted successfully'})
    else
        cb({success = false, message = 'Failed to save config'})
    end
end)

-- ════════════════════════════════════════════════════════════
-- BULK IMPORT
-- ════════════════════════════════════════════════════════════

-- Import from QBCore
CMCore.Callbacks.Register('CMCore:Editor:ImportFromQBCore', function(source, cb, configType, qbData)
    if Config.Editor.RequirePermission and not CMCore.Permissions.HasPermission(source, Config.Editor.Permission) then
        cb({success = false, message = 'No permission'})
        return
    end
    
    -- Convert QBCore data to CM-Core format
    local converted = {}
    
    if configType == 'Items' then
        for k, v in pairs(qbData) do
            converted[k] = {
                name = v.name,
                label = v.label,
                weight = v.weight or 0,
                type = v.type or 'item',
                image = v.image or (v.name .. '.png'),
                unique = v.unique or false,
                useable = v.useable or false,
                shouldClose = v.shouldClose or true,
                combinable = v.combinable or nil,
                description = v.description or ''
            }
        end
    elseif configType == 'Vehicles' then
        for k, v in pairs(qbData) do
            converted[k] = {
                model = v.model or k,
                name = v.name,
                brand = v.brand,
                price = v.price or 0,
                category = v.category or 'sedans',
                shop = v.shop or 'pdm',
                stock = v.stock or -1,
                image = v.image or (k .. '.png')
            }
        end
    end
    
    -- Save config
    if CMCore.Editor.WriteConfig(configType, converted) then
        cb({success = true, message = 'Imported successfully', count = CMCore.Shared.TableSize(converted)})
    else
        cb({success = false, message = 'Failed to save config'})
    end
end)

CMCore.Logger.Success('Editor', 'Editor module loaded successfully')