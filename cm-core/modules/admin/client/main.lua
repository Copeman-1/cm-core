if not Config.Modules.Admin then return end

local noclip = false
local godmode = false
local spectating = false
local spectateTarget = nil

-- ════════════════════════════════════════════════════════════
-- NOCLIP
-- ════════════════════════════════════════════════════════════

RegisterNetEvent('CMCore:Admin:Client:ToggleNoclip', function()
    noclip = not noclip
    local ped = PlayerPedId()
    
    if noclip then
        CMCore.Functions.Notify('Noclip enabled', 'success')
        
        CreateThread(function()
            while noclip do
                Wait(0)
                
                local ped = PlayerPedId()
                local coords = GetEntityCoords(ped)
                local heading = GetEntityHeading(ped)
                
                SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false)
                SetEntityRotation(ped, 0.0, 0.0, heading, 2, true)
                SetEntityVelocity(ped, 0.0, 0.0, 0.0)
                SetEntityAlpha(ped, 51, false)
                SetEntityCollision(ped, false, false)
                FreezeEntityPosition(ped, true)
                SetPlayerInvincible(PlayerId(), true)
                
                -- Movement
                local speed = 1.0
                
                if IsControlPressed(0, 21) then -- Shift
                    speed = 5.0
                end
                
                if IsControlPressed(0, 19) then -- Alt
                    speed = 0.1
                end
                
                -- Forward
                if IsControlPressed(0, 32) then -- W
                    local newCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, speed, 0.0)
                    SetEntityCoordsNoOffset(ped, newCoords.x, newCoords.y, newCoords.z, false, false, false)
                end
                
                -- Backward
                if IsControlPressed(0, 33) then -- S
                    local newCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, -speed, 0.0)
                    SetEntityCoordsNoOffset(ped, newCoords.x, newCoords.y, newCoords.z, false, false, false)
                end
                
                -- Left
                if IsControlPressed(0, 34) then -- A
                    local newCoords = GetOffsetFromEntityInWorldCoords(ped, -speed, 0.0, 0.0)
                    SetEntityCoordsNoOffset(ped, newCoords.x, newCoords.y, newCoords.z, false, false, false)
                end
                
                -- Right
                if IsControlPressed(0, 35) then -- D
                    local newCoords = GetOffsetFromEntityInWorldCoords(ped, speed, 0.0, 0.0)
                    SetEntityCoordsNoOffset(ped, newCoords.x, newCoords.y, newCoords.z, false, false, false)
                end
                
                -- Up
                if IsControlPressed(0, 22) then -- Space
                    local newCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.0, speed)
                    SetEntityCoordsNoOffset(ped, newCoords.x, newCoords.y, newCoords.z, false, false, false)
                end
                
                -- Down
                if IsControlPressed(0, 36) then -- Ctrl
                    local newCoords = GetOffsetFromEntityInWorldCoords(ped, 0.0, 0.0, -speed)
                    SetEntityCoordsNoOffset(ped, newCoords.x, newCoords.y, newCoords.z, false, false, false)
                end
            end
            
            -- Disable noclip
            local ped = PlayerPedId()
            FreezeEntityPosition(ped, false)
            SetEntityCollision(ped, true, true)
            SetEntityAlpha(ped, 255, false)
            SetPlayerInvincible(PlayerId(), false)
        end)
    else
        CMCore.Functions.Notify('Noclip disabled', 'error')
        
        local ped = PlayerPedId()
        FreezeEntityPosition(ped, false)
        SetEntityCollision(ped, true, true)
        SetEntityAlpha(ped, 255, false)
        SetPlayerInvincible(PlayerId(), false)
    end
end)

-- ════════════════════════════════════════════════════════════
-- GOD MODE
-- ════════════════════════════════════════════════════════════

RegisterNetEvent('CMCore:Admin:Client:ToggleGodmode', function()
    godmode = not godmode
    
    if godmode then
        CMCore.Functions.Notify('God mode enabled', 'success')
        
        CreateThread(function()
            while godmode do
                Wait(0)
                SetPlayerInvincible(PlayerId(), true)
            end
            SetPlayerInvincible(PlayerId(), false)
        end)
    else
        CMCore.Functions.Notify('God mode disabled', 'error')
        SetPlayerInvincible(PlayerId(), false)
    end
end)

