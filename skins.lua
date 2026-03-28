local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local ChangeSettingEvent = RemoteEvents:WaitForChild("SettingsToggle")
local TweenService = game:GetService("TweenService")
local Settings = Player:WaitForChild("Settings")
local ButtonTweenInfo = TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0,false,0)
local ClickSound = script.Parent.Parent:WaitForChild("Click")
local MarketplaceService = game:GetService("MarketplaceService")


task.wait(1)


for i,v in pairs(script.Parent:GetChildren()) do
	if v:IsA("Frame") then
		if v:FindFirstChild("TextButton") then
			local Button:TextButton = v:FindFirstChild("TextButton")
			Button.MouseButton1Click:Connect(function()
				if v:FindFirstChild("GamepassID") then
					-- Gamepass Skin --
					local GamepassID = v:WaitForChild("GamepassID")
					if MarketplaceService:UserOwnsGamePassAsync(Player.UserId, GamepassID.Value) then
						ClickSound:Play()
						for index,variable in pairs(script.Parent:GetChildren()) do
							if variable:IsA("Frame") and variable ~= v then
								if variable:FindFirstChild("TextButton") then
									variable:FindFirstChild("TextButton").BackgroundColor3 = Color3.fromRGB(0, 146, 179)
									variable:FindFirstChild("TextButton").Text = "Equip"
								end
							end
						end
						Button.Text = "Equipped"
						Button.BackgroundColor3 = Color3.fromRGB(0, 76, 93)
						ChangeSettingEvent:FireServer("Skin", v.Name)
					else
						local success, fail = pcall(MarketplaceService:PromptPurchase(Player, GamepassID.Value))
						if success then
							ClickSound:Play()
							ChangeSettingEvent:FireServer("Skin", v.Name)
						else
							warn(fail)
						end
					end
					MarketplaceService:PromptGamePassPurchase(Player, v:FindFirstChild("GamepassID").Value)
				elseif v:FindFirstChild("GroupID") then
					-- Group Skin --
					local GroupID = v:WaitForChild("GroupID")
					if Player:IsInGroup(GroupID.Value) then
						for index,variable in pairs(script.Parent:GetChildren()) do
							if variable:IsA("Frame") and variable ~= v then
								if variable:FindFirstChild("TextButton") then
									variable:FindFirstChild("TextButton").BackgroundColor3 = Color3.fromRGB(0, 146, 179)
									variable:FindFirstChild("TextButton").Text = "Equip"
								end
							end
						end
						ClickSound:Play()
						Button.Text = "Equipped"
						Button.BackgroundColor3 = Color3.fromRGB(0, 76, 93)
						ChangeSettingEvent:FireServer("Skin", v.Name)
					end
				else
					-- Free Skin --
					for index,variable in pairs(script.Parent:GetChildren()) do
						if variable:IsA("Frame") and variable ~= v then
							if variable:FindFirstChild("TextButton") then
								variable:FindFirstChild("TextButton").BackgroundColor3 = Color3.fromRGB(0, 146, 179)
								variable:FindFirstChild("TextButton").Text = "Equip"
							end
						end
					end
					ClickSound:Play()
					Button.Text = "Equipped"
					Button.BackgroundColor3 = Color3.fromRGB(0, 76, 93)
					ChangeSettingEvent:FireServer("Skin", v.Name)
				end
			end)
		end
	end
end

