-- server/missions/missions.lua
-- Server-side mission helpers (instancing, cleanup, etc.)

local Missions = {}

function Missions.Init(Bridge)
    -- Initialize the sub-table
    Bridge.Missions = {}

    -- [[ PLAYER INSTANCING ]]
    -- Moves a player to a private or shared routing bucket
    function Bridge.Missions.SetPlayerInstance(src, bucket)
        SetPlayerRoutingBucket(src, bucket or 0)
        Bridge.Utils.Debug(("Missions: Player %s moved to bucket %s"):format(src, bucket or 0))
    end

    -- [[ ENTITY INSTANCING ]]
    -- Useful for spawning mission-specific cars/NPCs that only players in that instance can see
    function Bridge.Missions.SetEntityInstance(entity, bucket)
        if DoesEntityExist(entity) then
            SetEntityRoutingBucket(entity, bucket or 0)
            return true
        end
        return false
    end

    -- [[ RESET INSTANCE ]]
    -- Quickly moves player and their vehicle back to the main world (Bucket 0)
    function Bridge.Missions.ResetInstance(src)
        SetPlayerRoutingBucket(src, 0)
        local ped = GetPlayerPed(src)
        local veh = GetVehiclePedIsIn(ped, false)
        if veh ~= 0 then
            SetEntityRoutingBucket(veh, 0)
        end
        Bridge.Utils.Debug(("Missions: Player %s and vehicle reset to main world"):format(src))
    end

    -- [[ GET BUCKET POPULATION ]]
    -- Returns how many players are currently in a specific instance
    function Bridge.Missions.GetPopulation(bucket)
        local count = 0
        for _, src in ipairs(GetPlayers()) do
            if GetPlayerRoutingBucket(src) == bucket then
                count = count + 1
            end
        end
        return count
    end
end

return Missions