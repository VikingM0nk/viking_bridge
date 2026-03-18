-- server/banking/detect.lua
-- Detects and initializes the active banking system

local Detect = {}

function Detect.Init(Bridge)
    -- 1. Determine the System
    local system = "standalone"
    
    if GetResourceState("tgg-banking") == "started" then system = "tgg"
    elseif GetResourceState("Renewed-Banking") == "started" then system = "renewed"
    elseif GetResourceState("okokBanking") == "started" then system = "okok"
    elseif GetResourceState("pepe-banking") == "started" then system = "pepe"
    elseif GetResourceState("qb-banking") == "started" then system = "qb"
    end

    -- Allow Config override if the user wants to force a specific one
    if Bridge.Config.ForceBanking then system = Bridge.Config.ForceBanking end

    Bridge.Banking = { Type = system }
    
    -- 2. Attach the Universal Functions
    -- These are placeholders; you'll expand them in your banking/provider files
    function Bridge.Banking.AddMoney(source, amount, reason)
        Bridge.Utils.Debug(("Adding $%s to %s (Reason: %s)"):format(amount, source, reason or "None"))
        -- Logic for each system goes here
        return true
    end

    function Bridge.Banking.GetBalance(source)
        -- Logic to return bank balance
        return 0
    end

    Bridge.Utils.Debug("Banking initialized: ^2" .. system .. "^7")
end

return Detect