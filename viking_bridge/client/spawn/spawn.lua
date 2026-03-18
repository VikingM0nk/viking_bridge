-- client/spawn/spawn.lua
-- Ped and object spawning utilities for Viking Bridge

local Spawn = {}

function Spawn.Init(Bridge)
    -- Initialize sub-tables
    Bridge.Missions = Bridge.Missions or {}
    Bridge.Spawn = Bridge.Spawn or {}

    -- [[ EXPOSED: LOAD MODEL ]]
    -- We make this global within the Bridge so other scripts can call it
    function Bridge.Spawn.LoadModel(model)
        local hash = type(model) == "string" and GetHashKey(model) or model
        if not IsModelInCdimage(hash) then return false end
        
        RequestModel(hash)
        local timeout = 1000 -- ~10 seconds
        while not HasModelLoaded(hash) and timeout > 0 do
            Wait(10)
            timeout = timeout - 1
        end
        return HasModelLoaded(hash)
    end

    -- [[ SPAWN PED ]]
    function Bridge.Missions.SpawnPed(model, coords, heading, isNetwork)
        local hash = type(model) == "string" and GetHashKey(model) or model
        -- Use the newly exposed global function internally
        if not Bridge.Spawn.LoadModel(hash) then 
            Bridge.Utils.Debug("^1[SPAWN ERROR]^7 Model failed to load: " .. tostring(model))
            return nil 
        end

        local ped = CreatePed(4, hash, coords.x, coords.y, coords.z, heading or 0.0, isNetwork ~= false, false)
        
        SetEntityAsMissionEntity(ped, true, true)
        SetBlockingOfNonTemporaryEvents(ped, true) 
        SetModelAsNoLongerNeeded(hash)

        if Bridge.Missions.RegisterEntity then
            Bridge.Missions.RegisterEntity(ped, "ped")
        end

        return ped
    end

    -- [[ SPAWN OBJECT ]]
    function Bridge.Missions.SpawnObject(model, coords, isNetwork)
        local hash = type(model) == "string" and GetHashKey(model) or model
        if not Bridge.Spawn.LoadModel(hash) then 
            Bridge.Utils.Debug("^1[SPAWN ERROR]^7 Object failed to load: " .. tostring(model))
            return nil 
        end

        local obj = CreateObject(hash, coords.x, coords.y, coords.z, isNetwork ~= false, false, false)
        SetEntityAsMissionEntity(obj, true, true)
        SetModelAsNoLongerNeeded(hash)

        if Bridge.Missions.RegisterEntity then
            Bridge.Missions.RegisterEntity(obj, "object")
        end

        return obj
    end
end

return Spawn