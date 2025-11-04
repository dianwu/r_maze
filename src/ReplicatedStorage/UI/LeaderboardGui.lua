-- LeaderboardGui.lua

local LeaderboardGui = {}

function LeaderboardGui.create(parent)
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "LeaderboardGui"

    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(0, 300, 0, 400)
    background.Position = UDim2.new(0.5, -150, 0.5, -200)
    background.Parent = screenGui

    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Text = "Leaderboard"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Parent = background

    local list = Instance.new("UIListLayout")
    list.Parent = background

    screenGui.Parent = parent
    return screenGui
end

function LeaderboardGui.addEntry(leaderboardGui, rank, name, score, time)
    local background = leaderboardGui:FindFirstChild("Background")
    if background then
        local entry = Instance.new("TextLabel")
        entry.Name = "Entry" .. tostring(rank)
        entry.Text = string.format("%d. %s - %d (%.2fs)", rank, name, score, time)
        entry.Size = UDim2.new(1, 0, 0, 20)
        entry.Parent = background
    end
end

return LeaderboardGui
