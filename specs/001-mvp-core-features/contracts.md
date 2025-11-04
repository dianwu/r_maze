# API Contracts: MVP Core Gameplay Features

This document defines the client-server communication interface using RemoteEvents and RemoteFunctions.

## Location

All communication objects should be stored in a folder named `Remotes` in `ReplicatedStorage`.

---

## Client → Server

These are `RemoteEvent`s fired by the client to request an action from the server.

### 1. `SelectDifficulty`

-   **Type**: `RemoteEvent`
-   **Direction**: Client → Server
-   **Description**: Fired when a player clicks a UI button to select a maze difficulty.
-   **Parameters**:
    -   `difficulty` (string): The name of the selected difficulty (e.g., "Small", "Medium", "Large").
-   **Server Logic**: When received, the server validates the request, gets the player's data, and teleports the player to the appropriate maze starting area.

---

## Server → Client

These are events fired by the server to update the client's UI or state.

### 1. `UpdateHUD`

-   **Type**: `RemoteEvent`
-   **Direction**: Server → Client
-   **Description**: Fired periodically by the server or when the score changes to update the player's Heads-Up Display.
-   **Parameters**:
    -   `score` (number): The player's current score.
    -   `elapsedTime` (number): The current elapsed time in seconds.
-   **Client Logic**: When received, the client updates the score and timer labels on the screen.

### 2. `ShowNotification`

-   **Type**: `RemoteEvent`
-   **Direction**: Server → Client
-   **Description**: Fired by the server to show a notification to the player (e.g., score could not be saved).
-   **Parameters**:
    -   `message` (string): The notification message to display.
    -   `type` (string): The type of notification (e.g., "Error", "Info").
-   **Client Logic**: When received, the client displays the message in a UI element.

### 3. `TeleportToLobby`

-   **Type**: `RemoteEvent`
-   **Direction**: Server → Client
-   **Description**: Fired by the server when a maze run is over to send the player back to the lobby.
-   **Parameters**: None
-   **Client Logic**: The client can hide the in-game HUD and show the lobby UI.

---

## Client ↔ Server (Request/Response)

These are `RemoteFunction`s invoked by the client to request data from the server.

### 1. `GetLeaderboard`

-   **Type**: `RemoteFunction`
-   **Direction**: Client → Server → Client
-   **Description**: Invoked by the client when it needs to display or update a leaderboard.
-   **Parameters**:
    -   `difficulty` (string): The leaderboard to retrieve (e.g., "Small", "Medium", "Large").
-   **Return Value** (table): An array of tables, where each table represents a leaderboard entry:
    ```lua
    {
        { Rank = 1, PlayerName = "Player1", RawScore = 150, Time = 123.45 },
        { Rank = 2, PlayerName = "Player2", RawScore = 140, Time = 115.90 },
        -- ... up to 20 entries
    }
    ```
