-- /src/ReplicatedStorage/UI/InGameHud.lua
-- This module will contain the UI elements for the in-game HUD.

local InGameHud = {}

function InGameHud.create(parent)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "InGameHud"
    
    -- Timer
    local timerLabel = Instance.new("TextLabel")
    timerLabel.Name = "TimerLabel"
    timerLabel.Size = UDim2.new(0, 200, 0, 50)
    timerLabel.Position = UDim2.new(0.02, 0, 0.98, 0) -- Position to bottom-left
    timerLabel.AnchorPoint = Vector2.new(0, 1) -- Anchor to bottom-left
    timerLabel.Text = "Time: 00:00"
    timerLabel.TextColor3 = Color3.new(1, 1, 1)
    timerLabel.BackgroundTransparency = 1
    timerLabel.Font = Enum.Font.SourceSansBold
    timerLabel.TextSize = 24
    timerLabel.Parent = screenGui

    -- Compass (placeholder)
    local compassFrame = Instance.new("Frame")
    compassFrame.Name = "CompassFrame"
    compassFrame.Size = UDim2.new(0, 100, 0, 100)
    compassFrame.Position = UDim2.new(1, -120, 1, -120)
    compassFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    compassFrame.BackgroundTransparency = 0.5
    compassFrame.Parent = screenGui

    local distanceLabel = Instance.new("TextLabel")
    distanceLabel.Name = "DistanceLabel"
    distanceLabel.Size = UDim2.new(0, 100, 0, 20)
    distanceLabel.Position = UDim2.new(0, 0, 0, -25) -- Position it above the compass frame
    distanceLabel.AnchorPoint = Vector2.new(0.5, 1)
    distanceLabel.Text = "100.0m"
    distanceLabel.TextColor3 = Color3.new(1, 1, 1)
    distanceLabel.BackgroundTransparency = 1
    distanceLabel.Font = Enum.Font.SourceSans
    distanceLabel.TextSize = 18
    distanceLabel.Parent = compassFrame

    local compassArrow = Instance.new("TextLabel")
    compassArrow.Name = "CompassArrow"
    compassArrow.Size = UDim2.new(1, 0, 1, 0)
    compassArrow.Text = "^"
    compassArrow.TextColor3 = Color3.new(1, 0, 0)
    compassArrow.BackgroundTransparency = 1
    compassArrow.Font = Enum.Font.SourceSansBold
    compassArrow.TextSize = 48
    compassArrow.Parent = compassFrame

    screenGui.Parent = parent
    return screenGui
end

return InGameHud