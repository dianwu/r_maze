--[[
    ItemController
    Handles client-side logic for item interactions.
    - Detects player input for picking up or placing items.
    - Provides visual feedback to the player.
    - Communicates with the server-side ItemService.
]]

local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Players = game:GetService("Players")

local Remotes = require(ReplicatedStorage.Modules.Remotes)
local PlaceCrateRequest = Remotes.PlaceCrateRequest
local CrateStateChanged = Remotes.CrateStateChanged
local SelectItemRequest = Remotes.SelectItemRequest

local BackpackController = require(script.Parent.BackpackController)

local ItemController = {}

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

local RunService = game:GetService("RunService")

local carriedCrate = nil
local previewCrate = nil
local placementModeActive = false
local renderSteppedConnection = nil

local function enterPlacementMode()
    if not carriedCrate or placementModeActive then return end
    placementModeActive = true

    -- Create a preview crate
    previewCrate = carriedCrate:Clone()
    previewCrate.Transparency = 0.5
    previewCrate.CanCollide = false
    previewCrate.Parent = workspace

    -- Start updating its position
    renderSteppedConnection = RunService.RenderStepped:Connect(function()
        -- TODO: The raycast for the mouse's target can sometimes hit the local player's character,
        -- causing the previewCrate to jump to a position right in front of the camera.
        -- This can be fixed by adding the player's character to a RaycastParams filter.
        local mouse = player:GetMouse()
        local targetPosition = mouse.Hit.p
        previewCrate.Position = targetPosition
    end)
end

local function exitPlacementMode()
    if not placementModeActive then return end
    placementModeActive = false

    if renderSteppedConnection then
        renderSteppedConnection:Disconnect()
        renderSteppedConnection = nil
    end

    if previewCrate then
        previewCrate:Destroy()
        previewCrate = nil
    end
end

local function onInputBegan(input, gameProcessedEvent)
    if gameProcessedEvent then return end

    if placementModeActive then
        if input.UserInputType == Enum.UserInputType.MouseButton1 then -- Left click to place
            print("CLIENT: Attempting to place crate via mouse click.")
            local selectedSlotIndex = BackpackController.getSelectedSlotIndex()
            if selectedSlotIndex and previewCrate then
                PlaceCrateRequest:FireServer(previewCrate.Position, selectedSlotIndex)
                BackpackController.clearSelection()
                -- The server response will trigger the exitPlacementMode via onCrateStateChanged
            end
        elseif input.UserInputType == Enum.UserInputType.MouseButton2 then -- Right click to cancel
            print("CLIENT: Canceling placement mode.")
            exitPlacementMode()
            -- Optionally, tell the server to un-hold the item
            local selectedSlotIndex = BackpackController.getSelectedSlotIndex()
            if selectedSlotIndex then
                Remotes.SelectItemRequest:FireServer(selectedSlotIndex) -- Re-selecting the same item will un-hold it
                BackpackController.clearSelection()
            end
        end
    end
end

local function onCrateStateChanged(crate, action, targetPlayer)
    if action == "pickup" then
        -- This is just to hide the crate from the world, no change needed here
        crate.Parent = nil
    elseif action == "hold" then
        if targetPlayer == player then
            carriedCrate = crate
            enterPlacementMode()
        end
    elseif action == "unhold" then
        if targetPlayer == player and carriedCrate and crate == carriedCrate then
            carriedCrate = nil
            exitPlacementMode()
        end
    elseif action == "place" then
        if carriedCrate and crate == carriedCrate then
            carriedCrate = nil
            exitPlacementMode()
        end
        -- Make the placed crate visible for all players
        local maze = workspace:FindFirstChild("MazeContainer")
        local cratesModel = maze and maze:FindFirstChildOfClass("Model") and maze:FindFirstChildOfClass("Model"):FindFirstChild("Crates")
        if cratesModel then
            crate.Parent = cratesModel
        else
            crate.Parent = workspace -- Fallback
        end
        crate.Anchored = true
        crate.CanCollide = true
        crate.Transparency = 0
        crate.Size = Vector3.new(5, 5, 5)
    end
end

function ItemController.start()
    player.CharacterAdded:Connect(function(newCharacter)
        character = newCharacter
        humanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
        exitPlacementMode() -- Ensure placement mode is off on respawn
        carriedCrate = nil
    end)

    CrateStateChanged.OnClientEvent:Connect(onCrateStateChanged)
    UserInputService.InputBegan:Connect(onInputBegan)
end

return ItemController
