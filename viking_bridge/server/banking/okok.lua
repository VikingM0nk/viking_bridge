-- server/banking/okok.lua
-- OkOk Banking adapter

local OKOK = {}

function OKOK.Init(Bridge)
    local bank = exports['okokBanking']
    
    -- [[ INTERNAL MAPPING ]]
    -- Normalizes "money" to "cash" to match OkOk's expected parameters
    local function getAcc(name)
        return (name == "money") and "cash" or name
    end

    -- [[ ADD MONEY ]]
    function Bridge.Banking.AddMoney(src, account, amount)
        local acc = getAcc(account)
        bank:AddMoney(src, acc, amount)
        Bridge.Utils.Debug(("OkOk: Added %s to %s for player %s"):format(amount, acc, src))
        return true
    end

    -- [[ REMOVE MONEY ]]
    function Bridge.Banking.RemoveMoney(src, account, amount)
        local acc = getAcc(account)
        bank:RemoveMoney(src, acc, amount)
        Bridge.Utils.Debug(("OkOk: Removed %s from %s for player %s"):format(amount, acc, src))
        return true
    end

    -- [[ GET BALANCE ]]
    function Bridge.Banking.GetBalance(src, account)
        local acc = getAcc(account)
        -- OkOk returns the balance directly via this export
        return bank:GetAccountMoney(src, acc) or 0
    end
end

return OKOK