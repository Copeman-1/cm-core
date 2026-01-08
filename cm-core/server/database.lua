CMCore.Database = {}

local queryQueue = {}
local isProcessing = false

function CMCore.Database.Init()
    -- Test connection
    MySQL.ready(function()
        CMCore.Logger.Success('Database', 'MySQL connection established')
        
        -- Create tables if they don't exist
        CMCore.Database.CreateTables()
    end)
end

function CMCore.Database.CreateTables()
    MySQL.query([[
        CREATE TABLE IF NOT EXISTS players (
            id INT AUTO_INCREMENT PRIMARY KEY,
            citizenid VARCHAR(50) UNIQUE NOT NULL,
            license VARCHAR(50) UNIQUE NOT NULL,
            name VARCHAR(255) NOT NULL,
            money TEXT,
            job TEXT,
            gang TEXT,
            position TEXT,
            metadata TEXT,
            last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
            INDEX idx_citizenid (citizenid),
            INDEX idx_license (license)
        )
    ]])
    
    CMCore.Logger.Success('Database', 'Tables created/verified')
end

-- Execute SQL query (async)
function CMCore.Database.Execute(query, parameters, cb)
    local startTime = GetGameTimer()
    
    MySQL.query(query, parameters, function(result)
        local queryTime = GetGameTimer() - startTime
        
        -- Log slow queries
        if queryTime > Config.Database.SlowQueryThreshold then
            CMCore.Logger.Warn('Database', string.format('Slow query detected: %dms - %s', queryTime, query))
        end
        
        if cb then cb(result) end
    end)
end

-- Insert query
function CMCore.Database.Insert(query, parameters, cb)
    local startTime = GetGameTimer()
    
    MySQL.insert(query, parameters, function(result)
        local queryTime = GetGameTimer() - startTime
        
        if queryTime > Config.Database.SlowQueryThreshold then
            CMCore.Logger.Warn('Database', string.format('Slow insert: %dms - %s', queryTime, query))
        end
        
        if cb then cb(result) end
    end)
end

-- Update query
function CMCore.Database.Update(query, parameters, cb)
    local startTime = GetGameTimer()
    
    MySQL.update(query, parameters, function(result)
        local queryTime = GetGameTimer() - startTime
        
        if queryTime > Config.Database.SlowQueryThreshold then
            CMCore.Logger.Warn('Database', string.format('Slow update: %dms - %s', queryTime, query))
        end
        
        if cb then cb(result) end
    end)
end

-- Fetch single row
function CMCore.Database.FetchSingle(query, parameters, cb)
    MySQL.single(query, parameters, function(result)
        if cb then cb(result) end
    end)
end

-- Fetch all rows
function CMCore.Database.FetchAll(query, parameters, cb)
    MySQL.query(query, parameters, function(result)
        if cb then cb(result) end
    end)
end

-- Load player from database
function CMCore.Database.LoadPlayer(identifier)
    local result = MySQL.single.await('SELECT * FROM players WHERE license = ?', {identifier})
    
    if result then
        -- Parse JSON fields
        result.money = json.decode(result.money) or Config.Player.StartingMoney
        result.job = json.decode(result.job) or { name = 'unemployed', label = 'Civilian', grade = 0 }
        result.gang = json.decode(result.gang) or { name = 'none', label = 'No Gang', grade = 0 }
        result.position = json.decode(result.position) or { x = 0, y = 0, z = 0 }
        result.metadata = json.decode(result.metadata) or {}
        
        CMCore.Logger.Info('Database', string.format('Loaded player: %s (%s)', result.name, result.citizenid))
        return result
    else
        -- Create new player
        local citizenid = CMCore.Player.CreateCitizenId()
        
        MySQL.insert('INSERT INTO players (citizenid, license, name, money, job, gang, position, metadata) VALUES (?, ?, ?, ?, ?, ?, ?, ?)', {
            citizenid,
            identifier,
            'New Player',
            json.encode(Config.Player.StartingMoney),
            json.encode({ name = 'unemployed', label = 'Civilian', grade = 0 }),
            json.encode({ name = 'none', label = 'No Gang', grade = 0 }),
            json.encode({ x = 0, y = 0, z = 0 }),
            json.encode({})
        })
        
        CMCore.Logger.Info('Database', string.format('Created new player: %s', citizenid))
        
        return {
            citizenid = citizenid,
            license = identifier,
            name = 'New Player',
            money = Config.Player.StartingMoney,
            job = { name = 'unemployed', label = 'Civilian', grade = 0 },
            gang = { name = 'none', label = 'No Gang', grade = 0 },
            position = { x = 0, y = 0, z = 0 },
            metadata = {}
        }
    end
end

-- Save player to database
function CMCore.Database.SavePlayer(source, playerData)
    MySQL.update('UPDATE players SET name = ?, money = ?, job = ?, gang = ?, position = ?, metadata = ? WHERE citizenid = ?', {
        playerData.name,
        json.encode(playerData.money),
        json.encode(playerData.job),
        json.encode(playerData.gang),
        json.encode(playerData.position),
        json.encode(playerData.metadata),
        playerData.citizenid
    }, function(affectedRows)
        if affectedRows > 0 then
            CMCore.Logger.Info('Database', string.format('Saved player: %s (%s)', playerData.name, playerData.citizenid))
        end
    end)
end

-- Batch save (for auto-save)
function CMCore.Database.BatchSave(players)
    local queries = {}
    
    for _, playerData in pairs(players) do
        table.insert(queries, {
            query = 'UPDATE players SET name = ?, money = ?, job = ?, gang = ?, position = ?, metadata = ? WHERE citizenid = ?',
            values = {
                playerData.name,
                json.encode(playerData.money),
                json.encode(playerData.job),
                json.encode(playerData.gang),
                json.encode(playerData.position),
                json.encode(playerData.metadata),
                playerData.citizenid
            }
        })
    end
    
    MySQL.transaction(queries, function(success)
        if success then
            CMCore.Logger.Success('Database', string.format('Batch saved %d players', #queries))
        else
            CMCore.Logger.Error('Database', 'Batch save failed')
        end
    end)
end