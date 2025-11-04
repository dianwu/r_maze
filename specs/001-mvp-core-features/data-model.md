# Data Model: MVP Core Gameplay Features

This document defines the key data entities for the maze game.

---

### 1. Player

Represents a user in the game.

**Attributes**:
-   `UserId` (string): The player's unique Roblox user ID. (Primary Key)
-   `State` (string): The player's current state. Enum: `Lobby`, `InMaze`.
-   `CurrentSession` (table | nil): A table containing data for the current maze run. Is `nil` if the player is in the Lobby.
    -   `Difficulty` (string): The difficulty of the current maze (e.g., "Small", "Medium", "Large").
    -   `StartTime` (number): The `os.clock()` timestamp when the player started the maze.
    -   `Score` (number): The player's score for the current run.

**State Transitions**:
-   `Lobby` -> `InMaze`: When the player selects a difficulty and is teleported to the maze.
-   `InMaze` -> `Lobby`: When the player finishes the maze, disconnects, or returns to the lobby manually.

---

### 2. Maze

A server-generated structure for a specific difficulty level.

**Attributes**:
-   `Difficulty` (string): The difficulty level this maze corresponds to. (Primary Key)
-   `Seed` (number): The seed used to generate the maze layout.
-   `Dimensions` (table): The width and height of the maze (e.g., `{ Width = 20, Height = 20 }`).
-   `Collectibles` (table): A list of `Collectible` objects within the maze.

---

### 3. Collectible

A server-controlled object within the maze that awards points.

**Attributes**:
-   `Instance` (Part): The actual `Part` object in the workspace.
-   `Value` (number): The score awarded when collected.

---

### 4. LeaderboardEntry

Represents a player's record on a specific leaderboard.

**Attributes**:
-   `UserId` (string): The player's unique Roblox user ID.
-   `PlayerName` (string): The player's display name.
-   `CompositeScore` (number): The calculated score used for ranking. Formula: `(Score * 1000) - TotalSeconds`.
-   `RawScore` (number): The total score from collectibles.
-   `Time` (number): The total time taken in seconds.
