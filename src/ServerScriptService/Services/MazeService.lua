-- MazeService.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local Configuration = require(ReplicatedStorage.Modules.Configuration)
local Remotes = require(ReplicatedStorage.Modules.Remotes)
local Waypoint = require(ReplicatedStorage.Modules.Waypoint)
local ItemService = require(ServerScriptService.Services.ItemService)

local MazeService = {}

local mazeContainer = workspace:FindFirstChild("MazeContainer")
if not mazeContainer then
    mazeContainer = Instance.new("Folder")
    mazeContainer.Name = "MazeContainer"
    mazeContainer.Parent = workspace
end

local CELL_SIZE = 12
local WALL_THICKNESS = 2
local WALL_HEIGHT = 13

-- A table to prevent a single waypoint from being touched multiple times by the same player
local playerWaypointDebounce = {}

local function createWall(size, position, parent)
    local wall = Instance.new("Part")
    wall.Size = size
    wall.Position = position
    wall.Anchored = true
    wall.Parent = parent
    wall.BrickColor = BrickColor.new("Medium stone grey")
    wall.Material = Enum.Material.Concrete
    return wall
end

local function findFurthestPoint(grid, startX, startY)
    local queue = {{x = startX, y = startY, dist = 0}}
    local visited = {[startX .. "," .. startY] = true}
    local furthest = {x = startX, y = startY, dist = 0}

    while #queue > 0 do
        local current = table.remove(queue, 1)
        
        if current.dist > furthest.dist then
            furthest = current
        end

        local cx, cy = current.x, current.y
        local mazeWidthCells = #grid
        local mazeDepthCells = #grid[1]
        
        -- Check neighbors with boundary checks
        if cy > 1 and not grid[cx][cy].walls.Top and not visited[cx .. "," .. (cy - 1)] then
            visited[cx .. "," .. (cy - 1)] = true
            table.insert(queue, {x = cx, y = cy - 1, dist = current.dist + 1})
        end
        if cy < mazeDepthCells and not grid[cx][cy].walls.Bottom and not visited[cx .. "," .. (cy + 1)] then
            visited[cx .. "," .. (cy + 1)] = true
            table.insert(queue, {x = cx, y = cy + 1, dist = current.dist + 1})
        end
        if cx > 1 and not grid[cx][cy].walls.Left and not visited[(cx - 1) .. "," .. cy] then
            visited[(cx - 1) .. "," .. cy] = true
            table.insert(queue, {x = cx - 1, y = cy, dist = current.dist + 1})
        end
        if cx < mazeWidthCells and not grid[cx][cy].walls.Right and not visited[(cx + 1) .. "," .. cy] then
            visited[(cx + 1) .. "," .. cy] = true
            table.insert(queue, {x = cx + 1, y = cy, dist = current.dist + 1})
        end
    end
    
    return furthest.x, furthest.y
end

