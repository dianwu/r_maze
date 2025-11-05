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
local BackpackService = require(ServerScriptService.Services.BackpackService)

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
        
        local crate = crateAsset:Clone()
        crate.Size = Vector3.new(2, 2, 2) -- Smaller size for floating crates
        crate.Position = Vector3.new(xPos, crate.Size.Y / 2 + 2, zPos) -- Float slightly above ground
        crate.Anchored = true
        crate.CanCollide = false -- Players can walk through it to pick it up
        crate.Transparency = 0.2 -- Make it slightly transparent
        crate.Parent = cratesModel

        -- Add floating effect
        local bodyPos = Instance.new("BodyPosition")
        bodyPos.Position = crate.Position
        bodyPos.D = 1000 -- Damping
        bodyPos.P = 10000 -- Proportional control
        bodyPos.Parent = crate

        -- Add rotation effect
        local bodyAngVel = Instance.new("BodyAngularVelocity")
        bodyAngVel.AngularVelocity = Vector3.new(0, 1, 0) -- Rotate around Y-axis
        bodyAngVel.P = 10000
        bodyAngVel.Parent = crate

        -- Connect Touched event for pickup
        crate.Touched:Connect(function(hit)
            local player = game.Players:GetPlayerFromCharacter(hit.Parent)
            if player then
                ItemService.pickupCrate(player, crate)
            end
        end)
    end

    print("ItemService: Spawned " .. numberOfCrates .. " crates.")
end

function ItemService.pickupCrate(player, crate)
    -- Validation: Ensure the crate is a valid part and is in the workspace
    if not crate or not crate:IsA("Part") or not crate:IsDescendantOf(workspace) then
        return
    end

    -- Attempt to add to backpack
    local success = BackpackService.addItemToBackpack(player, crate)
    if success then
        print("SERVER: Player " .. player.Name .. " picked up crate " .. crate.Name .. " and added to backpack.")
        crate.Parent = nil -- Hide from workspace
        Remotes.CrateStateChanged:FireAllClients(crate, "pickup", player) -- Notify clients it's gone from world
    else
        warn("SERVER: Player " .. player.Name .. " could not pick up crate (backpack full or other issue).")
    end
end

function ItemService.placeCrate(player, position, itemIndex)
    local crate = _playerCrates[player]
    if not crate then
        warn("Player " .. player.Name .. " tried to place a crate but isn't carrying one.")
        return
    end

    -- Ensure the item being placed is the one currently held and is in the backpack
    local backpackItems = BackpackService.getBackpack(player)
    if not backpackItems[itemIndex] or backpackItems[itemIndex] ~= crate then
        warn("Player " .. player.Name .. " tried to place a crate that is not currently held or not in backpack at that index.")
        return
    end

    print("SERVER: Player " .. player.Name .. " placed crate " .. crate.Name .. " at " .. tostring(position))
    _playerCrates[player] = nil
    BackpackService.removeItemFromBackpack(player, itemIndex) -- Now, permanently remove from backpack

    -- Update crate properties and notify clients
    crate.Anchored = false -- Let physics settle it
    crate.CFrame = CFrame.new(position)
    task.wait(0.5) -- Wait for it to settle
    crate.Anchored = true -- Re-anchor after placing

    Remotes.CrateStateChanged:FireAllClients(crate, "place", player)
end

function ItemService.selectCrate(player, itemIndex)
    if _playerCrates[player] then
        -- Player is already holding a crate, just un-hold it.
        -- The client will handle putting it back visually.
        local currentlyHeldCrate = _playerCrates[player]
        _playerCrates[player] = nil
        Remotes.CrateStateChanged:FireAllClients(currentlyHeldCrate, "unhold", player)
        print("SERVER: Player " .. player.Name .. " unheld crate " .. currentlyHeldCrate.Name)
    end

    local backpackItems = BackpackService.getBackpack(player)
    local crate = backpackItems[itemIndex]

    if crate then
        print("SERVER: Player " .. player.Name .. " selected crate " .. crate.Name .. " from backpack.")
        _playerCrates[player] = crate
        Remotes.CrateStateChanged:FireAllClients(crate, "hold", player)
    else
        warn("SERVER: Player " .. player.Name .. " tried to select non-existent item from backpack at index " .. itemIndex)
    end
end

function ItemService.start()
    Remotes.PlaceCrateRequest.OnServerEvent:Connect(ItemService.placeCrate)
    Remotes.SelectItemRequest.OnServerEvent:Connect(ItemService.selectCrate)

    game.Players.PlayerRemoving:Connect(function(player)
        -- Drop all items from the player's backpack when they leave
        local backpackItems = BackpackService.getBackpack(player)
        local character = player.Character
        local dropPos = character and character:GetPrimaryPartCFrame().Position or Vector3.new(0, 5, 0)

        for i = #backpackItems, 1, -1 do -- Iterate backwards to safely remove items
            local crateToDrop = BackpackService.removeItemFromBackpack(player, i)
            if crateToDrop then
                -- Make the crate visible and anchored in the world
                crateToDrop.Parent = workspace.MazeContainer:FindFirstChildOfClass("Model"):FindFirstChild("Crates") or workspace
                crateToDrop.Anchored = true
                crateToDrop.CanCollide = true
                crateToDrop.Transparency = 0
                crateToDrop.Size = Vector3.new(4, 4, 4) -- Reset to original size
                crateToDrop.CFrame = CFrame.new(dropPos) -- Place at player's last position
                Remotes.CrateStateChanged:FireAllClients(crateToDrop, "place", nil) -- Notify clients it's back in world
            end
        end
        _playerCrates[player] = nil -- Clear any actively held item
    end)
end

return ItemService
