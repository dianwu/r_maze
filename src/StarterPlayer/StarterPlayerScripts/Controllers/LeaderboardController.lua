-- LeaderboardController.lua

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local GetLeaderboardFunction = ReplicatedStorage.Remotes.ClientToServerRequest.GetLeaderboard

local LeaderboardController = {}

function LeaderboardController.displayLeaderboard(leaderboardGui, difficulty)
    local data = GetLeaderboardFunction:InvokeServer(difficulty)

    -- TODO: Clear existing leaderboard display

    for _, entry in ipairs(data) do
        -- TODO: Create a new UI element for the entry and display it
        print(string.format("Rank %d: %s - Score: %d", entry.Rank, entry.PlayerName, entry.CompositeScore))
    end
end

return LeaderboardController