function MazeService.generate(difficulty)
    -- Clear previous debounce table
    playerWaypointDebounce = {}

    local mazeConfig = Configuration.Mazes[difficulty]
    if not mazeConfig then
        warn("MazeService: Invalid difficulty provided: " .. tostring(difficulty))
        return nil
    end

    print("MazeService: Generating maze for difficulty " .. difficulty)

    local mazeModel = Instance.new("Model")
    mazeModel.Name = difficulty .. "Maze"
    mazeModel.Parent = mazeContainer

    local mazeWidthCells = mazeConfig.Size.X
    local mazeDepthCells = mazeConfig.Size.Y

    local mazeWidthStuds = mazeWidthCells * CELL_SIZE
    local mazeDepthStuds = mazeDepthCells * CELL_SIZE

    local baseplate = Instance.new("Part")
    baseplate.Size = Vector3.new(mazeWidthStuds, 1, mazeDepthStuds)
    baseplate.Position = Vector3.new(0, -0.5, 0)
    baseplate.Anchored = true
    baseplate.Parent = mazeModel
    baseplate.BrickColor = BrickColor.new("Dirt")
    baseplate.Material = Enum.Material.Grass

    local grid = {}
    for x = 1, mazeWidthCells do
        grid[x] = {}
        for y = 1, mazeDepthCells do
            grid[x][y] = {
                visited = false,
                walls = { Top = true, Bottom = true, Left = true, Right = true },
                distanceToExit = -1 -- Initialize distance
            }
        end
    end

    local stack = {}
    local startX, startY = math.random(1, mazeWidthCells), math.random(1, mazeDepthCells)
    grid[startX][startY].visited = true
    table.insert(stack, { x = startX, y = startY })

    while #stack > 0 do
        local current = stack[#stack]
        local cx, cy = current.x, current.y

        local neighbors = {}
        if cy > 1 and not grid[cx][cy - 1].visited then table.insert(neighbors, { x = cx, y = cy - 1, wall = "Top", opposite = "Bottom" }) end
        if cy < mazeDepthCells and not grid[cx][cy + 1].visited then table.insert(neighbors, { x = cx, y = cy + 1, wall = "Bottom", opposite = "Top" }) end
        if cx > 1 and not grid[cx - 1][cy].visited then table.insert(neighbors, { x = cx - 1, y = cy, wall = "Left", opposite = "Right" }) end
        if cx < mazeWidthCells and not grid[cx + 1][cy].visited then table.insert(neighbors, { x = cx + 1, y = cy, wall = "Right", opposite = "Left" }) end

        if #neighbors > 0 then
            local next = neighbors[math.random(#neighbors)]
            
            grid[cx][cy].walls[next.wall] = false
            grid[next.x][next.y].walls[next.opposite] = false

            grid[next.x][next.y].visited = true
            table.insert(stack, { x = next.x, y = next.y })
        else
            table.remove(stack)
        end
    end

    local walls = Instance.new("Model")
    walls.Name = "Walls"
    walls.Parent = mazeModel

    local halfMazeW = mazeWidthStuds / 2
    local halfMazeD = mazeDepthStuds / 2

    local exitX, exitY
    local exitSide = math.random(4)
    if exitSide == 1 then -- Top
        exitX, exitY = math.random(1, mazeWidthCells), 1
        grid[exitX][exitY].walls.Top = false
    elseif exitSide == 2 then -- Bottom
        exitX, exitY = math.random(1, mazeWidthCells), mazeDepthCells
        grid[exitX][exitY].walls.Bottom = false
    elseif exitSide == 3 then -- Left
        exitX, exitY = 1, math.random(1, mazeDepthCells)
        grid[exitX][exitY].walls.Left = false
    else -- Right
        exitX, exitY = mazeWidthCells, math.random(1, mazeDepthCells)
        grid[exitX][exitY].walls.Right = false
    end

    local startX, startY = findFurthestPoint(grid, exitX, exitY)

    for x = 1, mazeWidthCells do
        for y = 1, mazeDepthCells do
            local cellXPos = (x - 1) * CELL_SIZE - halfMazeW + CELL_SIZE / 2
            local cellZPos = (y - 1) * CELL_SIZE - halfMazeD + CELL_SIZE / 2

            if grid[x][y].walls.Top then
                local wallPos = Vector3.new(cellXPos, WALL_HEIGHT / 2, cellZPos - CELL_SIZE / 2)
                createWall(Vector3.new(CELL_SIZE, WALL_HEIGHT, WALL_THICKNESS), wallPos, walls)
            end
            if grid[x][y].walls.Left then
                local wallPos = Vector3.new(cellXPos - CELL_SIZE / 2, WALL_HEIGHT / 2, cellZPos)
                createWall(Vector3.new(WALL_THICKNESS, WALL_HEIGHT, CELL_SIZE), wallPos, walls)
            end
            if x == mazeWidthCells and grid[x][y].walls.Right then
                 local wallPos = Vector3.new(cellXPos + CELL_SIZE / 2, WALL_HEIGHT / 2, cellZPos)
                 createWall(Vector3.new(WALL_THICKNESS, WALL_HEIGHT, CELL_SIZE), wallPos, walls)
            end
            if y == mazeDepthCells and grid[x][y].walls.Bottom then
                 local wallPos = Vector3.new(cellXPos, WALL_HEIGHT / 2, cellZPos + CELL_SIZE / 2)
                 createWall(Vector3.new(CELL_SIZE, WALL_HEIGHT, WALL_THICKNESS), wallPos, walls)
            end
        end
    end

    local startPosition = Vector3.new(
        (startX - 1) * CELL_SIZE - halfMazeW + CELL_SIZE / 2,
        5,
        (startY - 1) * CELL_SIZE - halfMazeD + CELL_SIZE / 2
    )

    local exitPosition = Vector3.new(
        (exitX - 1) * CELL_SIZE - halfMazeW + CELL_SIZE / 2,
        5,
        (exitY - 1) * CELL_SIZE - halfMazeD + CELL_SIZE / 2
    )

    -- Create a physical part for the exit
    local exitPart = Instance.new("Part")
    exitPart.Name = "ExitPart"
    exitPart.Size = Vector3.new(CELL_SIZE, WALL_HEIGHT * 10, CELL_SIZE)
    exitPart.Position = exitPosition
    exitPart.Anchored = true
    exitPart.CanCollide = false
    exitPart.Transparency = 0.5
    exitPart.BrickColor = BrickColor.new("Bright green")
    exitPart.Material = Enum.Material.Neon
    exitPart.Parent = mazeModel

    -- START: Waypoint Generation Logic
    -- 1. Calculate distance from exit for all cells using BFS
    local queue = {{x = exitX, y = exitY}}
    grid[exitX][exitY].distanceToExit = 0
    local visitedForBfs = {[exitX .. "," .. exitY] = true}

    while #queue > 0 do
        local current = table.remove(queue, 1)
        local cx, cy = current.x, current.y
        local currentCell = grid[cx][cy]

        -- Check neighbors
        local neighbors = {}
        if cy > 1 and not currentCell.walls.Top then table.insert(neighbors, {x = cx, y = cy - 1}) end
        if cy < mazeDepthCells and not currentCell.walls.Bottom then table.insert(neighbors, {x = cx, y = cy + 1}) end
        if cx > 1 and not currentCell.walls.Left then table.insert(neighbors, {x = cx - 1, y = cy}) end
        if cx < mazeWidthCells and not currentCell.walls.Right then table.insert(neighbors, {x = cx + 1, y = cy}) end

        for _, neighbor in ipairs(neighbors) do
            if not visitedForBfs[neighbor.x .. "," .. neighbor.y] then
                visitedForBfs[neighbor.x .. "," .. neighbor.y] = true
                grid[neighbor.x][neighbor.y].distanceToExit = currentCell.distanceToExit + 1
                table.insert(queue, neighbor)
            end
        end
    end

    -- 2. Identify all junctions
    local junctions = {}
    for x = 1, mazeWidthCells do
        for y = 1, mazeDepthCells do
            local cell = grid[x][y]
            local openPaths = 0
            if not cell.walls.Top then openPaths += 1 end
            if not cell.walls.Bottom then openPaths += 1 end
            if not cell.walls.Left then openPaths += 1 end
            if not cell.walls.Right then openPaths += 1 end

            if openPaths > 2 and cell.distanceToExit > 0 then
                table.insert(junctions, {x = x, y = y, distance = cell.distanceToExit})
            end
        end
    end

    -- 3. Sort junctions by distance and place waypoints
    table.sort(junctions, function(a, b) return a.distance < b.distance end)

    local waypointsModel = Instance.new("Model")
    waypointsModel.Name = "Waypoints"
    waypointsModel.Parent = mazeModel

    for i = 3, #junctions, 3 do
        local junction = junctions[i]
        local waypointPos = Vector3.new(
            (junction.x - 1) * CELL_SIZE - halfMazeW + CELL_SIZE / 2,
            3,
            (junction.y - 1) * CELL_SIZE - halfMazeD + CELL_SIZE / 2
        )
        
        local waypointPart = Waypoint.create(waypointPos, junction.distance)
        waypointPart.Parent = waypointsModel

        -- 4. Setup touch event for the waypoint
        waypointPart.Touched:Connect(function(hit)
            local player = Players:GetPlayerFromCharacter(hit.Parent)
            if not player then return end

            if not playerWaypointDebounce[player] then
                playerWaypointDebounce[player] = {}
            end

            if playerWaypointDebounce[player][waypointPart] then return end
            
            playerWaypointDebounce[player][waypointPart] = true
            Remotes.ShowWaypointDistance:FireClient(player, junction.distance, waypointPart)
        end)
    end
    -- END: Waypoint Generation Logic

    local maze = {
        mazeModel = mazeModel,
        grid = grid,
        startPosition = startPosition,
        exitPosition = exitPosition,
        PlayerStartPoint = startPosition,
        widthInCells = mazeWidthCells,
        depthInCells = mazeDepthCells,
        cellSize = CELL_SIZE
    }

    ItemService.spawnCratesInMaze(maze)

    return maze
end

function MazeService.destroy(mazeModel)
    if mazeModel and mazeModel:IsA("Model") then
        mazeModel:Destroy()
        print("MazeService: Cleaned up maze.")
    end
end

return MazeService