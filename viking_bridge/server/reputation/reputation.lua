-- server/reputation/reputation.lua
-- SQL-based reputation system for Viking Bridge

local Reputation = {}

function Reputation.Init(Bridge)
    -- Initialize the sub-table
    Bridge.Reputation = {}

    -- [[ GET REPUTATION ]]
    function Bridge.Reputation.Get(src)
        local cid = Bridge.Framework.GetIdentifier(src)
        if not cid then return 0 end

        -- Use a scalar fetch for the single integer value
        local rep = MySQL.scalar.await(
            'SELECT reputation FROM viking_reputation WHERE citizenid = ?',
            { cid }
        )
        return rep or 0
    end

    -- [[ ADD / REMOVE REPUTATION ]]
    function Bridge.Reputation.Add(src, amount)
        local cid = Bridge.Framework.GetIdentifier(src)
        if not cid then return false end

        local current = Bridge.Reputation.Get(src)
        -- Caps at 1000, floors at 0
        local newRep = math.max(0, math.min(current + amount, 1000))

        -- Upsert logic: Updates if exists, inserts if it doesn't
        -- Using oxmysql syntax for performance
        local affectedRows = MySQL.update.await([[
            INSERT INTO viking_reputation (citizenid, reputation) 
            VALUES (?, ?) 
            ON DUPLICATE KEY UPDATE reputation = ?
        ]], { cid, newRep, newRep })

        -- Sync with client for UI/HUD updates
        TriggerClientEvent('viking_bridge:client:UpdateRep', src, newRep)
        
        Bridge.Utils.Debug(("^2Reputation Updated:^7 Player %s now has %s XP"):format(src, newRep))
        return true
    end

    -- [[ REMOVE REPUTATION (Alias for convenience) ]]
    function Bridge.Reputation.Remove(src, amount)
        return Bridge.Reputation.Add(src, -amount)
    end
end

return Reputation