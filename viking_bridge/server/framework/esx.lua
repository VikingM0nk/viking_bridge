-- server/framework/esx.lua
-- Adapter for ESX framework

local ESX = {}

function ESX.Init(Bridge)
    -- Standardized Shared Object fetch
    if GetResourceState('es_extended') == 'started' then
        Bridge.Core = exports['es_extended']:getSharedObject()
    end

    -- [[ GLOBAL SHORTCUT ]]
    -- This allows Bridge.GetPlayer(src) to work across ALL modules
    function Bridge.GetPlayer(src)
        return Bridge.Core.GetPlayerFromId(src)
    end

    -- [[ PLAYER DATA ]]
    function Bridge.Framework.GetPlayerData(src)
        local xP = Bridge.GetPlayer(src)
        return xP and xP.getPlayerData() or nil
    end

    -- [[ IDENTITY ]]
    function Bridge.Framework.GetIdentifier(src)
        local xP = Bridge.GetPlayer(src)
        return xP and xP.getIdentifier()
    end

    -- [[ MONEY ]]
    function Bridge.Framework.AddMoney(src, account, amount)
        local xP = Bridge.GetPlayer(src)
        if xP then
            local acc = (account == "cash") and "money" or "bank"
            xP.addAccountMoney(acc, amount)
            return true
        end
        return false
    end

    function Bridge.Framework.GetMoney(src, account)
        local xP = Bridge.GetPlayer(src)
        if xP then
            local acc = (account == "cash") and "money" or "bank"
            local accountData = xP.getAccount(acc)
            return accountData and accountData.money or 0
        end
        return 0
    end

    -- [[ JOB & DUTY ]]
    function Bridge.Framework.GetJob(src)
        local xP = Bridge.GetPlayer(src)
        return xP and xP.getJob() or {name = 'unemployed', label = 'Unemployed', grade = 0}
    end

    function Bridge.Framework.IsOnDuty(src)
        local xP = Bridge.GetPlayer(src)
        if not xP then return false end
        local job = xP.getJob()
        -- Checks if "off" is anywhere in the job name (e.g., offpolice, offduty_medic)
        return not string.find(job.name:lower(), "off")
    end

    -- [[ PERMISSIONS ]]
    function Bridge.Framework.HasPermission(src, perm)
        local xP = Bridge.GetPlayer(src)
        if not xP then return false end
        local group = xP.getGroup()
        
        -- Default ESX hierarchy
        if group == "superadmin" or group == "admin" then return true end
        return group == perm
    end

    Bridge.Utils.Debug("ESX Framework Adapter Loaded and Linked.")
end

return ESX