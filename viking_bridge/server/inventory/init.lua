-- server/inventory/detect.lua
-- Detects and initializes the active inventory system

local Detect = {}

function Detect.Init(Bridge)
    -- 1. Determine the System
    local system = "standalone"
    
    if GetResourceState("ox_inventory") == "started" then system = "ox"
    elseif GetResourceState("codem-inventory") == "started" then system = "codem"
    elseif GetResourceState("mf-inventory") == "started" then system = "mf"
    elseif GetResourceState("qs-inventory") == "started" then system = "qs" -- Added Quasar support
    elseif GetResourceState("qb-inventory") == "started" or GetResourceState("ps-inventory") == "started" or GetResourceState("lj-inventory") == "started" then 
        system = "qb"
    end

    -- Allow Config override
    if Bridge.Config.ForceInventory then system = Bridge.Config.ForceInventory end

    Bridge.Inventory = { Type = system }
    
    -- 2. Load the specific Adapter File
    local adapterPath = ('server/inventory/%s'):format(system)
    local adapter = LoadServerModule(adapterPath)
    
    if adapter and adapter.Init then
        adapter.Init(Bridge)
        Bridge.Utils.Debug("Inventory initialized: ^2" .. system .. "^7")
    else
       Bridge.Utils.Debug("^1[INVENTORY ERROR]^7 Could not load adapter: " .. adapterPath)
        if not adapter then print("^1[DEBUG]^7 LoadServerModule returned NIL for " .. adapterPath) end
    end
end

return Detect