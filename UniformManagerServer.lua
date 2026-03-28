local Event = game.ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("ChangeUniform")

local Clothes = {}

Event.OnServerEvent:Connect(function(Player, Status, Shirt, Pants)
	if Status == true then
		for _,plr in pairs(Clothes) do
			if plr.Name == Player.Name then
				plr.WearingUniform = true
				
				plr.Shirt = Shirt.ShirtTemplate
				plr.Pants = Pants.PantsTemplate

				Player.Character:FindFirstChildOfClass("Shirt").ShirtTemplate = plr.Shirt
				Player.Character:FindFirstChildOfClass("Pants").PantsTemplate = plr.Pants
			end
		end
	else
		for _,plr in pairs(Clothes) do
			if plr.Name == Player.Name then
				plr.WearingUniform = false
				
				Player.Character:FindFirstChildOfClass("Shirt").ShirtTemplate = plr.OGShirt
				Player.Character:FindFirstChildOfClass("Pants").PantsTemplate = plr.OGPants
			end
		end
	end
end)

game.Players.PlayerAdded:Connect(function(Player)
	Player.CharacterAdded:Connect(function(Character)
		local playerClothing = {
			Name = Player.Name,
			OGShirt = Character:WaitForChild("Shirt").ShirtTemplate,
			OGPants = Character:WaitForChild("Pants").PantsTemplate,
			Shirt = '',
			Pants = '',
			WearingUniform = false
		}
		local alreadyExists = false
		for _, v in pairs(Clothes) do
			if v.Name == Player.Name then
				alreadyExists = true
				break
			end
		end
		
		if not alreadyExists then table.insert(Clothes, playerClothing) end
		
		for _,plr in pairs(Clothes) do
			if plr.Name == Player.Name and plr.WearingUniform then
				Player.Character:FindFirstChildOfClass("Shirt").ShirtTemplate = plr.Shirt
				Player.Character:FindFirstChildOfClass("Pants").PantsTemplate = plr.Pants
			end
		end
	end)
end)