-- ════════════════════════════════════════════════════════════
-- FREEZE
-- ════════════════════════════════════════════════════════════

RegisterNetEvent('CMCore:Admin:Client:Freeze', function(toggle)
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, toggle)
    
    if toggle then
        CMCore.Functions.Notify('You have been frozen by an admin', 'error', 5000)
    else
        CMCore.Functions.Notify('You have been unfrozen', 'success', 5000)
    end
end)

-- ════════════════════════════════════════════════════════════
-- TELEPORT
-- ════════════════════════════════════════════════════════════

RegisterNetEvent('CMCore:Admin:Client:Teleport', function(coords)
    local ped = PlayerPedId()
    
    if IsPedInAnyVehicle(ped, false) then
        local vehicle = GetVehiclePedIsIn(ped, false)
        SetEntityCoords(vehicle, coords.x, coords.y, coords.z, false, false, false, false)
    else
        SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    end
end)

RegisterNetEvent('CMCore:Admin:Client:TeleportToWaypoint', function()
    local waypoint = GetFirstBlipInfoId(8)
    
    if not DoesBlipExist(waypoint) then
        CMCore.Functions.Notify('No waypoint set', 'error')
        return
    end
    
    local waypointCoords = GetBlipInfoIdCoord(waypoint)
    local ped = PlayerPedId()
    
    -- Find ground Z
    local _, groundZ = GetGroundZFor_3dCoord(waypointCoords.x, waypointCoords.y, 1000.0, false)
    
    if IsPedInAnyVehicle(ped, false) then
        local vehicle = GetVehiclePedIsIn(ped, false)
        SetEntityCoords(vehicle, waypointCoords.x, waypointCoords.y, groundZ, false, false, false, false)
    else
        SetEntityCoords(ped, waypointCoords.x, waypointCoords.y, groundZ, false, false, false, false)
    end
    
    CMCore.Functions.Notify('Teleported to waypoint', 'success')
end)

RegisterNetEvent('CMCore:Admin:Client:GetCoords', function(cb)
    local coords = GetEntityCoords(PlayerPedId())
    cb(coords)
end)

-- ════════════════════════════════════════════════════════════
-- SPECTATE
-- ════════════════════════════════════════════════════════════

RegisterNetEvent('CMCore:Admin:Client:Spectate', function(targetSource)
    if spectating then
        -- Stop spectating
        spectating = false
        local playerPed = PlayerPedId()
        
        SetEntityVisible(playerPed, true, false)
        SetEntityCollision(playerPed, true, true)
        FreezeEntityPosition(playerPed, false)
        NetworkSetInSpectatorMode(false, spectateTarget)
        
        spectateTarget = nil
        CMCore.Functions.Notify('Stopped spectating', 'info')
    else
        -- Start spectating
        if targetSource == GetPlayerServerId(PlayerId()) then
            CMCore.Functions.Notify('Cannot spectate yourself', 'error')
            return
        end
        
        local targetPed = GetPlayerPed(GetPlayerFromServerId(targetSource))
        
        if not DoesEntityExist(targetPed) then
            CMCore.Functions.Notify('Player not found', 'error')
            return
        end
        
        spectating = true
        spectateTarget = targetPed
        
        local playerPed = PlayerPedId()
        SetEntityVisible(playerPed, false, false)
        SetEntityCollision(playerPed, false, false)
        FreezeEntityPosition(playerPed, true)
        NetworkSetInSpectatorMode(true, targetPed)
        
        CMCore.Functions.Notify('Spectating player ' .. targetSource, 'success')
        
        CreateThread(function()
            while spectating do
                Wait(0)
                
                if not DoesEntityExist(spectateTarget) then
                    spectating = false
                    local playerPed = PlayerPedId()
                    SetEntityVisible(playerPed, true, false)
                    SetEntityCollision(playerPed, true, true)
                    FreezeEntityPosition(playerPed, false)
                    NetworkSetInSpectatorMode(false, spectateTarget)
                    CMCore.Functions.Notify('Target disconnected', 'error')
                    break
                end
                
                -- Display spectate info
                local targetCoords = GetEntityCoords(spectateTarget)
                local street = GetStreetNameFromHashKey(GetStreetNameAtCoord(targetCoords.x, targetCoords.y, targetCoords.z))
                
                SetTextFont(4)
                SetTextScale(0.5, 0.5)
                SetTextColour(255, 255, 255, 255)
                SetTextDropshadow(0, 0, 0, 0, 255)
                SetTextEdge(1, 0, 0, 0, 255)
                SetTextDropShadow()
                SetTextOutline()
                SetTextEntry("STRING")
                AddTextComponentString(string.format('Spectating ID: %s | Location: %s', targetSource, street))
                DrawText(0.5, 0.05)
            end
        end)
    end
end)

