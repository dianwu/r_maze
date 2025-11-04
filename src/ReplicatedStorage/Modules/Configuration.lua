-- Configuration.lua

local Configuration = {}

Configuration.Mazes = {
    Small = {
        Size = Vector2.new(20, 20),
        StartPosition = Vector3.new(0, 5, 0)
    },
    Medium = {
        Size = Vector2.new(40, 40),
        StartPosition = Vector3.new(0, 5, 0)
    },
    Large = {
        Size = Vector2.new(60, 60),
        StartPosition = Vector3.new(0, 5, 0)
    }
}

Configuration.Collectibles = {
    Coin = {
        Value = 10, -- Score value for each coin
        SpawnRatio = 0.05 -- 5% chance to spawn a coin in a given maze cell
    }
}

return Configuration