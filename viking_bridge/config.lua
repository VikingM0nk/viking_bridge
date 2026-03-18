-- config.lua
-- Global configuration for Viking Bridge

local Config = {}

-- [[ SYSTEM CORE ]]
-- Set to true to see detailed initialization and logic logs in console
Config.Debug = true

-- [[ MISSION DEFAULTS ]]
-- Global settings for how missions handle entity management
Config.Mission = {
    AutoCleanup = true,      -- Automatically delete peds/vehicles when mission ends
    CleanupRadius = 150.0,   -- Distance in meters to check for "abandoned" assets
    RespawnDelay = 5000      -- Time in ms before a failed mission can be restarted
}

-- [[ PREFERENCE OVERRIDES ]]
-- Use these to force a specific system if detection fails
Config.ForceFramework = false -- Set to 'qb', 'esx', or 'qbox' to bypass detection
Config.ForceInventory = false -- Set to 'ox', 'qb', 'codem', etc.
Config.ForceBanking   = false -- Set to 'renewed', 'okok', etc.

-- [[ UI SETTINGS ]]
-- Default styling for notifications and progress bars
Config.UI = {
    NotifyPosition = 'top-right',
    ProgressColor = '#cfb53b' -- Viking Gold hex code
}

return Config