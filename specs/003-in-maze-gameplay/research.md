# Research: Furthest Point Algorithm

**Version**: 1.0
**Status**: Completed
**Author**: Gemini AI
**Created**: 2025-11-02
**Last Updated**: 2025-11-02

## 1. Problem

The feature requires placing the player at the "furthest possible traversable point" from the maze exit. We need to select an efficient and accurate algorithm to calculate this point on the server each time a maze is generated. The maze is represented as a grid.

## 2. Algorithms Considered

### a. Breadth-First Search (BFS)

- **Description**: BFS explores a graph layer by layer. Starting from the exit, it would explore all adjacent cells, then their neighbors, and so on. The last traversable cell visited in this search would be one of the furthest from the starting point.
- **Pros**:
    - Guaranteed to find the shortest path in terms of number of cells (which, in an unweighted grid, is the actual shortest path).
    - Relatively simple to implement.
- **Cons**:
    - For this specific problem (finding the *longest* path), we can adapt it. By starting the BFS from the *exit*, the last node visited will be the furthest away.

### b. Dijkstra's Algorithm

- **Description**: A more general version of BFS that works on weighted graphs. It finds the shortest path from a source node to all other nodes.
- **Pros**:
    - Very effective for weighted graphs.
- **Cons**:
    - Our maze grid is unweighted (each move has a cost of 1), making Dijkstra's functionally identical to BFS but with slightly more overhead. It's unnecessarily complex for this problem.

### c. A* Search Algorithm

- **Description**: An informed search algorithm that uses a heuristic to guide its pathfinding towards a destination. It's optimized for finding a single shortest path from point A to point B.
- **Pros**:
    - Highly efficient for finding a single shortest path.
- **Cons**:
    - Not suitable for our use case. We are not trying to find a path *to* a known destination; we are trying to find the furthest point from a known origin (the exit) by exploring the entire maze. A* is designed to avoid exploring the whole maze.

## 3. Decision

**Chosen Algorithm**: **Breadth-First Search (BFS)**

**Rationale**:

1.  **Correctness**: By starting a BFS from the maze's exit cell, the algorithm will explore the entire maze layer by layer. The very last traversable cell that the BFS reaches is, by definition, the furthest from the exit in terms of path length. This directly solves the problem.
2.  **Performance**: For an unweighted grid like our maze, BFS is the most efficient algorithm for finding the shortest path to all nodes. Its time complexity is proportional to the number of cells and connections, which is perfectly acceptable for maze generation, as it's a one-time calculation.
3.  **Simplicity**: BFS is simpler to implement and debug compared to Dijkstra's or A*, reducing the risk of errors.

**Implementation Strategy**:
The `MazeService` will perform the following steps after a maze is generated:
1.  Identify the exit cell.
2.  Initiate a BFS starting from the exit cell.
3.  Keep track of the last visited cell during the traversal.
4.  Once the search is complete, the last visited cell is stored as the designated `PlayerStartPoint` for that maze instance.