-- ════════════════════════════════════════════════════════════
-- REVIVE / HEAL / ARMOR
-- ════════════════════════════════════════════════════════════

RegisterNetEvent('CMCore:Admin:Client:Revive', function()
    local ped = PlayerPedId()
    
    SetEntityHealth(ped, 200)
    ClearPedBloodDamage(ped)
    ClearPedTasksImmediately(ped)
    
    CMCore.Functions.Notify('You have been revived', 'success')
end)

RegisterNetEvent('CMCore:Admin:Client:Heal', function()
    local ped = PlayerPedId()
    
    SetEntityHealth(ped, 200)
    ClearPedBloodDamage(ped)
    
    CMCore.Functions.Notify('You have been healed', 'success')
end)

RegisterNetEvent('CMCore:Admin:Client:GiveArmor', function(amount)
    local ped = PlayerPedId()
    SetPedArmour(ped, amount)
    
    CMCore.Functions.Notify('Armor given', 'success')
end)

-- ════════════════════════════════════════════════════════════
-- VEHICLE
-- ════════════════════════════════════════════════════════════

RegisterNetEvent('CMCore:Admin:Client:SpawnVehicle', function(model)
    local hash = GetHashKey(model)
    
    if not IsModelInCdimage(hash) or not IsModelAVehicle(hash) then
        CMCore.Functions.Notify('Invalid vehicle model', 'error')
        return
    end
    
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(10)
    end
    
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    
    local vehicle = CreateVehicle(hash, coords.x, coords.y, coords.z, heading, true, false)
    
    SetPedIntoVehicle(ped, vehicle, -1)
    SetVehicleEngineOn(vehicle, true, true, false)
    SetVehicleOnGroundProperly(vehicle)
    SetModelAsNoLongerNeeded(hash)
    
    CMCore.Functions.Notify('Vehicle spawned: ' .. model, 'success')
end)

RegisterNetEvent('CMCore:Admin:Client:DeleteVehicle', function()
    local ped = PlayerPedId()
    
    if IsPedInAnyVehicle(ped, false) then
        local vehicle = GetVehiclePedIsIn(ped, false)
        DeleteVehicle(vehicle)
        CMCore.Functions.Notify('Vehicle deleted', 'success')
    else
        local vehicle, distance = CMCore.Functions.GetClosestVehicle()
        
        if vehicle and distance < 5.0 then
            DeleteVehicle(vehicle)
            CMCore.Functions.Notify('Vehicle deleted', 'success')
        else
            CMCore.Functions.Notify('No vehicle nearby', 'error')
        end
    end
end)

-- ════════════════════════════════════════════════════════════
-- CLEAR AREA
-- ════════════════════════════════════════════════════════════

RegisterNetEvent('CMCore:Admin:Client:ClearArea', function(adminSource, radius)
    local adminPed = GetPlayerPed(GetPlayerFromServerId(adminSource))
    local coords = GetEntityCoords(adminPed)
    
    -- Clear vehicles
    local vehicles = GetGamePool('CVehicle')
    for _, vehicle in ipairs(vehicles) do
        local vehicleCoords = GetEntityCoords(vehicle)
        local distance = #(coords - vehicleCoords)
        
        if distance <= radius then
            DeleteVehicle(vehicle)
        end
    end
    
    -- Clear peds
    local peds = GetGamePool('CPed')
    for _, ped in ipairs(peds) do
        if not IsPedAPlayer(ped) then
            local pedCoords = GetEntityCoords(ped)
            local distance = #(coords - pedCoords)
            
            if distance <= radius then
                DeletePed(ped)
            end
        end
    end
    
    -- Clear objects
    local objects = GetGamePool('CObject')
    for _, object in ipairs(objects) do
        local objCoords = GetEntityCoords(object)
        local distance = #(coords - objCoords)
        
        if distance <= radius then
            DeleteObject(object)
        end
    end
end)

