-- server/jobs/jobs.lua
-- Unified job + duty + multi-job system

local Jobs = {}

function Jobs.Init(Bridge)
    Bridge.Jobs = {}

    -- [[ GET CURRENT JOB ]]
    function Bridge.Jobs.GetJob(src)
        return Bridge.Framework.GetJob(src)
    end

    -- [[ CHECK DUTY STATUS ]]
    function Bridge.Jobs.IsOnDuty(src)
        return Bridge.Framework.IsOnDuty(src)
    end

    -- [[ GET PLAYERS BY JOB ]] 
    -- FIX: This solves the nil error in your Blackmarket utils
    function Bridge.Jobs.GetPlayersByJob(jobName)
        local players = {}
        local type = Bridge.Framework.Type

        if type == "qb" or type == "qbox" then
            local QBCore = exports['qb-core']:GetCoreObject()
            local allPlayers = QBCore.Functions.GetPlayers()
            for _, src in pairs(allPlayers) do
                local pData = QBCore.Functions.GetPlayer(src)
                if pData and pData.PlayerData.job.name == jobName then
                    table.insert(players, src)
                end
            end
        elseif type == "esx" then
            local xPlayers = exports['es_extended']:getSharedObject().GetExtendedPlayers('job', jobName)
            for _, xP in pairs(xPlayers) do
                table.insert(players, xP.source)
            end
        end

        return players
    end

    -- [[ HAS JOB (MULTI-JOB SUPPORT) ]]
    function Bridge.Jobs.HasJob(src, jobName)
        local job = Bridge.Framework.GetJob(src)
        if job and job.name == jobName then return true end

        if Bridge.Framework.Type == "qbox" then
            if exports.qbx_core:HasGroup(src, jobName) then return true end
        end

        if GetResourceState("ps-multijob") == "started" then
            local jobs = exports['ps-multijob']:GetJobs(src)
            if jobs and jobs[jobName] then return true end
        end

        if GetResourceState("ks-multijob") == "started" then
            local success, jobs = pcall(function() return exports['ks-multijob']:getJobs(src) end)
            if success and jobs then
                for _, v in pairs(jobs) do
                    if v.job == jobName then return true end
                end
            end
        end

        return false
    end

    -- [[ COUNT ON-DUTY EMPLOYEES ]]
    function Bridge.Jobs.DutyCount(jobName)
        local count = 0
        local type = Bridge.Framework.Type

        if type == "qb" or type == "qbox" then
            local QBCore = exports['qb-core']:GetCoreObject()
            local players = QBCore.Functions.GetPlayers()
            for _, src in pairs(players) do
                local p = QBCore.Functions.GetPlayer(src)
                if p and p.PlayerData.job.name == jobName and p.PlayerData.job.onduty then
                    count = count + 1
                end
            end
        elseif type == "esx" then
            local xPlayers = exports['es_extended']:getSharedObject().GetExtendedPlayers('job', jobName)
            for _, xP in pairs(xPlayers) do
                if Bridge.Framework.IsOnDuty(xP.source) then 
                    count = count + 1 
                end
            end
        end

        return count
    end
    
    if Bridge.Debug then print("^2[Bridge Debug]^7 Jobs & Multi-job module initialized.") end
end

return Jobs