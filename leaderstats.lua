local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local StatChangeEvent:RemoteEvent = RemoteEvents:WaitForChild("StatsUpdate")

Players.PlayerAdded:Connect(function(Player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = Player
	
	local Kills = Instance.new("IntValue")
	Kills.Name = "Kills"
	Kills.Parent = leaderstats
	Kills.Value = 0
	
	local Damage = Instance.new("IntValue")
	Damage.Name = "Damage"
	Damage.Parent = leaderstats
	Damage.Value = 0
	
	local Heals = Instance.new("IntValue")
	Heals.Name = "Heals"
	Heals.Parent = leaderstats
	Heals.Value = 0
	
	local Caps = Instance.new("IntValue")
	Caps.Name = "Caps"
	Caps.Parent = leaderstats
	Caps.Value = 0
end)

StatChangeEvent.OnServerEvent:Connect(function(Player, Stat, Value)
	if Player:FindFirstChild("leaderstats") then
		if Player.leaderstats:FindFirstChild(Stat) then
			Player.leaderstats[Stat].Value = Player.leaderstats[Stat].Value + Value
		end
	end
end)
