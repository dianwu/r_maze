-- /src/StarterPlayer/StarterPlayerScripts/Controllers/AudioController.lua
-- This controller will manage all game audio effects.

local AudioController = {}

local Workspace = game:GetService("Workspace")

-- Find sound objects. Using WaitForChild is robust against replication timing issues.
local backgroundMusic = Workspace:WaitForChild("Escape The Maze", 10)
local exitSound = Workspace:WaitForChild("Running Faster B", 10)

function AudioController.playBackgroundMusic()
    if exitSound and exitSound.IsPlaying then
        exitSound:Stop()
    end

    if backgroundMusic then
        backgroundMusic.Looped = true
        backgroundMusic:Play()
    else
        warn("AudioController: Could not find 'Escape The Maze' sound.")
    end
end

function AudioController.stopBackgroundMusic()
    if backgroundMusic and backgroundMusic.IsPlaying then
        backgroundMusic:Stop()
    end
end

function AudioController.playExitSound()
    if exitSound then
        exitSound:Play()
    else
        warn("AudioController: Could not find 'Running Faster B' sound.")
    end
end

function AudioController.start()
    print("AudioController started")
end

return AudioController
