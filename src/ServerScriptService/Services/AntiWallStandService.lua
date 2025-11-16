--!strict
--[[
    @class AntiWallStandService
    Prevents players from standing on parts tagged with "Wall" by teleporting them
    to their last known safe position.
]]

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local AntiWallStandService = {}

local RAY_DIRECTION = Vector3.new(0, -4, 0) -- Raycast downwards to detect the ground
local SAFE_GROUND_UPDATE_INTERVAL = 0.5 -- How often to update the player's safe position (in seconds)

local lastSafePositions = {}
local lastCheckTime = {}

-- Check if the player is standing on a wall
function AntiWallStandService.checkPlayer(player: Player)
    local character = player.Character
    if not character then return end

    local humanoid = character:FindFirstChildOfClass("Humanoid")
    local rootPart = character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not rootPart or humanoid:GetState() == Enum.HumanoidStateType.Freefall then
        return
    end

    -- Raycast down from the player's feet to find what they're standing on
    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    local result = workspace:Raycast(rootPart.Position, RAY_DIRECTION, raycastParams)

    if result and result.Instance then
        if CollectionService:HasTag(result.Instance, "Wall") then
            -- Player is on a wall, teleport them back to their last safe position
            local safePosition = lastSafePositions[player]
            if safePosition then
                print("DEBUG: Player " .. player.Name .. " detected on wall. Teleporting back.")
                rootPart.CFrame = CFrame.new(safePosition)
            end
        else
            -- Player is on safe ground, update their last safe position periodically
            local now = os.clock()
            if not lastCheckTime[player] or (now - lastCheckTime[player] > SAFE_GROUND_UPDATE_INTERVAL) then
                lastCheckTime[player] = now
                lastSafePositions[player] = rootPart.Position
            end
        end
    end
end

-- On every frame, check all players
function AntiWallStandService.start()
    RunService.Heartbeat:Connect(function()
        for _, player in ipairs(Players:GetPlayers()) do
            AntiWallStandService.checkPlayer(player)
        end
    end)

    Players.PlayerRemoving:Connect(function(player)
        -- Clean up memory when a player leaves
        lastSafePositions[player] = nil
        lastCheckTime[player] = nil
    end)
end

return AntiWallStandService
