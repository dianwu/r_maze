# Tasks: MVP Core Gameplay Features

**Input**: Design documents from `/specs/001-mvp-core-features/`

**Organization**: Tasks are grouped by user story to enable independent implementation and testing of each story.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: Can run in parallel (different files, no dependencies)
- **[Story]**: Which user story this task belongs to (e.g., US1, US2, US3)
- Include exact file paths in descriptions

---

## Phase 1: Setup (Shared Infrastructure)

**Purpose**: Project initialization and basic structure for a Rojo-based workflow.

- [x] T001 Create Rojo project file `default.project.json` in the root directory.
- [x] T002 Create project directories: `src/ReplicatedStorage`, `src/ServerScriptService`, `src/StarterPlayer/StarterPlayerScripts`.
- [x] T003 [P] Initialize TestEz framework in `src/ServerScriptService/Tests`.

---

## Phase 2: Foundational (Blocking Prerequisites)

**Purpose**: Core infrastructure that MUST be complete before ANY user story can be implemented.

- [x] T004 Create main server script entry point in `src/ServerScriptService/main.server.lua`.
- [x] T005 Create main client script entry point in `src/StarterPlayer/StarterPlayerScripts/main.client.lua`.
- [x] T006 [P] Implement `Remotes` folder and all `RemoteEvent`/`RemoteFunction` objects from `contracts.md` in `src/ReplicatedStorage/Remotes`.
- [x] T007 [P] Create a `Configuration` ModuleScript in `src/ReplicatedStorage/Modules/Configuration.lua` to hold values for collectibles.

**Checkpoint**: Foundation ready - user story implementation can now begin.

---

## Phase 3: User Story 1 - Play a Maze (Priority: P1) 🎯 MVP

**Goal**: Player can select a difficulty and play a maze from start to finish.
**Independent Test**: A player can join, select a difficulty, be teleported, run the maze, and have their time recorded upon finishing.

- [x] T008 [P] [US1] Implement `MazeService` ModuleScript in `src/ServerScriptService/Services/MazeService.lua` with a `generate` function using the Recursive Backtracker algorithm.
- [x] T009 [P] [US1] Implement `GameLoopService` ModuleScript in `src/ServerScriptService/Services/GameLoopService.lua` to manage player states (`Lobby`, `InMaze`) and timers.
- [x] T010 [P] [US1] Implement `LevelSelectController` on the client in `src/StarterPlayer/StarterPlayerScripts/Controllers/LevelSelectController.lua` to handle UI clicks and fire the `SelectDifficulty` remote event.
- [x] T011 [US1] Implement the server-side handler for the `SelectDifficulty` remote event in `main.server.lua` to call `GameLoopService` and teleport the player.
- [x] T012 [P] [US1] Create the basic UI for level selection (e.g., three buttons for Small, Medium, Large) in `StarterGui`.
- [x] T013 [P] [US1] Create the in-game HUD UI in `StarterGui` to display the timer and score.
- [x] T014 [US1] Implement the client-side handler for the `UpdateHUD` remote event in `main.client.lua` to update the HUD text labels.

**Checkpoint**: User Story 1 is fully functional and testable independently.

---

## Phase 4: User Story 2 - Earn a Score (Priority: P2)

**Goal**: Player can collect items to earn points.
**Independent Test**: Touching a collectible on the client correctly updates the score on the server, the object is destroyed, and the HUD reflects the new score.

- [x] T015 [P] [US2] Implement `ScoringService` ModuleScript in `src/ServerScriptService/Services/ScoringService.lua`.
- [x] T016 [US2] Modify `MazeService` (from T008) to spawn collectible `Part`s within the maze, using values from the `Configuration` module.
- [x] T017 [US2] In `ScoringService`, implement the server-side logic to handle `.Touched` events for collectibles. This must validate the touch, award points to the player, and destroy the collectible.

**Checkpoint**: User Stories 1 and 2 work independently and together.

---

## Phase 5: User Story 3 - Compete on Leaderboards (Priority: P3)

**Goal**: Player's performance is ranked on a leaderboard.
**Independent Test**: Completing a maze correctly calculates and saves the score to the `OrderedDataStore`. The lobby leaderboard UI correctly displays the top 20 ranks for that difficulty.

- [x] T018 [P] [US3] Implement `LeaderboardService` ModuleScript in `src/ServerScriptService/Services/LeaderboardService.lua` to handle saving scores and retrieving leaderboard data. All `DataStore` calls **MUST** be wrapped in `pcall()`.
- [x] T019 [US3] Modify `GameLoopService` (from T009) to call `LeaderboardService.saveScore` when a player finishes a maze.
- [x] T020 [P] [US3] Implement `LeaderboardController` on the client in `src/StarterPlayer/StarterPlayerScripts/Controllers/LeaderboardController.lua` to invoke the `GetLeaderboard` remote function and display the returned data.
- [x] T021 [US3] Implement the server-side handler for the `GetLeaderboard` remote function in `main.server.lua` that calls the `LeaderboardService`.
- [x] T022 [P] [US3] Create the leaderboard display UI in the lobby to show ranks, names, scores, and times.

**Checkpoint**: All user stories are independently functional.

---

## Phase N: Polish & Cross-Cutting Concerns

**Purpose**: Improvements that affect multiple user stories.

- [x] T023 [P] Implement "Standard" level logging in all services as per the clarification (log errors, maze generation, completion, score updates).
- [x] T024 [P] Implement the UI behavior for disabled buttons during maze regeneration (from clarification) in `LevelSelectController.lua`.
- [x] T025 Code cleanup, refactoring, and adding comments where necessary.

---

## Dependencies & Execution Order

- **Phase 1 (Setup)** must be completed first.
- **Phase 2 (Foundational)** depends on Phase 1 and blocks all user stories.
- **User Stories (Phase 3, 4, 5)** can be implemented sequentially (P1 → P2 → P3) or in parallel if staffed, as they are largely independent after the foundational phase.

