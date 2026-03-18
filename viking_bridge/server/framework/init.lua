-- server/framework/detect.lua
local Framework = {}

function Framework.Init(Bridge)
    -- 1. Determine the System
    local system = "standalone"
    
    if GetResourceState("qbx_core") == "started" then 
        system = "qbox"
    elseif GetResourceState("qb-core") == "started" then 
        system = "qb"
    elseif GetResourceState("es_extended") == "started" then 
        system = "esx"
    end

    -- 2. Allow Config override
    if Bridge.Config and Bridge.Config.ForceFramework then 
        system = Bridge.Config.ForceFramework 
    end

    -- 3. Set the Framework Table
    -- We initialize this as a table so adapters can attach data to it later
    Bridge.Framework = { 
        Type = system,
        Object = nil 
    }
    
    -- 4. Load the specific Adapter File
    -- REMOVED: .lua extension (require handles this)
    -- REMOVED: Redundant Init call (LoadServerModule already calls .Init)
    local adapterPath = ('server/framework/%s'):format(system)
    local adapter = LoadServerModule(adapterPath)
    
    if adapter then
        if Bridge.Utils and Bridge.Utils.Debug then
            Bridge.Utils.Debug("Framework successfully fortified: ^2" .. system .. "^7")
        else
            print(("[VIKING-BRIDGE] Framework initialized: %s"):format(system))
        end
    else
        print(("^1[VIKING-ERROR]^7 Could not load adapter: %s"):format(adapterPath))
    end
end

return Framework