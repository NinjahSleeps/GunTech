local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local StatChangeEvent:RemoteEvent = RemoteEvents:WaitForChild("StatsUpdate")
local LeaderboardUpdateEvent:RemoteEvent = RemoteEvents:WaitForChild("LeaderboardUpdate")

Players.PlayerAdded:Connect(function(Player)
	LeaderboardUpdateEvent:FireAllClients("Add",Player)
end)

Players.PlayerRemoving:Connect(function(Player)
	LeaderboardUpdateEvent:FireAllClients("Remove",Player)
end)
