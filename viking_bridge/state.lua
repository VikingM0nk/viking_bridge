-- shared/state.lua
-- Global entity state helpers for Viking Bridge

Bridge = Bridge or {}
Bridge.State = Bridge.State or {}

-- [[ SET STATE ]]
function Bridge.State.Set(entity, key, value, replicated)
    if not DoesEntityExist(entity) then 
        if Bridge.Utils and Bridge.Utils.Debug then 
            Bridge.Utils.Debug("State.Set failed: Entity " .. tostring(entity) .. " does not exist.") 
        end
        return false 
    end
    
    -- The third argument 'true' makes it replicate to all clients/server
    Entity(entity).state:set(key, value, replicated ~= nil and replicated or true)
    return true
end

-- [[ GET STATE ]]
function Bridge.State.Get(entity, key)
    if not DoesEntityExist(entity) then return nil end
    return Entity(entity).state[key]
end

-- [[ CLEAR STATE ]]
function Bridge.State.Clear(entity, key)
    if not DoesEntityExist(entity) then return end
    Entity(entity).state:set(key, nil, true)
end