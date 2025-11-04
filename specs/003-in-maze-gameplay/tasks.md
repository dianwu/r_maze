# Tasks: In-Maze Gameplay Features

**Version**: 1.0
**Status**: To Do
**Author**: Gemini AI
**Created**: 2025-11-02
**Last Updated**: 2025-11-02

## 1. Overview

This document outlines the development tasks for implementing the in-maze gameplay features, including the compass, timer, results screen, and dynamic player start position.

## 2. Phase 1: Setup & Foundational Tasks

These tasks prepare the existing project structure for the new gameplay features.

- [x] T001 Update `Remotes` module in `src/ReplicatedStorage/Modules/Remotes.lua` to include new RemoteEvents: `PlayerFinishedMaze`, `RequestRetry`, `RequestNewMaze`, `ShowGameHud`, `ShowResults`, `HideGameHud`.
- [x] T002 Create a new `InGameHudController.lua` module in `src/StarterPlayer/StarterPlayerScripts/Controllers/`.
- [x] T003 Create a new `ResultsController.lua` module in `src/StarterPlayer/StarterPlayerScripts/Controllers/`.
- [x] T004 Create a new `ResultsGui.lua` module in `src/ReplicatedStorage/UI/`.
- [x] T005 Modify `_SetupRemotes.server.lua` to connect server-side handlers for the new client-to-server RemoteEvents.

## 3. Phase 2: US1 - In-Game HUD (Compass & Timer)

**Goal**: As a player, when I enter a maze, I want to see a compass pointing towards the exit and a timer that starts automatically.

**Independent Test Criteria**:
- When a maze is selected, the Level Select UI disappears.
- The In-Game HUD, containing a timer and a compass, becomes visible.
- The timer starts counting up from 00:00.
- The compass points towards the maze exit.

### Implementation Tasks

- [x] T006 [US1] Implement the basic UI for the `InGameHud` in `src/ReplicatedStorage/UI/InGameHud.lua`, including placeholders for a timer and a compass.
- [x] T007 [US1] In `InGameHudController.lua`, implement the client-side logic to show/hide the HUD based on the `ShowGameHud` and `HideGameHud` events.
- [x] T008 [US1] In `InGameHudController.lua`, implement the timer functionality, starting it when the HUD is shown and updating the UI every frame.
- [x] T009 [P] [US1] In `InGameHudController.lua`, implement the compass logic. It should get the maze exit location from the `ShowGameHud` event payload and update the compass rotation every frame to point towards it.
- [x] T010 [US1] In `GameLoopService.lua`, trigger the `ShowGameHud` event for a player when they enter a maze, passing the exit position.

## 4. Phase 3: US2 - Results Screen

**Goal**: As a player, when I reach the exit, I want to see my completion time.

**Independent Test Criteria**:
- Upon touching the maze exit, the In-Game HUD disappears.
- The Results Screen appears, displaying the final, server-verified completion time.
- The screen shows two buttons: "Try Again" and "New Maze".

### Implementation Tasks

- [x] T011 [US2] Implement the basic UI for the `ResultsGui.lua`, including a text label for the time and two buttons ("Try Again", "New Maze").
- [x] T012 [US2] In `ResultsController.lua`, implement the client-side logic to show the `ResultsGui` when the `ShowResults` event is received, and display the completion time from the payload.
- [x] T013 [US2] In `GameLoopService.lua`, listen for the `PlayerFinishedMaze` event from the client.
- [x] T014 [US2] In `GameLoopService.lua`, upon receiving `PlayerFinishedMaze`, validate the completion, calculate the final time, and fire the `ShowResults` event to the client.
- [x] T015 [US2] In `GameLoopService.lua`, fire the `HideGameHud` event when the player finishes the maze.
- [x] T016 [US2] In `InGameHudController.lua`, add logic to fire the `PlayerFinishedMaze` event when the player character touches the maze exit.

## 5. Phase 4: US3 - Post-Game Options

**Goal**: As a player, after finishing a maze, I want the option to play the same maze again or return to the level selection.

**Independent Test Criteria**:
- Clicking "Try Again" on the Results Screen teleports the player to the start of the same maze and restarts the timer.
- Clicking "New Maze" on the Results Screen closes the Results Screen and shows the Level Select UI.

### Implementation Tasks

- [x] T017 [US3] In `ResultsController.lua`, fire the `RequestRetry` event when the "Try Again" button is clicked.
- [x] T018 [US3] In `ResultsController.lua`, fire the `RequestNewMaze` event when the "New Maze" button is clicked.
- [x] T019 [US3] In `GameLoopService.lua`, handle the `RequestRetry` event by resetting the player's state and teleporting them back to the maze start.
- [x] T020 [US3] In `GameLoopService.lua`, handle the `RequestNewMaze` event by transitioning the player's state back to the lobby/level select.
- [x] T021 [US3] In `ResultsController.lua`, hide the `ResultsGui` after either button is clicked.

## 6. Phase 5: US4 - Furthest Start Point

**Goal**: As a player, I expect to start at the most challenging position, furthest from the exit.

**Independent Test Criteria**:
- For any generated maze, the player's spawn point is verified to be the furthest traversable point from the exit.

### Implementation Tasks

- [x] T022 [US4] In `MazeService.lua`, implement the Breadth-First Search (BFS) algorithm as a private function to find the furthest traversable cell from a given starting cell.
- [x] T023 [US4] In `MazeService.lua`, after generating a maze, use the BFS algorithm to calculate the furthest point from the exit.
- [x] T024 [US4] In `MazeService.lua`, store this calculated point as the `PlayerStartPoint` in the maze data.
- [x] T025 [US4] In `GameLoopService.lua`, when a player starts a maze, use the `PlayerStartPoint` from the maze data as their spawn location.

## 7. Dependencies

- **US1** is a prerequisite for **US2**.
- **US2** is a prerequisite for **US3**.
- **US4** is independent and can be implemented in parallel with US1/US2/US3, but the final integration happens in `GameLoopService` (T025).

## 8. Parallel Execution Examples

- **Story US1 & US4**: One developer can work on the client-side HUD (`InGameHudController.lua`, `InGameHud.lua`) while another implements the server-side BFS algorithm in `MazeService.lua`.
- **Task T009 & T008**: The compass and timer logic within the `InGameHudController` can be developed in parallel as they are independent UI components.

## 9. Implementation Strategy

The implementation will follow the phases outlined above, starting with foundational setup, then implementing each user story incrementally. This allows for each piece of functionality (HUD, Results Screen, Post-Game Options, Start Point) to be tested independently before final integration. The MVP is the completion of US1 and US4.
