-- /src/ReplicatedStorage/Modules/Remotes.lua
-- This module waits for all remote events and functions to be available
-- and returns them in a single table, preventing race conditions.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemotesFolder = ReplicatedStorage:WaitForChild("Remotes")

local Remotes = {
    -- Client to Server
    SelectDifficulty = RemotesFolder:WaitForChild("SelectDifficulty"),
    PlayerFinishedMaze = RemotesFolder:WaitForChild("PlayerFinishedMaze"),
    RequestRetry = RemotesFolder:WaitForChild("RequestRetry"),
    RequestNewMaze = RemotesFolder:WaitForChild("RequestNewMaze"),
    -- PickupCrateRequest is no longer used for touch pickup
    PlaceCrateRequest = RemotesFolder:WaitForChild("PlaceCrateRequest"),
    SelectItemRequest = RemotesFolder:WaitForChild("SelectItemRequest"),

    -- Server to Client
    UpdateHUD = RemotesFolder:WaitForChild("UpdateHUD"),
    ShowNotification = RemotesFolder:WaitForChild("ShowNotification"),
    TeleportToLobby = RemotesFolder:WaitForChild("TeleportToLobby"),
    ShowGameHud = RemotesFolder:WaitForChild("ShowGameHud"),
    ShowResults = RemotesFolder:WaitForChild("ShowResults"),
    CrateStateChanged = RemotesFolder:WaitForChild("CrateStateChanged"),
    UpdateBackpackUI = RemotesFolder:WaitForChild("UpdateBackpackUI"),
    
    -- Custom Events
    SelectMaze = RemotesFolder:WaitForChild("SelectMaze"),
    ShowWaypointDistance = RemotesFolder:WaitForChild("ShowWaypointDistance"),

    -- RemoteFunctions
    GetLeaderboard = RemotesFolder:WaitForChild("GetLeaderboard"),
    
    -- Other Events
    HideGameHud = RemotesFolder:WaitForChild("HideGameHud")
}

return Remotes