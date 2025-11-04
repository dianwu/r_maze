-- /src/ReplicatedStorage/Modules/Waypoint.lua
-- This module is responsible for creating the visual appearance and basic properties of a waypoint part.

local Waypoint = {}

function Waypoint.create(position, distance)
    local part = Instance.new("Part")
    part.Name = "Waypoint"
    part.Shape = Enum.PartType.Ball
    part.Size = Vector3.new(4, 4, 4)
    part.Position = position
    part.Anchored = true
    part.CanCollide = false
    part.Material = Enum.Material.Neon
    part.Color = Color3.fromRGB(0, 150, 255) -- A nice blue color
    part.Transparency = 0.6

    -- Store the distance value directly on the part for easy access
    part:SetAttribute("Distance", distance)

    -- Add a visual effect
    local pointLight = Instance.new("PointLight")
    pointLight.Color = part.Color
    pointLight.Brightness = 2
    pointLight.Range = 12
    pointLight.Parent = part

    return part
end

return Waypoint
