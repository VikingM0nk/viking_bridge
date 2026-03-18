-- server/keys/keys.lua
local Keys = {}

function Keys.Init(Bridge)
    -- Initialize the sub-table so Bridge.Keys exists
    Bridge.Keys = {}

    -- [[ GIVE VEHICLE KEYS (SERVER) ]]
    -- @param src: The player server ID
    -- @param plate: The vehicle plate string
    function Bridge.Keys.GiveKeys(src, plate)
        if not src or not plate then 
            return print("^1[Bridge Error]^7 GiveKeys called with missing source or plate.") 
        end

        -- Standardize plate for the handshake
        local cleanPlate = string.gsub(plate, '^%s*(.-)%s*$', '%1')

        -- Trigger the NetEvent we just added to client/main.lua
        TriggerClientEvent('viking_bridge:client:GiveKeys', src, cleanPlate)

        -- Optional: Debug log
        if Config and Config.Debug then
            print(("^2[Bridge Debug]^7 Keys sent to ID %s for plate [%s]"):format(src, cleanPlate))
        end
    end
end

return Keys