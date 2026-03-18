-- server/items/items.lua
-- Unified usable item registration

local Items = {}

function Items.Init(Bridge)
    -- Initialize the sub-table so Bridge.Items.CreateUseable exists
    Bridge.Items = {}

    -- [[ REGISTER USEABLE ITEM ]]
    function Bridge.Items.CreateUseable(itemName, cb)
        -- Safety check: ensure the inventory module is ready
        if Bridge.Inventory and Bridge.Inventory.CreateUseableItem then
            -- Use the bridge's unified debug tool instead of a local one
            Bridge.Utils.Debug(("Registering usable item: ^2%s^7"):format(itemName))
            Bridge.Inventory.CreateUseableItem(itemName, cb)
        else
            Bridge.Utils.Debug(("^1[ITEMS ERROR]^7 Cannot register '%s' - Inventory module not initialized."):format(itemName))
        end
    end

    -- Shortcut alias for easier typing
    Bridge.CreateUseableItem = Bridge.Items.CreateUseable

    -- Register the tablet explicitly here
    Bridge.CreateUseableItem("contract_tablet", function(source, item)
        TriggerClientEvent('viking_contracts:client:useTablet', source)
    end)
end

return Items