-- server/vehicles/vehicles.lua
local Vehicles = {}

function Vehicles.Init(Bridge)
    Bridge.Vehicles = {}

    -- [[ SERVER-SIDE SPAWNER ]]
    function Bridge.Vehicles.SpawnVehicle(source, model, coords, plate, cb)
        local modelHash = type(model) == "string" and GetHashKey(model) or model
        local x, y, z, w = coords.x, coords.y, coords.z, (coords.w or 0.0)

        -- Use Server Setter for persistent ownership
        local vehicle = CreateVehicleServerSetter(modelHash, "automobile", x, y, z, w)
        
        local timeout = 0
        while not DoesEntityExist(vehicle) and timeout < 100 do
            Wait(10)
            timeout = timeout + 1
        end

        if DoesEntityExist(vehicle) then
            if plate then SetVehicleNumberPlateText(vehicle, plate) end
            
            -- Sync bucket with player
            SetEntityRoutingBucket(vehicle, GetPlayerRoutingBucket(source))

            -- State Bags for cross-script tracking
            Entity(vehicle).state:set('isBridgeVehicle', true, true)
            Entity(vehicle).state:set('spawnedBy', source, true)

            local netId = NetworkGetNetworkIdFromEntity(vehicle)
            if cb then cb(netId, vehicle) end
        else
            print("^1[Viking-Bridge]^7: Failed to spawn vehicle " .. tostring(model))
            if cb then cb(nil, nil) end
        end
    end
end

return Vehicles