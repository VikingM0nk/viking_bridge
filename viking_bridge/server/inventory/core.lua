-- server/inventory/core.lua
-- Core Inventory adapter

local CORE = {}

function CORE.Init(Bridge)
    local inv = exports["core_inventory"]

    -- [[ CHECK ITEM ]]
    function Bridge.Inventory.HasItem(src, item, amount)
        return inv:hasItem(src, item, amount or 1)
    end

    -- [[ ADD ITEM ]]
    function Bridge.Inventory.AddItem(src, item, amount, metadata)
        local count = amount or 1
        local success = inv:addItem(src, item, count, metadata)
        Bridge.Utils.Debug(("Core: Added %sx %s to %s (Success: %s)"):format(count, item, src, success))
        return success
    end

    -- [[ REMOVE ITEM ]]
    function Bridge.Inventory.RemoveItem(src, item, amount)
        local count = amount or 1
        local success = inv:removeItem(src, item, count)
        Bridge.Utils.Debug(("Core: Removed %sx %s from %s (Success: %s)"):format(count, item, src, success))
        return success
    end

    -- [[ GET ITEM WORTH ]]
    function Bridge.Inventory.GetItemWorth(src, itemName)
        local playerInv = inv:getInventory(src)
        local totalWorth = 0
        if not playerInv then return 0 end

        for _, item in pairs(playerInv) do
            if item.name == itemName then
                -- Core Inventory usually stores metadata in 'metadata' or 'info'
                local meta = item.metadata or item.info or {}
                totalWorth = totalWorth + (meta.worth or meta.value or 0)
            end
        end
        return totalWorth
    end

    -- [[ REMOVE BY WORTH ]]
    function Bridge.Inventory.RemoveByWorth(src, itemName, amountNeeded)
        local playerInv = inv:getInventory(src)
        local remaining = amountNeeded
        if not playerInv then return false end

        for _, item in pairs(playerInv) do
            if item.name == itemName then
                local meta = item.metadata or item.info or {}
                local itemWorth = meta.worth or meta.value or 0

                if itemWorth > 0 then
                    if itemWorth <= remaining then
                        remaining = remaining - itemWorth
                        -- Core removeItem handles by name/amount
                        inv:removeItem(src, itemName, item.count or 1)
                    else
                        -- Handle Change
                        local change = itemWorth - remaining
                        remaining = 0
                        inv:removeItem(src, itemName, 1)
                        
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
            Bridge.Utils.Debug(("^3[INV-WARNING]^7 Could not register usable item '%s' for Core Inventory - No framework detected."):format(itemName))
        end
    end
end

return CORE