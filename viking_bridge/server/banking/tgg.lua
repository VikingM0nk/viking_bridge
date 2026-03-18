-- server/banking/tgg.lua
-- TGG Banking adapter

local TGG = {}

function TGG.Init(Bridge)
    local bank = exports['tgg-banking']

    -- [[ ACCOUNT MAPPING ]]
    -- Maps "money" to "cash" to match TGG's expected string parameters
    local function getAcc(name)
        return (name == "money") and "cash" or name
    end

    -- [[ ADD MONEY ]]
    function Bridge.Banking.AddMoney(src, account, amount, reason)
        local acc = getAcc(account)
        -- TGG: AddMoney(source, amount, account, reason)
        local success = bank:AddMoney(src, amount, acc, reason or "Viking Reward")
        Bridge.Utils.Debug(("TGG: Added %s to %s for %s"):format(amount, acc, src))
        return success
    end

    -- [[ REMOVE MONEY ]]
    function Bridge.Banking.RemoveMoney(src, account, amount, reason)
        local acc = getAcc(account)
        -- TGG: RemoveMoney(source, amount, account, reason)
        local success = bank:RemoveMoney(src, amount, acc, reason or "Viking Deduction")
        Bridge.Utils.Debug(("TGG: Removed %s from %s for %s (Success: %s)"):format(amount, acc, src, success))
        return success
    end

    -- [[ GET BALANCE ]]
    function Bridge.Banking.GetBalance(src, account)
        local acc = getAcc(account)
        -- Returns the balance for the specified account
        return bank:GetMoney(src, acc) or 0
    end
end

return TGG