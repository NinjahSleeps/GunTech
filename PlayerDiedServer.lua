local KillEvent = game.ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("KillEvent")

game.Players.PlayerAdded:Connect(function(Player)
	Player.CharacterAdded:Connect(function(Character)
		local Humanoid:Humanoid = Character:WaitForChild("Humanoid")
		Humanoid.Died:Connect(function()
			if Humanoid:FindFirstChild("CreatorTag") then
				if Humanoid:FindFirstChild("ShootPosition") then
					KillEvent:FireClient(Humanoid:FindFirstChild("CreatorTag").Value, Humanoid, Humanoid:FindFirstChild("ShootPosition").Value)
				else
					KillEvent:FireClient(Humanoid:FindFirstChild("CreatorTag").Value, Humanoid, Humanoid:WaitForChild("HumanoidRootPart").Position)
				end
				
				print(Humanoid:FindFirstChild("CreatorTag").Value)
			end
		end)
	end)
end)
