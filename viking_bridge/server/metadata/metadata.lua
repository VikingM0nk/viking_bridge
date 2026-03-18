-- server/metadata/metadata.lua
-- Unified metadata system (stress, thirst, custom values)

local Metadata = {}

function Metadata.Init(Bridge)
    -- Initialize the sub-table
    Bridge.Metadata = {}

    -- [[ GET METADATA ]]
    function Bridge.Metadata.Get(src, key)
        local p = Bridge.GetPlayer(src)
        if not p then return nil end

        local type = Bridge.Framework.Type

        if type == "qb" or type == "qbox" then
            -- QB-Core / Qbox store metadata in the PlayerData table
            return p.PlayerData.metadata and p.PlayerData.metadata[key]
        elseif type == "esx" then
            -- Modern ESX (1.9.0+) uses getMeta. 
            -- Older versions might require a custom solution or xPlayer.get('meta')
            if p.getMeta then 
                return p.getMeta(key) 
            else
                Bridge.Utils.Debug("^3[METADATA WARNING]^7 ESX version does not support native metadata (getMeta).")
                return nil
            end
        end
    end

    -- [[ SET METADATA ]]
    function Bridge.Metadata.Set(src, key, value)
        local p = Bridge.GetPlayer(src)
        if not p then return false end

        local type = Bridge.Framework.Type

        if type == "qb" or type == "qbox" then
            -- QB-Core / Qbox native setter
            p.Functions.SetMetaData(key, value)
            return true
        elseif type == "esx" then
            -- Modern ESX native setter
            if p.setMeta then 
                p.setMeta(key, value)
                return true
            else
                Bridge.Utils.Debug("^3[METADATA WARNING]^7 ESX version does not support native metadata (setMeta).")
                return false
            end
        end
        return false
    end

    Bridge.Utils.Debug("Metadata module initialized.")
end

return Metadata