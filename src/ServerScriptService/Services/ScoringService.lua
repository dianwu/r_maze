-- ScoringService.lua

local ServerScriptService = game:GetService("ServerScriptService")
local GameLoopService = require(ServerScriptService.Services.GameLoopService)

local ScoringService = {}

function ScoringService.setupCollectible(collectible)
    collectible.Touched:Connect(function(otherPart)
        local player = game.Players:GetPlayerFromCharacter(otherPart.Parent)
        if player then
            ScoringService.onCollectibleTouched(player, collectible)
        end
    end)
end

function ScoringService.onCollectibleTouched(player, collectible)
    -- Basic validation
    if not collectible or not collectible.Parent then
        return
    end

    local playerState = GameLoopService.getPlayerState(player)
    if not playerState or playerState.State ~= "InMaze" then
        return
    end

    -- TODO: Get score value from collectible or configuration
    local scoreValue = 10 
    playerState.Score = playerState.Score + scoreValue

    -- Destroy collectible
    collectible:Destroy()

    print("ScoringService: Player " .. player.Name .. " collected an item. New score: " .. playerState.Score)
end

return ScoringService
