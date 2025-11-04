# Service Contracts: In-Maze Gameplay

**Version**: 1.0
**Status**: Completed
**Author**: Gemini AI
**Created**: 2025-11-02
**Last Updated**: 2025-11-02

## 1. Overview

This document defines the RemoteEvents and RemoteFunctions used for communication between the client and server for the in-maze gameplay features. These will be added to the `Remotes` module.

## 2. Client-to-Server Events

### `PlayerFinishedMaze`

- **Direction**: Client → Server
- **Type**: `RemoteEvent`
- **Description**: Fired by the client when the player character touches the maze exit. The server will verify this action.
- **Payload**: None. The server identifies the player who fired the event.

### `RequestRetry`

- **Direction**: Client → Server
- **Type**: `RemoteEvent`
- **Description**: Fired from the results screen when the player clicks the "Try Again" button.
- **Payload**: None.

### `RequestNewMaze`

- **Direction**: Client → Server
- **Type**: `RemoteEvent`
- **Description**: Fired from the results screen when the player clicks the "New Maze" button.
- **Payload**: None.

## 3. Server-to-Client Events

### `ShowGameHud`

- **Direction**: Server → Client
- **Type**: `RemoteEvent`
- **Description**: Sent by the server to a specific client to signal the start of a maze run, prompting the client to display the in-game HUD (compass and timer).
- **Payload**:
    - `exitPosition` (`Vector3`): The world-space coordinates of the maze exit for the compass to track.

### `ShowResults`

- **Direction**: Server → Client
- **Type**: `RemoteEvent`
- **Description**: Sent by the server to a specific client after validating a maze completion. Prompts the client to display the results screen.
- **Payload**:
    - `completionTime` (`number`): The final, server-verified time in seconds.

### `HideGameHud`

- **Direction**: Server → Client
- **Type**: `RemoteEvent`
- **Description**: Sent by the server to tell the client to hide the in-game HUD, typically when the player enters the results phase.
- **Payload**: None.
