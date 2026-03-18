-- client/keys/keys.lua
local Keys = {}

function Keys.Init(Bridge)
    Bridge.Keys = {}

    -- [[ GIVE VEHICLE KEYS ]]
    function Bridge.Keys.GiveKeys(plate, vehicle) -- Changed from .Give to .GiveKeys
        if not plate then return end
        
        local cleanPlate = string.gsub(plate, '^%s*(.-)%s*$', '%1')

        -- 1. MrNewbVehicleKeys
        if GetResourceState("MrNewbVehicleKeys") == "started" then
            if vehicle then exports.MrNewbVehicleKeys:GiveKeys(vehicle) end

        -- 2. AK47 Vehicle Keys
        elseif GetResourceState("ak47_vehiclekeys") == "started" then
            exports.ak47_vehiclekeys:GiveKeys(cleanPlate)

        -- 3. Qbox / QBX Vehicle Keys
        elseif GetResourceState("qbx_vehiclekeys") == "started" then
            exports.qbx_vehiclekeys:GiveKeys(cleanPlate)

        -- 4. QB-VehicleKeys (FIXED SECTION)
        elseif GetResourceState("qb-vehiclekeys") == "started" then
            -- Standard qb-vehiclekeys uses this event to assign ownership
            TriggerEvent("vehiclekeys:client:SetOwner", cleanPlate)
            
            -- If you want to be extra safe, we can also trigger the sync event
            TriggerServerEvent('qb-vehiclekeys:server:AcquireVehicleKeys', cleanPlate)
            
            Bridge.Utils.Debug("Keys assigned via QB-Event for: " .. cleanPlate)

        -- 5. Wasabi Car Keys
        elseif GetResourceState("wasabi_carkeys") == "started" then
            exports.wasabi_carkeys:GiveKeys(cleanPlate)
            
        -- [ ... Other checks ... ]

        else
            Bridge.Utils.Debug("No key system detected for: " .. cleanPlate)
        end
    end
end

return Keys