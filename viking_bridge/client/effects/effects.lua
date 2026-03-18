-- client/effects/effects.lua
-- Screen FX, camera shake, and audio feedback for Viking Bridge

local Effects = {}

function Effects.Init(Bridge)
    -- Ensure the Missions sub-table exists on client
    if not Bridge.Missions then Bridge.Missions = {} end

    -- [[ PLAY SOUND ]]
    -- Standard frontend audio feedback
    function Bridge.Missions.PlaySound(soundName, soundSet)
        PlaySoundFrontend(-1, soundName or "Menu_Accept", soundSet or "Phone_SoundSet_Default", true)
    end

    -- [[ SCREEN FLASH ]]
    -- Uses Post-FX for a tactical visual transition (non-blocking)
    function Bridge.Missions.ScreenFlash(duration)
        local time = duration or 500
        CreateThread(function()
            AnimpostfxPlay("MinigameTransitionIn", time, false)
            Wait(time)
            AnimpostfxStop("MinigameTransitionIn")
        end)
    end

    -- [[ CAMERA SHAKE ]]
    -- Adds physical weight to explosions or impacts (non-blocking)
    function Bridge.Missions.ShakeCam(intensity, duration)
        local time = duration or 500
        CreateThread(function()
            ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", intensity or 1.0)
            Wait(time)
            StopGameplayCamShaking(true)
        end)
    end

    -- [[ BLOODY SCREEN ]]
    -- Custom effect for taking damage or low health
    function Bridge.Missions.EffectBlood(duration)
        local time = duration or 1000
        CreateThread(function()
            AnimpostfxPlay("Rampage", time, false)
            Wait(time)
            AnimpostfxStop("Rampage")
        end)
    end
end

return Effects