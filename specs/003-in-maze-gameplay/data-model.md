# Data Model: In-Maze Gameplay

**Version**: 1.0
**Status**: Completed
**Author**: Gemini AI
**Created**: 2025-11-02
**Last Updated**: 2025-11-02

## 1. Overview

This document defines the data structures related to the in-maze gameplay experience. The primary focus is on managing the player's state during a maze run.

## 2. PlayerGameState

This is not a persistent data model but rather a transient state managed by the `GameLoopService` for each active player in a maze.

| Field Name | Data Type | Description | Example |
|---|---|---|---|
| `Player` | `Player` | The Roblox Player object. | `game.Players.LocalPlayer` |
| `CurrentMaze` | `table` | A reference to the maze data table from `MazeService`. | `{ Size = "Small", ExitPosition = Vector3.new(10, 0, 10) }` |
| `StartTime` | `number` | The server timestamp (`os.clock()`) when the player started the maze. | `12345.678` |
| `State` | `string` | The current state of the player in the game loop. | `"InMaze"`, `"Results"` |
| `LastCompletionTime` | `number` | The duration of the player's last completed run, in seconds. | `45.3` |

### State Transitions

1.  **`Lobby` -> `InMaze`**: When the player selects a maze, `GameLoopService` creates a `PlayerGameState`. `StartTime` is set.
2.  **`InMaze` -> `Results`**: When the player reaches the exit, the state transitions. `LastCompletionTime` is calculated (`os.clock() - StartTime`).
3.  **`Results` -> `InMaze`**: If the player chooses "Try Again", the state reverts. `StartTime` is reset.
4.  **`Results` -> `Lobby`**: If the player chooses "New Maze", the `PlayerGameState` is cleared/destroyed.
