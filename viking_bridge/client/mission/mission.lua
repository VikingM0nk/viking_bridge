-- client/mission/mission.lua
-- Mission asset management and cleanup for Viking Bridge

local Mission = {}
-- Organized storage for spawned mission entities
local Entities = { peds = {}, objects = {}, vehicles = {} }

function Mission.Init(Bridge)
    -- Ensure the sub-table exists
    if not Bridge.Missions then Bridge.Missions = {} end

    -- [[ REGISTER ENTITY ]]
    -- Tracks an entity so it can be automatically deleted later
    -- type: "ped", "object", or "vehicle"
    function Bridge.Missions.RegisterEntity(entity, type)
        local category = type .. "s"
        if not Entities[category] or not DoesEntityExist(entity) then return end
        
        -- Prevent duplicate registration
        for _, val in ipairs(Entities[category]) do
            if val == entity then return end
        end

        table.insert(Entities[category], entity)
        -- Mark as mission entity so the engine doesn't delete it randomly
        SetEntityAsMissionEntity(entity, true, true)
        Bridge.Utils.Debug(("Missions: Registered %s (%s)"):format(type, entity))
    end

    -- [[ CLEANUP ASSETS ]]
    -- Safely removes all tracked entities from the game world
    function Bridge.Missions.Cleanup()
        local function SafeDelete(ent, isVeh)
            if DoesEntityExist(ent) then
                -- Remove mission flag so it can be deleted
                SetEntityAsMissionEntity(ent, false, true)
                -- If it's a vehicle, check for occupants to prevent "falling through world"
                if isVeh then
                    local ped = GetPedInVehicleSeat(ent, -1)
                    if ped ~= 0 then TaskLeaveVehicle(ped, ent, 64) end
                    DeleteVehicle(ent)
                else
                    DeleteEntity(ent)
                end
            end
        end

        -- Execute cleanup across all categories
        for _, ped in ipairs(Entities.peds) do SafeDelete(ped) end
        for _, obj in ipairs(Entities.objects) do SafeDelete(obj) end
        for _, veh in ipairs(Entities.vehicles) do SafeDelete(veh, true) end

        -- Clear the registry tables
        Entities = { peds = {}, objects = {}, vehicles = {} }
        
        Bridge.Utils.Debug("Viking mission assets cleared.")
    end
end

return Mission