-- server/banking/esx.lua
-- ESX banking adapter

local ESX = {}

function ESX.Init(Bridge)
    -- Attach functions to the existing Bridge.Banking table
    
    -- [[ ADD MONEY ]]
    function Bridge.Banking.AddMoney(src, account, amount)
        -- Using Bridge.GetPlayer ensures we use your universal identity logic
        local xPlayer = Bridge.GetPlayer(src)
        if xPlayer then
            -- ESX standardizes 'money' for cash and 'bank' for bank
            local acc = (account == "cash") and "money" or "bank"
            xPlayer.addAccountMoney(acc, amount)
            Bridge.Utils.Debug(("ESX: Added %s to %s (%s)"):format(amount, acc, src))
            return true
        end
        return false
    end

    -- [[ REMOVE MONEY ]]
    function Bridge.Banking.RemoveMoney(src, account, amount)
        local xPlayer = Bridge.GetPlayer(src)
        if xPlayer then
            local acc = (account == "cash") and "money" or "bank"
            xPlayer.removeAccountMoney(acc, amount)
            Bridge.Utils.Debug(("ESX: Removed %s from %s (%s)"):format(amount, acc, src))
            return true
        end
        return false
    end

    -- [[ GET BALANCE ]]
    function Bridge.Banking.GetBalance(src, account)
        local xPlayer = Bridge.GetPlayer(src)
        if xPlayer then
            local acc = (account == "cash") and "money" or "bank"
            local accountData = xPlayer.getAccount(acc)
            return accountData and accountData.money or 0
        end
        return 0
    end
end

return ESX