-- main.client.lua
-- Client-side entry point
-- This script sets up the UI, controllers, and client-side remote event handlers.

-- Services & Modules
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LevelSelectGui = require(ReplicatedStorage.UI.LevelSelectGui)
local InGameHud = require(ReplicatedStorage.UI.InGameHud)
local HintLogGui = require(ReplicatedStorage.UI.HintLogGui)
local LevelSelectController = require(script.Parent.Controllers.LevelSelectController)
local InGameHudController = require(script.Parent.Controllers.InGameHudController)
local ResultsController = require(script.Parent.Controllers.ResultsController)
local WaypointController = require(script.Parent.Controllers.WaypointController)
local ItemController = require(script.Parent.Controllers.ItemController)
local AudioController = require(script.Parent.Controllers.AudioController) -- 1. Load the new controller

-- Remotes
local Remotes = require(ReplicatedStorage.Modules:WaitForChild("Remotes"))

-- Local Player Setup
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Create UIs
local levelSelectGui = LevelSelectGui.create(playerGui)
local hintLogGui = HintLogGui.create(playerGui)

-- Setup Controllers
LevelSelectController.setup(levelSelectGui)
InGameHudController.start()
ResultsController.start()
WaypointController.start(hintLogGui)
ItemController.start()
AudioController.start() -- 2. Start the new controller

print("Client script is running.")

-- 3. Centralized Event Handling (Coordinator Logic)
Remotes.EnterMaze.OnClientEvent:Connect(function(mazeModel, exitPosition)
    print("Coordinator: EnterMaze received. Starting game...")
    InGameHudController.show(mazeModel, exitPosition)
    AudioController.playBackgroundMusic()
end)

Remotes.ExitMaze.OnClientEvent:Connect(function()
    print("Coordinator: ExitMaze received.")
    InGameHudController.hide()
end)

Remotes.DisplayResults.OnClientEvent:Connect(function(completionTime)
    print("Coordinator: DisplayResults received. Ending game...")
    ResultsController.show(completionTime)
    AudioController.stopBackgroundMusic()
end)

InGameHudController.OnExitTouched.Event:Connect(function()
    print("Coordinator: OnExitTouched received from InGameHudController.")
    AudioController.playExitSound()
end)


-- Add a trail effect to the player's character
local function addTrailEffect(character)
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

    -- Create the Trail object
    local trail = Instance.new("Trail")
    trail.Lifetime = 0.5
    trail.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.7, 0.5),
        NumberSequenceKeypoint.new(1, 1)
    })
    trail.Color = ColorSequence.new(Color3.fromRGB(0, 255, 255), Color3.fromRGB(0, 100, 255))
    trail.WidthScale = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0)
    })
    trail.FaceCamera = true

    -- Create attachments for the trail
    local attachment0 = Instance.new("Attachment")
    attachment0.Position = Vector3.new(0, 1, 0)
    attachment0.Parent = humanoidRootPart

    local attachment1 = Instance.new("Attachment")
    attachment1.Position = Vector3.new(0, -1, 0)
    attachment1.Parent = humanoidRootPart

    trail.Attachment0 = attachment0
    trail.Attachment1 = attachment1
    trail.Parent = humanoidRootPart
end

-- Connect to the CharacterAdded event
player.CharacterAdded:Connect(addTrailEffect)

-- Also add the effect if the character already exists
if player.Character then
    addTrailEffect(player.Character)
end
