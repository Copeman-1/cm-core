CMCore.Callbacks = {}
CMCore.Callbacks.ServerCallbacks = {}
CMCore.Callbacks.ClientCallbacks = {}

local callbackId = 0

-- Register a server callback
function CMCore.Callbacks.Register(name, cb)
    CMCore.Callbacks.ServerCallbacks[name] = cb
end

-- Trigger a client callback from server
function CMCore.Callbacks.TriggerClient(name, source, cb, ...)
    callbackId = callbackId + 1
    local currentId = callbackId
    
    CMCore.Callbacks.ClientCallbacks[currentId] = cb
    
    TriggerClientEvent('CMCore:Client:TriggerCallback', source, name, currentId, ...)
    
    -- Timeout after 30 seconds
    SetTimeout(30000, function()
        if CMCore.Callbacks.ClientCallbacks[currentId] then
            CMCore.Logger.Warn('Callbacks', string.format('Callback %s timed out for player %s', name, source))
            CMCore.Callbacks.ClientCallbacks[currentId] = nil
        end
    end)
end

-- Handle client callback response
RegisterNetEvent('CMCore:Server:TriggerCallback', function(name, requestId, ...)
    local source = source
    
    -- Rate limit check
    if not CMCore.RateLimit.Check(source, 'callback:' .. name) then
        CMCore.Logger.Warn('RateLimit', string.format('Player %s exceeded callback rate limit for %s', source, name))
        return
    end
    
    if CMCore.Callbacks.ServerCallbacks[name] then
        CMCore.Callbacks.ServerCallbacks[name](source, function(...)
            TriggerClientEvent('CMCore:Client:TriggerCallbackResponse', source, requestId, ...)
        end, ...)
    else
        CMCore.Logger.Error('Callbacks', string.format('Server callback %s does not exist', name))
    end
end)

-- Handle callback response from client
RegisterNetEvent('CMCore:Server:TriggerCallbackResponse', function(requestId, ...)
    if CMCore.Callbacks.ClientCallbacks[requestId] then
        CMCore.Callbacks.ClientCallbacks[requestId](...)
        CMCore.Callbacks.ClientCallbacks[requestId] = nil
    end
end)