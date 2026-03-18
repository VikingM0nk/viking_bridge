-- server/framework/qbox.lua
-- Adapter for Qbox framework

local QBOX = {}

function QBOX.Init(Bridge)
    -- Qbox typically uses the qbx-core resource
    Bridge.Core = exports['qbx-core']

    -- [[ GLOBAL SHORTCUT ]]
    -- Essential for linking Banking and Inventory modules
    function Bridge.GetPlayer(src)
        -- Qbox provides GetPlayer directly via exports or through the functions table
        return Bridge.Core:GetPlayer(src)
    end

    -- [[ PLAYER DATA ]]
    function Bridge.Framework.GetPlayerData(src)
        local p = Bridge.GetPlayer(src)
        return p and p.PlayerData or nil
    end

    -- [[ IDENTITY ]]
    function Bridge.Framework.GetIdentifier(src)
        local p = Bridge.GetPlayer(src)
        return p and p.PlayerData.citizenid
    end

    -- [[ MONEY ]]
    function Bridge.Framework.AddMoney(src, account, amount, reason)
        local p = Bridge.GetPlayer(src)
        if p then 
            local acc = (account == "money") and "cash" or account
            p.Functions.AddMoney(acc, amount, reason or "Viking Bridge Transaction") 
            return true
        end
        return false
    end

    function Bridge.Framework.GetMoney(src, account)
        local p = Bridge.GetPlayer(src)
        if p and p.PlayerData and p.PlayerData.money then
            local acc = (account == "money") and "cash" or account
            return p.PlayerData.money[acc] or 0
        end
        return 0
    end

    -- [[ JOB & DUTY ]]
    function Bridge.Framework.GetJob(src)
        local p = Bridge.GetPlayer(src)
        return p and p.PlayerData.job or {name = "unemployed", label = "Unemployed", grade = {level = 0}}
    end

    function Bridge.Framework.IsOnDuty(src)
        local p = Bridge.GetPlayer(src)
        -- Qbox inherits the QB onduty boolean but often manages it via state bags
        return p and p.PlayerData.job.onduty or false
    end

    -- [[ PERMISSIONS ]]
    function Bridge.Framework.HasPermission(src, perm)
        -- Qbox uses the same permission naming as QB for compatibility
        return Bridge.Core:HasPermission(src, perm)
    end

    Bridge.Utils.Debug("Qbox Framework Adapter Loaded and Linked.")
end

return QBOX