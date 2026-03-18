-- client/ui/progress.lua
-- Unified progress bar system for Viking Bridge

local Progress = {}

function Progress.Init(Bridge)
    -- Ensure UI table is initialized
    if not Bridge.UI then Bridge.UI = {} end

    -- [[ UNIFIED PROGRESS BAR ]]
    -- duration: time in ms
    -- label: text to show
    -- anim: animation clip
    -- dict: animation dictionary
    function Bridge.UI.Progress(duration, label, anim, dict)
        -- 1. OX_LIB (Native Promise support)
        if GetResourceState("ox_lib") == "started" then
            return lib.progressBar({
                duration = duration,
                label = label,
                useWhileDead = false,
                canCancel = true,
                disable = { car = true, move = true, combat = true },
                anim = (dict and anim) and { dict = dict, clip = anim, flag = 49 } or nil
            })
        end

        -- 2. QB-CORE / QBOX (Wrapped in a promise for sync-like return)
        if Bridge.Framework.Type == "qb" or Bridge.Framework.Type == "qbox" then
            local p = promise.new()
            
            Bridge.Core.Functions.Progressbar("viking_prog", label, duration, false, true, {
                disableMovement = true,
                disableCarMovement = true,
                disableMouse = false,
                disableCombat = true,
            }, (dict and anim) and { animDict = dict, anim = anim, flags = 49 } or {}, {}, {}, function()
                p:resolve(true) -- Finished
            end, function()
                p:resolve(false) -- Canceled
                ClearPedTasks(PlayerPedId())
            end)
            
            return Citizen.Await(p)
        end

        -- 3. STANDALONE FALLBACK
        -- If no UI is found, we simulate the time but keep the game fair
        Bridge.Utils.Debug("^3[PROGRESS]^7 No progress UI found. Falling back to Wait().")
        if dict and anim then
            RequestAnimDict(dict)
            while not HasAnimDictLoaded(dict) do Wait(10) end
            TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, 8.0, duration, 49, 0, false, false, false)
        end
        
        Wait(duration)
        ClearPedTasks(PlayerPedId())
        return true
    end
end

return Progress