-- server/inventory/standalone.lua
-- Standalone fallback inventory

local Standalone = {}

function Standalone.Init(Bridge)
    -- [[ CHECK ITEM ]]
    function Bridge.Inventory.HasItem(src, item, amount)
        Bridge.Utils.Debug(("^3[INV-STANDALONE]^7 Check: Player %s for %sx %s"):format(src, amount or 1, item))
        return false
    end

    -- [[ ADD ITEM ]]
    function Bridge.Inventory.AddItem(src, item, amount, metadata)
        Bridge.Utils.Debug(("^3[INV-STANDALONE]^7 Add: %sx %s to Player %s"):format(amount or 1, item, src))
        if metadata then
            Bridge.Utils.Debug(("^3[INV-STANDALONE]^7 Metadata: %s"):format(json.encode(metadata)))
        end
        return true 
    end

    -- [[ REMOVE ITEM ]]
    function Bridge.Inventory.RemoveItem(src, item, amount)
        Bridge.Utils.Debug(("^3[INV-STANDALONE]^7 Remove: %sx %s from Player %s"):format(amount or 1, item, src))
        return true
    end

    -- [[ GET ITEM WORTH ]]
    function Bridge.Inventory.GetItemWorth(src, itemName)
        -- Hardcoded return for testing purposes
        Bridge.Utils.Debug(("^3[INV-STANDALONE]^7 GetItemWorth called for '%s'. Returning 0 (Mock)."):format(itemName))
        return 0
    end

    -- [[ REMOVE BY WORTH ]]
    function Bridge.Inventory.RemoveByWorth(src, itemName, amountNeeded)
        Bridge.Utils.Debug(("^3[INV-STANDALONE]^7 RemoveByWorth: %s needed for '%s'."):format(amountNeeded, itemName))
        -- In standalone, we pretend the transaction succeeded
        return true
    end

    -- [[ USABLE ITEM ]]
    function Bridge.Inventory.CreateUseableItem(itemName, cb)
        Bridge.Utils.Debug(("^3[INV-STANDALONE]^7 Registered usable item: %s"):format(itemName))
    end
end

return Standalone