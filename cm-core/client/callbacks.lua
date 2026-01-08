CMCore.Callbacks = {}
CMCore.Callbacks.ServerCallbacks = {}
CMCore.Callbacks.ClientCallbacks = {}

local callbackId = 0

-- Register a client callback
function CMCore.Callbacks.Register(name, cb)
    CMCore.Callbacks.ClientCallbacks[name] = cb
end

-- Trigger a server callback from client
function CMCore.Callbacks.TriggerServer(name, cb, ...)
    callbackId = callbackId + 1
    local currentId = callbackId
    
    CMCore.Callbacks.ServerCallbacks[currentId] = cb
    
    TriggerServerEvent('CMCore:Server:TriggerCallback', name, currentId, ...)
    
    -- Timeout after 30 seconds
    SetTimeout(30000, function()
        if CMCore.Callbacks.ServerCallbacks[currentId] then
            print(string.format('^3[CM-Core] ^7Callback ^5%s^7 timed out^7', name))
            CMCore.Callbacks.ServerCallbacks[currentId] = nil
        end
    end)
end

-- Handle server callback request
RegisterNetEvent('CMCore:Client:TriggerCallback', function(name, requestId, ...)
    if CMCore.Callbacks.ClientCallbacks[name] then
        CMCore.Callbacks.ClientCallbacks[name](function(...)
            TriggerServerEvent('CMCore:Server:TriggerCallbackResponse', requestId, ...)
        end, ...)
    else
        print(string.format('^1[CM-Core] ^7Client callback ^5%s^7 does not exist^7', name))
    end
end)

-- Handle callback response from server
RegisterNetEvent('CMCore:Client:TriggerCallbackResponse', function(requestId, ...)
    if CMCore.Callbacks.ServerCallbacks[requestId] then
        CMCore.Callbacks.ServerCallbacks[requestId](...)
        CMCore.Callbacks.ServerCallbacks[requestId] = nil
    end
end)