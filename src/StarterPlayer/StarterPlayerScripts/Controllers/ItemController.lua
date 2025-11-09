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
local RunService = game:GetService("RunService")

local Remotes = require(ReplicatedStorage.Modules.Remotes)
local PlaceCrateRequest = Remotes.PlaceCrateRequest
local CrateStateChanged = Remotes.CrateStateChanged

local ItemController = {}

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()

local equippedTool = nil
local previewCrate = nil
local placementModeActive = false
local renderSteppedConnection = nil

local function enterPlacementMode()
    if not equippedTool or placementModeActive then return end
    
    local handle = equippedTool:FindFirstChild("Handle")
    if not handle then return end

    placementModeActive = true

    -- Create a preview crate
    previewCrate = handle:Clone()
    previewCrate.Size = Vector3.new(4, 4, 4) -- Set to final size for accurate preview
    previewCrate.Transparency = 0.5
    previewCrate.CanCollide = false
    previewCrate.Anchored = true -- Anchor the preview so it doesn't fall
    previewCrate.Parent = workspace

    -- Remove any physics movers from the preview
    for _, child in ipairs(previewCrate:GetChildren()) do
        if child:IsA("BodyMover") then
            child:Destroy()
        end
    end

    -- Start updating its position to be in front of the player
    renderSteppedConnection = RunService.RenderStepped:Connect(function()
        if not previewCrate or not character or not character:FindFirstChild("HumanoidRootPart") then return end
        
        local rootPart = character.HumanoidRootPart
        local forwardVector = rootPart.CFrame.LookVector
        local raycastOrigin = rootPart.Position + (forwardVector * 5) -- 5 studs in front
        
        -- Raycast down to find the ground
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {character, previewCrate}
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        
        local raycastResult = workspace:Raycast(raycastOrigin, Vector3.new(0, -10, 0), raycastParams)
        
        local groundPosition = raycastResult and raycastResult.Position or (rootPart.Position - Vector3.new(0, 3, 0))
        
        -- Adjust the position to sit on top of the surface
        local adjustedPosition = groundPosition + Vector3.new(0, previewCrate.Size.Y / 2, 0)
        previewCrate.CFrame = CFrame.new(adjustedPosition)
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
    if gameProcessedEvent or not placementModeActive then return end

    if input.UserInputType == Enum.UserInputType.MouseButton1 then -- Left click to place
        print("CLIENT: Attempting to place crate via mouse click.")
        if previewCrate then
            PlaceCrateRequest:FireServer(previewCrate.Position)
        end
    elseif input.UserInputType == Enum.UserInputType.MouseButton2 then -- Right click to cancel
        print("CLIENT: Canceling placement mode by unequipping.")
        if equippedTool then
            character.Humanoid:UnequipTools()
        end
    end
end

local function onCrateStateChanged(item, action, targetPlayer)
    if action == "pickup" then
        -- The tool is parented to the backpack on the server,
        -- here we just destroy the floating world model of it.
        local tool = item
        if tool and tool:IsA("Tool") then
             tool:Destroy()
        end
    elseif action == "place" then
        -- The server has placed the crate, which will be replicated automatically.
        -- The only thing the client needs to do is exit its placement mode.
        exitPlacementMode()
        
        -- The server is now responsible for parenting the placed crate.
        -- The client no longer needs to manually handle this.
    end
end

local function onToolEquipped(tool)
    if tool.Name == "CrateTool" then
        equippedTool = tool
        enterPlacementMode()
    end
end

local function onToolUnequipped(tool)
    if tool.Name == "CrateTool" then
        equippedTool = nil
        exitPlacementMode()
    end
end

local function onCharacterAdded(newCharacter)
    character = newCharacter
    exitPlacementMode()
    equippedTool = nil
    
    character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") and child.Name == "CrateTool" then
            onToolEquipped(child)
        end
    end)
    
    character.ChildRemoved:Connect(function(child)
        if child:IsA("Tool") then
            onToolUnequipped(child)
        end
    end)
end

function ItemController.start()
    player.CharacterAdded:Connect(onCharacterAdded)
    if player.Character then
        onCharacterAdded(player.Character)
    end

    CrateStateChanged.OnClientEvent:Connect(onCrateStateChanged)
    UserInputService.InputBegan:Connect(onInputBegan)
end

return ItemController
