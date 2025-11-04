# Contracts: MazeService

**Version**: 1.0
**Status**: Draft
**Author**: Gemini
**Created**: 2025-11-02
**Last Updated**: 2025-11-02
**Feature Spec**: [spec.md](./spec.md)
**Implementation Plan**: [plan.md](./plan.md)
**Data Model**: [data-model.md](./data-model.md)

## 1. Overview

This document formally defines the public function signatures and expected behaviors of the `MazeService` module, located at `src/ServerScriptService/Services/MazeService.lua`. These contracts ensure clear communication and interaction between `MazeService` and other services (e.g., `GameLoopService`).

## 2. `MazeService` Module Structure

```lua
local MazeService = {}

-- Public Functions
function MazeService.generate(difficulty: string): Model
    -- ... implementation ...
end

function MazeService.destroy(mazeModel: Model)
    -- ... implementation ...
end

return MazeService
```

## 3. Public Function Contracts

### `MazeService.generate(difficulty: string): Model`

-   **Description**: Generates a new physical maze structure in the Roblox workspace based on the specified difficulty.
-   **Parameters**:
    -   `difficulty` (string): A string representing the desired maze difficulty (e.g., "Small", "Medium", "Large"). This string will correspond to configurations defined in `src/ReplicatedStorage/Modules/Configuration.lua`.
-   **Returns**:
    -   `Model`: A Roblox `Model` instance containing all the `Part` instances that make up the generated maze (walls and floor). This model will be parented to the workspace upon creation.
-   **Preconditions**:
    -   The `difficulty` string must be a valid key in the maze configuration table within `Configuration.lua`.
-   **Postconditions**:
    -   A new `Model` containing the maze parts is created and returned.
    -   The returned `Model` is parented to `workspace`.
    -   The generated maze adheres to the dimensional requirements specified in `spec.md` (cell size, wall thickness, wall height).
    -   The generated maze is a "perfect" maze (exactly one path between any two cells).
    -   Maze generation completes within the performance criteria (under 2 seconds for the largest maze).
-   **Error Handling**:
    -   If an invalid `difficulty` is provided, the function should error or return `nil` and log a warning.

### `MazeService.destroy(mazeModel: Model)`

-   **Description**: Removes a previously generated maze model from the Roblox workspace and cleans up its memory.
-   **Parameters**:
    -   `mazeModel` (Model): The `Model` instance representing the maze to be destroyed. This should be a model previously returned by `MazeService.generate`.
-   **Returns**:
    -   None.
-   **Preconditions**:
    -   `mazeModel` must be a valid Roblox `Model` instance that is currently parented to the workspace.
-   **Postconditions**:
    -   The `mazeModel` and all its descendants are removed from the workspace (e.g., by setting `mazeModel.Parent = nil`).
    -   Memory associated with the `mazeModel` is released.
-   **Error Handling**:
    -   If `mazeModel` is `nil` or not a `Model` instance, the function should log a warning but not error, as it's a cleanup operation.
