-- LevelSelectController.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Modules:WaitForChild("Remotes"))
local SelectDifficultyEvent = Remotes.SelectDifficulty

local LevelSelectController = {}

function LevelSelectController.handleRegeneration(button)
    button.AutoButtonColor = false
    button.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    button.Text = "Regenerating..."
    task.wait(2) -- Simulate regeneration time
    button.AutoButtonColor = true
    button.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    -- This is a simplified example. In a real game, the text would be reset by another event.
end

function LevelSelectController.setup(levelSelectGui)
    local smallButton = levelSelectGui:FindFirstChild("SmallButton")
    local mediumButton = levelSelectGui:FindFirstChild("MediumButton")
    local largeButton = levelSelectGui:FindFirstChild("LargeButton")

    if smallButton then
        smallButton.MouseButton1Click:Connect(function()
            if smallButton.AutoButtonColor then
                SelectDifficultyEvent:FireServer("Small")
                levelSelectGui.Enabled = false
            end
        end)
    end

    if mediumButton then
        mediumButton.MouseButton1Click:Connect(function()
            if mediumButton.AutoButtonColor then
                SelectDifficultyEvent:FireServer("Medium")
                levelSelectGui.Enabled = false
            end
        end)
    end

    if largeButton then
        largeButton.MouseButton1Click:Connect(function()
            if largeButton.AutoButtonColor then
                SelectDifficultyEvent:FireServer("Large")
                levelSelectGui.Enabled = false
            end
        end)
    end
end

return LevelSelectController
