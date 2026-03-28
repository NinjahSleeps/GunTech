local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Lighting = game:GetService("Lighting")

local Camera = workspace.CurrentCamera
local Music = script.Parent:WaitForChild("KronianTheme")
local Blur = Lighting:WaitForChild("Blur")
local MainFrame = script.Parent.Parent
local LocalButton = script.Parent.Parent:WaitForChild("Local")
local SkinsButton = script.Parent.Parent:WaitForChild("Skins")
local BannersButton = script.Parent.Parent:WaitForChild("Banners")

local WorldButton = script.Parent.Parent:WaitForChild("World")
local UniformsButton = script.Parent.Parent:WaitForChild("Uniforms")
local UiPage = script.Parent:WaitForChild("UIPageLayout")
local Main = script.Parent.Parent
local SpecialClick = script.Parent:WaitForChild("SpecialClick")
local isOpen = false

function openUI(openType)
	if openType == true then
		Main.Visible = true
		local BigTween = TweenService:Create(MainFrame, TweenInfo.new(.3,Enum.EasingStyle.Quad, Enum.EasingDirection.Out,0,false,0), {Size = UDim2.new(0.401, 0,0.837, 0)})
		BigTween:Play()
		local LightTween = TweenService:Create(Blur, TweenInfo.new(.3,Enum.EasingStyle.Quad, Enum.EasingDirection.InOut,0,false,0), {Size = 56})
		LightTween:Play()
		local MusicTween = TweenService:Create(Music, TweenInfo.new(1,Enum.EasingStyle.Quad, Enum.EasingDirection.InOut,0,false,0), {Volume = 0.5})
		MusicTween:Play()
		local FoVTwin = TweenService:Create(Camera, TweenInfo.new(.3,Enum.EasingStyle.Quad, Enum.EasingDirection.InOut,0,false,0), {FieldOfView = 40})
		FoVTwin:Play()
	else
		local BigTween = TweenService:Create(MainFrame, TweenInfo.new(.3,Enum.EasingStyle.Quad, Enum.EasingDirection.Out,0,false,0), {Size = UDim2.new(0, 0,0, 0)})
		BigTween:Play()
		local LightTween = TweenService:Create(Blur, TweenInfo.new(.3,Enum.EasingStyle.Quad, Enum.EasingDirection.InOut,0,false,0), {Size = 0})
		LightTween:Play()
		local MusicTween = TweenService:Create(Music, TweenInfo.new(1,Enum.EasingStyle.Quad, Enum.EasingDirection.InOut,0,false,0), {Volume = 0})
		MusicTween:Play()
		local FoVTwin = TweenService:Create(Camera, TweenInfo.new(.3,Enum.EasingStyle.Quad, Enum.EasingDirection.InOut,0,false,0), {FieldOfView = 70})
		FoVTwin:Play()
		BigTween.Completed:Connect(function()
			Main.Visible = false
		end)
	end 
end

WorldButton.MouseButton1Click:Connect(function()
	UiPage:JumpTo(script.Parent:WaitForChild("World")) 
	SpecialClick:Play()
end)

LocalButton.MouseButton1Click:Connect(function()
	UiPage:JumpTo(script.Parent:WaitForChild("Local")) 
	SpecialClick:Play()

end)

SkinsButton.MouseButton1Click:Connect(function()
	UiPage:JumpTo(script.Parent:WaitForChild("Skins")) 
	SpecialClick:Play()

end)

BannersButton.MouseButton1Click:Connect(function()
	UiPage:JumpTo(script.Parent:WaitForChild("Banners")) 
	SpecialClick:Play()

end)

UniformsButton.MouseButton1Click:Connect(function()
	UiPage:JumpTo(script.Parent:WaitForChild("Uniforms")) 
	SpecialClick:Play()

end)


UserInputService.InputBegan:Connect(function(Key, IsTyping)
	if not IsTyping then
		if Key.KeyCode == Enum.KeyCode.M then
			isOpen = not isOpen
			openUI(isOpen)
		end
	end
end)
