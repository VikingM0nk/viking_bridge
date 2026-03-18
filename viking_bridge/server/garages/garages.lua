-- server/garages/garages.lua
-- Unified Garage/Database system for Viking Bridge

local Garages = {}

function Garages.Init(Bridge)
    Bridge.Garages = {}

    -- [[ SAVE VEHICLE TO DATABASE ]]
    -- @param source: Player ID
    -- @param data: Table containing { model, plate, props, type, garage }
    function Bridge.Garages.SaveVehicle(source, data)
        if not data or not source then return end
        
        local player = Bridge.GetPlayer(source)
        if not player then 
            if Bridge.Debug then print("^1[Bridge Debug]^7 Failed to save vehicle: Player object nil for ID " .. source) end
            return 
        end

        -- Framework-Agnostic Identifier Selection
        -- QB/Qbox use .PlayerData.citizenid | ESX uses .identifier
        local identifier = player.PlayerData and player.PlayerData.citizenid or player.identifier
        local license = player.PlayerData and player.PlayerData.license or (player.getIdentifier and player.getIdentifier())
        
        local plate = data.plate
        local model = data.model
        local vehicleProps = json.encode(data.props or {})
        local defaultGarage = data.garage or "pillbox"
        local vehicleType = data.type or "automobile"

        -- 1. okokGarage & Generic QB-Core Systems
        if GetResourceState("okokGarage") == "started" or GetResourceState("qb-garage") == "started" then
            MySQL.insert('INSERT INTO player_vehicles (license, citizenid, vehicle, hash, mods, plate, garage, state) VALUES (?, ?, ?, ?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE mods = ?', {
                license, 
                identifier,
                model,
                GetHashKey(model),
                vehicleProps,
                plate,
                defaultGarage,
                1, -- Stored state
                vehicleProps
            })

        -- 2. CD Garage (Codesign)
        elseif GetResourceState("cd_garage") == "started" then
            -- CD Garage usually expects the owner, plate, and the vehicle name/props
            MySQL.insert('INSERT INTO owned_vehicles (owner, plate, vehicle, garage_type, stored) VALUES (?, ?, ?, ?, ?)', {
                identifier,
                plate,
                vehicleProps,
                'car',
                1
            })

        -- 3. JG Garage
        elseif GetResourceState("jg-garage") == "started" then
            TriggerEvent('jg-garage:server:SaveVehicle', source, model, plate, data.props, defaultGarage)

        -- Fallback: Standard Framework Tables (QB-Core / ESX)
        else
            local isQB = (GetResourceState("qb-core") == "started" or GetResourceState("qbx_core") == "started")
            local tableName = isQB and "player_vehicles" or "owned_vehicles"
            local ownerCol = isQB and "citizenid" or "owner"
            
            -- Construct the query dynamically based on detected framework
            local query = string.format('INSERT INTO %s (%s, plate, vehicle, mods, state) VALUES (?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE mods = ?', tableName, ownerCol)
            
            MySQL.insert(query, {
                identifier,
                plate,
                model,
                vehicleProps,
                1,
                vehicleProps
            })
        end
        
        if Bridge.Debug then 
            print("^2[Bridge Debug]^7 Vehicle [" .. plate .. "] persisted to database for " .. identifier) 
        end
    end
end

return Garages