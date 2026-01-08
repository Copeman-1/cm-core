CMCore.Locale = {}
CMCore.Locale.Translations = {}
CMCore.Locale.CurrentLocale = Config.Locale or 'en'

-- Load locale
function CMCore.Locale.Load(locale)
    local resourceName = GetCurrentResourceName()
    local localeFile = ('locales/%s.lua'):format(locale)
    local localePath = GetResourcePath(resourceName) .. '/' .. localeFile
    
    if LoadResourceFile(resourceName, localeFile) then
        CMCore.Locale.CurrentLocale = locale
        print(string.format('^2[CM-Core]^7 Loaded locale: ^5%s^7', locale))
        return true
    else
        print(string.format('^1[CM-Core]^7 Failed to load locale: ^5%s^7', locale))
        return false
    end
end

-- Translate
function CMCore.Locale.Translate(key, ...)
    local translation = CMCore.Locale.Translations[CMCore.Locale.CurrentLocale]
    
    if translation and translation[key] then
        return string.format(translation[key], ...)
    end
    
    -- Fallback to English
    if CMCore.Locale.CurrentLocale ~= 'en' and CMCore.Locale.Translations['en'] and CMCore.Locale.Translations['en'][key] then
        return string.format(CMCore.Locale.Translations['en'][key], ...)
    end
    
    return key
end

-- Shorthand
function _(key, ...)
    return CMCore.Locale.Translate(key, ...)
end