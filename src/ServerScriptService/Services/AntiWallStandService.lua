--!strict
--[[
    @class AntiWallStandService
    Prevents players from standing on parts tagged with "Wall" by applying a physical push force.
]]

local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")

local AntiWallStandService = {}

local RAY_DIRECTION = Vector3.new(0, -5, 0) -- Raycast downwards
local PUSH_FORCE = 80 -- Adjust force magnitude

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
            -- Player is on a wall, apply a push force
            local wallPart = result.Instance
            
            -- Determine push direction: away from the center of the wall part
            -- We use the object space relative position to decide left/right or forward/back
            local relPos = wallPart.CFrame:PointToObjectSpace(rootPart.Position)
            local pushDir = Vector3.new(0, 0, 0)

            if math.abs(relPos.X) > math.abs(relPos.Z) then
                -- Push along X axis of the part (local X)
                pushDir = wallPart.CFrame.RightVector * math.sign(relPos.X)
            else
                -- Push along Z axis of the part (local Z)
                pushDir = wallPart.CFrame.LookVector * math.sign(relPos.Z)
            end
            
            -- If standing dead center, pick a random direction
            if pushDir.Magnitude < 0.1 then
                pushDir = Vector3.new(math.random() - 0.5, 0, math.random() - 0.5).Unit
            end
            
            -- Flatten to horizontal plane and normalize
            pushDir = Vector3.new(pushDir.X, 0, pushDir.Z).Unit

            -- Apply impulse
            local impulse = pushDir * rootPart.AssemblyMass * PUSH_FORCE
            rootPart:ApplyImpulse(impulse)
            
            -- Optional: Make them jump/trip to break friction
            -- humanoid.Jump = true 
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
end

return AntiWallStandService