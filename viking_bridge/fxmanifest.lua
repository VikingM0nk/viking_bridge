fx_version 'cerulean'
game 'gta5'

author 'VikingM0nk'
description 'Viking Universal Bridge (C3 Modular Architecture)'
version '1.0.0'

lua54 'yes'

-- ===========================
-- SHARED FILES
-- ===========================
shared_scripts {
    'bridge.lua',   -- The Bridge Core must be included in shared scripts to be accessible by both client and server
    'config.lua',    -- Config first to initialize variables
    'state.lua',     -- State management
    'utils.lua',     -- Shared helpers
   
}

-- All internal modules accessed via require/LoadModule
files {
    -- Server Framework Modules
    'server/framework/qb.lua',
    'server/framework/qbox.lua',
    'server/framework/esx.lua',
    'server/framework/standalone.lua',

    -- Server Inventory Adaptors
    'server/inventory/init.lua',
    'server/inventory/ox.lua',
    'server/inventory/qb.lua',
    'server/inventory/codem.lua',
    'server/inventory/mf.lua',
    'server/inventory/jaksam.lua',
    'server/inventory/core.lua',
    'server/inventory/standalone.lua',

    -- Server Banking Adaptors
    'server/banking/banking.lua',
    'server/banking/renewed.lua',
    'server/banking/tgg.lua',
    'server/banking/okok.lua',
    'server/banking/qb.lua',
    'server/banking/esx.lua',
    'server/banking/standalone.lua',

    -- Server Core Modules
    'server/identity/identity.lua',
    'server/jobs/jobs.lua',
    'server/metadata/metadata.lua',
    'server/permissions/permissions.lua',
    'server/reputation/reputation.lua',
    'server/items/items.lua',
    'server/missions/missions.lua',

    -- Server Garage/Vehicle Persistence
    'server/garages/garages.lua',
    'server/vehicles/vehicles.lua',
    'server/keys/keys.lua',
    
    -- Client Framework & Detectors
    'client/framework/detect.lua',
    'client/framework/init.lua',

    -- Client UI & Interaction Modules
    'client/ui/notify.lua',
    'client/ui/progress.lua',
    'client/target/target.lua',
    'client/keys/keys.lua',
    'client/blips/blips.lua',
    'client/spawn/spawn.lua',
    'client/effects/effects.lua',

    -- Client Vehicle Management
    'client/vehicles/vehicles.lua',

    -- Client Logic Modules
    'client/mission/mission.lua',
}

-- ===========================
-- SERVER FILES
-- ===========================
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/callbacks/callbacks.lua', 
    'server/main.lua'
}

-- ===========================
-- CLIENT FILES
-- ===========================
client_scripts {
    'client/callbacks/callbacks.lua', 
    'client/main.lua'
}

-- ===========================
-- DEPENDENCIES
-- ===========================
optional_dependencies {
    'ox_lib',
    'ox_target',
    'qb-target',
    'qbx_core',
    'oxmysql'
}

-- ===========================
-- EXPORTS
-- ===========================
-- These are accessible by any script via exports['viking_bridge']:Function()
exports {
    'GetBridge',      -- Returns the full C3 Table
    'CreateCallback',
    'TriggerCallback',
    'GetItemCount',
    'RemoveItem',
    'AddItem',
    'AddMoney',
    'Notify'
}

escrow_ignore {
    'bridge.lua',
    'config.lua',
    'state.lua',
    'utils.lua',
    'server/**/*.lua',
    'client/**/*.lua',
    'fxmanifest.lua',
    'README.md'
}