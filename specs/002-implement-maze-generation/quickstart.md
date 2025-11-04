# Quickstart Guide: MazeService

**Version**: 1.0
**Status**: Draft
**Author**: Gemini
**Created**: 2025-11-02
**Last Updated**: 2025-11-02
**Feature Spec**: [spec.md](./spec.md)
**Implementation Plan**: [plan.md](./plan.md)
**Data Model**: [data-model.md](./data-model.md)
**Contracts**: [contracts.md](./contracts.md)

## 1. Overview

This guide provides a quick introduction to using the updated `MazeService` for generating and destroying mazes within the game. It assumes you have a basic understanding of Luau and the Roblox Engine API.

## 2. Accessing the `MazeService`

The `MazeService` is a server-side module. You can access it from any server script using `require`:

```lua
local ServerScriptService = game:GetService("ServerScriptService")
local MazeService = require(ServerScriptService.Services.MazeService)
```

## 3. Generating a Maze

To generate a maze, call the `generate` function on the `MazeService`, passing in the desired difficulty. The function will return a `Model` containing the physical maze parts.

```lua
-- Example: Generate a medium difficulty maze
local difficulty = "Medium" -- Can be "Small", "Medium", or "Large" (as defined in Configuration.lua)
local generatedMazeModel = MazeService.generate(difficulty)

print("Generated maze model: " .. generatedMazeModel.Name)
-- The generatedMazeModel is automatically parented to the workspace.
```

### Available Difficulties

The available difficulties are defined in `src/ReplicatedStorage/Modules/Configuration.lua`. Common examples include:

-   `"Small"`
-   `"Medium"`
-   `"Large"`

## 4. Destroying a Maze

When a maze is no longer needed (e.g., at the end of a player's session), you should call the `destroy` function to remove it from the workspace and clean up memory.

```lua
-- Example: Destroy a previously generated maze
MazeService.destroy(generatedMazeModel)

print("Destroyed maze model.")
```

## 5. Example Usage Flow

Here's a typical flow for generating and destroying a maze within a game session:

```lua
-- In a GameLoopService or similar server-side logic:

local ServerScriptService = game:GetService("ServerScriptService")
local MazeService = require(ServerScriptService.Services.MazeService)

local currentMaze = nil

function startGameSession(player)
    -- ... other game setup ...

    -- Generate a maze for the player
    local difficulty = "Medium" -- Or dynamically determined
    currentMaze = MazeService.generate(difficulty)
    print("Maze generated for player " .. player.Name)

    -- Teleport player into the maze, etc.
    -- ...
end

function endGameSession(player)
    -- ... other game cleanup ...

    -- Destroy the maze if one exists
    if currentMaze then
        MazeService.destroy(currentMaze)
        print("Maze destroyed for player " .. player.Name)
        currentMaze = nil
    end
end

-- Simulate a game session
-- startGameSession(somePlayerObject)
-- -- ... gameplay ...
-- endGameSession(somePlayerObject)
```
