if not Config.QBCoreCompatibility then return end

print('^3[CM-Core]^7 Loading QBCore compatibility bridge...')

-- Create QBCore object that mimics QBCore structure
QBCore = {}
QBCore.Config = Config
QBCore.Shared = CMCore.Shared
QBCore.Functions = {}
QBCore.Player = {}
QBCore.Commands = {}
QBCore.UseableItems = {}

-- ════════════════════════════════════════════════════════════
-- SERVER-SIDE COMPATIBILITY
-- ════════════════════════════════════════════════════════════
if IsDuplicityVersion() then
    
    -- ════════════════════════════════════════════════════════════
    -- PLAYER FUNCTIONS
    -- ════════════════════════════════════════════════════════════
    
    -- QBCore.Functions.GetPlayer(source)
    QBCore.Functions.GetPlayer = function(source)
        local player = CMCore.Player.GetPlayer(source)
        if not player then return nil end
        
        -- Wrap CM-Core player object with QBCore methods
        return setmetatable({}, {
            __index = function(_, key)
                -- Direct access to PlayerData
                if key == 'PlayerData' then
                    return player.PlayerData
                end
                
                -- QBCore method mappings
                local qbMethods = {
                    -- Money functions
                    AddMoney = function(self, moneyType, amount, reason)
                        return player:AddMoney(moneyType, amount, reason)
                    end,
                    
                    RemoveMoney = function(self, moneyType, amount, reason)
                        return player:RemoveMoney(moneyType, amount, reason)
                    end,
                    
                    SetMoney = function(self, moneyType, amount, reason)
                        return player:SetMoney(moneyType, amount, reason)
                    end,
                    
                    GetMoney = function(self, moneyType)
                        return player:GetMoney(moneyType)
                    end,
                    
                    -- Job functions
                    SetJob = function(self, job, grade)
                        return player:SetJob(job, grade)
                    end,
                    
                    -- Gang functions
                    SetGang = function(self, gang, grade)
                        -- CM-Core uses same structure
                        local gangData = CMCore.Shared.Gangs[gang]
                        if not gangData then return false end
                        
                        grade = grade or 0
                        if not gangData.grades[grade] then return false end
                        
                        player.PlayerData.gang = {
                            name = gang,
                            label = gangData.label,
                            grade = grade,
                            gradeLabel = gangData.grades[grade].name
                        }
                        
                        CMCore.Cache.Set('player:' .. player.source, player.PlayerData, Config.Performance.CacheTTL)
                        
                        TriggerEvent('CMCore:Server:OnGangUpdate', player.source, player.PlayerData.gang)
                        TriggerClientEvent('CMCore:Client:OnGangUpdate', player.source, player.PlayerData.gang)
                        
                        return true
                    end,
                    
                    -- Metadata functions
                    SetMetaData = function(self, meta, val)
                        return player:SetMetadata(meta, val)
                    end,
                    
                    GetMetaData = function(self, meta)
                        return player:GetMetadata(meta)
                    end,
                    
                    -- Inventory functions (if CM-Core has inventory module)
                    AddItem = function(self, item, amount, slot, info)
                        -- Trigger event for inventory resource to handle
                        TriggerEvent('CMCore:Server:AddItem', player.source, item, amount, slot, info)
                    end,
                    
                    RemoveItem = function(self, item, amount, slot)
                        TriggerEvent('CMCore:Server:RemoveItem', player.source, item, amount, slot)
                    end,
                    
                    GetItemBySlot = function(self, slot)
                        -- Will be handled by inventory resource
                        return nil
                    end,
                    
                    GetItemByName = function(self, item)
                        -- Will be handled by inventory resource
                        return nil
                    end,
                    
                    -- Citizen ID
                    SetCitizenId = function(self, citizenid)
                        player.PlayerData.citizenid = citizenid
                        CMCore.Cache.Set('player:' .. player.source, player.PlayerData, Config.Performance.CacheTTL)
                    end,
                    
                    -- Save function
                    Save = function(self)
                        return player:Save()
                    end,
                    
                    -- Logout function
                    Logout = function(self)
                        CMCore.Player.UnloadPlayer(player.source)
                    end,
                }
                
                return qbMethods[key]
            end
        })
    end
    
    -- QBCore.Functions.GetPlayerByCitizenId(citizenid)
    QBCore.Functions.GetPlayerByCitizenId = function(citizenid)
        local player = CMCore.Player.GetPlayerByCitizenId(citizenid)
        if not player then return nil end
        return QBCore.Functions.GetPlayer(player.source)
    end
    
    -- QBCore.Functions.GetPlayers()
    QBCore.Functions.GetPlayers = function()
        return CMCore.Player.GetAllPlayers()
    end
    
    -- QBCore.Functions.GetQBPlayers()
    QBCore.Functions.GetQBPlayers = function()
        local qbPlayers = {}
        for source, _ in pairs(CMCore.Player.GetAllPlayers()) do
            qbPlayers[source] = QBCore.Functions.GetPlayer(source)
        end
        return qbPlayers
    end
    
    -- QBCore.Functions.CreateUseableItem(item, cb)
    QBCore.Functions.CreateUseableItem = function(item, cb)
        QBCore.UseableItems[item] = cb
    end
    
    -- QBCore.Functions.CanUseItem(item)
    QBCore.Functions.CanUseItem = function(item)
        return QBCore.UseableItems[item] ~= nil
    end
    
    -- QBCore.Functions.UseItem(source, item)
    QBCore.Functions.UseItem = function(source, item)
        if QBCore.UseableItems[item.name] then
            QBCore.UseableItems[item.name](source, item)
        end
    end
    
    -- ════════════════════════════════════════════════════════════
    -- CALLBACK FUNCTIONS
    -- ════════════════════════════════════════════════════════════
    
    -- QBCore.Functions.CreateCallback(name, cb)
    QBCore.Functions.CreateCallback = function(name, cb)
        CMCore.Callbacks.Register(name, cb)
    end
    
    -- QBCore.Functions.TriggerCallback(name, source, cb, ...)
    QBCore.Functions.TriggerCallback = function(name, source, cb, ...)
        CMCore.Callbacks.TriggerClient(name, source, cb, ...)
    end
    
    -- ════════════════════════════════════════════════════════════
    -- UTILITY FUNCTIONS
    -- ════════════════════════════════════════════════════════════
    
    -- QBCore.Functions.GetIdentifier(source, idtype)
    QBCore.Functions.GetIdentifier = function(source, idtype)
        idtype = idtype or 'license'
        return GetPlayerIdentifierByType(source, idtype)
    end
    
    -- QBCore.Functions.GetSource(identifier)
    QBCore.Functions.GetSource = function(identifier)
        for _, playerId in ipairs(GetPlayers()) do
            local playerIdentifier = GetPlayerIdentifierByType(playerId, 'license')
            if playerIdentifier == identifier then
                return tonumber(playerId)
            end
        end
        return nil
    end
    
    -- QBCore.Functions.GetPermission(source)
    QBCore.Functions.GetPermission = function(source)
        return CMCore.Permissions.GetGroup(source)
    end
    
    -- QBCore.Functions.HasPermission(source, permission)
    QBCore.Functions.HasPermission = function(source, permission)
        if type(permission) == "string" then
            return CMCore.Permissions.HasPermission(source, permission)
        elseif type(permission) == "table" then
            for _, perm in ipairs(permission) do
                if CMCore.Permissions.HasPermission(source, perm) then
                    return true
                end
            end
        end
        return false
    end
    
    -- QBCore.Functions.IsOptin(source)
    QBCore.Functions.IsOptin = function(source)
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return false end
        return Player.PlayerData.optin or false
    end
    
    -- QBCore.Functions.ToggleOptin(source)
    QBCore.Functions.ToggleOptin = function(source)
        local Player = QBCore.Functions.GetPlayer(source)
        if not Player then return end
        Player.PlayerData.optin = not Player.PlayerData.optin
    end
    
    -- QBCore.Functions.IsPlayerBanned(source)
    QBCore.Functions.IsPlayerBanned = function(source)
        local license = GetPlayerIdentifierByType(source, 'license')
        if not license then return false end
        
        local result = MySQL.single.await('SELECT * FROM bans WHERE license = ?', {license})
        
        if result then
            local timeLeft = os.difftime(result.expire, os.time())
            if timeLeft > 0 or result.expire == -1 then
                return true, result.reason, timeLeft
            else
                -- Ban expired, remove it
                MySQL.query('DELETE FROM bans WHERE license = ?', {license})
                return false
            end
        end
        
        return false
    end
    
    -- QBCore.Functions.Kick(source, reason, setKickReason, deferrals)
    QBCore.Functions.Kick = function(source, reason, setKickReason, deferrals)
        reason = reason or 'You have been kicked from the server'
        
        if setKickReason then
            setKickReason(reason)
        end
        
        CreateThread(function()
            DropPlayer(source, reason)
        end)
    end
    
    -- QBCore.Functions.Notify(source, text, type, length)
    QBCore.Functions.Notify = function(source, text, notifyType, length)
        TriggerClientEvent('CMCore:Client:Notify', source, text, notifyType, length)
    end
    
    -- ════════════════════════════════════════════════════════════
    -- COMMAND FUNCTIONS
    -- ════════════════════════════════════════════════════════════
    
    -- QBCore.Commands.Add(name, help, arguments, argsrequired, callback, permission)
    QBCore.Commands.Add = function(name, help, arguments, argsrequired, callback, permission)
        CMCore.Commands.Register(name, permission, function(source, args)
            if argsrequired and #args < argsrequired then
                TriggerClientEvent('CMCore:Client:Notify', source, 'Not enough arguments', 'error')
                return
            end
            
            callback(source, args)
        end, {
            help = help,
            params = arguments
        })
    end
    
    -- QBCore.Commands.Refresh(source)
    QBCore.Commands.Refresh = function(source)
        -- CM-Core handles this automatically through permissions
    end
    
    -- ════════════════════════════════════════════════════════════
    -- DATABASE FUNCTIONS
    -- ════════════════════════════════════════════════════════════
    
    -- QBCore.Functions.ExecuteSql(query, cb)
    QBCore.Functions.ExecuteSql = function(query, cb)
        return CMCore.Database.Execute(query, {}, cb)
    end
    
    -- QBCore.Functions.InsertSql(query, cb)
    QBCore.Functions.InsertSql = function(query, cb)
        return CMCore.Database.Insert(query, {}, cb)
    end
    
    -- ════════════════════════════════════════════════════════════
    -- EVENTS
    -- ════════════════════════════════════════════════════════════
    
    -- Map CM-Core events to QBCore events
    AddEventHandler('CMCore:Server:PlayerLoaded', function(source, player)
        TriggerEvent('QBCore:Server:PlayerLoaded', QBCore.Functions.GetPlayer(source))
    end)
    
    AddEventHandler('CMCore:Server:OnPlayerUnloaded', function(source)
        TriggerEvent('QBCore:Server:OnPlayerUnload', source)
    end)
    
    AddEventHandler('CMCore:Server:OnMoneyChange', function(source, moneyType, amount, changeType, reason)
        TriggerEvent('QBCore:Server:OnMoneyChange', source, moneyType, amount, changeType, reason)
    end)
    
    AddEventHandler('CMCore:Server:OnJobUpdate', function(source, job)
        TriggerEvent('QBCore:Server:OnJobUpdate', source, job)
    end)
    
    AddEventHandler('CMCore:Server:OnGangUpdate', function(source, gang)
        TriggerEvent('QBCore:Server:OnGangUpdate', source, gang)
    end)
    
    -- ════════════════════════════════════════════════════════════
    -- SHARED FUNCTIONS
    -- ════════════════════════════════════════════════════════════
    
    QBCore.Shared.Round = CMCore.Shared.Round
    QBCore.Shared.Trim = CMCore.Shared.Trim
    QBCore.Shared.SplitStr = CMCore.Shared.Split
    QBCore.Shared.Items = {} -- Will be loaded from cm-core/config/items.json
    QBCore.Shared.Jobs = CMCore.Shared.Jobs
    QBCore.Shared.Gangs = CMCore.Shared.Gangs
    QBCore.Shared.Vehicles = {} -- Will be loaded from cm-core/config/vehicles.json
    QBCore.Shared.Weapons = {} -- Will be loaded from cm-core/config/weapons.json
    
    -- Load items from JSON
    local itemsFile = LoadResourceFile(GetCurrentResourceName(), 'config/items.json')
    if itemsFile then
        QBCore.Shared.Items = json.decode(itemsFile)
    end
    
    -- Load vehicles from JSON
    local vehiclesFile = LoadResourceFile(GetCurrentResourceName(), 'config/vehicles.json')
    if vehiclesFile then
        QBCore.Shared.Vehicles = json.decode(vehiclesFile)
    end
    
    -- QBCore.Shared.SplitStr kept for compatibility
    QBCore.Shared.SplitStr = CMCore.Shared.Split

