CMCore.Functions = {}

-- Notification system
function CMCore.Functions.Notify(message, type, duration)
    type = type or 'info'
    duration = duration or 5000
    
    -- You can use any notification system here
    -- For now, we'll use native GTA notifications
    
    SetNotificationTextEntry('STRING')
    AddTextComponentString(message)
    DrawNotification(false, true)
    
    -- Trigger event for custom notification resources
    TriggerEvent('CMCore:Client:Notify', message, type, duration)
end

-- Draw 3D text
function CMCore.Functions.DrawText3D(coords, text)
    local onScreen, x, y = World3dToScreen2d(coords.x, coords.y, coords.z)
    local camCoords = GetGameplayCamCoords()
    local dist = #(coords - camCoords)
    
    local scale = (1 / dist) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov
    
    if onScreen then
        SetTextScale(0.0 * scale, 0.55 * scale)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(x, y)
    end
end

-- Show help notification
function CMCore.Functions.ShowHelpNotification(message)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandDisplayHelp(0, false, true, -1)
end

-- Progress bar
function CMCore.Functions.Progressbar(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
    -- You can integrate with progressbar resources here (ox_lib, qb-progressbar, etc.)
    -- For now, we'll use a simple implementation
    
    local finished = false
    local cancelled = false
    
    CreateThread(function()
        local timer = GetGameTimer() + duration
        
        while GetGameTimer() < timer do
            Wait(0)
            
            if disableControls then
                DisableAllControlActions(0)
            end
            
            -- Show progress text
            SetTextFont(4)
            SetTextScale(0.5, 0.5)
            SetTextColour(255, 255, 255, 255)
            SetTextDropshadow(0, 0, 0, 0, 255)
            SetTextEdge(1, 0, 0, 0, 255)
            SetTextDropShadow()
            SetTextOutline()
            SetTextEntry("STRING")
            AddTextComponentString(label)
            DrawText(0.5, 0.85)
            
            if canCancel then
                if IsControlJustPressed(0, 73) then -- X key
                    cancelled = true
                    break
                end
            end
        end
        
        finished = true
        
        if cancelled and onCancel then
            onCancel()
        elseif not cancelled and onFinish then
            onFinish()
        end
    end)
    
    if animation and animation.animDict then
        RequestAnimDict(animation.animDict)
        while not HasAnimDictLoaded(animation.animDict) do
            Wait(1)
        end
        TaskPlayAnim(PlayerPedId(), animation.animDict, animation.anim, 8.0, 8.0, -1, animation.flags or 49, 0, false, false, false)
    end
    
    return {
        IsFinished = function() return finished end,
        IsCancelled = function() return cancelled end
    }
end

-- Get closest player
function CMCore.Functions.GetClosestPlayer(coords)
    local players = GetActivePlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local playerPed = PlayerPedId()
    local playerCoords = coords or GetEntityCoords(playerPed)
    
    for i = 1, #players do
        local target = GetPlayerPed(players[i])
        
        if target ~= playerPed then
            local targetCoords = GetEntityCoords(target)
            local distance = #(playerCoords - targetCoords)
            
            if closestDistance == -1 or closestDistance > distance then
                closestPlayer = players[i]
                closestDistance = distance
            end
        end
    end
    
    return closestPlayer, closestDistance
end

-- Get players in area
function CMCore.Functions.GetPlayersInArea(coords, area)
    local players = GetActivePlayers()
    local playersInArea = {}
    
    for i = 1, #players do
        local target = GetPlayerPed(players[i])
        local targetCoords = GetEntityCoords(target)
        local distance = #(coords - targetCoords)
        
        if distance <= area then
            table.insert(playersInArea, players[i])
        end
    end
    
    return playersInArea
end

-- Get closest vehicle
function CMCore.Functions.GetClosestVehicle(coords)
    local vehicles = GetGamePool('CVehicle')
    local closestDistance = -1
    local closestVehicle = -1
    local playerCoords = coords or GetEntityCoords(PlayerPedId())
    
    for i = 1, #vehicles do
        local vehicleCoords = GetEntityCoords(vehicles[i])
        local distance = #(playerCoords - vehicleCoords)
        
        if closestDistance == -1 or closestDistance > distance then
            closestVehicle = vehicles[i]
            closestDistance = distance
        end
    end
    
    return closestVehicle, closestDistance
end

-- Get vehicles in area
function CMCore.Functions.GetVehiclesInArea(coords, area)
    local vehicles = GetGamePool('CVehicle')
    local vehiclesInArea = {}
    
    for i = 1, #vehicles do
        local vehicleCoords = GetEntityCoords(vehicles[i])
        local distance = #(coords - vehicleCoords)
        
        if distance <= area then
            table.insert(vehiclesInArea, vehicles[i])
        end
    end
    
    return vehiclesInArea
end

-- Get closest object
function CMCore.Functions.GetClosestObject(coords, modelFilter)
    local objects = GetGamePool('CObject')
    local closestDistance = -1
    local closestObject = -1
    local playerCoords = coords or GetEntityCoords(PlayerPedId())
    
    for i = 1, #objects do
        local objectCoords = GetEntityCoords(objects[i])
        local distance = #(playerCoords - objectCoords)
        
        if closestDistance == -1 or closestDistance > distance then
            if not modelFilter or GetEntityModel(objects[i]) == GetHashKey(modelFilter) then
                closestObject = objects[i]
                closestDistance = distance
            end
        end
    end
    
    return closestObject, closestDistance
end

-- Spawn vehicle
function CMCore.Functions.SpawnVehicle(model, coords, heading, cb)
    local hash = type(model) == 'string' and GetHashKey(model) or model
    
    if not IsModelInCdimage(hash) or not IsModelAVehicle(hash) then
        return
    end
    
    RequestModel(hash)
    while not HasModelLoaded(hash) do
        Wait(10)
    end
    
    local vehicle = CreateVehicle(hash, coords.x, coords.y, coords.z, heading or 0.0, true, false)
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    SetVehicleHasBeenOwnedByPlayer(vehicle, true)
    SetNetworkIdCanMigrate(netId, true)
    SetVehicleNeedsToBeHotwired(vehicle, false)
    SetVehRadioStation(vehicle, 'OFF')
    SetModelAsNoLongerNeeded(hash)
    
    if cb then
        cb(vehicle)
    end
    
    return vehicle
end

-- Delete vehicle
function CMCore.Functions.DeleteVehicle(vehicle)
    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)
