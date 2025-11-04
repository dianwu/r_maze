-- LeaderboardService.lua

local DataStoreService = game:GetService("DataStoreService")

local LeaderboardService = {}

local leaderboards = {} -- Cache for datastores

local function getLeaderboard(difficulty)
    if leaderboards[difficulty] then
        return leaderboards[difficulty]
    end

    local success, result = pcall(function()
        return DataStoreService:GetOrderedDataStore("Leaderboard_" .. difficulty)
    end)

    if success then
        leaderboards[difficulty] = result
        return result
    else
        warn("LeaderboardService: Failed to get DataStore for " .. difficulty .. ": " .. tostring(result))
        return nil
    end
end

function LeaderboardService.saveScore(player, difficulty, score, time)
    local leaderboard = getLeaderboard(difficulty)
    if not leaderboard then
        warn("LeaderboardService: Cannot save score, leaderboard not available for " .. tostring(difficulty))
        return
    end

    local compositeScore = (score * 1000) - math.floor(time)

    local success, err = pcall(function()
        leaderboard:SetAsync(tostring(player.UserId), compositeScore)
    end)

    if not success then
        warn("LeaderboardService: Failed to save score for " .. player.Name .. ": " .. tostring(err))
    else
        print("LeaderboardService: Score saved for " .. player.Name .. ": " .. compositeScore)
    end
end

function LeaderboardService.getLeaderboard(difficulty)
    local leaderboard = getLeaderboard(difficulty)
    if not leaderboard then
        warn("LeaderboardService: Cannot get leaderboard, not available for " .. tostring(difficulty))
        return {}
    end

    local data = {}
    local success, pages = pcall(function()
        return leaderboard:GetSortedAsync(false, 20)
    end)

    if success then
        local currentPage = pages:GetCurrentPage()
        for rank, entry in ipairs(currentPage) do
            local playerName = "Player" -- Default name
            local nameSuccess, nameResult = pcall(function()
                return game.Players:GetNameFromUserIdAsync(tonumber(entry.key))
            end)
            if nameSuccess then
                playerName = nameResult
            end

            table.insert(data, {
                Rank = rank,
                PlayerName = playerName,
                CompositeScore = entry.value
                -- TODO: Store and retrieve raw score and time
            })
        end
    else
        warn("LeaderboardService: Failed to get leaderboard data: " .. tostring(pages))
    end

    return data
end

return LeaderboardService
