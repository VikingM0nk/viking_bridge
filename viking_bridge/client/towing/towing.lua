-- viking_bridge/client/modules/towing.lua

local TowingModule = {}

--- Internal Helper: Robust Framework Detection
-- Checks the global 'Framework' variable set by your bridge's auto-detect loop.
local function GetActiveFramework()
    if Framework then return Framework end
    if Config and Config.Framework then return Config.Framework end
    
    -- Fallback to 'qb' to prevent ESX defaulting on QB/Qbox servers
    return 'qb' 
end

--- Helper: Get Player Data from the detected framework
function TowingModule.GetPlayerData()
    local active = GetActiveFramework()
    
    if active == 'qb' or active == 'qbox' then
        return exports['qb-core']:GetCoreObject().Functions.GetPlayerData()
    elseif active == 'esx' then
        return exports['es_extended']:getSharedObject().GetPlayerData()
    end
    return nil
end

--- Export: Check if player has the correct job
exports('IsTowDriver', function()
    local data = TowingModule.GetPlayerData()
    if not data or not data.job then return false end
    
    -- Returns true if job matches 'tow'
    return data.job.name == 'tow'
end)

--- Export: Show Framework-Specific Notification
exports('Notify', function(msg, type)
    local active = GetActiveFramework()
    
    if active == 'qb' or active == 'qbox' then
        exports['qb-core']:GetCoreObject().Functions.Notify(msg, type)
    elseif active == 'esx' then
        exports['es_extended']:getSharedObject().ShowNotification(msg, type)
    else
        -- Native GTA Fallback
        BeginTextCommandThefeedPost("STRING")
        AddTextComponentString(msg)
        EndTextCommandThefeedPostTicker(false, true)
    end
end)

--- Export: Show Help Notification (Top Left)
exports('ShowHelpNotification', function(msg)
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentScaleform(msg)
    EndTextCommandDisplayHelp(0, false, true, -1)
end)

return TowingModule