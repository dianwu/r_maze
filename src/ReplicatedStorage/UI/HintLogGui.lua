-- /src/ReplicatedStorage/UI/HintLogGui.lua
-- This module creates and manages a small log in the bottom-right corner to display waypoint distances.

local HintLogGui = {}
HintLogGui.__index = HintLogGui

function HintLogGui.create(parent)
    local self = setmetatable({}, HintLogGui)

    self.hintCounter = 1
    
    -- Create the main GUI
    self.screenGui = Instance.new("ScreenGui")
    self.screenGui.Name = "HintLogGui"
    self.screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    self.screenGui.Parent = parent

    -- Create the scrolling frame for the log
    local scrollingFrame = Instance.new("ScrollingFrame")
    scrollingFrame.Name = "HintLog"
    scrollingFrame.Size = UDim2.new(0.2, 0, 0.3, 0) -- 20% of screen width, 30% of height
    scrollingFrame.Position = UDim2.new(0.98, 0, 0.98, 0) -- Position in bottom right
    scrollingFrame.AnchorPoint = Vector2.new(1, 1)
    scrollingFrame.BackgroundTransparency = 0.7
    scrollingFrame.BackgroundColor3 = Color3.new(0, 0, 0)
    scrollingFrame.BorderSizePixel = 1
    scrollingFrame.BorderColor3 = Color3.new(1, 1, 1)
    scrollingFrame.ScrollBarThickness = 0 -- Remove scrollbar
    scrollingFrame.Parent = self.screenGui

    -- Add a UIListLayout to automatically stack the hints
    local uiListLayout = Instance.new("UIListLayout")
    uiListLayout.Padding = UDim.new(0, 5)
    uiListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    uiListLayout.Parent = scrollingFrame

    self.logContainer = scrollingFrame

    return self
end

function HintLogGui:addHint(distanceText)
    local hintLabel = Instance.new("TextLabel")
    hintLabel.Name = "Hint" .. self.hintCounter
    hintLabel.Text = "提示點 " .. self.hintCounter .. ": " .. distanceText
    hintLabel.Font = Enum.Font.SourceSans
    hintLabel.TextColor3 = Color3.new(1, 1, 1)
    hintLabel.TextSize = 16
    hintLabel.TextXAlignment = Enum.TextXAlignment.Left
    hintLabel.Size = UDim2.new(1, -10, 0, 20) -- Full width minus padding, fixed height
    hintLabel.BackgroundTransparency = 1
    hintLabel.LayoutOrder = -self.hintCounter -- Negative order to put newest on top
    hintLabel.Parent = self.logContainer

    self.hintCounter = self.hintCounter + 1
end

function HintLogGui:clear()
    for _, child in ipairs(self.logContainer:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy()
        end
    end
    self.hintCounter = 1
end

function HintLogGui:destroy()
    self.screenGui:Destroy()
end

return HintLogGui
