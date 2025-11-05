--[[
    BackpackController
    Handles client-side logic for the Backpack UI and item selection.
    - Listens for UI interactions (slot clicks).
    - Communicates item selection to the server.
    - Updates the Backpack UI based on server-sent data.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Remotes = require(ReplicatedStorage.Modules.Remotes)
local BackpackGui = require(ReplicatedStorage.UI.BackpackGui)

local BackpackController = {}

local backpackGuiInstance = nil
local currentBackpackItems = {}
local selectedSlotIndex = nil

function BackpackController.setup(guiInstance)
    backpackGuiInstance = guiInstance

    local function updateBackpackUI()
        if not backpackGuiInstance then return end

        for i = 1, #currentBackpackItems do
            local item = currentBackpackItems[i]
            BackpackGui.updateSlot(backpackGuiInstance, i, item.Name)
        end
        -- Clear any remaining slots if backpack size decreased
        for i = #currentBackpackItems + 1, BackpackGui.SLOT_COUNT do
            BackpackGui.updateSlot(backpackGuiInstance, i, nil)
        end
    end

    local function onUpdateBackpackUI(items)
        currentBackpackItems = items
        updateBackpackUI()
    end

    local function onSlotClicked(slotIndex)
        if currentBackpackItems[slotIndex] then
            selectedSlotIndex = slotIndex
            Remotes.SelectItemRequest:FireServer(slotIndex)
            print("CLIENT: Selected item in slot " .. slotIndex)
        else
            print("CLIENT: Slot " .. slotIndex .. " is empty.")
        end
    end

    -- Connect slot click events
    for i = 1, BackpackGui.SLOT_COUNT do
        local slotButton = BackpackGui.getSlotButton(backpackGuiInstance, i)
        if slotButton then
            slotButton.MouseButton1Click:Connect(function()
                onSlotClicked(i)
            end)
        end
    end

    -- Listen for server updates
    Remotes.UpdateBackpackUI.OnClientEvent:Connect(onUpdateBackpackUI)
end

function BackpackController.getSelectedCrate()
    if selectedSlotIndex and currentBackpackItems[selectedSlotIndex] then
        return currentBackpackItems[selectedSlotIndex]
    end
    return nil
end

function BackpackController.getSelectedSlotIndex()
    return selectedSlotIndex
end

function BackpackController.clearSelection()
    selectedSlotIndex = nil
end

return BackpackController
