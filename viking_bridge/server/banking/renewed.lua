-- server/banking/renewed.lua
-- Renewed Banking adapter

local Renewed = {}

function Renewed.Init(Bridge)
    local bank = exports['Renewed-Banking']
    
    -- [[ ACCOUNT MAPPING ]]
    -- Normalizes "money" to "cash" to ensure compatibility with Renewed's core logic
    local function getAcc(name)
        return (name == "money") and "cash" or name
    end

    -- [[ ADD MONEY ]]
    function Bridge.Banking.AddMoney(src, account, amount, reason)
        local acc = getAcc(account)
        local success = bank:AddMoney(src, acc, amount, reason or "Viking Reward")
        Bridge.Utils.Debug(("Renewed: Added %s to %s for %s"):format(amount, acc, src))
        return success
    end

    -- [[ REMOVE MONEY ]]
    function Bridge.Banking.RemoveMoney(src, account, amount, reason)
        local acc = getAcc(account)
        -- Renewed-Banking returns true/false based on if the player has enough funds
        local success = bank:RemoveMoney(src, acc, amount, reason or "Viking Deduction")
        Bridge.Utils.Debug(("Renewed: Removed %s from %s for %s (Success: %s)"):format(amount, acc, src, success))
        return success
    end

    -- [[ GET BALANCE ]]
    function Bridge.Banking.GetBalance(src, account)
        local acc = getAcc(account)
        -- Renewed uses GetAccountMoney or GetMoney depending on the version, 
        -- GetBalance is the most common universal wrapper for them.
        return bank:GetAccountMoney(src, acc) or 0
    end
end

return Renewed