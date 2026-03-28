local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local ChangeUniformEvent = RemoteEvents:WaitForChild("ChangeUniform")
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
				if v:FindFirstChild("Dependencies") then
					-- Uniforms --
					local Dependancies = v:WaitForChild("Dependencies")
					local GroupID = Dependancies:WaitForChild("Group")
					local RankValue = Dependancies:WaitForChild("Rank")
					local Equipped = Dependancies:WaitForChild("Equipped")
					if Player:IsInGroup(GroupID.Value) and Player:GetRankInGroup(GroupID.Value) >= RankValue.Value then
						for index,variable in pairs(script.Parent:GetChildren()) do
							if variable:IsA("Frame") and variable ~= v then
								if variable:FindFirstChild("TextButton") then
									variable:FindFirstChild("TextButton").BackgroundColor3 = Color3.fromRGB(0, 146, 179)
									variable:FindFirstChild("TextButton").Text = "Equip"
									variable:WaitForChild("Dependencies"):WaitForChild("Equipped").Value = false
								end
							end
						end
						Equipped.Value = not Equipped.Value
						if Equipped.Value == true then
							Button.Text = "Equipped"
							Button.BackgroundColor3 = Color3.fromRGB(0, 76, 93)
						else
							Button.Text = "Equip"
							Button.BackgroundColor3 = Color3.fromRGB(0, 146, 179)
						end
						ClickSound:Play()
						ChangeUniformEvent:FireServer(Equipped.Value, Dependancies:WaitForChild("Shirt"), Dependancies:WaitForChild("Pants"))
					end
				else
					-- Equip since theres no dependancies for some reason --
					local Dependancies = v:WaitForChild("Dependencies")
					local Equipped = Dependancies:WaitForChild("Equipped")

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
					ChangeUniformEvent:FireServer(Dependancies:WaitForChild("Shirt"), Dependancies:WaitForChild("Pants"))
				end
			end)
		end
	end
end

