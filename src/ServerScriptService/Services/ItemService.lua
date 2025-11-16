--[[
    ItemService
    Handles the logic for all in-game items (crates, etc.).
    - Spawning items within the maze.
    - Handling player pickup and placement actions.
    - Managing item state and ownership.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Remotes = require(ReplicatedStorage.Modules.Remotes)

local ItemService = {}

local ASSET_FOLDER = ReplicatedStorage:WaitForChild("Assets")

-- Store which player is carrying which crate (actively held, not in backpack)
local _playerCrates = {} -- [player] = crateInstance

function ItemService.spawnCratesInMaze(maze)
    print("ItemService: Spawning crates in maze.")
    local crateAsset = ASSET_FOLDER:FindFirstChild("Crate")
    if not crateAsset then
        -- This is a fallback for studio testing if the asset doesn't exist.
        -- In a real environment, the asset would be created by the loader from the .meta.json
        warn("ItemService: Crate asset not found! Creating a temporary one.")
        crateAsset = Instance.new("Part")
        crateAsset.Name = "Crate"
        crateAsset.Size = Vector3.new(4, 4, 4)
        crateAsset.Color = Color3.fromRGB(132, 82, 36)
        crateAsset.Material = Enum.Material.Wood
        crateAsset.Anchored = true
        crateAsset.Parent = ASSET_FOLDER
    end

    local cratesModel = Instance.new("Model")
    cratesModel.Name = "Crates"
    cratesModel.Parent = maze.mazeModel

    local emptyTiles = {}
    for x = 1, maze.widthInCells do
        for y = 1, maze.depthInCells do
            -- Exclude start and exit positions to avoid blocking them
            if (x ~= maze.startPosition.X and y ~= maze.startPosition.Z) and (x ~= maze.exitPosition.X and y ~= maze.exitPosition.Z) then
                table.insert(emptyTiles, {x = x, y = y})
            end
        end
    end

    -- Spawn crates in about 5% of the empty tiles
    local numberOfCrates = math.max(1, math.floor(#emptyTiles * 0.05))
    
    for i = 1, numberOfCrates do
        if #emptyTiles == 0 then break end

        local randomIndex = math.random(#emptyTiles)
        local tile = table.remove(emptyTiles, randomIndex)

        local halfMazeW = (maze.widthInCells * maze.cellSize) / 2
        local halfMazeD = (maze.depthInCells * maze.cellSize) / 2

        local xPos = (tile.x - 1) * maze.cellSize - halfMazeW + maze.cellSize / 2
        local zPos = (tile.y - 1) * maze.cellSize - halfMazeD + maze.cellSize / 2
        
        local cratePart = crateAsset:Clone()

        -- Remove any scripts that might be embedded in the asset
        for _, child in ipairs(cratePart:GetDescendants()) do
            if child:IsA("Script") or child:IsA("LocalScript") then
                child:Destroy()
            end
        end
        
        cratePart.Name = "Handle"
        cratePart.Size = Vector3.new(2, 2, 2) -- Smaller size for floating crates
        cratePart.Position = Vector3.new(xPos, cratePart.Size.Y / 2 + 2, zPos) -- Float slightly above ground
        cratePart.Anchored = true
        cratePart.CanCollide = false -- Players can walk through it to pick it up
        cratePart.Transparency = 0.2 -- Make it slightly transparent
        
        local tool = Instance.new("Tool")
        tool.Name = "CrateTool"
        tool.Parent = cratesModel
        cratePart.Parent = tool

        -- Add floating effect
        local bodyPos = Instance.new("BodyPosition")
        bodyPos.Position = cratePart.Position
        bodyPos.D = 1000 -- Damping
        bodyPos.P = 10000 -- Proportional control
        bodyPos.Parent = cratePart

        -- Add rotation effect
        local bodyAngVel = Instance.new("BodyAngularVelocity")
        bodyAngVel.AngularVelocity = Vector3.new(0, 1, 0) -- Rotate around Y-axis
        bodyAngVel.P = 10000
        bodyAngVel.Parent = cratePart

        -- Connect Touched event for pickup
        cratePart.Touched:Connect(function(hit)
            local player = game.Players:GetPlayerFromCharacter(hit.Parent)
            if player then
                ItemService.pickupCrate(player, tool)
            end
        end)
    end

    print("ItemService: Spawned " .. numberOfCrates .. " crates.")
end

function ItemService.pickupCrate(player, tool)
    -- Validation: Ensure the crate is a valid tool and is in the workspace
    if not tool or not tool:IsA("Tool") or not tool:IsDescendantOf(workspace) then
        return
    end

    -- Clone the tool to give a unique copy to the player, then destroy the original
    local toolClone = tool:Clone()

    -- Clean up any physics movers and unanchor the handle from the tool before giving it to the player
    local handle = toolClone:FindFirstChild("Handle")
    if handle then
        for _, child in ipairs(handle:GetChildren()) do
            if child:IsA("BodyMover") then
                child:Destroy()
            end
        end
        handle.Anchored = false -- <--- 關鍵修正：解除錨定
    end

    local backpack = player:FindFirstChildOfClass("Backpack")
    toolClone.Parent = backpack
    
    -- Debug: Print backpack contents after adding the crate
    print("DEBUG: Backpack contents after adding " .. toolClone.Name .. ":")
    if backpack then
        local backpackItems = backpack:GetChildren()
        if #backpackItems == 0 then
            print("    (empty)")
        else
            for i, item in ipairs(backpackItems) do
                print("    Slot " .. i .. ": " .. item.Name)
            end
        end
    else
        print("    (Backpack not found!)")
    end
    
    print("SERVER: Player " .. player.Name .. " picked up crate " .. tool.Name .. " and added to backpack.")
    Remotes.CrateStateChanged:FireAllClients(tool, "pickup", player) -- Notify clients the original is gone
    
    tool:Destroy()
end

function ItemService.placeCrate(player, position)
    local character = player.Character
    if not character then return end

    -- The tool to be placed must be equipped (i.e., a child of the character)
    local tool = character:FindFirstChildOfClass("Tool")
    if not tool or tool.Name ~= "CrateTool" then
        warn("Player " .. player.Name .. " tried to place a crate but isn't holding one.")
        return
    end

    local handle = tool:FindFirstChild("Handle")
    if not handle then
        warn("CrateTool for player " .. player.Name .. " is missing its Handle.")
        return
    end

        print("SERVER: Player " .. player.Name .. " placed crate " .. tool.Name .. " at " .. tostring(position))
    
        -- Get the player's current maze model from the GameLoopService
        local GameLoopService = require(ServerScriptService.Services.GameLoopService)
        local playerState = GameLoopService.getPlayerState(player)
    
        -- Clone the handle to break the weld to the player's character
        local cratePart = handle:Clone()
    
        if not playerState or not playerState.mazeModel then
            warn("Could not find a valid maze model for player " .. player.Name .. ". Placing crate in workspace as a fallback.")
            cratePart.Parent = workspace
        else
            local cratesModel = playerState.mazeModel:FindFirstChild("Crates")
            if not cratesModel then
                warn("Could not find 'Crates' folder in the player's maze model. Creating one.")
                cratesModel = Instance.new("Model")
                cratesModel.Name = "Crates"
                cratesModel.Parent = playerState.mazeModel
            end
            cratePart.Parent = cratesModel
        end
        
        -- Set the properties of the newly placed crate part
        local rootPart = character:FindFirstChild("HumanoidRootPart")
        local safeYPosition = rootPart and rootPart.Position.Y or position.Y
        cratePart.CFrame = CFrame.new(position.X, safeYPosition, position.Z)
        cratePart.Anchored = true -- 立即錨定，防止掉落
        cratePart.CanCollide = true
        cratePart.Transparency = 0
        cratePart.Size = Vector3.new(4, 4, 4) -- Reset to original size
    
        -- Explicitly remove the "Wall" tag, just in case the asset has it by mistake
        local CollectionService = game:GetService("CollectionService")
        if CollectionService:HasTag(cratePart, "Wall") then
            CollectionService:RemoveTag(cratePart, "Wall")
        end

        -- Notify clients about the placed crate (which is the handle)
        task.wait(0.05) -- Give replication a moment
        Remotes.CrateStateChanged:FireAllClients(cratePart, "place", player)
    
        -- Destroy the tool from the player's inventory
        tool:Destroy()end



function ItemService.start()
    Remotes.PlaceCrateRequest.OnServerEvent:Connect(ItemService.placeCrate)

    game.Players.PlayerRemoving:Connect(function(player)
        -- Drop all items from the player's backpack when they leave
        local backpack = player:FindFirstChildOfClass("Backpack")
        if not backpack then return end

        local character = player.Character
        local dropPos = character and character:GetPrimaryPartCFrame().Position or Vector3.new(0, 5, 0)

        for _, crateToDrop in ipairs(backpack:GetChildren()) do
            -- Make the crate visible and anchored in the world
            crateToDrop.Parent = workspace.MazeContainer:FindFirstChildOfClass("Model"):FindFirstChild("Crates") or workspace
            crateToDrop.Anchored = true
            crateToDrop.CanCollide = true
            crateToDrop.Transparency = 0
            crateToDrop.Size = Vector3.new(4, 4, 4) -- Reset to original size
            crateToDrop.CFrame = CFrame.new(dropPos) -- Place at player's last position
            Remotes.CrateStateChanged:FireAllClients(crateToDrop, "place", nil) -- Notify clients it's back in world
        end
        _playerCrates[player] = nil -- Clear any actively held item
    end)
end

return ItemService
