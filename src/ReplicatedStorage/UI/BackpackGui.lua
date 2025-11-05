--[[
    BackpackGui
    Creates and manages the client-side Backpack UI.
]]

local BackpackGui = {}

BackpackGui.SLOT_COUNT = 4
local SLOT_SIZE = 60
local SLOT_PADDING = 10

function BackpackGui.create(playerGui)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BackpackGui"
    screenGui.Parent = playerGui

    local frame = Instance.new("Frame")
    frame.Name = "BackpackFrame"
    frame.Size = UDim2.new(0, (SLOT_SIZE + SLOT_PADDING) * BackpackGui.SLOT_COUNT - SLOT_PADDING, 0, SLOT_SIZE)
    frame.Position = UDim2.new(0.5, -frame.Size.X.Offset / 2, 1, -SLOT_SIZE - 20) -- Bottom center
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BorderSizePixel = 0
    frame.Parent = screenGui

    for i = 1, BackpackGui.SLOT_COUNT do
        local slotButton = Instance.new("TextButton")
        slotButton.Name = "Slot" .. i
        slotButton.Size = UDim2.new(0, SLOT_SIZE, 0, SLOT_SIZE)
        slotButton.Position = UDim2.new(0, (i - 1) * (SLOT_SIZE + SLOT_PADDING), 0, 0)
        slotButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        slotButton.BorderColor3 = Color3.fromRGB(100, 100, 100)
        slotButton.BorderSizePixel = 2
        slotButton.Text = ""
        slotButton.Font = Enum.Font.SourceSansBold
        slotButton.TextColor3 = Color3.fromRGB(255, 255, 255)
        slotButton.TextSize = 18
        slotButton.Parent = frame

        local uiCorner = Instance.new("UICorner")
        uiCorner.CornerRadius = UDim.new(0, 5)
        uiCorner.Parent = slotButton
    end

    return screenGui
end

function BackpackGui.updateSlot(backpackGui, slotIndex, itemName)
    local slotButton = backpackGui:FindFirstChild("BackpackFrame"):FindFirstChild("Slot" .. slotIndex)
    if slotButton then
        slotButton.Text = itemName or ""
    end
end

function BackpackGui.getSlotButton(backpackGui, slotIndex)
    return backpackGui:FindFirstChild("BackpackFrame"):FindFirstChild("Slot" .. slotIndex)
end

return BackpackGui