-- ════════════════════════════════════════════════════════════
-- ADMIN PANEL
-- ════════════════════════════════════════════════════════════

RegisterNetEvent('CMCore:Admin:Client:OpenPanel', function()
    CMCore.NUI.Send('openAdminPanel', {})
    SetNuiFocus(true, true)
end)

-- Close panel
RegisterNUICallback('closeAdminPanel', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Get online players
RegisterNUICallback('getOnlinePlayers', function(data, cb)
    CMCore.Callbacks.TriggerServer('CMCore:Admin:GetOnlinePlayers', function(players)
        cb(players)
    end)
end)

-- Get player details
RegisterNUICallback('getPlayerDetails', function(data, cb)
    CMCore.Callbacks.TriggerServer('CMCore:Admin:GetPlayerDetails', function(details)
        cb(details)
    end, data.source)
end)

-- Kick player
RegisterNUICallback('kickPlayer', function(data, cb)
    CMCore.Callbacks.TriggerServer('CMCore:Admin:KickPlayer', function(success)
        cb(success)
    end, data.source, data.reason)
end)

-- Ban player
RegisterNUICallback('banPlayer', function(data, cb)
    CMCore.Callbacks.TriggerServer('CMCore:Admin:BanPlayer', function(success)
        cb(success)
    end, data)
end)

-- Warn player
RegisterNUICallback('warnPlayer', function(data, cb)
    CMCore.Callbacks.TriggerServer('CMCore:Admin:WarnPlayer', function(success)
        cb(success)
    end, data.source, data.reason)
end)

-- Get bans
RegisterNUICallback('getBans', function(data, cb)
    CMCore.Callbacks.TriggerServer('CMCore:Admin:GetBans', function(bans)
        cb(bans)
    end)
end)

-- Unban player
RegisterNUICallback('unbanPlayer', function(data, cb)
    CMCore.Callbacks.TriggerServer('CMCore:Admin:UnbanPlayer', function(success)
        cb(success)
    end, data.license)
end)

-- Get server stats
RegisterNUICallback('getServerStats', function(data, cb)
    CMCore.Callbacks.TriggerServer('CMCore:Admin:GetServerStats', function(stats)
        cb(stats)
    end)
end)

-- Get admin logs
RegisterNUICallback('getAdminLogs', function(data, cb)
    CMCore.Callbacks.TriggerServer('CMCore:Admin:GetLogs', function(logs)
        cb(logs)
    end, data.limit or 50)
end)

-- Teleport to player
RegisterNUICallback('teleportToPlayer', function(data, cb)
    ExecuteCommand('goto ' .. data.source)
    cb('ok')
end)

-- Bring player
RegisterNUICallback('bringPlayer', function(data, cb)
    ExecuteCommand('bring ' .. data.source)
    cb('ok')
end)

-- Spectate player
RegisterNUICallback('spectatePlayer', function(data, cb)
    TriggerServerEvent('CMCore:Admin:RequestSpectate', data.source)
    SetNuiFocus(false, false)
    cb('ok')
end)

-- Freeze player
RegisterNUICallback('freezePlayer', function(data, cb)
    ExecuteCommand('freeze ' .. data.source)
    cb('ok')
end)

-- Revive player
RegisterNUICallback('revivePlayer', function(data, cb)
    ExecuteCommand('revive ' .. data.source)
    cb('ok')
end)

-- Heal player
RegisterNUICallback('healPlayer', function(data, cb)
    ExecuteCommand('heal ' .. data.source)
    cb('ok')
end)

print('^2[CM-Core Admin]^7 Client loaded')