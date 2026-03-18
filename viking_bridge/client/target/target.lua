-- client/target/target.lua
-- Unified target system (OX / QB / Standalone) for Viking Bridge

local Target = {}

function Target.Init(Bridge)
    Bridge.Target = {}

    -- [[ ADD ENTITY TARGET ]]
    function Bridge.Target.AddEntity(entity, options)
        if not DoesEntityExist(entity) then return end

        -- 1. OX_TARGET
        if GetResourceState("ox_target") == "started" then
            for _, v in ipairs(options) do
                if v.action and not v.onSelect then v.onSelect = v.action end
            end
            exports.ox_target:addLocalEntity(entity, options)

        -- 2. QB-TARGET
        elseif GetResourceState("qb-target") == "started" then
            for _, v in ipairs(options) do
                if v.onSelect and not v.action then v.action = v.onSelect end
            end
            exports['qb-target']:AddTargetEntity(entity, {
                options = options,
                distance = 2.5
            })
        
        -- 3. STANDALONE FALLBACK (Press E)
        else
            Bridge.Target.CreateInteractionLoop(entity, options)
        end
    end

    -- [[ STANDALONE INTERACTION LOOP ]]
    function Bridge.Target.CreateInteractionLoop(entity, options)
        CreateThread(function()
            local firstOption = options[1] -- We use the first action for the E-key
            while DoesEntityExist(entity) do
                local sleep = 1000
                local pCoords = GetEntityCoords(PlayerPedId())
                local eCoords = GetEntityCoords(entity)
                local dist = #(pCoords - eCoords)

                if dist < 2.5 then
                    sleep = 0
                    -- Using the label from the first option provided
                    local label = firstOption.label or "Interact"
                    
                    -- Native Help Notification (Top Left)
                    BeginTextCommandDisplayHelp("STRING")
                    AddTextComponentSubstringPlayerName("Press ~INPUT_CONTEXT~ to " .. label)
                    EndTextCommandDisplayHelp(0, false, true, -1)

                    if IsControlJustPressed(0, 38) then -- [E] Key
                        if firstOption.action then 
                            firstOption.action(entity) 
                        elseif firstOption.onSelect then
                            firstOption.onSelect({entity = entity})
                        end
                        Wait(500) -- Simple debouncing
                    end
                end
                Wait(sleep)
            end
        end)
    end

    -- [[ REMOVE ENTITY TARGET ]]
    function Bridge.Target.RemoveEntity(entity)
        if GetResourceState("ox_target") == "started" then
            exports.ox_target:removeLocalEntity(entity)
        elseif GetResourceState("qb-target") == "started" then
            exports['qb-target']:RemoveTargetEntity(entity)
        end
    end
end

return Target