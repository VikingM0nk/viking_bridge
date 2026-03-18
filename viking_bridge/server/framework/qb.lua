-- server/framework/qb.lua
-- Adapter for QB-Core framework

local QB = {}

function QB.Init(Bridge)
    -- Initialize the Core Object
    Bridge.Core = exports['qb-core']:GetCoreObject()

    -- [[ GLOBAL SHORTCUT ]]
    -- Maps the universal Bridge.GetPlayer to QB's specific function
    function Bridge.GetPlayer(src)
        return Bridge.Core.Functions.GetPlayer(src)
    end

    -- [[ PLAYER DATA ]]
    function Bridge.Framework.GetPlayerData(src)
        local p = Bridge.GetPlayer(src)
        return p and p.PlayerData or nil
    end

    -- [[ IDENTITY ]]
    function Bridge.Framework.GetIdentifier(src)
        local p = Bridge.GetPlayer(src)
        -- QB-Core identifies players primarily via CitizenID
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
        -- QB-Core tracks duty as a boolean within the job object
        return p and p.PlayerData.job.onduty or false
    end

    -- [[ PERMISSIONS ]]
    function Bridge.Framework.HasPermission(src, perm)
        -- Uses QB-Core's built-in permission/ace check
        return Bridge.Core.Functions.HasPermission(src, perm)
    end

    Bridge.Utils.Debug("QB-Core Framework Adapter Loaded and Linked.")
end

return QB