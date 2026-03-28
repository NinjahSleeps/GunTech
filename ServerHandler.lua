local DebrisService = game:GetService("Debris")

local Remote1 = Instance.new("RemoteEvent", game.ReplicatedStorage:WaitForChild("RemoteEvents"))
Remote1.Name = "Shoot"

local MediEvent = Instance.new("RemoteEvent", game.ReplicatedStorage:WaitForChild("RemoteEvents"))
MediEvent.Name = "MediEvent"

local KillEvent = Instance.new("RemoteEvent", game.ReplicatedStorage:WaitForChild("RemoteEvents"))
KillEvent.Name = "KillEvent"

local ChangeUniformEvent = Instance.new("RemoteEvent", game.ReplicatedStorage:WaitForChild("RemoteEvents"))
ChangeUniformEvent.Name = "ChangeUniform"

local LeaderboardEvent = Instance.new("RemoteEvent", game.ReplicatedStorage:WaitForChild("RemoteEvents"))
LeaderboardEvent.Name = "LeaderboardUpdate"

local StatsUpdateEvent = Instance.new("RemoteEvent", game.ReplicatedStorage:WaitForChild("RemoteEvents"))
StatsUpdateEvent.Name = "StatsUpdate"


Remote1.OnServerEvent:Connect(function(Player, Shootpart, Hits, Misses, Damage, HeadshotDamage, ChargeAmt, ChargeDamage)

	for i,v in pairs(Hits) do
		if v then
			local HitPlayer = v[1]
			local HitPart = v[2]
			local BeamPosition = v[3]
			
			local Humanoid = HitPlayer:FindFirstChild("Humanoid")
			print(HitPart)
			print(HitPlayer)
			print(BeamPosition)
			local Playerstats = Player:WaitForChild("leaderstats")
			local DamageStat = Playerstats:WaitForChild("Damage")
			if Humanoid then
				if ChargeAmt then
					if ChargeAmt >= 1 then
						Humanoid:TakeDamage(ChargeDamage)
						DamageStat.Value = DamageStat.Value + ChargeDamage
					end
					
				elseif HitPart.Name == "Head" then
					Humanoid:TakeDamage(HeadshotDamage)
					DamageStat.Value = DamageStat.Value + HeadshotDamage
				else
					Humanoid:TakeDamage(Damage)
					DamageStat.Value = DamageStat.Value + Damage
				end
				if Humanoid:FindFirstChild("CreatorTag") then
					Humanoid:WaitForChild("CreatorTag").Value = Player
					DebrisService:AddItem(Humanoid:WaitForChild("CreatorTag"), 1)
				else
					local CreatorTag = Instance.new("ObjectValue")
					CreatorTag.Name = "CreatorTag"
					CreatorTag.Parent = Humanoid
					CreatorTag.Value = Player
					DebrisService:AddItem(CreatorTag, 1)
				end

				if Humanoid:FindFirstChild("ShootPosition") then
					Humanoid:WaitForChild("ShootPosition").Value = BeamPosition
				else
					local ShootPosition = Instance.new("Vector3Value")
					ShootPosition.Name = "ShootPosition"
					ShootPosition.Parent = Humanoid
					ShootPosition.Value = BeamPosition
					DebrisService:AddItem(ShootPosition, 1)
				end
			end
		end
	end
	
	for i,v in pairs(game.Players:GetPlayers()) do
		if v ~= Player then
			Remote1:FireClient(v, Player, Shootpart, Hits, Misses)
		end
	end
	
	
end)

MediEvent.OnServerEvent:Connect(function(Player, Humanoid, HealedTorso, HealAmount)
	if Humanoid then
		Humanoid.Health = Humanoid.Health + HealAmount
	end
end)
