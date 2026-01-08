CMCore.Player = {}

-- Player class
local Player = {}
Player.__index = Player

function Player.new(source, identifier, playerData)
    local self = setmetatable({}, Player)
    
    self.source = source
    self.identifier = identifier
    self.PlayerData = playerData or {}
    
    -- Default structure
    self.PlayerData.source = source
    self.PlayerData.citizenid = self.PlayerData.citizenid or CMCore.Player.CreateCitizenId()
    self.PlayerData.license = self.PlayerData.license or identifier
    self.PlayerData.name = self.PlayerData.name or GetPlayerName(source)
    self.PlayerData.money = self.PlayerData.money or Config.Player.StartingMoney
    self.PlayerData.job = self.PlayerData.job or { name = 'unemployed', label = 'Civilian', grade = 0 }
    self.PlayerData.gang = self.PlayerData.gang or { name = 'none', label = 'No Gang', grade = 0 }
    self.PlayerData.position = self.PlayerData.position or { x = 0, y = 0, z = 0 }
    self.PlayerData.metadata = self.PlayerData.metadata or {}
    
    -- Cache player data
    CMCore.Cache.Set('player:' .. source, self.PlayerData, Config.Performance.CacheTTL)
    
    return self
end

-- Get player money
function Player:GetMoney(moneyType)
    moneyType = moneyType or 'cash'
    return self.PlayerData.money[moneyType] or 0
end

-- Add money
function Player:AddMoney(moneyType, amount, reason)
    moneyType = moneyType or 'cash'
    reason = reason or 'Unknown'
    
    if not self.PlayerData.money[moneyType] then
        self.PlayerData.money[moneyType] = 0
    end
    
    self.PlayerData.money[moneyType] = self.PlayerData.money[moneyType] + amount
    
    -- Update cache
    CMCore.Cache.Set('player:' .. self.source, self.PlayerData, Config.Performance.CacheTTL)
    
    -- Trigger event for logging/other resources
    TriggerEvent('CMCore:Server:OnMoneyChange', self.source, moneyType, amount, 'add', reason)
    TriggerClientEvent('CMCore:Client:OnMoneyChange', self.source, moneyType, amount, 'add')
    
    -- Log transaction
    CMCore.Logger.Info('Money', string.format('Player %s (%s) received %d %s. Reason: %s', 
        self.PlayerData.name, self.source, amount, moneyType, reason))
    
    return true
end

-- Remove money
function Player:RemoveMoney(moneyType, amount, reason)
    moneyType = moneyType or 'cash'
    reason = reason or 'Unknown'
    
    if not self.PlayerData.money[moneyType] or self.PlayerData.money[moneyType] < amount then
        return false
    end
    
    self.PlayerData.money[moneyType] = self.PlayerData.money[moneyType] - amount
    
    -- Update cache
    CMCore.Cache.Set('player:' .. self.source, self.PlayerData, Config.Performance.CacheTTL)
    
    TriggerEvent('CMCore:Server:OnMoneyChange', self.source, moneyType, amount, 'remove', reason)
    TriggerClientEvent('CMCore:Client:OnMoneyChange', self.source, moneyType, amount, 'remove')
    
    CMCore.Logger.Info('Money', string.format('Player %s (%s) paid %d %s. Reason: %s', 
        self.PlayerData.name, self.source, amount, moneyType, reason))
    
    return true
end

-- Set money
function Player:SetMoney(moneyType, amount, reason)
    moneyType = moneyType or 'cash'
    reason = reason or 'Unknown'
    
    self.PlayerData.money[moneyType] = amount
    
    CMCore.Cache.Set('player:' .. self.source, self.PlayerData, Config.Performance.CacheTTL)
    
    TriggerEvent('CMCore:Server:OnMoneyChange', self.source, moneyType, amount, 'set', reason)
    TriggerClientEvent('CMCore:Client:OnMoneyChange', self.source, moneyType, self.PlayerData.money[moneyType], 'set')
    
    return true
end

-- Set job
function Player:SetJob(jobName, grade)
    local job = CMCore.Shared.Jobs[jobName]
    if not job then return false end
    
    grade = grade or 0
    if not job.grades[grade] then return false end
    
    self.PlayerData.job = {
        name = jobName,
        label = job.label,
        grade = grade,
        gradeLabel = job.grades[grade].name,
        payment = job.grades[grade].payment or 0,
        onduty = true
    }
    
    CMCore.Cache.Set('player:' .. self.source, self.PlayerData, Config.Performance.CacheTTL)
    
    TriggerEvent('CMCore:Server:OnJobUpdate', self.source, self.PlayerData.job)
    TriggerClientEvent('CMCore:Client:OnJobUpdate', self.source, self.PlayerData.job)
    
    return true
end

-- Get metadata
function Player:GetMetadata(key)
    return self.PlayerData.metadata[key]
end

-- Set metadata
function Player:SetMetadata(key, value)
    self.PlayerData.metadata[key] = value
    CMCore.Cache.Set('player:' .. self.source, self.PlayerData, Config.Performance.CacheTTL)
end

-- Save player data
function Player:Save()
    CMCore.Database.SavePlayer(self.source, self.PlayerData)
end

-- Functions
function CMCore.Player.CreateCitizenId()
    local charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local citizenid = ""
    
    math.randomseed(GetGameTimer())
    
    for i = 1, 8 do
        local rand = math.random(1, #charset)
        citizenid = citizenid .. string.sub(charset, rand, rand)
    end
    
    return citizenid
end

function CMCore.Player.GetPlayer(source)
    return CMCore.Players[source]
end

function CMCore.Player.GetPlayerByCitizenId(citizenid)
    return CMCore.PlayersByIdentifier[citizenid]
end

function CMCore.Player.GetAllPlayers()
    return CMCore.Players
end

function CMCore.Player.LoadPlayer(source, identifier)
    -- Check cache first
    local cached = CMCore.Cache.Get('player:' .. source)
    if cached then
        local player = Player.new(source, identifier, cached)
        CMCore.Players[source] = player
        CMCore.PlayersByIdentifier[player.PlayerData.citizenid] = player
        return player
    end
    
    -- Load from database
    local playerData = CMCore.Database.LoadPlayer(identifier)
    
    local player = Player.new(source, identifier, playerData)
    CMCore.Players[source] = player
    CMCore.PlayersByIdentifier[player.PlayerData.citizenid] = player
    
    -- Trigger loaded event
    TriggerEvent('CMCore:Server:PlayerLoaded', source, player)
    TriggerClientEvent('CMCore:Client:PlayerLoaded', source, player.PlayerData)
    
    return player
end

function CMCore.Player.UnloadPlayer(source)
    local player = CMCore.Players[source]
    if not player then return end
    
    -- Save before unload
    player:Save()
    
    -- Remove from cache
    CMCore.Cache.Delete('player:' .. source)
    
    -- Remove from tables
    CMCore.PlayersByIdentifier[player.PlayerData.citizenid] = nil
    CMCore.Players[source] = nil
    
    TriggerEvent('CMCore:Server:PlayerUnloaded', source)
end

-- Auto-save players
CreateThread(function()
    while true do
        Wait(Config.Player.AutoSaveInterval * 60000)
        
        CMCore.Logger.Info('Player', 'Auto-saving all players...')
        
        for source, player in pairs(CMCore.Players) do
            player:Save()
        end
        
        CMCore.Logger.Success('Player', 'All players saved!')
    end
end)