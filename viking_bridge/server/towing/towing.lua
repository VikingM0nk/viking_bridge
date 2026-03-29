-- viking_bridge/server/modules/towing.lua

local TowingModule = {}

--- Internal Helper: Robust Framework Detection
-- This checks the global 'Framework' variable set by your bridge's auto-detect.
local function GetActiveFramework()
    if Framework then return Framework end
    if Config and Config.Framework then return Config.Framework end
    
    -- Final fallback: If you are on QB, change this to 'qb' to prevent ESX errors
    return 'qb' 
end

--- Helper: Get DB Schema based on Auto-Detected Framework
local function GetSchema()
    local active = GetActiveFramework()
    
    if active == 'qb' or active == 'qbox' then
        return { 
            table = "player_vehicles", 
            plate = "plate", 
            model = "hash", 
            owner = "citizenid", 
            state = "state", 
            impVal = 2 
        }
    else
        return { 
            table = "owned_vehicles", 
            plate = "plate", 
            model = "vehicle", 
            owner = "owner", 
            state = "stored", 
            impVal = 0 
        }
    end
end

--- Export: Get Repo List
exports('GetRepoVehicles', function()
    local schema = GetSchema()
    local repoVehicles = {}
    
    -- Dynamic Query Construction
    local query = string.format("SELECT %s, %s, %s, repo_fee FROM %s WHERE repossessed = 1", 
        schema.plate, schema.model, schema.owner, schema.table)

    local results = MySQL.query.await(query)
    if results then
        for _, row in pairs(results) do
            table.insert(repoVehicles, {
                plate = row[schema.plate],
                model = row[schema.model] or "Unknown",
                owner_name = row[schema.owner] or "Unknown",
                repo_fee = row.repo_fee or 2500
            })
        end
    end
    return repoVehicles
end)

--- Export: Mark vehicle status in DB
exports('SetVehicleImpounded', function(plate, status)
    local schema = GetSchema()
    local targetState = status and schema.impVal or 1
    
    local query = string.format("UPDATE %s SET %s = ?, repossessed = 0 WHERE %s = ?", 
        schema.table, schema.state, schema.plate)

    local affectedRows = MySQL.update.await(query, {targetState, plate})
    return affectedRows > 0
end)

--- Export: Add Money (Bank)
exports('AddMoney', function(source, account, amount)
    local active = GetActiveFramework()
    
    if active == 'qb' or active == 'qbox' then
        local Player = exports['qb-core']:GetCoreObject().Functions.GetPlayer(source)
        if Player then Player.Functions.AddMoney(account, amount) end
    elseif active == 'esx' then
        local xPlayer = exports['es_extended']:getSharedObject().GetPlayerFromId(source)
        if xPlayer then xPlayer.addAccountMoney(account, amount) end
    end
end)

--- Export: Get Players On Duty
exports('GetPlayersOnDuty', function(jobName)
    local active = GetActiveFramework()
    local list = {}
    
    if active == 'qb' or active == 'qbox' then
        local players = exports['qb-core']:GetCoreObject().Functions.GetPlayers()
        for _, src in pairs(players) do
            local Player = exports['qb-core']:GetCoreObject().Functions.GetPlayer(src)
            if Player and Player.PlayerData.job.name == jobName and Player.PlayerData.job.onduty then
                table.insert(list, src)
            end
        end
    elseif active == 'esx' then
        local xPlayers = exports['es_extended']:getSharedObject().GetExtendedPlayers('job', jobName)
        for _, xPlayer in pairs(xPlayers) do
            table.insert(list, xPlayer.source)
        end
    end
    return list
end)

return TowingModule