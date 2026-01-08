CMCore.NUI = {}

local nuiCallbacks = {}
local nuiCallbackId = 0

-- Send NUI message
function CMCore.NUI.Send(action, data)
    SendNUIMessage({
        action = action,
        data = data
    })
end

-- Register NUI callback
function CMCore.NUI.RegisterCallback(name, cb)
    nuiCallbacks[name] = cb
end

-- NUI callback handler
RegisterNUICallback('nuiCallback', function(data, cb)
    if nuiCallbacks[data.name] then
        nuiCallbacks[data.name](data.data, cb)
    else
        cb('error')
    end
end)

-- Open NUI frame
function CMCore.NUI.OpenFrame(url)
    CMCore.NUI.Send('openFrame', { url = url })
    SetNuiFocus(true, true)
end

-- Close NUI frame
function CMCore.NUI.CloseFrame()
    CMCore.NUI.Send('closeFrame', {})
    SetNuiFocus(false, false)
end

-- Set NUI focus
function CMCore.NUI.SetFocus(hasFocus, hasCursor)
    SetNuiFocus(hasFocus, hasCursor)
end

-- Example: Simple notification through NUI
function CMCore.NUI.ShowNotification(message, type, duration)
    CMCore.NUI.Send('notification', {
        message = message,
        type = type or 'info',
        duration = duration or 5000
    })
end