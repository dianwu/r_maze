--[[
    BackpackService
    Manages player inventories (backpacks) on the server.
    - Stores which items each player is carrying.
    - Provides functions to add, remove, and query items in a player's backpack.
    - Communicates changes to clients.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Remotes = require(ReplicatedStorage.Modules.Remotes)

local BackpackService = {}

-- Stores player backpacks: [player] = {item1, item2, ...}
local _playerBackpacks = {}
local MAX_BACKPACK_SLOTS = 4

function BackpackService.addItemToBackpack(player, item)
    print("BackpackService: addItemToBackpack called for player " .. player.Name .. ", item " .. item.Name)
    if not _playerBackpacks[player] then
        _playerBackpacks[player] = {}
    end

    print("BackpackService: Current backpack size for " .. player.Name .. ": " .. #_playerBackpacks[player])
    if #_playerBackpacks[player] >= MAX_BACKPACK_SLOTS then
        warn("BackpackService: Player " .. player.Name .. " backpack is full. Max slots: " .. MAX_BACKPACK_SLOTS)
        return false
    end

    table.insert(_playerBackpacks[player], item)
    print("BackpackService: Item " .. item.Name .. " added to backpack. New size: " .. #_playerBackpacks[player])
    Remotes.UpdateBackpackUI:FireClient(player, _playerBackpacks[player])
    print("BackpackService: Fired UpdateBackpackUI to client for " .. player.Name)
    return true
end

function BackpackService.removeItemFromBackpack(player, itemIndex)
    if not _playerBackpacks[player] or not _playerBackpacks[player][itemIndex] then
        warn("Player " .. player.Name .. " tried to remove non-existent item from backpack.")
        return nil
    end

    local item = table.remove(_playerBackpacks[player], itemIndex)
    Remotes.UpdateBackpackUI:FireClient(player, _playerBackpacks[player])
    return item
end

function BackpackService.getBackpack(player)
    return _playerBackpacks[player] or {}
end

function BackpackService.start()
    -- Handle player leaving the game
    Players.PlayerRemoving:Connect(function(player)
        _playerBackpacks[player] = nil
    end)
end

return BackpackService
