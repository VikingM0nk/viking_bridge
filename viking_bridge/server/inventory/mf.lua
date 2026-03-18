-- server/inventory/mf.lua
-- MF Inventory adapter

local MF = {}

function MF.Init(Bridge)
    local inv = exports["mf-inventory"]

    -- [[ CHECK ITEM ]]
    function Bridge.Inventory.HasItem(src, item, amount)
        local inventory = inv:getInventory(src)
        if not inventory then return false end
        
        local targetAmount = amount or 1
        local currentCount = 0

        for _, v in pairs(inventory) do
            if v.name == item then
                currentCount = currentCount + (v.count or 0)
            end
        end
        
        return currentCount >= targetAmount
    end

    -- [[ ADD ITEM ]]
    function Bridge.Inventory.AddItem(src, item, amount, metadata)
        local count = amount or 1
        local success = inv:addItem(src, item, count, metadata)
        Bridge.Utils.Debug(("MF: Added %sx %s to %s (Success: %s)"):format(count, item, src, success ~= nil))
        return success ~= nil
    end

    -- [[ REMOVE ITEM ]]
    function Bridge.Inventory.RemoveItem(src, item, amount)
        local count = amount or 1
        local success = inv:removeItem(src, item, count)
        Bridge.Utils.Debug(("MF: Removed %sx %s from %s (Success: %s)"):format(count, item, src, success ~= nil))
        return success ~= nil
    end

    -- [[ GET ITEM WORTH ]]
    function Bridge.Inventory.GetItemWorth(src, itemName)
        local inventory = inv:getInventory(src)
        local totalWorth = 0
        if not inventory then return 0 end

        for _, item in pairs(inventory) do
            if item.name == itemName then
                -- MF typically uses 'metadata' but we check 'info' for cross-framework items
                local meta = item.metadata or item.info or {}
                totalWorth = totalWorth + (meta.worth or meta.value or 0)
            end
        end
        return totalWorth
    end

    -- [[ REMOVE BY WORTH ]]
    function Bridge.Inventory.RemoveByWorth(src, itemName, amountNeeded)
        local inventory = inv:getInventory(src)
        local remaining = amountNeeded
        if not inventory then return false end

        for _, item in pairs(inventory) do
            if item.name == itemName then
                local meta = item.metadata or item.info or {}
                local itemWorth = meta.worth or meta.value or 0

                if itemWorth > 0 then
                    if itemWorth <= remaining then
                        remaining = remaining - itemWorth
                        -- We remove the specific item based on its count in that stack
                        inv:removeItem(src, itemName, item.count or 1)
                    else
                        local change = itemWorth - remaining
                        remaining = 0
                        inv:removeItem(src, itemName, 1)
                        
                        -- Return the change as a new bill with updated metadata
                        Bridge.Inventory.AddItem(src, itemName, 1, { worth = change })
                    end
                end
            end
            if remaining <= 0 then break end
        end
        return remaining <= 0
    end

    -- [[ USABLE ITEM FALLBACK ]]
    function Bridge.Inventory.CreateUseableItem(itemName, cb)
        local framework = Bridge.Framework.Type
        if framework == "qb" or framework == "qbox" then
            Bridge.Core.Functions.CreateUseableItem(itemName, function(source, item)
                cb(source, item)
            end)
        elseif framework == "esx" then
            Bridge.Core.RegisterUsableItem(itemName, function(source)
                cb(source)
            end)
        else
            Bridge.Utils.Debug(("^3[INV-WARNING]^7 Could not register usable item '%s' for MF - No framework support."):format(itemName))
        end
    end
end

return MF