🔗 VIKING_BRIDGE (C3 MODULAR ARCHITECTURE)
The viking_bridge is a high-performance, framework-agnostic synchronization layer designed to unify core server functions. It acts as a translation layer between specialized "Viking" resources and the underlying server framework (QB-Core, QBox, or ESX).

By utilizing a modular "C3" architecture, the bridge ensures that metadata, inventories, and vehicle properties are handled consistently across all environments.

💎 CORE CAPABILITIES
🏦 Financial & Inventory Intelligence
Metadata Worth Calculation: Unlike standard bridges that count items, the Viking Bridge scans metadata. It can calculate the total "worth" of items like Marked Bills, Gold Bars, or Encrypted USBs.

Automatic "Change" Logic: When a transaction occurs using metadata-based currency, the bridge automatically "breaks" the item and returns the remaining balance to the player as a new item with updated metadata.

🚘 Vehicle & Garage Unified API
Universal Spawning: A single function call to spawn vehicles with consistent routing to framework-specific garages.

Property Syncing: Automatically handles the saving and loading of vehicle properties (mods, plate, fuel, engine health) across different garage scripts.

Ghost Plate Integration: Native support for generating and registering non-standard license plates.

🆔 Identity & Reputation
Cross-Framework Handshake: Instantly resolves CitizenID (QB/QBox) or Identifier (ESX) into a unified "Viking ID" for use in persistent database tables like viking_reputation.

Internal Ready-State: Features a "Tactical Wait" system that ensures the bridge is fully linked to the core framework before allowing dependent scripts to initialize.

🛠️ INSTALLATION
Place the viking_bridge folder into your resources directory.

CRITICAL: This resource must be started BEFORE any other Viking resources.

Add the following to your server.cfg:

Code snippet
ensure viking_bridge
# Ensure your other Viking scripts AFTER the bridge
ensure viking_vehicle_blackmarket
ensure viking_darknet
📡 TECHNICAL ARCHITECTURE (FOR DEVELOPERS)
The bridge exports a single primary object: GetBridge(). This object contains sub-modules for:

Bridge.Functions: Identity and player data.

Bridge.Inventory: Money, items, and metadata scanning.

Bridge.Vehicles: Spawning, keys, and properties.

Bridge.UI: Framework-native notifications and progress bars.

⚙️ CONFIGURATION
The config.lua allows you to toggle framework detection:

Auto-Detect: Set Config.Framework = 'auto' to let the bridge identify the environment.

Manual Override: Force the bridge to a specific framework if you are running a highly customized core.

⚖️ LICENSE & USAGE
© 2026 VikingMonk Development.

Core Logic: The bridge is a core dependency for all Viking Series resources.

Modifications: You are permitted to modify the bridge to support custom inventory or garage systems not covered in the base build.

Distribution: This bridge may not be redistributed as a standalone "utility" without being bundled with an authorized Viking Series resource.

🆘 TECHNICAL SUPPORT
If the bridge fails to link, check your server console for [VIKING-BRIDGE] Shared Core initialized. If this message does not appear, verify that your framework (QB/ESX/QBox) is started before the bridge.

Join the Viking Development Discord for technical documentation: https://discord.gg/75cZuQBMzD