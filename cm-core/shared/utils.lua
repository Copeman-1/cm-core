CMCore.Shared = CMCore.Shared or {}

-- Round number
function CMCore.Shared.Round(value, numDecimalPlaces)
    if not numDecimalPlaces then return math.floor(value + 0.5) end
    local power = 10 ^ numDecimalPlaces
    return math.floor((value * power) + 0.5) / power
end

-- Trim string
function CMCore.Shared.Trim(value)
    if not value then return nil end
    return (string.gsub(value, '^%s*(.-)%s*$', '%1'))
end

-- Split string
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

-- Random string
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

-- Random int
function CMCore.Shared.RandomInt(length)
    math.randomseed(GetGameTimer())
    
    if length > 9 then length = 9 end
    
    local min = 10 ^ (length - 1)
    local max = (10 ^ length) - 1
    
    return math.random(min, max)
end

-- Format number
function CMCore.Shared.FormatNumber(num)
    local formatted = tostring(num)
    local k
    
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    
    return formatted
end

-- Format money
function CMCore.Shared.FormatMoney(amount)
    return '$' .. CMCore.Shared.FormatNumber(amount)
end

-- Get distance
function CMCore.Shared.GetDistance(pos1, pos2)
    if not pos1 or not pos2 then return 0 end
    
    local x1, y1, z1 = pos1.x or pos1[1], pos1.y or pos1[2], pos1.z or pos1[3]
    local x2, y2, z2 = pos2.x or pos2[1], pos2.y or pos2[2], pos2.z or pos2[3]
    
    return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2 + (z2 - z1) ^ 2)
end

-- Jobs table (example)
CMCore.Shared.Jobs = {
    unemployed = {
        label = 'Civilian',
        grades = {
            [0] = { name = 'Freelancer', payment = 10 }
        }
    },
    police = {
        label = 'Police',
        grades = {
            [0] = { name = 'Cadet', payment = 50 },
            [1] = { name = 'Officer', payment = 75 },
            [2] = { name = 'Sergeant', payment = 100 },
            [3] = { name = 'Lieutenant', payment = 125 },
            [4] = { name = 'Chief', payment = 150 }
        }
    },
    ambulance = {
        label = 'EMS',
        grades = {
            [0] = { name = 'Trainee', payment = 50 },
            [1] = { name = 'Paramedic', payment = 75 },
            [2] = { name = 'Doctor', payment = 100 },
            [3] = { name = 'Surgeon', payment = 125 },
            [4] = { name = 'Chief', payment = 150 }
        }
    },
    mechanic = {
        label = 'Mechanic',
        grades = {
            [0] = { name = 'Trainee', payment = 50 },
            [1] = { name = 'Mechanic', payment = 75 },
            [2] = { name = 'Manager', payment = 100 },
            [3] = { name = 'Owner', payment = 125 }
        }
    }
}

-- Gangs table (example)
CMCore.Shared.Gangs = {
    none = {
        label = 'No Gang',
        grades = {
            [0] = { name = 'No Affiliation' }
        }
    }
}