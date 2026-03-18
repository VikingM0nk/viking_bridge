-- server/inventory/qb.lua
local QB = {}

function QB.Init(Bridge)
    local QBCore = exports['qb-core']:GetCoreObject()

    -- [[ CHECK ITEM ]]
    function Bridge.Inventory.HasItem(src, item, amount)
        local Player = QBCore.Functions.GetPlayer(src)
        if not Player or not Player.PlayerData.items then return false end
        
        local target = amount or 1
        local count = 0

        for _, itm in pairs(Player.PlayerData.items) do
            if itm and itm.name == item then
                count = count + itm.amount
            end
        end
        return count >= target
    end

    -- [[ ADD ITEM ]]
    function Bridge.Inventory.AddItem(src, item, amount, metadata)
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            local count = amount or 1
            local success = Player.Functions.AddItem(item, count, false, metadata)
            if success then
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "add")
            end
            return success
        end
        return false
    end

    -- [[ REMOVE ITEM ]]
    function Bridge.Inventory.RemoveItem(src, item, amount)
        local Player = QBCore.Functions.GetPlayer(src)
        if Player then
            local count = amount or 1
            local success = Player.Functions.RemoveItem(item, count)
            if success then
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "remove")
            end
            return success
        end
        return false
    end

    -- [[ GET ITEM WORTH ]]
    function Bridge.Inventory.GetItemWorth(src, itemName)
        local Player = QBCore.Functions.GetPlayer(src)
        local totalWorth = 0
        if not Player or not Player.PlayerData.items then return 0 end

        for _, item in pairs(Player.PlayerData.items) do
            if item and item.name == itemName then
                -- QB metadata is stored in 'info'
                totalWorth = totalWorth + (item.info and item.info.worth or 0)
            end
        end
        return totalWorth
    end

    -- [[ REMOVE BY WORTH ]]
    function Bridge.Inventory.RemoveByWorth(src, itemName, amountNeeded)
        local Player = QBCore.Functions.GetPlayer(src)
        if not Player or not Player.PlayerData.items then return false end

        local remaining = amountNeeded
        -- We loop through a copy of the items to avoid index issues during removal
        for slot, item in pairs(Player.PlayerData.items) do
            if item and item.name == itemName then
                local itemWorth = (item.info and item.info.worth) or 0
                
                if itemWorth > 0 then
                    if itemWorth <= remaining then
                        remaining = remaining - itemWorth
                        Player.Functions.RemoveItem(itemName, item.amount, slot)
                    else
                        -- Handle the change
                        local change = itemWorth - remaining
                        remaining = 0
                        -- Remove 1 bill from this slot
                        Player.Functions.RemoveItem(itemName, 1, slot)
                        
                        -- Add a new bill with the leftover value
                        Bridge.Inventory.AddItem(src, itemName, 1, { worth = change })
                    end
                end
            end
            if remaining <= 0 then break end
        end

        if remaining <= 0 then
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[itemName], "remove")
            return true
        end
        return false
    end

    -- [[ USABLE ITEM ]]
    function Bridge.Inventory.CreateUseableItem(itemName, cb)
        QBCore.Functions.CreateUseableItem(itemName, function(source, item)
            cb(source, item)
        end)
        Bridge.Utils.Debug("QB Registered usable item: " .. itemName)
    end
end

return QB