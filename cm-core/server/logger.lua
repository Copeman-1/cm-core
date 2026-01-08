CMCore.Logger = {}

local logLevels = {
    INFO = '^5[INFO]^7',
    SUCCESS = '^2[SUCCESS]^7',
    WARN = '^3[WARN]^7',
    ERROR = '^1[ERROR]^7',
    DEBUG = '^6[DEBUG]^7'
}

local logFile = 'cm-core.log'
local maxLogSize = 10485760 -- 10MB

-- Log to console and file
local function log(level, category, message)
    local timestamp = os.date('%Y-%m-%d %H:%M:%S')
    local logMessage = string.format('[%s] [CM-Core] %s [%s] %s', timestamp, logLevels[level], category, message)
    
    print(logMessage)
    
    -- Write to file
    local file = io.open(logFile, 'a')
    if file then
        file:write(logMessage .. '\n')
        file:close()
        
        -- Check file size and rotate if needed
        local fileSize = io.open(logFile, 'r')
        if fileSize then
            local size = fileSize:seek('end')
            fileSize:close()
            
            if size > maxLogSize then
                os.rename(logFile, 'cm-core_' .. os.date('%Y%m%d_%H%M%S') .. '.log')
            end
        end
    end
end

function CMCore.Logger.Info(category, message)
    log('INFO', category, message)
end

function CMCore.Logger.Success(category, message)
    log('SUCCESS', category, message)
end

function CMCore.Logger.Warn(category, message)
    log('WARN', category, message)
end

function CMCore.Logger.Error(category, message)
    log('ERROR', category, message)
end

function CMCore.Logger.Debug(category, message)
    if Config.Core.DebugMode then
        log('DEBUG', category, message)
    end
end

-- Discord webhook logging
function CMCore.Logger.Discord(webhook, title, description, color)
    if not webhook or webhook == '' then return end
    
    local embed = {
        {
            ["title"] = title,
            ["description"] = description,
            ["color"] = color or 3447003,
            ["footer"] = {
                ["text"] = "CM-Core Logger",
            },
            ["timestamp"] = os.date("!%Y-%m-%dT%H:%M:%S")
        }
    }
    
    PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({
        username = "CM-Core",
        embeds = embed
    }), { ['Content-Type'] = 'application/json' })
end