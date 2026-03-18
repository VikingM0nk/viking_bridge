-- server/framework/standalone.lua
-- Standalone fallback adapter

local Standalone = {}

function Standalone.Init(Bridge)
    Bridge.Core = nil

    -- [[ GLOBAL SHORTCUT ]]
    function Bridge.GetPlayer(src)
        return nil -- No framework player object exists in standalone
    end

    -- [[ PLAYER DATA ]]
    function Bridge.Framework.GetPlayerData(src)
        return nil
    end

    -- [[ MONEY ]]
    function Bridge.Framework.AddMoney(src, account, amount, reason)
        Bridge.Utils.Debug(("^3[FRAMEWORK-STANDALONE]^7 AddMoney: Player %s received $%s (Reason: %s)"):format(src, amount, reason or "None"))
        return true
    end

    function Bridge.Framework.GetMoney(src, account)
        return 0
    end

    -- [[ JOB & DUTY ]]
    function Bridge.Framework.GetJob(src)
        return { name = "unemployed", label = "Unemployed", grade = 0, level = 0 }
    end

    function Bridge.Framework.IsOnDuty(src)
        -- In standalone, we assume everyone is "on duty" to avoid blocking script logic
        return true
    end

    -- [[ PERMISSIONS ]]
    function Bridge.Framework.HasPermission(src, perm)
        -- Fallback to FiveM's built-in Ace Permissions
        if IsPlayerAceAllowed(src, "admin") then return true end
        if perm then return IsPlayerAceAllowed(src, perm) end
        return false
    end

    -- [[ IDENTITY ]]
    function Bridge.Framework.GetIdentifier(src)
        -- Attempts to find Rockstar License, then Steam, then IP as a last resort
        local identifier = GetPlayerIdentifierByType(src, "license") 
            or GetPlayerIdentifierByType(src, "steam")
            or GetPlayerIdentifierByType(src, "ip")
            
        if identifier then
            -- Strips the prefix (e.g., "license:") for a cleaner ID string
            return identifier:gsub(".-:", "")
        end
        return nil
    end

    Bridge.Utils.Debug("Framework initialized in ^3Standalone^7 mode.")
end

return Standalone