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


task.wait(1)


for i,v in pairs(script.Parent:GetChildren()) do
	if v:IsA("Frame") then
		if v.Name ~= "Title" then
			if v:FindFirstChild("Toggle") then
				print(v:FindFirstChild("Toggle"))
				local ToggleButton:TextButton = v:FindFirstChild("Toggle"):WaitForChild("Button")
				local Gradient = ToggleButton:WaitForChild("UIGradient") or ToggleButton:FindFirstChildOfClass("UIGradient")
				local Setting = Settings:WaitForChild(v.Name)
				
				-- Initialize Button Positioning upon settings being loaded --
				if Setting.Value == true then
					TweenService:Create(ToggleButton, ButtonTweenInfo, {Position = UDim2.new(0.401, 0,0, 0)}):Play()
					local ColorSequence = ColorSequence.new(Color3.fromRGB(25,115,135), Color3.fromRGB(0, 146, 179))
					Gradient.Color = ColorSequence	
				elseif Setting.Value == false then
					TweenService:Create(ToggleButton, ButtonTweenInfo, {Position = UDim2.new(-0.009, 0,0, 0)}):Play()
					local ColorSequence = ColorSequence.new(Color3.fromRGB(63, 63, 63), Color3.fromRGB(129, 129, 129))
					Gradient.Color = ColorSequence
				end
				
				-- Change if Button Clicked --
				ToggleButton.MouseButton1Click:Connect(function()
					if ToggleButton.Position == UDim2.new(0.401, 0,0, 0) or Setting.Value == true then
						TweenService:Create(ToggleButton, ButtonTweenInfo, {Position = UDim2.new(-0.009, 0,0, 0)}):Play()
						local ColorSequence = ColorSequence.new(Color3.fromRGB(63, 63, 63), Color3.fromRGB(129, 129, 129))
						Gradient.Color = ColorSequence
						ChangeSettingEvent:FireServer(v.Name, false)
						ClickSound:Play()
					elseif ToggleButton.Position == UDim2.new(-0.009, 0,0, 0) or  Setting.Value == false then
						TweenService:Create(ToggleButton, ButtonTweenInfo, {Position = UDim2.new(0.401, 0,0, 0)}):Play()
						local ColorSequence = ColorSequence.new(Color3.fromRGB(25,115,135), Color3.fromRGB(0, 146, 179))
						Gradient.Color = ColorSequence
						ChangeSettingEvent:FireServer(v.Name, true)
						ClickSound:Play()

					end
				end)
			elseif v:FindFirstChild("Options") then
				if v.Name ~= "Title" then
					for index,variable in pairs(v:WaitForChild("Options"):GetChildren()) do
						if variable:IsA("TextButton") then
							local Option = Settings:WaitForChild("HitmarkerType")
							variable.BackgroundColor3 = Color3.fromRGB(0, 146, 179)

							variable.MouseButton1Click:Connect(function()
								for type,settingType in pairs(v:WaitForChild("Options"):GetChildren()) do
									if settingType:IsA("TextButton") then
										if settingType ~= variable then
											settingType.BackgroundColor3 = Color3.fromRGB(0, 146, 179)

										end
									end
								end
								variable.BackgroundColor3 = Color3.fromRGB(27, 67, 71)
								ChangeSettingEvent:FireServer(Option.Name, variable.Name)
								ClickSound:Play()
							end)
						end
					end
				end
			end
		end
	end
end

