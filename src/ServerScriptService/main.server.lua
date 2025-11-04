-- main.server.lua
-- Server-side entry point
-- This script wires up all the server-side services and remote event handlers.

-- Services
local ServerScriptService = game:GetService("ServerScriptService")
local GameLoopService = require(ServerScriptService.Services.GameLoopService)
local LeaderboardService = require(ServerScriptService.Services.LeaderboardService)

-- Remotes
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Modules:WaitForChild("Remotes"))
local SelectDifficultyEvent = Remotes.SelectDifficulty
local GetLeaderboardFunction = Remotes.GetLeaderboard

-- Event Handlers
SelectDifficultyEvent.OnServerEvent:Connect(function(player, difficulty)
    print("DEBUG: main.server.lua event handler running...")
    GameLoopService.startPlayerSession(player, difficulty)
end)

GetLeaderboardFunction.OnServerInvoke = function(player, difficulty)
    return LeaderboardService.getLeaderboard(difficulty)
end

print("Server script is running.")
