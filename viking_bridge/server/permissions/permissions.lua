-- server/permissions/permissions.lua
-- Unified admin/staff permission system

local Permissions = {}

function Permissions.Init(Bridge)
    -- Initialize the sub-table
    Bridge.Permissions = {}

    -- [[ IS ADMIN ]]
    -- Checks for highest level access (God, Admin, Management)
    function Bridge.Permissions.IsAdmin(src)
        -- 1. Check Ace Permissions (server.cfg)
        if IsPlayerAceAllowed(src, "admin") or IsPlayerAceAllowed(src, "viking.admin") or IsPlayerAceAllowed(src, "viking.god") then
            return true
        end

        -- 2. Check Framework-specific ranks
        local type = Bridge.Framework.Type
        if type == "qb" or type == "qbox" then
            return Bridge.Framework.HasPermission(src, "admin") or Bridge.Framework.HasPermission(src, "god")
        elseif type == "esx" then
            local xP = Bridge.GetPlayer(src)
            if xP then
                local group = xP.getGroup()
                return group == "admin" or group == "superadmin"
            end
        end

        return false
    end

    -- [[ IS STAFF ]]
    -- Lower-tier check for Moderators/Helpers
    function Bridge.Permissions.IsStaff(src)
        if Bridge.Permissions.IsAdmin(src) then return true end -- Admins are always staff
        
        if IsPlayerAceAllowed(src, "viking.mod") or IsPlayerAceAllowed(src, "viking.helper") then
            return true
        end

        local type = Bridge.Framework.Type
        if type == "esx" then
            local xP = Bridge.GetPlayer(src)
            return xP and xP.getGroup() == "mod"
        end

        return false
    end

    -- [[ CUSTOM PERMISSION CHECK ]]
    -- Flexible check for specific script-based permissions (e.g. 'viking.heist.start')
    function Bridge.Permissions.HasPermission(src, perm)
        if Bridge.Permissions.IsAdmin(src) then return true end -- God-mode override
        
        if IsPlayerAceAllowed(src, perm) then return true end
        
        return Bridge.Framework.HasPermission(src, perm)
    end

    Bridge.Utils.Debug("Permissions module initialized (Ace + Framework Mixed).")
end

return Permissions