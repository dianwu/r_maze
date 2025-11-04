-- LevelSelectGui.lua

local LevelSelectGui = {}

function LevelSelectGui.create(parent)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LevelSelectGui"

    local smallButton = Instance.new("TextButton")
    smallButton.Name = "SmallButton"
    smallButton.Text = "Small Maze"
    smallButton.Size = UDim2.new(0, 200, 0, 50)
    smallButton.Position = UDim2.new(0.5, -100, 0.3, 0)
    smallButton.Parent = screenGui

    local mediumButton = Instance.new("TextButton")
    mediumButton.Name = "MediumButton"
    mediumButton.Text = "Medium Maze"
    mediumButton.Size = UDim2.new(0, 200, 0, 50)
    mediumButton.Position = UDim2.new(0.5, -100, 0.5, 0)
    mediumButton.Parent = screenGui

    local largeButton = Instance.new("TextButton")
    largeButton.Name = "LargeButton"
    largeButton.Text = "Large Maze"
    largeButton.Size = UDim2.new(0, 200, 0, 50)
    largeButton.Position = UDim2.new(0.5, -100, 0.7, 0)
    largeButton.Parent = screenGui

    screenGui.Parent = parent
    return screenGui
end

return LevelSelectGui