end

-- Load model
function CMCore.Functions.LoadModel(model)
    local hash = type(model) == 'string' and GetHashKey(model) or model
    
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        while not HasModelLoaded(hash) do
            Wait(10)
        end
    end
end

-- Load anim dict
function CMCore.Functions.LoadAnimDict(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do
            Wait(10)
        end
    end
end

-- Play animation
function CMCore.Functions.PlayAnim(animDict, animName, duration, flag)
    CMCore.Functions.LoadAnimDict(animDict)
    TaskPlayAnim(PlayerPedId(), animDict, animName, 8.0, 8.0, duration or -1, flag or 49, 0, false, false, false)
end

-- Request and wait for named ptfx asset
function CMCore.Functions.RequestNamedPtfxAsset(asset)
    if not HasNamedPtfxAssetLoaded(asset) then
        RequestNamedPtfxAsset(asset)
        while not HasNamedPtfxAssetLoaded(asset) do
            Wait(10)
        end
    end
end

-- Draw marker
function CMCore.Functions.DrawMarker(type, coords, dir, rot, scale, color, bobUpAndDown, faceCamera, p19, rotate, textureDict, textureName, drawOnEnts)
    DrawMarker(
        type or 1,
        coords.x, coords.y, coords.z,
        dir.x or 0.0, dir.y or 0.0, dir.z or 0.0,
        rot.x or 0.0, rot.y or 0.0, rot.z or 0.0,
        scale.x or 1.0, scale.y or 1.0, scale.z or 1.0,
        color.r or 255, color.g or 255, color.b or 255, color.a or 255,
        bobUpAndDown or false,
        faceCamera or false,
        p19 or 2,
        rotate or false,
        textureDict or nil,
        textureName or nil,
        drawOnEnts or false
    )
end

-- Get street name
function CMCore.Functions.GetStreetName(coords)
    local playerCoords = coords or GetEntityCoords(PlayerPedId())
    local streetHash, crossingHash = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)
    local street = GetStreetNameFromHashKey(streetHash)
    local crossing = GetStreetNameFromHashKey(crossingHash)
    
    if crossing ~= '' then
        return street .. ' | ' .. crossing
    else
        return street
    end
end

-- Get zone name
function CMCore.Functions.GetZoneName(coords)
    local playerCoords = coords or GetEntityCoords(PlayerPedId())
    local zone = GetNameOfZone(playerCoords.x, playerCoords.y, playerCoords.z)
    return GetLabelText(zone)
end

-- Get cardinal direction
function CMCore.Functions.GetCardinalDirection()
    local heading = GetEntityHeading(PlayerPedId())
    
    if heading >= 315 or heading < 45 then
        return "North"
    elseif heading >= 45 and heading < 135 then
        return "West"
    elseif heading >= 135 and heading < 225 then
        return "South"
    elseif heading >= 225 and heading < 315 then
        return "East"
    end
end