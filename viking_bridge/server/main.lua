-- server/main.lua
Bridge = Bridge or {}
Bridge.State = Bridge.State or {}
Bridge.Utils = Bridge.Utils or {}

-- [[ PRE-INITIALIZE CRITICAL TABLES ]]
-- This prevents "attempt to index nil" if scripts call the bridge during the loading loop
Bridge.Vehicles = {} 
Bridge.Garages = {}
Bridge.Inventory = {}
Bridge.Callbacks = {}

Bridge.IsReady = false 

-- ============================================================
-- GLOBAL MODULE LOADER
-- ============================================================
function LoadServerModule(modulePath)
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
        print(("^1[Bridge Loader Error]^7 Runtime error while loading %s: %s"):format(fileName, result))
        return nil
    end
end

-- ============================================================
-- BRIDGE INITIALIZATION
-- ============================================================
local function InitializeBridge()
    -- 1. LOAD FRAMEWORK DETECTION FIRST
    local fwModule = LoadServerModule('server/framework/init')
    if fwModule and fwModule.Init then
        fwModule.Init(Bridge)
    end

    -- 2. MAP FRAMEWORK CORE OBJECTS
    local framework = Bridge.Framework and Bridge.Framework.Type
    
    if framework == 'qb' or framework == 'qbox' then
        local Core = exports['qb-core']:GetCoreObject()
        Bridge.GetPlayer = function(src) return Core.Functions.GetPlayer(src) end
    elseif framework == 'esx' then
        local Core = exports['es_extended']:getSharedObject()
        Bridge.GetPlayer = function(src) return Core.GetPlayerFromId(src) end
    else
        print("^3[Bridge Warning]^7 No framework detected during server init.")
    end

    -- 3. LOAD ALL MODULES (Including Vehicles & Garages)
    local modules = {
        'server/inventory/init',
        'server/banking/banking',
        'server/jobs/jobs',
        'server/metadata/metadata',
        'server/permissions/permissions',
        'server/missions/missions',
        'server/items/items',
        'server/reputation/reputation',
        'server/identity/identity', 
        'server/callbacks/callbacks',
        'server/vehicles/vehicles', -- Added Vehicle Module
        'server/keys/keys',     -- Added Keys Module
        'server/garages/garages',     -- Added Garage Module
    }

    for _, modulePath in ipairs(modules) do
        local moduleTable = LoadServerModule(modulePath)
        
        if moduleTable then
            if type(moduleTable.Init) == "function" then
                moduleTable.Init(Bridge)
                if Bridge.Debug then print("^2[Bridge Debug]^7 Initialized: " .. modulePath) end
            else
                print("^3[Bridge Debug]^7 Loaded " .. modulePath .. " but no .Init() found.")
            end
        else
            print("^1[Bridge Error]^7 Failed to initialize module: " .. modulePath)
        end
    end

    Bridge.IsReady = true 
    print("^2[VIKING BRIDGE]^7 Server-side fortification complete. Modules synchronized.")
end

-- ============================================================
-- STARTUP
-- ============================================================
CreateThread(function()
    InitializeBridge()
end)

-- ============================================================
-- GLOBAL EXPORTS
-- ============================================================

exports('GetBridge', function()
    return Bridge
end)

-- Convenience Export for the Blackmarket's SaveVehicle call
exports('SaveVehicle', function(src, data)
    if Bridge.Garages and Bridge.Garages.SaveVehicle then
        Bridge.Garages.SaveVehicle(src, data)
    else
        print("^1[Bridge Error]^7 SaveVehicle export called but Garage module not loaded.")
    end
end)

exports('CreateCallback', function(name, cb)
    local attempts = 0
    while (not Bridge.Callbacks or not Bridge.Callbacks.Create) and attempts < 50 do
        attempts = attempts + 1
        Wait(100)
    end

    if Bridge.Callbacks and Bridge.Callbacks.Create then
        Bridge.Callbacks.Create(name, cb)
    else
        print("^1[Bridge Error]^7 Callback module failed for: " .. name)
    end
end)

exports('GetCharacterIdentifier', function(src)
    if not Bridge.Identity or not Bridge.Identity.GetCharacterIdentifier then return nil end
    return Bridge.Identity.GetCharacterIdentifier(src)
end)

exports('Notify', function(src, msg, type)
    if Bridge.Notify then
        Bridge.Notify(src, msg, type)
    else
        TriggerClientEvent('QBCore:Notify', src, msg, type) -- Final fallback
    end
end)