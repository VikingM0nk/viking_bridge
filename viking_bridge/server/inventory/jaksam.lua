-- server/inventory/jaksam.lua
-- Jaksam Inventory adapter

local JAK = {}

function JAK.Init(Bridge)
    local inv = exports["jaksam_inventory"]

    -- [[ CHECK ITEM ]]
    function Bridge.Inventory.HasItem(src, item, amount)
        local count = inv:getItemCount(src, item) or 0
        return count >= (amount or 1)
    end

    -- [[ ADD ITEM ]]
    function Bridge.Inventory.AddItem(src, item, amount, metadata)
        local count = amount or 1
        local success = inv:addItem(src, item, count, metadata)
        Bridge.Utils.Debug(("Jaksam: Added %sx %s to %s (Success: %s)"):format(count, item, src, success ~= nil))
        return success ~= nil
    end

    -- [[ REMOVE ITEM ]]
    function Bridge.Inventory.RemoveItem(src, item, amount)
        local count = amount or 1
        local success = inv:removeItem(src, item, count)
        Bridge.Utils.Debug(("Jaksam: Removed %sx %s from %s (Success: %s)"):format(count, item, src, success ~= nil))
        return success ~= nil
    end

    -- [[ GET ITEM WORTH ]]
    function Bridge.Inventory.GetItemWorth(src, itemName)
        local playerInv = inv:getUserInventory(src)
        local totalWorth = 0
        if not playerInv then return 0 end

        for _, item in pairs(playerInv) do
            if item.name == itemName then
                -- Jaksam usually stores the passed metadata table directly on the item object
                local metadata = item.metadata or item.itemData or {}
                totalWorth = totalWorth + (metadata.worth or metadata.value or 0)
            end
        end
        return totalWorth
    end

    -- [[ REMOVE BY WORTH ]]
    function Bridge.Inventory.RemoveByWorth(src, itemName, amountNeeded)
        local playerInv = inv:getUserInventory(src)
        local remaining = amountNeeded
        if not playerInv then return false end

        for _, item in pairs(playerInv) do
            if item.name == itemName then
                local metadata = item.metadata or item.itemData or {}
                local itemWorth = metadata.worth or metadata.value or 0

                if itemWorth > 0 then
                    if itemWorth <= remaining then
                        remaining = remaining - itemWorth
                        -- Jaksam removeItem usually handles by name/amount, 
                        -- but for specific metadata items, we target the amount in that slot if possible
                        inv:removeItem(src, itemName, item.count or 1)
                    else
                        local change = itemWorth - remaining
                        remaining = 0
                        inv:removeItem(src, itemName, 1) 
                        
                        -- Give back the change
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
            Bridge.Utils.Debug(("^3[INV-WARNING]^7 Could not register usable item '%s' for Jaksam - No framework support."):format(itemName))
        end
    end
end

return JAK