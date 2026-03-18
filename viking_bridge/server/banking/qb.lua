-- server/banking/qb.lua
-- QB / Qbox banking adapter

local QB = {}

function QB.Init(Bridge)
    -- [[ ACCOUNT MAPPING ]]
    -- QB/Qbox uses 'cash', 'bank', 'crypto'. We map 'money' to 'cash' for safety.
    local function getAcc(name)
        return (name == "money") and "cash" or name
    end

    -- [[ ADD MONEY ]]
    function Bridge.Banking.AddMoney(src, account, amount, reason)
        local p = Bridge.GetPlayer(src)
        if p then
            local acc = getAcc(account)
            p.Functions.AddMoney(acc, amount, reason or "Viking Reward")
            Bridge.Utils.Debug(("QB: Added %s to %s for %s"):format(amount, acc, src))
            return true
        end
        return false
    end

    -- [[ REMOVE MONEY ]]
    function Bridge.Banking.RemoveMoney(src, account, amount, reason)
        local p = Bridge.GetPlayer(src)
        if p then
            local acc = getAcc(account)
            local success = p.Functions.RemoveMoney(acc, amount, reason or "Viking Deduction")
            Bridge.Utils.Debug(("QB: Removed %s from %s for %s (Success: %s)"):format(amount, acc, src, success))
            return success
        end
        return false
    end

    -- [[ GET BALANCE ]]
    function Bridge.Banking.GetBalance(src, account)
        local p = Bridge.GetPlayer(src)
        if p and p.PlayerData and p.PlayerData.money then
            local acc = getAcc(account)
            return p.PlayerData.money[acc] or 0
        end
        return 0
    end
end

return QB