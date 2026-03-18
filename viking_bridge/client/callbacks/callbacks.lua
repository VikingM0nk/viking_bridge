-- client/callbacks/callbacks.lua
-- Client-side callback system for Viking Bridge

local Callbacks = {}
local Pending = {} 

-- [[ RECEIVE SERVER RESPONSE ]]
RegisterNetEvent('viking_bridge:client:receiveCallback', function(ticket, ...)
    -- Only handle the ticket if it was registered through the Bridge's internal trigger
    if Pending[ticket] then
        local callbackData = Pending[ticket]
        local success, err = pcall(callbackData.cb, ...)
        
        if not success then
            print(("^1[CALLBACK ERROR]^7 Error executing callback for %s: %s"):format(callbackData.name, err))
        end

        Pending[ticket] = nil
    end
    -- "Else" logic removed to allow other resources (like viking_contracts) 
    -- to process their own tickets via the same event without noise.
end)

-- [[ DIRECT TRIGGER EVENT ]]
RegisterNetEvent('viking_bridge:client:triggerCallbackDirect', function(name, cb, ...)
    if Callbacks.InternalTrigger then
        Callbacks.InternalTrigger(name, cb, ...)
    end
end)

function Callbacks.Init(Bridge)
    Bridge.Callbacks = {}

    function Callbacks.InternalTrigger(arg1, arg2, arg3, ...)
        local name, cb, extraArgs

        if type(arg1) == "string" and type(arg2) == "function" then
            name, cb, extraArgs = arg1, arg2, {arg3, ...}
        elseif type(arg2) == "string" and type(arg3) == "function" then
            name, cb, extraArgs = arg2, arg3, {...}
        end

        if type(cb) ~= "function" then
            return print(("^1[CALLBACK ERROR]^7 Received Name: %s | Received CB Type: %s"):format(tostring(name or arg1), type(cb)))
        end

        local ticket = ("%s_%s_%s"):format(name, GetGameTimer(), math.random(1111, 9999))
        
        Pending[ticket] = {
            cb = cb,
            name = name,
            time = GetGameTimer()
        }

        TriggerServerEvent('viking_bridge:server:triggerCallback', name, ticket, table.unpack(extraArgs))
        
        if Bridge.Utils and Bridge.Utils.Debug then
            Bridge.Utils.Debug(("^5[CALLBACK SENT]^7 Ticket: %s"):format(ticket))
        end
    end

    -- [[ AUTO-CLEANUP THREAD ]]
    CreateThread(function()
        while true do
            Wait(5000)
            local now = GetGameTimer()
            for ticket, data in pairs(Pending) do
                if (now - data.time) > 15000 then 
                    if Bridge.Utils and Bridge.Utils.Debug then
                        Bridge.Utils.Debug(("^1[CALLBACK TIMEOUT]^7 No response for: %s"):format(ticket))
                    end
                    Pending[ticket] = nil
                end
            end
        end
    end)

    Bridge.Callbacks.Trigger = Callbacks.InternalTrigger
    Bridge.TriggerCallback = Callbacks.InternalTrigger
    Bridge.CallbacksReady = true
end

return Callbacks