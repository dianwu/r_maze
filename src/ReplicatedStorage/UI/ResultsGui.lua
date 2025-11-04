-- /src/ReplicatedStorage/UI/ResultsGui.lua
-- This module will contain the UI elements for the results screen.

local ResultsGui = {}

function ResultsGui.create()
    local screenGui = Instance.new("ScreenGui")
    
    local frame = Instance.new("Frame")
    frame.Name = "ResultsFrame"
    frame.Size = UDim2.new(0, 400, 0, 200)
    frame.Position = UDim2.new(0.5, -200, 0.5, -100)
    frame.BackgroundColor3 = Color3.new(0.1, 0.1, 0.1)
    frame.Parent = screenGui

    local timeLabel = Instance.new("TextLabel")
    timeLabel.Name = "TimeLabel"
    timeLabel.Size = UDim2.new(1, 0, 0, 50)
    timeLabel.Text = "Time: 00:00"
    timeLabel.TextColor3 = Color3.new(1, 1, 1)
    timeLabel.Parent = frame

    local tryAgainButton = Instance.new("TextButton")
    tryAgainButton.Name = "TryAgainButton"
    tryAgainButton.Size = UDim2.new(0, 150, 0, 50)
    tryAgainButton.Position = UDim2.new(0.5, -160, 0, 100)
    tryAgainButton.Text = "Try Again"
    tryAgainButton.Parent = frame

    local newMazeButton = Instance.new("TextButton")
    newMazeButton.Name = "NewMazeButton"
    newMazeButton.Size = UDim2.new(0, 150, 0, 50)
    newMazeButton.Position = UDim2.new(0.5, 10, 0, 100)
    newMazeButton.Text = "New Maze"
    newMazeButton.Parent = frame
    
    return screenGui
end

return ResultsGui
