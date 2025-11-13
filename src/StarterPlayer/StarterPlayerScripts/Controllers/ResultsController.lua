-- /src/StarterPlayer/StarterPlayerScripts/Controllers/ResultsController.lua
-- This controller will manage the results screen.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Modules.Remotes)
local ResultsGui = require(ReplicatedStorage.UI.ResultsGui)

local ResultsController = {}

local resultsInstance

function ResultsController.hide()
    if resultsInstance then
        resultsInstance.Enabled = false
    end
end

function ResultsController.show(completionTime)
    if resultsInstance then
        resultsInstance.Enabled = true
        resultsInstance.ResultsFrame.TimeLabel.Text = string.format("Time: %.2f", completionTime)
    end
end

function ResultsController.start()
    resultsInstance = ResultsGui.create()
    resultsInstance.Parent = game.Players.LocalPlayer.PlayerGui
    resultsInstance.Enabled = false

    resultsInstance.ResultsFrame.TryAgainButton.MouseButton1Click:Connect(function()
        Remotes.RequestRetry:FireServer()
        ResultsController.hide()
    end)
    
    resultsInstance.ResultsFrame.NewMazeButton.MouseButton1Click:Connect(function()
        Remotes.RequestNewMaze:FireServer()
        ResultsController.hide()
    end)

    -- Remote event connection is now handled by main.client.lua
    print("ResultsController started")
end

return ResultsController
