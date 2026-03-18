-- client/ui/notify.lua
-- Unified notification system for Viking Bridge

local Notify = {}

function Notify.Init(Bridge)
    -- Initialize the sub-table
    Bridge.UI = {}

    -- [[ UNIFIED NOTIFICATION ]]
    -- msg: The text to display
    -- type: "success", "error", "inform", "warning"
    function Bridge.UI.Notify(msg, type)
        type = type or "inform"
        local fw = Bridge.Framework.Type

        -- 1. OX_LIB (Priority - often used with both QB and ESX)
        if GetResourceState("ox_lib") == "started" then
            lib.notify({
                title = 'Viking Bridge',
                description = msg,
                type = type,
                position = 'top-right',
                icon = 'shield-halved' -- Viking themed icon
            })

        -- 2. QB-CORE / QBOX
        elseif fw == "qb" or fw == "qbox" then
            -- Map 'inform' to QB's 'primary'
            local qbType = type == "inform" and "primary" or type
            Bridge.Core.Functions.Notify(msg, qbType)

        -- 3. ESX
        elseif fw == "esx" then
            -- ESX uses basic strings; mapping types to prefixes for clarity
            local prefix = ""
            if type == "success" then prefix = "~g~" 
            elseif type == "error" then prefix = "~r~"
            elseif type == "warning" then prefix = "~y~" end
            
            TriggerEvent('esx:showNotification', prefix .. msg)

        -- 4. STANDALONE (GTA Native Ticker)
        else
            BeginTextCommandThefeedPost("STRING")
            AddTextComponentSubstringPlayerName(msg)
            EndTextCommandThefeedPostTicker(false, true)
        end
    end
    
    -- Shortcut for quick debugging
    Bridge.Notify = Bridge.UI.Notify
end

return Notify