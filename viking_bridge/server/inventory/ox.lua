-- server/inventory/ox.lua
-- OX Inventory adapter

local OX = {}

function OX.Init(Bridge)
    local ox = exports.ox_inventory

    -- [[ CHECK ITEM ]]
    function Bridge.Inventory.HasItem(src, item, amount)
        local count = ox:Search(src, 'count', item) or 0
        return count >= (amount or 1)
    end

    -- [[ ADD ITEM ]]
    function Bridge.Inventory.AddItem(src, item, amount, metadata)
        local count = amount or 1
        local success = ox:AddItem(src, item, count, metadata)
        Bridge.Utils.Debug(("OX: Added %sx %s to %s (Success: %s)"):format(count, item, src, success ~= nil))
        return success ~= nil
    end

    -- [[ REMOVE ITEM ]]
    function Bridge.Inventory.RemoveItem(src, item, amount)
        local count = amount or 1
        local success = ox:RemoveItem(src, item, count)
        Bridge.Utils.Debug(("OX: Removed %sx %s from %s (Success: %s)"):format(count, item, src, success ~= nil))
        return success ~= nil
    end

    -- [[ GET ITEM WORTH ]]
    function Bridge.Inventory.GetItemWorth(src, itemName)
        -- Get all slots containing the specific item
        local items = ox:GetSlots(src, { name = itemName })
        local totalWorth = 0
        if not items then return 0 end

        for _, item in pairs(items) do
            if item.metadata then
                -- OX metadata is standard; we check 'worth' or 'value'
                totalWorth = totalWorth + (item.metadata.worth or item.metadata.value or 0)
            end
        end
        return totalWorth
    end

    -- [[ REMOVE BY WORTH ]]
    function Bridge.Inventory.RemoveByWorth(src, itemName, amountNeeded)
        local items = ox:GetSlots(src, { name = itemName })
        local remaining = amountNeeded
        if not items then return false end

        for _, item in pairs(items) do
            local itemWorth = (item.metadata and (item.metadata.worth or item.metadata.value)) or 0
            
            if itemWorth > 0 then
                if itemWorth <= remaining then
                    remaining = remaining - itemWorth
                    -- Remove the item from its specific slot to be precise
                    ox:RemoveItem(src, itemName, item.count, nil, item.slot)
                else
                    -- Give change logic
                    local change = itemWorth - remaining
                    remaining = 0
                    ox:RemoveItem(src, itemName, 1, nil, item.slot)
                    
                    -- OX handles metadata natively in AddItem
                    Bridge.Inventory.AddItem(src, itemName, 1, { worth = change })
                end
            end
            if remaining <= 0 then break end
        end
        return remaining <= 0
    end

    -- [[ USABLE ITEM ]]
    function Bridge.Inventory.CreateUseableItem(itemName, cb)
        ox:registerUsableItem(itemName, function(data)
            cb(data.source, data)
        end)
        Bridge.Utils.Debug("OX: Registered usable item: ^2" .. itemName .. "^7")
    end
end

return OX