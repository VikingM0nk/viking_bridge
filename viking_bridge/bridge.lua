-- bridge.lua (Shared)
Bridge = {}
Bridge.Framework = { Type = "standalone", Object = nil }
Bridge.Utils = {}
Bridge.Config = { Debug = true } -- Default for visibility
Bridge.State = {}

-- [[ THE PROTECTED LOADERS ]]
-- These prevent the Client from ever looking for Server files and vice versa.
function LoadServerModule(path)
    if not IsDuplicityVersion() then return nil end 
    local success, module = pcall(require, path)
    if success and module then
        if module.Init then module.Init(Bridge) end
        return module
    end
    return nil
end

function LoadClientModule(path)
    if IsDuplicityVersion() then return nil end 
    local success, module = pcall(require, path)
    if success and module then
        if module.Init then module.Init(Bridge) end
        return module
    end
    return nil
end

-- [[ IMMEDIATE FRAMEWORK DETECTION ]]
-- Runs instantly on both sides so Bridge.Framework.Type is never nil
local function DetectFramework()
    local system = "standalone"
    
    if GetResourceState("qbx_core") == "started" then system = "qbox"
    elseif GetResourceState("qb-core") == "started" then system = "qb"
    elseif GetResourceState("es_extended") == "started" then system = "esx"
    end

    Bridge.Framework.Type = system
    
    -- Load the specific adapter immediately
    if IsDuplicityVersion() then
        LoadServerModule(('server/framework/%s'):format(system))
    else
        LoadClientModule(('client/framework/%s'):format(system))
    end
end

DetectFramework()
print(("[VIKING-BRIDGE] Shared Core initialized. Framework: %s"):format(Bridge.Framework.Type))

exports('GetBridge', function()
    return Bridge
end)