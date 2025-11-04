-- /src/StarterPlayer/StarterPlayerScripts/Controllers/WaypointController.lua
-- This controller handles the client-side logic for waypoints.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Remotes = require(ReplicatedStorage.Modules.Remotes)

local WaypointController = {}

-- Constants for distance conversion
local CELL_SIZE = 12 -- Studs per maze cell
local STUDS_PER_METER = 3.57 -- Approximate conversion rate

local hintLog

function WaypointController.start(hintLogGui)
    hintLog = hintLogGui
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    Remotes.ShowWaypointDistance.OnClientEvent:Connect(function(distanceInSteps, waypointPart)
        if not waypointPart or not waypointPart:IsA("BasePart") then return end

        -- Convert distance from steps to meters
        local distanceInStuds = distanceInSteps * CELL_SIZE
        local distanceInMeters = distanceInStuds / STUDS_PER_METER
        local distanceText = string.format("%.1f 公尺", distanceInMeters)

        -- Add the hint to the persistent log
        if hintLog then
            hintLog:addHint(distanceText)
        end

        -- Create the temporary display GUI
        local screenGui = Instance.new("ScreenGui")
        screenGui.ResetOnSpawn = false
        screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

        local textLabel = Instance.new("TextLabel")
        textLabel.Text = "距離終點: " .. distanceText
        textLabel.Size = UDim2.new(0.8, 0, 0.2, 0)
        textLabel.Position = UDim2.new(0.5, 0, 0.2, 0)
        textLabel.AnchorPoint = Vector2.new(0.5, 0.5)
        textLabel.BackgroundTransparency = 1
        textLabel.Font = Enum.Font.SourceSansBold
        textLabel.TextColor3 = Color3.new(1, 1, 1)
        textLabel.TextScaled = true
        textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        textLabel.TextStrokeTransparency = 0.5
        textLabel.Parent = screenGui

        screenGui.Parent = playerGui

        -- Fade out and destroy the GUI after a delay
        task.delay(3, function()
            local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.Out)
            local tween = TweenService:Create(textLabel, tweenInfo, {TextTransparency = 1, TextStrokeTransparency = 1})
            tween:Play()
            tween.Completed:Wait()
            screenGui:Destroy()
        end)

        -- Destroy the waypoint part on the client
        waypointPart:Destroy()
    end)
end

return WaypointController
