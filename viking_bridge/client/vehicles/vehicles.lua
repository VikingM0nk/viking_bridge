-- client/vehicles/vehicles.lua
-- Unified vehicle management for Viking Bridge

function Bridge.Vehicles.Init(Bridge)
    Bridge.Vehicles = {}

    -- [[ GET VEHICLE PROPERTIES ]]
    -- Priority: ox_lib -> Framework Exports -> Native Fallback
    function Bridge.Vehicles.GetProperties(vehicle)
        if not DoesEntityExist(vehicle) then return nil end
        
        -- ox_lib is the most robust for capturing all mods/extas
        if GetResourceState("ox_lib") == "started" then
            return exports.ox_lib:getVehicleProperties(vehicle)
        
        -- QB-Core check
        elseif GetResourceState("qb-core") == "started" then
            local QBCore = exports['qb-core']:GetCoreObject()
            return QBCore.Functions.GetVehicleProperties(vehicle)

        -- ESX check (for broader framework support)
        elseif GetResourceState("es_extended") == "started" then
            local ESX = exports['es_extended']:getSharedObject()
            return ESX.Game.GetVehicleProperties(vehicle)
        end
        
        -- Native Fallback: Minimum viable data for DB storage
        return { 
            plate = GetVehicleNumberPlateText(vehicle), 
            model = GetEntityModel(vehicle),
            fuel = GetVehicleFuelLevel(vehicle),
            bodyHealth = GetVehicleBodyHealth(vehicle),
            engineHealth = GetVehicleEngineHealth(vehicle)
        }
    end

    -- [[ SET VEHICLE PROPERTIES ]]
    -- Useful for restoring a vehicle from the database
    function Bridge.Vehicles.SetProperties(vehicle, props)
        if not DoesEntityExist(vehicle) or not props then return end

        if GetResourceState("ox_lib") == "started" then
            exports.ox_lib:setVehicleProperties(vehicle, props)
        elseif GetResourceState("qb-core") == "started" then
            local QBCore = exports['qb-core']:GetCoreObject()
            QBCore.Functions.SetVehicleProperties(vehicle, props)
        elseif GetResourceState("es_extended") == "started" then
            local ESX = exports['es_extended']:getSharedObject()
            ESX.Game.SetVehicleProperties(vehicle, props)
        end
    end

    -- [[ UNIVERSAL FUEL SYSTEM ]]
    -- Sets fuel via State Bags (modern) and Exports (legacy)
    function Bridge.Vehicles.SetFuel(vehicle, level)
        if not DoesEntityExist(vehicle) then return end
        local amount = (level or 100.0) + 0.0 

        -- Global State Bag: Modern scripts (ox_fuel, etc.) watch this
        Entity(vehicle).state:set('fuel', amount, true)

        -- Legacy Script Support
        if GetResourceState("LegacyFuel") == "started" then
            exports["LegacyFuel"]:SetFuel(vehicle, amount)
        elseif GetResourceState("ps-fuel") == "started" then
            exports["ps-fuel"]:SetFuel(vehicle, amount)
        elseif GetResourceState("cdn-fuel") == "started" then
            exports["cdn-fuel"]:SetFuel(vehicle, amount)
        end



-- [[ WARP PLAYER INTO VEHICLE ]]
function Bridge.Vehicles.WarpPlayer(netId)
    local timeout = 0
    while not NetworkDoesNetworkIdExist(netId) and timeout < 100 do
        Wait(10)
        timeout = timeout + 1
    end

    local vehicle = NetToVeh(netId)
    if DoesEntityExist(vehicle) then
        local playerPed = PlayerPedId()
        TaskWarpPedIntoVehicle(playerPed, vehicle, -1) -- -1 is the driver seat
        return true
    end
    return false
end

        -- Native backup
        SetVehicleFuelLevel(vehicle, amount)
    end
end