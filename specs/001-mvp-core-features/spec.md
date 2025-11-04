# Feature Specification: MVP Core Gameplay Features

**Feature Branch**: `001-mvp-core-features`
**Created**: 2025-11-01
**Status**: Draft
**Input**: User description: "此規範定義了遊戲 V1.0 版本（Minimum Viable Product, 最小可行產品）必須包含的基礎功能..."

## Clarifications

### Session 2025-11-01
- Q: How often should the maze layout be regenerated for all players? → A: Daily: 每天在固定時間更新一次。

- Q: How should the UI respond when a player tries to select a maze that is currently being regenerated? → A: Disable the button and show a "Regenerating..." label on it.

- Q: What is the desired quantity of collectibles per maze and their individual score value? → A: Define in a config module.

- Q: What level of logging is required for key game events beyond DataStore failures? → A: Standard (Errors + major events like maze generation, player completion, score updates).

## User Scenarios & Testing *(mandatory)*

### User Story 1 - Play a Maze (Priority: P1)

As a player, I want to select a maze difficulty from a lobby, be transported to the start of the maze, and run through it to the finish line, so that I can experience the core gameplay loop.

**Why this priority**: This is the fundamental gameplay experience. Without it, there is no game.

**Independent Test**: A player can join the game, select any difficulty, and play the corresponding maze from the designated start point to the end point. The game timer must start and stop correctly.

**Acceptance Scenarios**:

1.  **Given** a player is in the Lobby, **When** they interact with the "Small" difficulty UI button, **Then** they are teleported to the starting area of the small maze.
2.  **Given** a player is at the maze start point, **When** they leave the designated "safe zone", **Then** a server-side timer for that player begins.
3.  **Given** a player is inside the maze, **When** they reach the designated "finish" area, **Then** the server-side timer stops and their final time is recorded.

---

### User Story 2 - Earn a Score (Priority: P2)

As a player, I want to find and collect items scattered throughout the maze to earn points, so that my performance is measured by more than just completion time.

**Why this priority**: This adds a layer of skill and strategy, encouraging exploration and replayability beyond just finding the fastest route.

**Independent Test**: Collectibles are present in the maze. When a player touches a collectible, their score increases on the HUD, and the object is removed. This action must be validated and controlled by the server.

**Acceptance Scenarios**:

1.  **Given** a maze has been generated, **When** the game loop starts, **Then** collectible items are scattered in random, reachable locations.
2.  **Given** a player is inside the maze, **When** they touch a collectible `Part`, **Then** the server validates the collection, increases the player's score, and the collectible is destroyed for all players.
3.  **Given** a player has collected an item, **When** they look at their HUD, **Then** their score display is immediately updated.

---

### User Story 3 - Compete on Leaderboards (Priority: P3)

As a competitive player, I want my performance (score and time) to be ranked on a leaderboard for each difficulty, so I can compare my skills against other players and strive for the top spot.

**Why this priority**: Leaderboards are a key driver of long-term engagement and competition, encouraging players to master the game.

**Independent Test**: After a player completes a maze, their composite score is calculated and saved to the correct `OrderedDataStore`. The in-lobby leaderboard display for that difficulty is updated to reflect the new ranking if the player makes it into the top 20.

**Acceptance Scenarios**:

1.  **Given** a player has finished a maze, **When** their score and time are finalized, **Then** the system calculates a composite score using the formula: `(Score * 1000) - TotalSeconds`.
2.  **Given** a composite score has been calculated, **When** the system saves it, **Then** it uses the correct `OrderedDataStore` for the completed difficulty (Small, Medium, or Large).
3.  **Given** a player is in the Lobby, **When** they view the leaderboard display, **Then** it shows the top 20 players for each difficulty, listing their name, score, and time.
4.  **Given** any `DataStore` operation, **When** it is executed, **Then** it is wrapped in a `pcall()` to handle potential API errors gracefully.

---

### Edge Cases

-   **DataStore Failure**: What happens if an `OrderedDataStore` call fails even with `pcall` (e.g., due to Roblox service outages)? The system should log the error, and the player should receive a message indicating their score could not be saved.
-   **Player Disconnect**: If a player disconnects mid-game, their current run is considered abandoned and is not saved to the leaderboard.
-   **Server Crash**: If the server crashes, all in-progress game data for that session will be lost. The system will not attempt to recover mid-game state upon restart.

## Requirements *(mandatory)*

### Functional Requirements

-   **FR-001**: The system **MUST** generate mazes using the Recursive Backtracker algorithm.
-   **FR-002**: Maze generation **MUST** be configurable by width and height parameters.
-   **FR-003**: The maze seed **MUST** be updated daily at a fixed time on the server to ensure all players compete on the same layout.
-   **FR-004**: The game loop **MUST** manage two distinct player states: "Lobby" and "InMaze".
-   **FR-005**: The game timer **MUST** be controlled entirely by the server, starting when a player leaves the start zone and stopping when they enter the finish zone.
-   **FR-006**: Collectible items **MUST** be server-side objects, and all collection logic (validation, scoring, destruction) **MUST** execute on the server.
-   **FR-007**: The system **MUST** use a separate `OrderedDataStore` for each of the three maze difficulties.
-   **FR-008**: The system **MUST** provide at least three maze difficulties: Small (e.g., 20x20), Medium (e.g., 35x35), and Large (e.g., 50x50).
-   **FR-009**: The in-game HUD **MUST** display a timer (MM:SS.ss format) and the player's current score.
-   **FR-010**: The Lobby **MUST** contain a UI for level selection and a display for the leaderboards.
-   **FR-011**: All `DataStore` API calls **MUST** be wrapped in `pcall()` to prevent script failures.
-   **FR-012**: When a maze is undergoing regeneration, its corresponding level selection UI button **MUST** be disabled and display a "Regenerating..." label.
-   **FR-013**: The quantity of collectibles per maze and their individual score values **MUST** be configurable, ideally through a dedicated configuration module.
-   **FR-014**: The system **MUST** implement standard logging for key game events, including errors, maze generation, player completion, and score updates.

### Key Entities

-   **Player**: Represents the user in the game. Has a state (Lobby, InMaze) and session data (current score, start time).
-   **Maze**: A server-generated structure defined by dimensions (width, height) and a seed. Contains a start zone, an end zone, and collectibles.
-   **Collectible**: A server-controlled object within the maze that awards points when touched.
-   **Leaderboard**: An `OrderedDataStore` for each maze difficulty that stores player rankings based on a composite score.

## Success Criteria *(mandatory)*

### Measurable Outcomes

-   **SC-001**: 100% of players can successfully select a difficulty, enter a maze, and complete it by reaching the finish line.
-   **SC-002**: Player scores and times are recorded with 100% accuracy on the correct leaderboard upon maze completion.
-   **SC-003**: The in-game HUD correctly displays the elapsed time and current score for 100% of players actively in a maze.
-   **SC-004**: The lobby leaderboards correctly display the top 20 players for each difficulty, with data being no more than 5 minutes out of date.
-   **SC-005**: The system can support at least 50 concurrent players actively running mazes without server-side game logic (timing, scoring, collection) error rates exceeding 1%.