-- ════════════════════════════════════════════════════════════
-- CLIENT-SIDE COMPATIBILITY
-- ════════════════════════════════════════════════════════════
else
    
    -- ════════════════════════════════════════════════════════════
    -- PLAYER FUNCTIONS
    -- ════════════════════════════════════════════════════════════
    
    -- QBCore.Functions.GetPlayerData(cb)
    QBCore.Functions.GetPlayerData = function(cb)
        if not cb then
            return CMCore.PlayerData
        else
            cb(CMCore.PlayerData)
        end
    end
    
    -- QBCore.Functions.GetCoords(entity)
    QBCore.Functions.GetCoords = function(entity)
        local coords = GetEntityCoords(entity or PlayerPedId())
        return vector4(coords.x, coords.y, coords.z, GetEntityHeading(entity or PlayerPedId()))
    end
    
    -- QBCore.Functions.HasItem(items, amount)
    QBCore.Functions.HasItem = function(items, amount)
        -- This will be handled by inventory resource
        return false
    end
    
    -- ════════════════════════════════════════════════════════════
    -- CALLBACK FUNCTIONS
    -- ════════════════════════════════════════════════════════════
    
    -- QBCore.Functions.TriggerCallback(name, cb, ...)
    QBCore.Functions.TriggerCallback = function(name, cb, ...)
        CMCore.Callbacks.TriggerServer(name, cb, ...)
    end
    
    -- ════════════════════════════════════════════════════════════
    -- UTILITY FUNCTIONS
    -- ════════════════════════════════════════════════════════════
    
    -- QBCore.Functions.Notify(text, type, length)
    QBCore.Functions.Notify = function(text, notifyType, length)
        CMCore.Functions.Notify(text, notifyType, length)
    end
    
    -- QBCore.Functions.DrawText(x, y, width, height, scale, r, g, b, a, text)
    QBCore.Functions.DrawText = function(x, y, width, height, scale, r, g, b, a, text)
        SetTextFont(4)
        SetTextScale(scale, scale)
        SetTextColour(r, g, b, a)
        SetTextOutline()
        SetTextCentre(true)
        SetTextEntry("STRING")
        AddTextComponentString(text)
        DrawText(x - width / 2, y - height / 2 + 0.005)
    end
    
    -- QBCore.Functions.DrawText3D(x, y, z, text)
    QBCore.Functions.DrawText3D = function(x, y, z, text)
        CMCore.Functions.DrawText3D(vector3(x, y, z), text)
    end
    
    -- QBCore.Functions.RequestAnimDict(animDict, cb)
    QBCore.Functions.RequestAnimDict = function(animDict, cb)
        if not HasAnimDictLoaded(animDict) then
            RequestAnimDict(animDict)
            while not HasAnimDictLoaded(animDict) do
                Wait(1)
            end
        end
        if cb then cb() end
    end
    
    -- QBCore.Functions.PlayAnim(animDict, animName, upperbodyOnly, duration)
    QBCore.Functions.PlayAnim = function(animDict, animName, upperbodyOnly, duration)
        local flags = upperbodyOnly and 48 or 0
        CMCore.Functions.PlayAnim(animDict, animName, duration, flags)
    end
    
    -- QBCore.Functions.Progressbar(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
    QBCore.Functions.Progressbar = function(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
        return CMCore.Functions.Progressbar(name, label, duration, useWhileDead, canCancel, disableControls, animation, prop, propTwo, onFinish, onCancel)
    end
    
    -- QBCore.Functions.GetVehicles()
    QBCore.Functions.GetVehicles = function()
        return GetGamePool('CVehicle')
    end
    
    -- QBCore.Functions.GetObjects()
    QBCore.Functions.GetObjects = function()
        return GetGamePool('CObject')
    end
    
    -- QBCore.Functions.GetPlayers()
    QBCore.Functions.GetPlayers = function()
        return GetActivePlayers()
    end
    
    -- QBCore.Functions.GetPeds(ignoreList)
    QBCore.Functions.GetPeds = function(ignoreList)
        local peds = {}
        local allPeds = GetGamePool('CPed')
        
        for i = 1, #allPeds do
            local found = false
            
            if ignoreList then
                for j = 1, #ignoreList do
                    if allPeds[i] == ignoreList[j] then
                        found = true
                        break
                    end
                end
            end
            
            if not found then
                table.insert(peds, allPeds[i])
            end
        end
        
        return peds
    end
    
    -- QBCore.Functions.GetClosestPlayer(coords)
    QBCore.Functions.GetClosestPlayer = function(coords)
        return CMCore.Functions.GetClosestPlayer(coords)
    end
    
    -- QBCore.Functions.GetPlayersFromCoords(coords, distance)
    QBCore.Functions.GetPlayersFromCoords = function(coords, distance)
        return CMCore.Functions.GetPlayersInArea(coords or GetEntityCoords(PlayerPedId()), distance)
    end
    
    -- QBCore.Functions.GetClosestVehicle(coords)
    QBCore.Functions.GetClosestVehicle = function(coords)
        return CMCore.Functions.GetClosestVehicle(coords)
    end
    
    -- QBCore.Functions.GetClosestObject(coords, modelFilter)
    QBCore.Functions.GetClosestObject = function(coords, modelFilter)
        return CMCore.Functions.GetClosestObject(coords, modelFilter)
    end
    
    -- QBCore.Functions.SpawnVehicle(model, cb, coords, isnetworked)
    QBCore.Functions.SpawnVehicle = function(model, cb, coords, isnetworked)
        local playerCoords = coords or GetEntityCoords(PlayerPedId())
        local playerHeading = GetEntityHeading(PlayerPedId())
        
        CMCore.Functions.SpawnVehicle(model, playerCoords, playerHeading, function(vehicle)
            if isnetworked then
                SetNetworkIdCanMigrate(NetworkGetNetworkIdFromEntity(vehicle), true)
            end
            if cb then cb(vehicle) end
        end)
    end
    
    -- QBCore.Functions.DeleteVehicle(vehicle)
    QBCore.Functions.DeleteVehicle = function(vehicle)
        CMCore.Functions.DeleteVehicle(vehicle)
    end
    
    -- QBCore.Functions.GetVehicleProperties(vehicle)
    QBCore.Functions.GetVehicleProperties = function(vehicle)
        if not DoesEntityExist(vehicle) then return nil end
        
        local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
        local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)
        local extras = {}
        
        for i = 1, 12 do
            if DoesExtraExist(vehicle, i) then
                extras[tostring(i)] = IsVehicleExtraTurnedOn(vehicle, i)
            end
        end
        
        return {
            model = GetEntityModel(vehicle),
            plate = GetVehicleNumberPlateText(vehicle),
            plateIndex = GetVehicleNumberPlateTextIndex(vehicle),
            bodyHealth = GetVehicleBodyHealth(vehicle),
            engineHealth = GetVehicleEngineHealth(vehicle),
            tankHealth = GetVehiclePetrolTankHealth(vehicle),
            fuelLevel = GetVehicleFuelLevel(vehicle),
            dirtLevel = GetVehicleDirtLevel(vehicle),
            color1 = colorPrimary,
            color2 = colorSecondary,
            pearlescentColor = pearlescentColor,
            wheelColor = wheelColor,
            wheels = GetVehicleWheelType(vehicle),
            windowTint = GetVehicleWindowTint(vehicle),
            xenonColor = GetVehicleXenonLightsColour(vehicle),
            customPrimaryColor = table.pack(GetVehicleCustomPrimaryColour(vehicle)),
            customSecondaryColor = table.pack(GetVehicleCustomSecondaryColour(vehicle)),
            neonEnabled = {
                IsVehicleNeonLightEnabled(vehicle, 0),
                IsVehicleNeonLightEnabled(vehicle, 1),
                IsVehicleNeonLightEnabled(vehicle, 2),
                IsVehicleNeonLightEnabled(vehicle, 3)
            },
            neonColor = table.pack(GetVehicleNeonLightsColour(vehicle)),
            extras = extras,
            tyreSmokeColor = table.pack(GetVehicleTyreSmokeColor(vehicle)),
            modSpoilers = GetVehicleMod(vehicle, 0),
            modFrontBumper = GetVehicleMod(vehicle, 1),
            modRearBumper = GetVehicleMod(vehicle, 2),
            modSideSkirt = GetVehicleMod(vehicle, 3),
            modExhaust = GetVehicleMod(vehicle, 4),
            modFrame = GetVehicleMod(vehicle, 5),
            modGrille = GetVehicleMod(vehicle, 6),
            modHood = GetVehicleMod(vehicle, 7),
            modFender = GetVehicleMod(vehicle, 8),
            modRightFender = GetVehicleMod(vehicle, 9),
            modRoof = GetVehicleMod(vehicle, 10),
            modEngine = GetVehicleMod(vehicle, 11),
            modBrakes = GetVehicleMod(vehicle, 12),
            modTransmission = GetVehicleMod(vehicle, 13),
            modHorns = GetVehicleMod(vehicle, 14),
            modSuspension = GetVehicleMod(vehicle, 15),
            modArmor = GetVehicleMod(vehicle, 16),
            modTurbo = IsToggleModOn(vehicle, 18),
            modSmokeEnabled = IsToggleModOn(vehicle, 20),
            modXenon = IsToggleModOn(vehicle, 22),
            modFrontWheels = GetVehicleMod(vehicle, 23),
            modBackWheels = GetVehicleMod(vehicle, 24),
            modPlateHolder = GetVehicleMod(vehicle, 25),
            modVanityPlate = GetVehicleMod(vehicle, 26),
            modTrimA = GetVehicleMod(vehicle, 27),
            modOrnaments = GetVehicleMod(vehicle, 28),
            modDashboard = GetVehicleMod(vehicle, 29),
            modDial = GetVehicleMod(vehicle, 30),
            modDoorSpeaker = GetVehicleMod(vehicle, 31),
            modSeats = GetVehicleMod(vehicle, 32),
            modSteeringWheel = GetVehicleMod(vehicle, 33),
            modShifterLeavers = GetVehicleMod(vehicle, 34),
            modAPlate = GetVehicleMod(vehicle, 35),
            modSpeakers = GetVehicleMod(vehicle, 36),
            modTrunk = GetVehicleMod(vehicle, 37),
            modHydrolic = GetVehicleMod(vehicle, 38),
            modEngineBlock = GetVehicleMod(vehicle, 39),
            modAirFilter = GetVehicleMod(vehicle, 40),
            modStruts = GetVehicleMod(vehicle, 41),
            modArchCover = GetVehicleMod(vehicle, 42),
            modAerials = GetVehicleMod(vehicle, 43),
            modTrimB = GetVehicleMod(vehicle, 44),
            modTank = GetVehicleMod(vehicle, 45),
            modWindows = GetVehicleMod(vehicle, 46),
            modLivery = GetVehicleLivery(vehicle),
        }
    end
    
    -- QBCore.Functions.SetVehicleProperties(vehicle, props)
    QBCore.Functions.SetVehicleProperties = function(vehicle, props)
        if not DoesEntityExist(vehicle) then return end
        
        if props.plate then SetVehicleNumberPlateText(vehicle, props.plate) end
        if props.plateIndex then SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex) end
        if props.bodyHealth then SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0) end
        if props.engineHealth then SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0) end
        if props.tankHealth then SetVehiclePetrolTankHealth(vehicle, props.tankHealth + 0.0) end
        if props.fuelLevel then SetVehicleFuelLevel(vehicle, props.fuelLevel + 0.0) end
        if props.dirtLevel then SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0) end
        if props.color1 then
            if type(props.color1) == 'number' then
                SetVehicleColours(vehicle, props.color1, props.color2 or 0)
            else
                SetVehicleCustomPrimaryColour(vehicle, props.color1[1], props.color1[2], props.color1[3])
            end
        end
        if props.color2 then
            if type(props.color2) == 'number' then
                SetVehicleColours(vehicle, props.color1 or 0, props.color2)
            else
                SetVehicleCustomSecondaryColour(vehicle, props.color2[1], props.color2[2], props.color2[3])
            end
        end
        if props.pearlescentColor then SetVehicleExtraColours(vehicle, props.pearlescentColor, props.wheelColor or 0) end
        if props.wheelColor then SetVehicleExtraColours(vehicle, props.pearlescentColor or 0, props.wheelColor) end
        if props.wheels then SetVehicleWheelType(vehicle, props.wheels) end
        if props.windowTint then SetVehicleWindowTint(vehicle, props.windowTint) end
        
        -- Apply mods
        if props.modSpoilers then SetVehicleMod(vehicle, 0, props.modSpoilers, false) end
        if props.modFrontBumper then SetVehicleMod(vehicle, 1, props.modFrontBumper, false) end
        if props.modRearBumper then SetVehicleMod(vehicle, 2, props.modRearBumper, false) end
        if props.modSideSkirt then SetVehicleMod(vehicle, 3, props.modSideSkirt, false) end
        if props.modExhaust then SetVehicleMod(vehicle, 4, props.modExhaust, false) end
        if props.modFrame then SetVehicleMod(vehicle, 5, props.modFrame, false) end
        if props.modGrille then SetVehicleMod(vehicle, 6, props.modGrille, false) end
        if props.modHood then SetVehicleMod(vehicle, 7, props.modHood, false) end
        if props.modFender then SetVehicleMod(vehicle, 8, props.modFender, false) end
        if props.modRightFender then SetVehicleMod(vehicle, 9, props.modRightFender, false) end
        if props.modRoof then SetVehicleMod(vehicle, 10, props.modRoof, false) end
        if props.modEngine then SetVehicleMod(vehicle, 11, props.modEngine, false) end
        if props.modBrakes then SetVehicleMod(vehicle, 12, props.modBrakes, false) end
        if props.modTransmission then SetVehicleMod(vehicle, 13, props.modTransmission, false) end
        if props.modHorns then SetVehicleMod(vehicle, 14, props.modHorns, false) end
        if props.modSuspension then SetVehicleMod(vehicle, 15, props.modSuspension, false) end
        if props.modArmor then SetVehicleMod(vehicle, 16, props.modArmor, false) end
        if props.modTurbo then ToggleVehicleMod(vehicle, 18, props.modTurbo) end
        if props.modXenon then ToggleVehicleMod(vehicle, 22, props.modXenon) end
        if props.modFrontWheels then SetVehicleMod(vehicle, 23, props.modFrontWheels, false) end
        if props.modBackWheels then SetVehicleMod(vehicle, 24, props.modBackWheels, false) end
        
        -- Apply extras
        if props.extras then
            for id, enabled in pairs(props.extras) do
                if DoesExtraExist(vehicle, tonumber(id)) then
                    SetVehicleExtra(vehicle, tonumber(id), enabled and 0 or 1)
                end
            end
        end
        
        -- Apply neons
        if props.neonEnabled then
            for i = 1, 4 do
                SetVehicleNeonLightEnabled(vehicle, i - 1, props.neonEnabled[i])
            end
        end
        
        if props.neonColor then
            SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3])
        end
    end
    
    -- ════════════════════════════════════════════════════════════
    -- EVENTS
    -- ════════════════════════════════════════════════════════════
    
    -- Map CM-Core events to QBCore events
    AddEventHandler('CMCore:Client:OnPlayerLoaded', function()
        TriggerEvent('QBCore:Client:OnPlayerLoaded')
    end)
    
    RegisterNetEvent('CMCore:Client:OnMoneyChange', function(moneyType, amount, changeType)
        TriggerEvent('QBCore:Client:OnMoneyChange', moneyType, amount, changeType)
    end)
    
    RegisterNetEvent('CMCore:Client:OnJobUpdate', function(job)
        TriggerEvent('QBCore:Client:OnJobUpdate', job)
    end)
    
    RegisterNetEvent('CMCore:Client:OnGangUpdate', function(gang)
        TriggerEvent('QBCore:Client:OnGangUpdate', gang)
    end)
    
    RegisterNetEvent('CMCore:Client:Notify', function(message, type, duration)
        TriggerEvent('QBCore:Notify', message, type, duration)
    end)
    
    -- ════════════════════════════════════════════════════════════
    -- SHARED FUNCTIONS
    -- ════════════════════════════════════════════════════════════
    
    QBCore.Shared.Round = CMCore.Shared.Round
    QBCore.Shared.Trim = CMCore.Shared.Trim
    QBCore.Shared.SplitStr = CMCore.Shared.Split
end

-- ════════════════════════════════════════════════════════════
-- EXPORT QBCORE OBJECT
-- ════════════════════════════════════════════════════════════

-- Export as 'qb-core'
exports('GetCoreObject', function()
    return QBCore
end)

-- Also set as global
_G.QBCore = QBCore

print('^2[CM-Core]^7 QBCore compatibility bridge loaded successfully!')