-- server/banking/standalone.lua
-- Standalone fallback banking (No-Op)

local Standalone = {}

function Standalone.Init(Bridge)
    -- [[ ADD MONEY ]]
    function Bridge.Banking.AddMoney(src, account, amount, reason)
        Bridge.Utils.Debug(("^3[BANKING-STANDALONE]^7 AddMoney called for Player %s: $%s (Reason: %s). No banking system detected, ignoring."):format(src, amount, reason or "None"))
        return true -- We return true to prevent calling scripts from hanging
    end

    -- [[ REMOVE MONEY ]]
    function Bridge.Banking.RemoveMoney(src, account, amount, reason)
        Bridge.Utils.Debug(("^3[BANKING-STANDALONE]^7 RemoveMoney called for Player %s: $%s. No banking system detected, ignoring."):format(src, amount))
        return true -- We return true so "Buy" actions still succeed in sandbox mode
    end

    -- [[ GET BALANCE ]]
    function Bridge.Banking.GetBalance(src, account)
        Bridge.Utils.Debug(("^3[BANKING-STANDALONE]^7 GetBalance called for Player %s. Returning 0."):format(src))
        return 0
    end

    Bridge.Utils.Debug("Banking initialized in ^3Standalone (No-Op)^7 mode.")
end

return Standalone