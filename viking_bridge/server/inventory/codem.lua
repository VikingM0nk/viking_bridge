-- server/inventory/codem.lua
-- CodeM Inventory adapter

local CODEM = {}

function CODEM.Init(Bridge)
    local inv = exports["codem-inventory"]

    -- [[ CHECK ITEM ]]
    function Bridge.Inventory.HasItem(src, item, amount)
        local count = inv:GetItemCount(src, item) or 0
        return count >= (amount or 1)
    end

    -- [[ ADD ITEM ]]
    function Bridge.Inventory.AddItem(src, item, amount, metadata)
        local count = amount or 1
        local success = inv:AddItem(src, item, count, nil, metadata)
        Bridge.Utils.Debug(("CodeM: Added %sx %s to %s (Success: %s)"):format(count, item, src, success))
        return success
    end

    -- [[ REMOVE ITEM ]]
    function Bridge.Inventory.RemoveItem(src, item, amount)
        local count = amount or 1
        local success = inv:RemoveItem(src, item, count)
        Bridge.Utils.Debug(("CodeM: Removed %sx %s from %s (Success: %s)"):format(count, item, src, success))
        return success
    end

    -- [[ GET ITEM WORTH ]]
    -- Sums the 'worth' metadata for a specific item (e.g., markedbills)
    function Bridge.Inventory.GetItemWorth(src, itemName)
        local playerInv = inv:GetPlayerInventory(src)
        local totalWorth = 0
        if not playerInv then return 0 end

        for _, item in pairs(playerInv) do
            if item.name == itemName and item.info then
                totalWorth = totalWorth + (item.info.worth or 0)
            end
        end
        return totalWorth
    end

    -- [[ REMOVE BY WORTH ]]
    -- Removes items based on monetary value and gives "change" back
    function Bridge.Inventory.RemoveByWorth(src, itemName, amountNeeded)
        local playerInv = inv:GetPlayerInventory(src)
        local remaining = amountNeeded
        if not playerInv then return false end

        for _, item in pairs(playerInv) do
            if item.name == itemName and item.info then
                local itemWorth = item.info.worth or 0
                
                if itemWorth > 0 then
                    if itemWorth <= remaining then
                        -- Take the whole stack/item
                        remaining = remaining - itemWorth
                        inv:RemoveItem(src, itemName, item.amount, item.slot)
                    else
                        -- This item is worth more than we need; give change back
                        local change = itemWorth - remaining
                        remaining = 0
                        inv:RemoveItem(src, itemName, 1, item.slot) -- Remove the 1 bill we are "breaking"
                        
                        -- Give back the "broken" bill with the new value
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
        if Bridge.Framework.Type == "qb" or Bridge.Framework.Type == "qbox" then
            Bridge.Core.Functions.CreateUseableItem(itemName, function(source, item)
                cb(source, item)
            end)
        elseif Bridge.Framework.Type == "esx" then
            Bridge.Core.RegisterUsableItem(itemName, function(source)
                cb(source)
            end)
        else
            Bridge.Utils.Debug(("^3[INV-WARNING]^7 Could not register usable item '%s' - No framework support."):format(itemName))
        end
    end
end

return CODEM