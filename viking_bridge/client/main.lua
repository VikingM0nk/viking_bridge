-- client/main.lua
Bridge = Bridge or {}
Bridge.State = Bridge.State or {}
Bridge.Utils = Bridge.Utils or {}
Bridge.Keys = Bridge.Keys or {} -- Added Keys table initialization
Bridge.IsReady = false 

-- ============================================================
-- GLOBAL CLIENT MODULE LOADER
-- ============================================================
function LoadClientModule(modulePath)
    local fileName = modulePath .. '.lua'
    local fileContent = LoadResourceFile(GetCurrentResourceName(), fileName)
    
    if not fileContent then
        print(("^1[Bridge Loader Error]^7 Could not read file: %s"):format(fileName))
        return nil
    end

    local chunk, err = load(fileContent, "@@" .. fileName)
    if not chunk then
        print(("^1[Bridge Loader Error]^7 Syntax error in %s: %s"):format(fileName, err))
        return nil
    end

    local success, result = pcall(chunk)
    if success then
        return result
    else
        print(("^1[Bridge Loader Error]^7 Runtime error in %s: %s"):format(fileName, result))
        return nil
    end
end

-- ============================================================
-- MODULE INITIALIZATION LOGIC
-- ============================================================
local function FortifyModule(modulePath)
    local moduleTable = LoadClientModule(modulePath)
    
    if moduleTable then
        if type(moduleTable.Init) == "function" then
            moduleTable.Init(Bridge)
            print("^2[Bridge Debug]^7 Fortified: " .. modulePath)
            return true
        else
            print("^3[Bridge Debug]^7 Loaded " .. modulePath .. " (No .Init found)")
            return true
        end
    end
    print("^1[Bridge Error]^7 Failed to fortify module: " .. modulePath)
    return false
end

local function InitializeBridge()
    -- 1. Initialize Framework First
    FortifyModule('client/framework/init')

    -- 2. Load Client-Side Modules
    local modules = {
        'client/callbacks/callbacks',
        'client/blips/blips',
        'client/effects/effects',
        'client/keys/keys',
        'client/mission/mission',
        'client/spawn/spawn',
        'client/target/target',
        'client/ui/notify',
        'client/ui/progress'
    }

    for _, modulePath in ipairs(modules) do
        FortifyModule(modulePath)
    end

    Bridge.IsReady = true
    print("^2[VIKING BRIDGE]^7 Client-side sensors active.")
    print("^2[VIKING BRIDGE]^7 Fortification Complete.")
    
    TriggerEvent('viking_bridge:client:Ready', Bridge)
end

-- ============================================================
-- NET EVENTS (The Handshake)
-- ============================================================

-- This listener allows the Server Bridge to trigger the Key Module
RegisterNetEvent('viking_bridge:client:GiveKeys', function(plate, vehicle)
    if Bridge.IsReady and Bridge.Keys and Bridge.Keys.GiveKeys then
        Bridge.Keys.GiveKeys(plate, vehicle)
        Bridge.Utils.Debug("Keys processed for plate: " .. tostring(plate))
    else
        -- Logic if the event arrives before the client is fully initialized
        local attempts = 0
        while not Bridge.IsReady and attempts < 20 do
            Wait(500)
            attempts = attempts + 1
        end
        if Bridge.Keys and Bridge.Keys.GiveKeys then
            Bridge.Keys.GiveKeys(plate, vehicle)
        end
    end
end)

-- ============================================================
-- EXPORTS
-- ============================================================

exports('GetBridge', function()
    return Bridge
end)

exports('TriggerCallback', function(...)
    local attempts = 0
    while (not Bridge.TriggerCallback) and attempts < 50 do 
        Wait(100) 
        attempts = attempts + 1
    end

    if Bridge.TriggerCallback then
        Bridge.TriggerCallback(...)
    end
end)

-- ============================================================
-- STARTUP
-- ============================================================

CreateThread(function()
    InitializeBridge()
end)