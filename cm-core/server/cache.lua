CMCore.Cache = {}

local cache = {}
local cacheTimestamps = {}

function CMCore.Cache.Init()
    CMCore.Logger.Info('Cache', 'Initializing cache system...')
    
    -- Cleanup expired cache every 5 minutes
    CreateThread(function()
        while true do
            Wait(300000) -- 5 minutes
            CMCore.Cache.Cleanup()
        end
    end)
    
    CMCore.Logger.Success('Cache', 'Cache system initialized')
end

-- Set cache value
function CMCore.Cache.Set(key, value, ttl)
    if not Config.Performance.CacheEnabled then return end
    
    ttl = ttl or Config.Performance.CacheTTL
    
    cache[key] = value
    cacheTimestamps[key] = os.time() + ttl
end

-- Get cache value
function CMCore.Cache.Get(key)
    if not Config.Performance.CacheEnabled then return nil end
    
    if cache[key] and cacheTimestamps[key] > os.time() then
        return cache[key]
    end
    
    -- Expired or doesn't exist
    cache[key] = nil
    cacheTimestamps[key] = nil
    return nil
end

-- Delete cache value
function CMCore.Cache.Delete(key)
    cache[key] = nil
    cacheTimestamps[key] = nil
end

-- Clear all cache
function CMCore.Cache.Clear()
    cache = {}
    cacheTimestamps = {}
    CMCore.Logger.Info('Cache', 'Cache cleared')
end

-- Cleanup expired cache
function CMCore.Cache.Cleanup()
    local currentTime = os.time()
    local cleaned = 0
    
    for key, expiry in pairs(cacheTimestamps) do
        if expiry <= currentTime then
            cache[key] = nil
            cacheTimestamps[key] = nil
            cleaned = cleaned + 1
        end
    end
    
    if cleaned > 0 then
        CMCore.Logger.Info('Cache', string.format('Cleaned %d expired cache entries', cleaned))
    end
end

-- Get cache stats
function CMCore.Cache.GetStats()
    local count = 0
    for _ in pairs(cache) do count = count + 1 end
    
    return {
        entries = count,
        enabled = Config.Performance.CacheEnabled
    }
end