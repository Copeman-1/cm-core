if not Config.Modules.Editor then return end

local currentEditor = nil

-- ════════════════════════════════════════════════════════════
-- OPEN EDITOR PANEL
-- ════════════════════════════════════════════════════════════

RegisterNetEvent('CMCore:Editor:Client:OpenPanel', function(editorType)
    editorType = editorType or 'items'
    currentEditor = editorType
    
    CMCore.NUI.Send('openEditor', {
        type = editorType
    })
    SetNuiFocus(true, true)
end)

-- ════════════════════════════════════════════════════════════
-- QUICK ADD ITEM
-- ════════════════════════════════════════════════════════════

RegisterNetEvent('CMCore:Editor:Client:QuickAddItem', function(itemName, itemLabel)
    CMCore.NUI.Send('openQuickAdd', {
        type = 'item',
        name = itemName,
        label = itemLabel
    })
    SetNuiFocus(true, true)
end)

-- ════════════════════════════════════════════════════════════
-- QUICK ADD VEHICLE
-- ════════════════════════════════════════════════════════════

RegisterNetEvent('CMCore:Editor:Client:QuickAddVehicle', function(vehicleModel, vehicleName)
    -- Check if player is in vehicle
    local ped = PlayerPedId()
    local inVehicle = IsPedInAnyVehicle(ped, false)
    local vehicleData = {
        model = vehicleModel,
        name = vehicleName
    }
    
    if inVehicle then
        local vehicle = GetVehiclePedIsIn(ped, false)
        local model = GetEntityModel(vehicle)
        local displayName = GetDisplayNameFromVehicleModel(model)
        local makeName = GetMakeNameFromVehicleModel(model)
        
        vehicleData.model = vehicleModel or string.lower(displayName)
        vehicleData.name = vehicleName or displayName
        vehicleData.brand = makeName
        vehicleData.category = CMCore.Constants.VehicleClasses[GetVehicleClass(vehicle)] or 'sedans'
    end
    
    CMCore.NUI.Send('openQuickAdd', {
        type = 'vehicle',
        data = vehicleData
    })
    SetNuiFocus(true, true)
end)

-- ════════════════════════════════════════════════════════════
-- NUI CALLBACKS
-- ════════════════════════════════════════════════════════════

-- Close editor
RegisterNUICallback('closeEditor', function(data, cb)
    SetNuiFocus(false, false)
    currentEditor = nil
    cb('ok')
end)

-- Get items
RegisterNUICallback('getItems', function(data, cb)
    CMCore.Callbacks.TriggerServer('CMCore:Editor:GetItems', function(items)
        cb(items)
    end)
end)

-- Add item
RegisterNUICallback('addItem', function(data, cb)
    CMCore.Callbacks.TriggerServer('CMCore:Editor:AddItem', function(result)
        if result.success then
            CMCore.Functions.Notify(result.message, 'success')
        else
            CMCore.Functions.Notify(result.message, 'error')
        end
        cb(result)
    end, data)
end)

-- Update item
RegisterNUICallback('updateItem', function(data, cb)
    CMCore.Callbacks.TriggerServer('CMCore:Editor:UpdateItem', function(result)
        if result.success then
            CMCore.Functions.Notify(result.message, 'success')
        else
            CMCore.Functions.Notify(result.message, 'error')
        end
        cb(result)
    end, data.name, data.item)
end)

-- Delete item
RegisterNUICallback('deleteItem', function(data, cb)
    CMCore.Callbacks.TriggerServer('CMCore:Editor:DeleteItem', function(result)
        if result.success then
            CMCore.Functions.Notify(result.message, 'success')
        else
            CMCore.Functions.Notify(result.message, 'error')
        end
        cb(result)
    end, data.name)
end)

-- Get vehicles
RegisterNUICallback('getVehicles', function(data, cb)
    CMCore.Callbacks.TriggerServer('CMCore:Editor:GetVehicles', function(vehicles)
        cb(vehicles)
    end)
end)

-- Add vehicle
RegisterNUICallback('addVehicle', function(data, cb)
    CMCore.Callbacks.TriggerServer('CMCore:Editor:AddVehicle', function(result)
        if result.success then
            CMCore.Functions.Notify(result.message, 'success')
        else
            CMCore.Functions.Notify(result.message, 'error')
        end
        cb(result)
    end, data)
end)

