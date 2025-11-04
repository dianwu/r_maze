-- /src/StarterPlayer/StarterPlayerScripts/Controllers/InGameHudController.lua
-- This controller will manage the in-game HUD (compass and timer).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Modules.Remotes)
local InGameHudUI = require(ReplicatedStorage.UI.InGameHud)

local InGameHudController = {}

local hudInstance
local timerConnection
local compassConnection
local mazeExitPosition
local startTime = 0

function InGameHudController.updateTimer()
    if not hudInstance or not hudInstance.Enabled then return end

    local elapsedTime = os.clock() - startTime
    local minutes = math.floor(elapsedTime / 60)
    local seconds = math.floor(elapsedTime % 60)
    
    local timerLabel = hudInstance:FindFirstChild("TimerLabel")
    if timerLabel then
        timerLabel.Text = string.format("Time: %02d:%02d", minutes, seconds)
    end
end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

-- ... (other variables)

function InGameHudController.updateCompass()
    if not hudInstance or not hudInstance.Enabled or not mazeExitPosition then
        return
    end

    local camera = workspace.CurrentCamera
    local character = player.Character
    if not camera or not character or not character:FindFirstChild("HumanoidRootPart") then
        return
    end

    local rootPart = character.HumanoidRootPart
    
    -- Get direction vector from player to exit, ignoring Y axis
    local direction = (mazeExitPosition - rootPart.Position) * Vector3.new(1, 0, 1)

    -- Update Distance
    local compassFrame = hudInstance:FindFirstChild("CompassFrame")
    if compassFrame then
        local distanceLabel = compassFrame:FindFirstChild("DistanceLabel")
        if distanceLabel then
            local distance = direction.Magnitude
            distanceLabel.Text = string.format("%.1fm", distance)
        end
    end
    
    -- Get camera's forward direction, ignoring Y axis
    local lookVector = camera.CFrame.LookVector * Vector3.new(1, 0, 1)
    
    -- Calculate the angle between the camera's direction and the direction to the exit
    local angle = math.atan2(direction.X, direction.Z) - math.atan2(lookVector.X, lookVector.Z)
    
    -- Convert angle to degrees and apply to the compass arrow
    local compassArrow = hudInstance:FindFirstChild("CompassFrame"):FindFirstChild("CompassArrow")
    if compassArrow then
        compassArrow.Rotation = math.deg(angle)
    end
end

local touchConnection = nil

function InGameHudController.onExitTouched(otherPart)
    local character = player.Character
    if character and otherPart:IsDescendantOf(character) then
        -- Disconnect immediately to prevent multiple firings
        if touchConnection then
            touchConnection:Disconnect()
            touchConnection = nil
        end
        Remotes.PlayerFinishedMaze:FireServer()
    end
end

function InGameHudController.show(mazeModel, exitPosition)
    if hudInstance and mazeModel then
        hudInstance.Enabled = true
        mazeExitPosition = exitPosition
        startTime = os.clock()
        
        if timerConnection then timerConnection:Disconnect() end
        timerConnection = RunService.RenderStepped:Connect(InGameHudController.updateTimer)
        
        if compassConnection then compassConnection:Disconnect() end
        compassConnection = RunService.RenderStepped:Connect(InGameHudController.updateCompass)

        -- Find the exit part on the provided model and connect the touch event
        -- Use WaitForChild to account for replication delay
        local exitPart = mazeModel:WaitForChild("ExitPart", 10) 
        if exitPart then
            if touchConnection then touchConnection:Disconnect() end
            touchConnection = exitPart.Touched:Connect(InGameHudController.onExitTouched)
        else
            warn("InGameHudController: Timed out waiting for ExitPart on the maze model!")
        end
    end
end

function InGameHudController.hide()
    if hudInstance then
        hudInstance.Enabled = false
        if timerConnection then timerConnection:Disconnect(); timerConnection = nil end
        if compassConnection then compassConnection:Disconnect(); compassConnection = nil end
        if touchConnection then touchConnection:Disconnect(); touchConnection = nil end
    end
end

function InGameHudController.start()
    hudInstance = InGameHudUI.create(player.PlayerGui)
    hudInstance.Enabled = false

    Remotes.ShowGameHud.OnClientEvent:Connect(InGameHudController.show)
    Remotes.HideGameHud.OnClientEvent:Connect(InGameHudController.hide)
    
    print("InGameHudController started")
end

return InGameHudController
