# Data Model: Maze Generation Grid

**Version**: 1.0
**Status**: Draft
**Author**: Gemini
**Created**: 2025-11-02
**Last Updated**: 2025-11-02
**Feature Spec**: [spec.md](./spec.md)
**Implementation Plan**: [plan.md](./plan.md)

## 1. Overview

This document describes the in-memory data structure used to represent the maze grid during the generation process. This grid will be a 2D representation of the maze cells, tracking their visited status and the walls between them.

## 2. Grid Structure

The maze will be represented as a 2D table (array of arrays) in Luau. Each element in the outer table represents a row, and each element in the inner table represents a cell within that row.

```lua
-- Example: A 3x3 maze grid
local mazeGrid = {
    -- Row 1
    {
        {visited = false, walls = {north = true, east = true, south = true, west = true}}, -- Cell (1,1)
        {visited = false, walls = {north = true, east = true, south = true, west = true}}, -- Cell (1,2)
        {visited = false, walls = {north = true, east = true, south = true, west = true}}  -- Cell (1,3)
    },
    -- Row 2
    {
        {visited = false, walls = {north = true, east = true, south = true, west = true}}, -- Cell (2,1)
        {visited = false, walls = {north = true, east = true, south = true, west = true}}, -- Cell (2,2)
        {visited = false, walls = {north = true, east = true, south = true, west = true}}  -- Cell (2,3)
    },
    -- Row 3
    {
        {visited = false, walls = {north = true, east = true, south = true, west = true}}, -- Cell (3,1)
        {visited = false, walls = {north = true, east = true, south = true, west = true}}, -- Cell (3,2)
        {visited = false, walls = {north = true, east = true, south = true, west = true}}  -- Cell (3,3)
    }
}
```

## 3. Cell Structure

Each cell in the `mazeGrid` will be a table with the following properties:

-   **`visited` (boolean)**:
    -   `true` if the cell has been visited by the maze generation algorithm.
    -   `false` if the cell has not yet been visited.
    -   **Initial State**: `false` for all cells.

-   **`walls` (table)**:
    -   A table containing boolean flags for each of the four cardinal walls of the cell.
    -   `north`: `true` if the wall to the north of the cell exists, `false` if it has been removed.
    -   `east`: `true` if the wall to the east of the cell exists, `false` if it has been removed.
    -   `south`: `true` if the wall to the south of the cell exists, `false` if it has been removed.
    -   `west`: `true` if the wall to the west of the cell exists, `false` if it has been removed.
    -   **Initial State**: All walls (`north`, `east`, `south`, `west`) are `true`.

## 4. Dimensions

The dimensions of the `mazeGrid` (number of rows and columns) will be determined by the difficulty setting loaded from `src/ReplicatedStorage/Modules/Configuration.lua`. For example, a "Small" maze might result in a 20x20 grid, while a "Large" maze might be 60x60.

## 5. Usage in Algorithm

The Recursive Backtracker algorithm will operate on this `mazeGrid` data structure:

1.  It will mark cells as `visited` as it explores them.
2.  When moving from one cell to an unvisited neighbor, it will "carve" a path by setting the corresponding wall flags to `false` in both the current cell and the neighbor cell. For example, if moving from cell A (east) to cell B (west), `A.walls.east` and `B.walls.west` would both be set to `false`.

Once the algorithm completes, the `mazeGrid` will contain the complete logical structure of the maze, which will then be used to physically construct the `Part` instances in the Roblox workspace.