-- Update vehicle
RegisterNUICallback('updateVehicle', function(data, cb)
    CMCore.Callbacks.TriggerServer('CMCore:Editor:UpdateVehicle', function(result)
        if result.success then
            CMCore.Functions.Notify(result.message, 'success')
        else
            CMCore.Functions.Notify(result.message, 'error')
        end
        cb(result)
    end, data.model, data.vehicle)
end)

-- Delete vehicle
RegisterNUICallback('deleteVehicle', function(data, cb)
    CMCore.Callbacks.TriggerServer('CMCore:Editor:DeleteVehicle', function(result)
        if result.success then
            CMCore.Functions.Notify(result.message, 'success')
        else
            CMCore.Functions.Notify(result.message, 'error')
        end
        cb(result)
    end, data.model)
end)

-- Get jobs
RegisterNUICallback('getJobs', function(data, cb)
    CMCore.Callbacks.TriggerServer('CMCore:Editor:GetJobs', function(jobs)
        cb(jobs)
    end)
end)

-- Add job
RegisterNUICallback('addJob', function(data, cb)
    CMCore.Callbacks.TriggerServer('CMCore:Editor:AddJob', function(result)
        if result.success then
            CMCore.Functions.Notify(result.message, 'success')
        else
            CMCore.Functions.Notify(result.message, 'error')
        end
        cb(result)
    end, data)
end)

-- Update job
RegisterNUICallback('updateJob', function(data, cb)
    CMCore.Callbacks.TriggerServer('CMCore:Editor:UpdateJob', function(result)
        if result.success then
            CMCore.Functions.Notify(result.message, 'success')
        else
            CMCore.Functions.Notify(result.message, 'error')
        end
        cb(result)
    end, data.name, data.job)
end)

-- Delete job
RegisterNUICallback('deleteJob', function(data, cb)
    CMCore.Callbacks.TriggerServer('CMCore:Editor:DeleteJob', function(result)
        if result.success then
            CMCore.Functions.Notify(result.message, 'success')
        else
            CMCore.Functions.Notify(result.message, 'error')
        end
        cb(result)
    end, data.name)
end)

-- Get gangs
RegisterNUICallback('getGangs', function(data, cb)
    CMCore.Callbacks.TriggerServer('CMCore:Editor:GetGangs', function(gangs)
        cb(gangs)
    end)
end)

-- Add gang
RegisterNUICallback('addGang', function(data, cb)
    CMCore.Callbacks.TriggerServer('CMCore:Editor:AddGang', function(result)
        if result.success then
            CMCore.Functions.Notify(result.message, 'success')
        else
            CMCore.Functions.Notify(result.message, 'error')
        end
        cb(result)
    end, data)
end)

-- Update gang
RegisterNUICallback('updateGang', function(data, cb)
    CMCore.Callbacks.TriggerServer('CMCore:Editor:UpdateGang', function(result)
        if result.success then
            CMCore.Functions.Notify(result.message, 'success')
        else
            CMCore.Functions.Notify(result.message, 'error')
        end
        cb(result)
    end, data.name, data.gang)
end)

-- Delete gang
RegisterNUICallback('deleteGang', function(data, cb)
    CMCore.Callbacks.TriggerServer('CMCore:Editor:DeleteGang', function(result)
        if result.success then
            CMCore.Functions.Notify(result.message, 'success')
        else
            CMCore.Functions.Notify(result.message, 'error')
        end
        cb(result)
    end, data.name)
end)

-- Preview vehicle
RegisterNUICallback('previewVehicle', function(data, cb)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    
    CMCore.Functions.SpawnVehicle(data.model, coords + vector3(5.0, 0.0, 0.0), heading, function(vehicle)
        SetVehicleEngineOn(vehicle, true, true, false)
        cb({success = true, message = 'Vehicle spawned for preview'})
    end)
end)

-- Test item (if player has inventory)
RegisterNUICallback('testItem', function(data, cb)
    -- This would integrate with your inventory system
    cb({success = true, message = 'Item test functionality depends on inventory resource'})
end)

-- Import from QBCore
RegisterNUICallback('importFromQBCore', function(data, cb)
    CMCore.Callbacks.TriggerServer('CMCore:Editor:ImportFromQBCore', function(result)
        if result.success then
            CMCore.Functions.Notify(string.format('Imported %d items successfully', result.count), 'success')
        else
            CMCore.Functions.Notify(result.message, 'error')
        end
        cb(result)
    end, data.type, data.data)
end)

-- Export config
RegisterNUICallback('exportConfig', function(data, cb)
    -- Copy to clipboard functionality
    cb({success = true, data = data.config})
end)

print('^2[CM-Core Editor]^7 Client loaded')