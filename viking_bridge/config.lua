-- config.lua
-- Global configuration for Viking Bridge
Config = Config or {}

-- [[ FRAMEWORK AUTO-DETECTION ]]
-- This snippet runs immediately when the resource loads, 
-- ensuring 'Framework' is never nil for your modules.
if not Config.ForceFramework then
    if GetResourceState('es_extended') == 'started' then
        Framework = 'esx'
    elseif GetResourceState('qbox') == 'started' then
        Framework = 'qbox'
    elseif GetResourceState('qb-core') == 'started' then
        Framework = 'qb'
    else
        Framework = 'standalone'
    end
else
    Framework = Config.ForceFramework
end

-- [[ SYSTEM CORE ]]
Config.Debug = true

-- [[ MISSION DEFAULTS ]]
Config.Mission = {
    AutoCleanup = true,
    CleanupRadius = 150.0,
    RespawnDelay = 5000
}

-- [[ PREFERENCE OVERRIDES ]]
-- Set to 'qb', 'esx', or 'qbox' to bypass detection if needed
Config.ForceFramework = false 
Config.ForceInventory = false 
Config.ForceBanking   = false 

-- [[ UI SETTINGS ]]
Config.UI = {
    NotifyPosition = 'top-right',
    ProgressColor = '#cfb53b' -- Viking Gold hex code
}

-- Ensure the global is available for other resources
return Config