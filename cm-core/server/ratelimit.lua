CMCore.RateLimit = {}

local rateLimits = {}

function CMCore.RateLimit.Check(source, identifier)
    if not Config.Performance.RateLimitEnabled then return true end
    
    local key = string.format('%s:%s', source, identifier)
    local currentTime = GetGameTimer()
    
    if not rateLimits[key] then
        rateLimits[key] = { count = 1, resetTime = currentTime + 1000 }
        return true
    end
    
    if currentTime > rateLimits[key].resetTime then
        rateLimits[key] = { count = 1, resetTime = currentTime + 1000 }
        return true
    end
    
    rateLimits[key].count = rateLimits[key].count + 1
    
    if rateLimits[key].count > Config.Performance.RateLimitMax then
        CMCore.Logger.Warn('RateLimit', string.format('Player %s exceeded rate limit for %s (%d requests)', 
            source, identifier, rateLimits[key].count))
        
        -- Kick if excessive
        if rateLimits[key].count > Config.Performance.RateLimitMax * 3 then
            DropPlayer(source, 'Rate limit exceeded - possible exploit attempt')
        end
        
        return false
    end
    
    return true
end

-- Cleanup old rate limit data
CreateThread(function()
    while true do
        Wait(60000) -- 1 minute
        
        local currentTime = GetGameTimer()
        local cleaned = 0
        
        for key, data in pairs(rateLimits) do
            if currentTime > data.resetTime + 60000 then
                rateLimits[key] = nil
                cleaned = cleaned + 1
            end
        end
        
        if cleaned > 0 then
            CMCore.Logger.Debug('RateLimit', string.format('Cleaned %d old rate limit entries', cleaned))
        end
    end
end)