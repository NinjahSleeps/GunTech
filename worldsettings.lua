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

local function toggleLighting(toggle)
	Lighting.GlobalShadows = toggle
end

local function toggleMaterials(toggle)
	for _, part in pairs(workspace:GetDescendants()) do
		if part:IsA("BasePart") and part.Parent ~= part.Parent:IsA("Accessory") then
			if toggle then
				if part:FindFirstChild("MaterialValue") then
					part.Material = part.MaterialValue.Value
				else
					local MaterialValue = Instance.new("StringValue")
					MaterialValue.Name = "MaterialValue"
					MaterialValue.Value = part.Material.Name
					MaterialValue.Parent = part
				end
			else
				if part:FindFirstChild("MaterialValue") then
					part.Material = part.MaterialValue.Value
				else
					local MaterialValue = Instance.new("StringValue")
					MaterialValue.Name = "MaterialValue"
					MaterialValue.Value = part.Material.Name
					MaterialValue.Parent = part
				end
				part.Material = Enum.Material.SmoothPlastic
			end
		end
	end
end

local function toggleShaders(toggle)
	for _, part in pairs(Lighting:GetDescendants()) do
		if part:IsA("BloomEffect") then
			part.Enabled = toggle
		elseif part:IsA("DepthOfFieldEffect") then
			part.Enabled = toggle
		elseif part:IsA("SunRaysEffect") then
			part.Enabled = toggle
		elseif part:IsA("Atmosphere") then
			if toggle == true then
				part.Density = 0.3
				part.Offset = 0.25
				part.Color = Color3.fromRGB(192, 192, 192)
			else
				part.Density = 0
				part.Offset = 0
				part.Color = Color3.fromRGB(0, 0, 0)
			end
		end
	end
end

task.wait(1)


for i,v in pairs(script.Parent:GetChildren()) do
	if v:IsA("Frame") then
		print(v)
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
			end
		end
	end
end

Settings:WaitForChild("Shadows"):GetPropertyChangedSignal("Value"):Connect(function()
	toggleLighting(Settings:WaitForChild("Shadows").Value)
end)

Settings:WaitForChild("Materials"):GetPropertyChangedSignal("Value"):Connect(function()
	toggleMaterials(Settings:WaitForChild("Materials").Value)
end)

Settings:WaitForChild("Shaders"):GetPropertyChangedSignal("Value"):Connect(function()
	toggleShaders(Settings:WaitForChild("Shaders").Value)
end)
