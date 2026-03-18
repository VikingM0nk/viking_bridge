-- server/callbacks/callbacks.lua
-- Universal callback system for Viking scripts

local Callbacks = {}

function Callbacks.Init(Bridge)
    Bridge.Callbacks = {}
    local Registered = {}

    -- [[ NETWORK LISTENER ]]
    RegisterNetEvent('viking_bridge:server:triggerCallback', function(name, ticket, ...)
        local src = source
        
        -- Safety check for early-load triggers
        local debug = (Bridge.Utils and Bridge.Utils.Debug) or function(msg) print(msg) end

        if Registered[name] then
            -- Registered[name] is the function from your contracts/missions scripts
            -- We pass src, a response function, and any extra arguments (...)
            Registered[name](src, function(...)
                -- Check if player is still online before sending data back
                if GetPlayerName(src) then
                    -- This triggers the event that the contracts/shared/bridge.lua is now listening for
                    TriggerClientEvent('viking_bridge:client:receiveCallback', src, ticket, ...)
                end
            end, ...)
            
            debug(("^5[CALLBACK EXECUTED]^7 %s (Ticket: %s)"):format(name, ticket))
        else
            debug(("^1[CALLBACK ERROR]^7 Unknown callback requested: %s"):format(name))
        end
    end)

    -- [[ CREATE CALLBACK ]]
    function Bridge.Callbacks.Create(name, cb)
        local debug = (Bridge.Utils and Bridge.Utils.Debug) or function(msg) print(msg) end

        if not name or not cb then 
            return debug("^1[CALLBACK ERROR]^7 Invalid registration for: " .. tostring(name)) 
        end
        
        if Registered[name] then
            debug("^3[CALLBACK WARNING]^7 Overwriting existing callback: " .. name)
        end
        
        Registered[name] = cb
        debug("Registered server callback: ^2" .. name .. "^7")
    end

    -- Map to the Bridge object
    Bridge.CreateCallback = Bridge.Callbacks.Create
end

return Callbacks