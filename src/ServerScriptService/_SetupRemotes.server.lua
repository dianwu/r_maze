-- /src/ServerScriptService/_SetupRemotes.server.lua
-- This script runs once on server startup to create all necessary remote communication instances.
-- This approach is more robust than relying on Rojo's file-to-instance mapping.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Create the main container folder
local remotesFolder = Instance.new("Folder")
remotesFolder.Name = "Remotes"
remotesFolder.Parent = ReplicatedStorage

-- Create RemoteEvents and RemoteFunctions
local remotesToCreate = {
    -- RemoteEvents
    SelectDifficulty = "RemoteEvent",
    UpdateHUD = "RemoteEvent",
    ShowNotification = "RemoteEvent",
    TeleportToLobby = "RemoteEvent",
    PlayerFinishedMaze = "RemoteEvent",
    RequestRetry = "RemoteEvent",
    RequestNewMaze = "RemoteEvent",
    ShowGameHud = "RemoteEvent",
    ShowResults = "RemoteEvent",
    HideGameHud = "RemoteEvent",
    SelectMaze = "RemoteEvent",
    ShowWaypointDistance = "RemoteEvent",

    -- RemoteFunctions
    GetLeaderboard = "RemoteFunction"
}

for name, className in pairs(remotesToCreate) do
    local instance = Instance.new(className)
    instance.Name = name
    instance.Parent = remotesFolder
end

print("Server: All remote events and functions created successfully.")
