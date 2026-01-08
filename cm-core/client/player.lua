CMCore.Player = {}

-- Get player data
function CMCore.Player.GetData()
    return CMCore.PlayerData
end

-- Get specific player data
function CMCore.Player.Get(key)
    return CMCore.PlayerData[key]
end

-- Get money
function CMCore.Player.GetMoney(moneyType)
    moneyType = moneyType or 'cash'
    return CMCore.PlayerData.money and CMCore.PlayerData.money[moneyType] or 0
end

-- Get job
function CMCore.Player.GetJob()
    return CMCore.PlayerData.job or {}
end

-- Get gang
function CMCore.Player.GetGang()
    return CMCore.PlayerData.gang or {}
end

-- Is player dead
function CMCore.Player.IsDead()
    return IsEntityDead(PlayerPedId())
end

-- Get player coords
function CMCore.Player.GetCoords()
    return GetEntityCoords(PlayerPedId())
end

-- Get player heading
function CMCore.Player.GetHeading()
    return GetEntityHeading(PlayerPedId())
end

-- Is in vehicle
function CMCore.Player.IsInVehicle()
    return IsPedInAnyVehicle(PlayerPedId(), false)
end

-- Get current vehicle
function CMCore.Player.GetVehicle()
    if CMCore.Player.IsInVehicle() then
        return GetVehiclePedIsIn(PlayerPedId(), false)
    end
    return nil
end

-- Is driver
function CMCore.Player.IsDriver()
    local vehicle = CMCore.Player.GetVehicle()
    if vehicle then
        return GetPedInVehicleSeat(vehicle, -1) == PlayerPedId()
    end
    return false
end

-- Teleport
function CMCore.Player.Teleport(coords, heading)
    local ped = PlayerPedId()
    
    if CMCore.Player.IsInVehicle() then
        local vehicle = GetVehiclePedIsIn(ped, false)
        SetEntityCoords(vehicle, coords.x, coords.y, coords.z, false, false, false, false)
        SetEntityHeading(vehicle, heading or 0.0)
    else
        SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
        SetEntityHeading(ped, heading or 0.0)
    end
end

-- Freeze player
function CMCore.Player.Freeze(toggle)
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, toggle)
    
    if toggle then
        SetPlayerInvincible(PlayerId(), true)
    else
        SetPlayerInvincible(PlayerId(), false)
    end
end

-- Set invincible
function CMCore.Player.SetInvincible(toggle)
    SetPlayerInvincible(PlayerId(), toggle)
end

-- Set health
function CMCore.Player.SetHealth(health)
    SetEntityHealth(PlayerPedId(), health)
end

-- Get health
function CMCore.Player.GetHealth()
    return GetEntityHealth(PlayerPedId())
end

-- Set armor
function CMCore.Player.SetArmor(armor)
    SetPedArmour(PlayerPedId(), armor)
end

-- Get armor
function CMCore.Player.GetArmor()
    return GetPedArmour(PlayerPedId())
end

-- Give weapon
function CMCore.Player.GiveWeapon(weapon, ammo)
    GiveWeaponToPed(PlayerPedId(), GetHashKey(weapon), ammo or 250, false, false)
end

-- Remove weapon
function CMCore.Player.RemoveWeapon(weapon)
    RemoveWeaponFromPed(PlayerPedId(), GetHashKey(weapon))
end

-- Remove all weapons
function CMCore.Player.RemoveAllWeapons()
    RemoveAllPedWeapons(PlayerPedId(), true)
end

-- Get current weapon
function CMCore.Player.GetCurrentWeapon()
    local _, weapon = GetCurrentPedWeapon(PlayerPedId(), true)
    return weapon
end

-- Set metadata (synced with server)
function CMCore.Player.SetMetadata(key, value)
    TriggerServerEvent('CMCore:Server:SetMetadata', key, value)
end