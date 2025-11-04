# Quickstart Guide: In-Maze Gameplay

**Version**: 1.0
**Status**: Completed
**Author**: Gemini AI
**Created**: 2025-11-02
**Last Updated**: 2025-11-02

## 1. Overview

This guide provides the steps to test the new in-maze gameplay loop, including the compass, timer, and results screen.

## 2. Testing Steps

### a. Verifying In-Game HUD

1.  **Launch the game** in Roblox Studio.
2.  From the **Level Select UI**, choose any maze difficulty.
3.  **Expected Result**:
    - The Level Select UI disappears.
    - The player is teleported into the maze at the furthest point from the exit.
    - An **In-Game HUD** appears, containing:
        - A **timer** that starts counting up from `00:00`.
        - A **compass** element that is visible on screen.

### b. Verifying Compass Functionality

1.  While in the maze, **move your character** around.
2.  Observe the compass UI element.
3.  **Expected Result**:
    - The compass should continuously orient itself to point towards the maze's exit, regardless of the player's position or camera angle.

### c. Verifying Results Screen

1.  Navigate through the maze and **reach the exit**.
2.  **Expected Result**:
    - The In-Game HUD (compass and timer) disappears.
    - A **Results Screen** appears, displaying your final completion time.
    - The screen shows two buttons: "Try Again" and "New Maze".

### d. Verifying Post-Game Options

1.  From the Results Screen, click the **"Try Again"** button.
2.  **Expected Result**:
    - The player is immediately teleported back to the start of the *same* maze.
    - The In-Game HUD reappears, and the timer restarts from `00:00`.
3.  Reach the exit again. From the Results Screen, click the **"New Maze"** button.
4.  **Expected Result**:
    - The Results Screen disappears.
    - The **Level Select UI** appears, allowing you to choose a different maze.
