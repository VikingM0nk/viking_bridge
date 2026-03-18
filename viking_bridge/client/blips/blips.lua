-- client/blips/blips.lua
-- Mission blip management for Viking Bridge

local Blips = {}
local Active = {}

function Blips.Init(Bridge)
    -- Ensure the Missions table exists on the client
    if not Bridge.Missions then Bridge.Missions = {} end

    -- [[ ADD MISSION BLIP ]]
    function Bridge.Missions.AddBlip(id, coords, label, sprite, color, scale, route)
        -- Auto-cleanup if the ID is already in use
        if Active[id] then 
            RemoveBlip(Active[id]) 
        end

        local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
        
        SetBlipSprite(blip, sprite or 1)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, scale or 0.8)
        SetBlipColour(blip, color or 3)
        SetBlipAsShortRange(blip, true)

        -- Optional GPS Route
        if route then
            SetBlipRoute(blip, true)
            SetBlipRouteColour(blip, color or 3)
        end

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(label or "Mission Objective")
        EndTextCommandSetBlipName(blip)

        Active[id] = blip
        return blip
    end

    -- [[ REMOVE MISSION BLIP ]]
    function Bridge.Missions.RemoveBlip(id)
        if Active[id] then
            RemoveBlip(Active[id])
            Active[id] = nil
        end
    end

    -- [[ CLEAR ALL MISSION BLIPS ]]
    -- Essential for cleanup when a player cancels a contract or logs out
    function Bridge.Missions.ClearAllBlips()
        for id, blip in pairs(Active) do
            if DoesBlipExist(blip) then
                RemoveBlip(blip)
            end
        end
        Active = {}
        Bridge.Utils.Debug("All mission blips cleared.")
    end
end

return Blips