-- GameLoopService.lua

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LeaderboardService = require(ServerScriptService.Services.LeaderboardService)
local MazeService = require(ServerScriptService.Services.MazeService)
local Remotes = require(ReplicatedStorage.Modules:WaitForChild("Remotes"))

local GameLoopService = {}

local playerStates = {}

function GameLoopService.startPlayerSession(player, difficulty)
    print("DEBUG: GameLoopService.startPlayerSession called for player: " .. player.Name .. ", difficulty: " .. difficulty)

    -- Clean up any existing maze for the player
    if playerStates[player] and playerStates[player].mazeModel then
        print("DEBUG: Cleaning up existing maze for player.")
        MazeService.destroy(playerStates[player].mazeModel)
    end

    local mazeData = MazeService.generate(difficulty)
    if not mazeData then
        warn("DEBUG: MazeService.generate returned nil. Aborting session start.")
        return
    end
    print("DEBUG: Maze generated. Start position: " .. tostring(mazeData.startPosition))

    local startTime = os.clock()
    playerStates[player] = {
        State = "InMaze",
        Difficulty = difficulty,
        StartTime = startTime,
        Score = 0,
        mazeModel = mazeData.mazeModel,
        startPosition = mazeData.startPosition
    }

    local character = player.Character or player.CharacterAdded:Wait()
    if not character then
        warn("DEBUG: Player character not found. Cannot teleport.")
        return
    end
    print("DEBUG: Character found: " .. character.Name)

    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then
        warn("DEBUG: HumanoidRootPart not found in character. Cannot teleport.")
        return
    end
    
    -- Clear the player's backpack before starting
    local backpack = player:FindFirstChildOfClass("Backpack")
    if backpack then
        backpack:ClearAllChildren()

        -- Debug: Print backpack contents after clearing
        print("DEBUG: Backpack contents after clearing:")
        if #backpack:GetChildren() == 0 then
            print("    (empty)")
        else
            for i, item in ipairs(backpack:GetChildren()) do
                print("    " .. i .. ": " .. item.Name)
            end
        end
    end
    
    print("DEBUG: HumanoidRootPart found. Current position: " .. tostring(rootPart.Position))
    
    print("DEBUG: Attempting to teleport player to " .. tostring(mazeData.PlayerStartPoint))
    rootPart.CFrame = CFrame.new(mazeData.PlayerStartPoint)
    print("DEBUG: Teleport CFrame set. New position should be " .. tostring(rootPart.Position))

    -- Pass the specific maze model to the client
    Remotes.EnterMaze:FireClient(player, mazeData.mazeModel, mazeData.exitPosition)
    print("GameLoopService: Player " .. player.Name .. " started maze of difficulty " .. difficulty)
end

function GameLoopService.endPlayerSession(player)
    local state = playerStates[player]
    if state then
        local elapsedTime = os.clock() - state.StartTime
        print("GameLoopService: Player " .. player.Name .. " finished maze in " .. elapsedTime .. " seconds with score " .. state.Score)
        
        LeaderboardService.saveScore(player, state.Difficulty, state.Score, elapsedTime)

        if state.mazeModel then
            MazeService.destroy(state.mazeModel)
        end

        playerStates[player] = nil
        Remotes.UpdateHUD:FireClient(player, "Lobby")
    end
end

function GameLoopService.getPlayerState(player)
    return playerStates[player]
end

function GameLoopService.onPlayerFinishedMaze(player)
    local state = playerStates[player]
    if state and state.State == "InMaze" then
        local elapsedTime = os.clock() - state.StartTime
        state.State = "Results"
        state.LastCompletionTime = elapsedTime
        
        Remotes.ExitMaze:FireClient(player)
        Remotes.DisplayResults:FireClient(player, elapsedTime)
    end
end

Remotes.PlayerFinishedMaze.OnServerEvent:Connect(GameLoopService.onPlayerFinishedMaze)

function GameLoopService.onRequestRetry(player)
    local state = playerStates[player]
    if state and state.State == "Results" then
        state.State = "InMaze"
        state.StartTime = os.clock()
        
        local character = player.Character or player.CharacterAdded:Wait()
        if character then
            local rootPart = character:FindFirstChild("HumanoidRootPart")
            if rootPart then
                rootPart.CFrame = CFrame.new(state.startPosition)
            end
        end
        
        -- Correctly fire the event with both the model and the exit position
        Remotes.EnterMaze:FireClient(player, state.mazeModel, state.mazeModel.ExitPart.Position)
    end
end

Remotes.RequestRetry.OnServerEvent:Connect(GameLoopService.onRequestRetry)

function GameLoopService.onRequestNewMaze(player)
    GameLoopService.endPlayerSession(player)
end

Remotes.RequestNewMaze.OnServerEvent:Connect(GameLoopService.onRequestNewMaze)

return GameLoopService