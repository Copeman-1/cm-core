CMCore.Shared = CMCore.Shared or {}

-- ════════════════════════════════════════════════════════════
-- STRING UTILITIES
-- ════════════════════════════════════════════════════════════

-- Trim whitespace from string
function CMCore.Shared.Trim(value)
    if not value then return nil end
    return (string.gsub(value, '^%s*(.-)%s*$', '%1'))
end

-- Split string by delimiter
function CMCore.Shared.Split(str, delimiter)
    local result = {}
    local from = 1
    local delim_from, delim_to = string.find(str, delimiter, from)
    
    while delim_from do
        table.insert(result, string.sub(str, from, delim_from - 1))
        from = delim_to + 1
        delim_from, delim_to = string.find(str, delimiter, from)
    end
    
    table.insert(result, string.sub(str, from))
    return result
end

-- Capitalize first letter
function CMCore.Shared.Capitalize(str)
    return str:gsub("^%l", string.upper)
end

-- Capitalize each word
function CMCore.Shared.CapitalizeWords(str)
    return str:gsub("(%a)([%w_']*)", function(first, rest)
        return first:upper() .. rest:lower()
    end)
end

-- Check if string starts with
function CMCore.Shared.StartsWith(str, start)
    return str:sub(1, #start) == start
end

-- Check if string ends with
function CMCore.Shared.EndsWith(str, ending)
    return ending == "" or str:sub(-#ending) == ending
end

-- Generate random string
function CMCore.Shared.RandomStr(length)
    local charset = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = ""
    
    math.randomseed(GetGameTimer())
    
    for i = 1, length do
        local rand = math.random(1, #charset)
        result = result .. string.sub(charset, rand, rand)
    end
    
    return result
end

-- Generate random string (uppercase only)
function CMCore.Shared.RandomStrUpper(length)
    local charset = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local result = ""
    
    math.randomseed(GetGameTimer())
    
    for i = 1, length do
        local rand = math.random(1, #charset)
        result = result .. string.sub(charset, rand, rand)
    end
    
    return result
end

-- Generate random integer
function CMCore.Shared.RandomInt(length)
    math.randomseed(GetGameTimer())
    
    if length > 9 then length = 9 end
    
    local min = 10 ^ (length - 1)
    local max = (10 ^ length) - 1
    
    return math.random(min, max)
end

-- ════════════════════════════════════════════════════════════
-- NUMBER UTILITIES
-- ════════════════════════════════════════════════════════════

-- Round number
function CMCore.Shared.Round(value, numDecimalPlaces)
    if not numDecimalPlaces then return math.floor(value + 0.5) end
    local power = 10 ^ numDecimalPlaces
    return math.floor((value * power) + 0.5) / power
end

-- Format number with commas
function CMCore.Shared.FormatNumber(num)
    local formatted = tostring(num)
    local k
    
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    
    return formatted
end

-- Format money with symbol
function CMCore.Shared.FormatMoney(amount, symbol)
    symbol = symbol or '$'
    return symbol .. CMCore.Shared.FormatNumber(amount)
end

-- Clamp number between min and max
function CMCore.Shared.Clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

-- Linear interpolation
function CMCore.Shared.Lerp(a, b, t)
    return a + (b - a) * t
end

-- Map value from one range to another
function CMCore.Shared.Map(value, inMin, inMax, outMin, outMax)
    return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin
end

-- ════════════════════════════════════════════════════════════
-- TABLE UTILITIES
-- ════════════════════════════════════════════════════════════

-- Get table size
function CMCore.Shared.TableSize(tbl)
    local count = 0
    for _ in pairs(tbl) do count = count + 1 end
    return count
end

-- Check if table has value
function CMCore.Shared.HasValue(tbl, value)
    for _, v in pairs(tbl) do
        if v == value then return true end
    end
    return false
end

-- Check if table has key
function CMCore.Shared.HasKey(tbl, key)
    return tbl[key] ~= nil
end

-- Get key by value
function CMCore.Shared.GetKeyByValue(tbl, value)
    for k, v in pairs(tbl) do
        if v == value then return k end
    end
    return nil
end

-- Deep copy table
function CMCore.Shared.DeepCopy(obj, seen)
    if type(obj) ~= 'table' then return obj end
    if seen and seen[obj] then return seen[obj] end
    
    local s = seen or {}
    local res = setmetatable({}, getmetatable(obj))
    s[obj] = res
    
    for k, v in pairs(obj) do
        res[CMCore.Shared.DeepCopy(k, s)] = CMCore.Shared.DeepCopy(v, s)
    end
    
    return res
end

-- Merge tables
function CMCore.Shared.MergeTables(t1, t2)
    for k, v in pairs(t2) do
        if type(v) == "table" and type(t1[k]) == "table" then
            CMCore.Shared.MergeTables(t1[k], v)
        else
            t1[k] = v
        end
    end
    return t1
end

-- Reverse table
function CMCore.Shared.ReverseTable(tbl)
    local reversed = {}
    local count = #tbl
    for i = count, 1, -1 do
        table.insert(reversed, tbl[i])
    end
    return reversed
end

-- Shuffle table
function CMCore.Shared.ShuffleTable(tbl)
    local shuffled = CMCore.Shared.DeepCopy(tbl)
    for i = #shuffled, 2, -1 do
        local j = math.random(i)
        shuffled[i], shuffled[j] = shuffled[j], shuffled[i]
    end
    return shuffled
end

-- Filter table
function CMCore.Shared.FilterTable(tbl, callback)
    local filtered = {}
    for k, v in pairs(tbl) do
        if callback(v, k) then
            filtered[k] = v
        end
    end
    return filtered
end

-- Map table
function CMCore.Shared.MapTable(tbl, callback)
    local mapped = {}
    for k, v in pairs(tbl) do
        mapped[k] = callback(v, k)
    end
    return mapped
end

-- ════════════════════════════════════════════════════════════
-- VECTOR & MATH UTILITIES
-- ════════════════════════════════════════════════════════════

-- Get distance between two points
function CMCore.Shared.GetDistance(pos1, pos2)
    if not pos1 or not pos2 then return 0 end
    
    local x1, y1, z1 = pos1.x or pos1[1], pos1.y or pos1[2], pos1.z or pos1[3]
    local x2, y2, z2 = pos2.x or pos2[1], pos2.y or pos2[2], pos2.z or pos2[3]
    
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2 + (z2 - z1) ^ 2)
end

-- Get 2D distance (ignore Z)
function CMCore.Shared.GetDistance2D(pos1, pos2)
    if not pos1 or not pos2 then return 0 end
    
    local x1, y1 = pos1.x or pos1[1], pos1.y or pos1[2]
    local x2, y2 = pos2.x or pos2[1], pos2.y or pos2[2]
    
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

-- Check if point is in sphere
function CMCore.Shared.IsPointInSphere(point, center, radius)
    return CMCore.Shared.GetDistance(point, center) <= radius
end

-- Check if point is in box
function CMCore.Shared.IsPointInBox(point, boxMin, boxMax)
    local x, y, z = point.x or point[1], point.y or point[2], point.z or point[3]
    local minX, minY, minZ = boxMin.x or boxMin[1], boxMin.y or boxMin[2], boxMin.z or boxMin[3]
    local maxX, maxY, maxZ = boxMax.x or boxMax[1], boxMax.y or boxMax[2], boxMax.z or boxMax[3]
    
    return x >= minX and x <= maxX and
           y >= minY and y <= maxY and
           z >= minZ and z <= maxZ
end

-- ════════════════════════════════════════════════════════════
-- TIME UTILITIES
-- ════════════════════════════════════════════════════════════

-- Format seconds to readable time
function CMCore.Shared.FormatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    
    if hours > 0 then
        return string.format("%02d:%02d:%02d", hours, minutes, secs)
    else
        return string.format("%02d:%02d", minutes, secs)
    end
end

-- Format seconds to human readable
function CMCore.Shared.FormatTimeString(seconds)
    local days = math.floor(seconds / 86400)
    local hours = math.floor((seconds % 86400) / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    
    local parts = {}
    
    if days > 0 then table.insert(parts, days .. " day" .. (days > 1 and "s" or "")) end
    if hours > 0 then table.insert(parts, hours .. " hour" .. (hours > 1 and "s" or "")) end
    if minutes > 0 then table.insert(parts, minutes .. " minute" .. (minutes > 1 and "s" or "")) end
    if secs > 0 then table.insert(parts, secs .. " second" .. (secs > 1 and "s" or "")) end
    
    return table.concat(parts, ", ")
end

-- Get current timestamp
function CMCore.Shared.GetTimestamp()
    return os.time()
end

-- Get formatted date
function CMCore.Shared.GetFormattedDate(timestamp, format)
    timestamp = timestamp or os.time()
    format = format or "%Y-%m-%d %H:%M:%S"
    return os.date(format, timestamp)
end

-- ════════════════════════════════════════════════════════════
-- IMAGE UTILITIES
-- ════════════════════════════════════════════════════════════

-- Get image path for item
function CMCore.Shared.GetItemImage(item)
    if not item then return Config.Images.DefaultItem end
    local imagePath = Config.Images.Items .. item .. '.png'
    return imagePath
end

-- Get image path for vehicle
function CMCore.Shared.GetVehicleImage(vehicle)
    if not vehicle then return Config.Images.DefaultVehicle end
    local imagePath = Config.Images.Vehicles .. vehicle .. '.png'
    return imagePath
end

-- Get image path for job
function CMCore.Shared.GetJobImage(job)
    if not job then return Config.Images.DefaultJob end
    local imagePath = Config.Images.Jobs .. job .. '.png'
    return imagePath
end

-- Get image path for gang
function CMCore.Shared.GetGangImage(gang)
    if not gang then return Config.Images.DefaultGang end
    local imagePath = Config.Images.Gangs .. gang .. '.png'
    return imagePath
end

-- Get image path for weapon
function CMCore.Shared.GetWeaponImage(weapon)
    if not weapon then return Config.Images.DefaultItem end
    local imagePath = Config.Images.Weapons .. weapon .. '.png'
    return imagePath
end

-- Get image path for clothing
function CMCore.Shared.GetClothingImage(clothing)
    if not clothing then return Config.Images.DefaultItem end
    local imagePath = Config.Images.Clothing .. clothing .. '.png'
    return imagePath
end

-- Get image with fallback
function CMCore.Shared.GetImageWithFallback(imagePath, fallback)
    return imagePath or fallback or Config.Images.DefaultItem
end

-- Get full image URL from filename
function CMCore.Shared.GetImageURL(category, filename)
    if not category or not filename then return Config.Images.DefaultItem end
    
    local basePath = Config.Images[CMCore.Shared.Capitalize(category)]
    if not basePath then return Config.Images.DefaultItem end
    
    -- Add extension if not present
    if not CMCore.Shared.EndsWith(filename, '.png') and 
       not CMCore.Shared.EndsWith(filename, '.jpg') and
       not CMCore.Shared.EndsWith(filename, '.webp') then
        filename = filename .. '.png'
    end
    
    return basePath .. filename
end

-- ════════════════════════════════════════════════════════════
-- VALIDATION UTILITIES
-- ════════════════════════════════════════════════════════════

-- Check if value is number
function CMCore.Shared.IsNumber(value)
    return type(value) == 'number'
end

-- Check if value is string
function CMCore.Shared.IsString(value)
    return type(value) == 'string'
end

-- Check if value is table
function CMCore.Shared.IsTable(value)
    return type(value) == 'table'
end

-- Check if value is boolean
function CMCore.Shared.IsBoolean(value)
    return type(value) == 'boolean'
end

-- Check if value is function
function CMCore.Shared.IsFunction(value)
    return type(value) == 'function'
end

-- Check if string is empty
function CMCore.Shared.IsEmpty(str)
    return str == nil or str == ''
end

-- Check if value is nil or empty
function CMCore.Shared.IsNilOrEmpty(value)
    return value == nil or value == '' or (type(value) == 'table' and CMCore.Shared.TableSize(value) == 0)
end

-- ════════════════════════════════════════════════════════════
-- COLOR UTILITIES
-- ════════════════════════════════════════════════════════════

-- RGB to Hex
function CMCore.Shared.RGBToHex(r, g, b)
    return string.format("#%02X%02X%02X", r, g, b)
end

-- Hex to RGB
function CMCore.Shared.HexToRGB(hex)
    hex = hex:gsub("#", "")
    return tonumber("0x" .. hex:sub(1, 2)), tonumber("0x" .. hex:sub(3, 4)), tonumber("0x" .. hex:sub(5, 6))
end

-- ════════════════════════════════════════════════════════════
-- SHARED DATA
-- ════════════════════════════════════════════════════════════

-- Jobs
CMCore.Shared.Jobs = Config.Jobs or {
    ['unemployed'] = {
        label = 'Civilian',
        defaultDuty = true,
        grades = {
            [0] = { name = 'Freelancer', payment = 10 }
        }
    },
    ['police'] = {
        label = 'Police',
        defaultDuty = false,
        grades = {
            [0] = { name = 'Cadet', payment = 50 },
            [1] = { name = 'Officer', payment = 75 },
            [2] = { name = 'Sergeant', payment = 100 },
            [3] = { name = 'Lieutenant', payment = 125 },
            [4] = { name = 'Chief', payment = 150 }
        }
    },
    ['ambulance'] = {
        label = 'EMS',
        defaultDuty = false,
        grades = {
            [0] = { name = 'Trainee', payment = 50 },
            [1] = { name = 'Paramedic', payment = 75 },
            [2] = { name = 'Doctor', payment = 100 },
            [3] = { name = 'Surgeon', payment = 125 },
            [4] = { name = 'Chief', payment = 150 }
        }
    },
    ['mechanic'] = {
        label = 'Mechanic',
        defaultDuty = false,
        grades = {
            [0] = { name = 'Trainee', payment = 50 },
            [1] = { name = 'Mechanic', payment = 75 },
            [2] = { name = 'Manager', payment = 100 },
            [3] = { name = 'Owner', payment = 125 }
        }
    }
}

-- Gangs
CMCore.Shared.Gangs = Config.Gangs or {
    ['none'] = {
        label = 'No Gang',
        grades = {
            [0] = { name = 'No Affiliation' }
        }
    },
    ['ballas'] = {
        label = 'Ballas',
        grades = {
            [0] = { name = 'Recruit', payment = 25 },
            [1] = { name = 'Member', payment = 50 },
            [2] = { name = 'Leader', payment = 75 }
        }
    },
    ['vagos'] = {
        label = 'Vagos',
        grades = {
            [0] = { name = 'Recruit', payment = 25 },
            [1] = { name = 'Member', payment = 50 },
            [2] = { name = 'Leader', payment = 75 }
        }
    }
}

-- Items (loaded from JSON if available)
CMCore.Shared.Items = {}

-- Load items from JSON if available
CreateThread(function()
    local itemsFile = LoadResourceFile(GetCurrentResourceName(), 'config/items.json')
    if itemsFile then
        CMCore.Shared.Items = json.decode(itemsFile) or {}
    end
end)

-- Vehicles (loaded from JSON if available)
CMCore.Shared.Vehicles = {}

-- Load vehicles from JSON if available
CreateThread(function()
    local vehiclesFile = LoadResourceFile(GetCurrentResourceName(), 'config/vehicles.json')
    if vehiclesFile then
        CMCore.Shared.Vehicles = json.decode(vehiclesFile) or {}
    end
end)

-- Weapons (loaded from JSON if available)
CMCore.Shared.Weapons = {}

-- Load weapons from JSON if available
CreateThread(function()
    local weaponsFile = LoadResourceFile(GetCurrentResourceName(), 'config/weapons.json')
    if weaponsFile then
        CMCore.Shared.Weapons = json.decode(weaponsFile) or {}
    end
end)

-- ════════════════════════════════════════════════════════════
-- COMPATIBILITY ALIASES
-- ════════════════════════════════════════════════════════════

-- QBCore compatibility
CMCore.Shared.SplitStr = CMCore.Shared.Split