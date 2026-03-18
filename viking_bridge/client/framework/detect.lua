-- client/framework/detect.lua
-- Detects and initializes the active framework on the client side

local Detect = {}
local CachedType = nil

-- [[ GET FRAMEWORK TYPE ]]
function Detect.GetType()
    if CachedType then return CachedType end

    if GetResourceState("qbx_core") == "started" then
        CachedType = "qbox"
    elseif GetResourceState("qb-core") == "started" then
        CachedType = "qb"
    elseif GetResourceState("es_extended") == "started" then
        CachedType = "esx"
    else
        CachedType = "standalone"
    end

    return CachedType
end

-- [[ INITIALIZE FRAMEWORK OBJECT ]]
-- Grabs the actual export object (ESX/QBCore) for the bridge to use
function Detect.InitFramework(Bridge)
    local fType = Detect.GetType()
    
    if fType == "qbox" then
        Bridge.Core = exports.qbx_core
    elseif fType == "qb" then
        Bridge.Core = exports['qb-core']:GetCoreObject()
    elseif fType == "esx" then
        Bridge.Core = exports['es_extended']:getSharedObject()
    else
        Bridge.Core = nil
        Bridge.Utils.Debug("^3[DETECT]^7 Running in Standalone mode.")
    end
    
    Bridge.Framework.Type = fType
end

return Detect