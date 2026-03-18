-- client/framework/init.lua
-- Initializes and standardizes the client-side framework adapter

-- client/framework/init.lua

-- Use your loader instead of require to ensure the pathing is correct
local Detect = LoadClientModule('client/framework/detect')

local Framework = {}

function Framework.Init(Bridge)

    -- 1. Identify and Bind the Core Object
    -- Ensure Detect exists before calling InitFramework
    if Detect and Detect.InitFramework then
        Detect.InitFramework(Bridge)
    else
        print("^1[Bridge Error]^7 Could not find Detect module in framework/init.lua")
        return
    end

    local fw = Bridge.Framework.Type

    -- 2. Standardize Player Data Access
    -- This allows you to call Bridge.Framework.GetPlayerData() anywhere
    function Bridge.Framework.GetPlayerData()
        if fw == "qbox" then
            return exports.qbx_core:GetPlayerData()
        elseif fw == "qb" then
            return Bridge.Core.Functions.GetPlayerData()
        elseif fw == "esx" then
            return Bridge.Core.GetPlayerData()
        end
        return {}
    end

    -- 3. Standardize Job Access
    function Bridge.Framework.GetJob()
        local data = Bridge.Framework.GetPlayerData()
        if fw == "qb" or fw == "qbox" then
            return data.job or {}
        elseif fw == "esx" then
            return data.job or {}
        end
        return { name = "unemployed", label = "Unemployed", grade = 0 }
    end

    -- 4. Standardize Duty Check
    function Bridge.Framework.IsOnDuty()
        local data = Bridge.Framework.GetPlayerData()
        if fw == "qb" or fw == "qbox" then
            return data.job and data.job.onduty
        elseif fw == "esx" then
            -- ESX usually handles duty via job names (e.g., 'offpolice')
            local jobName = data.job and data.job.name or ""
            return not jobName:find("off")
        end
        return true
    end

    Bridge.Utils.Debug("Client Framework Bridge initialized: ^2" .. fw .. "^7")
end

return Framework