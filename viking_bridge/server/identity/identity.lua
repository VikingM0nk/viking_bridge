-- server/identity/identity.lua
-- Universal identity and name resolution for Viking Bridge

local Identity = {}

function Identity.Init(Bridge)
    -- Attach these functions to the Bridge so other modules can use them
    Bridge.Identity = {}

    -- [[ CHARACTER IDENTIFIER ]]
    function Bridge.Identity.GetCharacterIdentifier(src)
        if not src or src == 0 then return nil end
        local framework = Bridge.Framework.Type

        if framework == "qb" or framework == "qbox" then
            -- Uses the Bridge.GetPlayer defined in server/main.lua
            local p = Bridge.GetPlayer(src)
            return p and p.PlayerData.citizenid
        elseif framework == "esx" then
            local xP = Bridge.GetPlayer(src)
            return xP and xP.getIdentifier()
        end

        local license = GetPlayerIdentifierByType(src, 'license')
        return license and license:gsub('license:', '') or nil
    end

    -- [[ SPECIFIC ID LOOKUP ]]
    function Bridge.Identity.GetSpecificIdentifier(src, idType)
        local id = GetPlayerIdentifierByType(src, idType)
        if id then return id end
        
        local identifiers = GetPlayerIdentifiers(src)
        for _, identifier in pairs(identifiers) do
            if string.find(identifier, idType .. ":") then
                return identifier
            end
        end
        return "Not Linked"
    end

    -- [[ CHARACTER NAME RESOLVER ]]
    function Bridge.Identity.GetCharacterName(src)
        local framework = Bridge.Framework.Type

        if framework == "qb" or framework == "qbox" then
            local p = Bridge.GetPlayer(src)
            if p and p.PlayerData.charinfo then
                return ("%s %s"):format(p.PlayerData.charinfo.firstname, p.PlayerData.charinfo.lastname)
            end
        elseif framework == "esx" then
            local xP = Bridge.GetPlayer(src)
            if xP then return xP.getName() end
        end
        
        return GetPlayerName(src)
    end

    -- [[ FULL IDENTITY PROFILE ]]
    function Bridge.Identity.GetFullIdentity(src)
        return {
            name = Bridge.Identity.GetCharacterName(src),
            oocName = GetPlayerName(src),
            cid = Bridge.Identity.GetCharacterIdentifier(src) or "Unknown",
            discord = Bridge.Identity.GetSpecificIdentifier(src, "discord"),
            steam = Bridge.Identity.GetSpecificIdentifier(src, "steam"),
            license = Bridge.Identity.GetSpecificIdentifier(src, "license")
        }
    end

    -- Global Exports
    exports('GetCharacterIdentifier', function(src) return Bridge.Identity.GetCharacterIdentifier(src) end)
    exports('GetCharacterName', function(src) return Bridge.Identity.GetCharacterName(src) end)
    exports('GetFullIdentity', function(src) return Bridge.Identity.GetFullIdentity(src) end)
end

return Identity