-- This is the module script called "Client Services" --

-- Services --
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local RunService = game:GetService("RunService")
local Player = Players.LocalPlayer

-- UI --
local StarterGui = Player.PlayerGui
local Main = StarterGui:WaitForChild("UI")
local AmmoBar = Main:WaitForChild("Main"):WaitForChild("CanvasGroup"):WaitForChild("AmmoBar")
local AmmoCircle = AmmoBar:WaitForChild("UIStroke"):WaitForChild("UIGradient")
local CanvasGroup = Main:WaitForChild("Main"):WaitForChild("CanvasGroup")
local IconTweenFrame = Main:WaitForChild("Main"):WaitForChild("CanvasGroup"):WaitForChild("IconTween")
local PageLayout = IconTweenFrame:WaitForChild("UIPageLayout")

-- Setting Values --
local Settings = Player:WaitForChild("Settings")
local HitmarkerTypeSetting:StringValue = Settings:WaitForChild("HitmarkerType")
local KillmarkerSetting:BoolValue = Settings:WaitForChild("Killmarker")

-- Cursor UI --
local CursorUi = StarterGui:WaitForChild("CursorUi")
local CursorFrame = CursorUi:WaitForChild("Frame")
local KillMarker = CursorFrame:WaitForChild("KillMarker")
local KillMarkerStroke = KillMarker:WaitForChild("UIStroke")

-- Hitmarker UI -- 
local HitmarkerUi = CursorFrame:WaitForChild("Hitmarker")
local HitmarkerImage = HitmarkerUi:WaitForChild("HitmarkerIcon")

local FADE_DELAY = 1
local FADE_TIME = 0.1
local SHOW_TIME = 0.85
local fadeTimerId = 0
local totalDamage = 0
local indicatorVisible = false

-- Remote Events --
local RemoteEvents= ReplicatedStorage:WaitForChild("RemoteEvents")
local Event:RemoteEvent = RemoteEvents:WaitForChild("Shoot")
local KillmarkerEvent:RemoteEvent = RemoteEvents:WaitForChild("KillEvent")

local CurrentRotation = 0

local ClientServices = {}

local function RandomCone(axis: Vector3, angle: number)
	local cosAngle = math.cos(angle)
	local z = 1 - math.random() * (1 - cosAngle)
	local phi = math.random() * math.pi * 2
	local r = math.sqrt(1 - z * z)
	local x, y = r * math.cos(phi), r * math.sin(phi)
	local vec = Vector3.new(x, y, z)
	if axis.Z > 0.9999 then
		return vec
	elseif axis.Z < -0.9999 then
		return -vec
	end
	local orth = Vector3.zAxis:Cross(axis)
	local rot = math.acos(axis:Dot(Vector3.zAxis))
	return CFrame.fromAxisAngle(orth, rot) * vec
end

function ClientServices:tweenTransparency(guiObject, targetTransparency, duration)
	for _, obj in ipairs(guiObject:GetDescendants()) do
		if obj:IsA("TextLabel") or obj:IsA("ImageLabel") then
			TweenService:Create(obj, TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				TextTransparency = targetTransparency,
			}):Play()
		end
	end
end

function ClientServices:Beam(StartPos, EndPos, PlrShooting, plr)

	local beam = Instance.new("Beam")
	local Attachment1 = Instance.new("Attachment", workspace.Terrain)
	local Attachment2 = Instance.new("Attachment", workspace.Terrain)
	Attachment1.Name = "Attachment1"
	Attachment2.Name = "Attachment2"
	Attachment1.Position = StartPos
	Attachment2.Position = EndPos
	beam.Name = Player.Name
	beam.Color = ColorSequence.new(PlrShooting.TeamColor.Color)
	beam.Attachment0 = Attachment1
	beam.Attachment1 = Attachment2
	beam.Parent = workspace
	beam.FaceCamera = true
	
	beam.LightEmission = 1
	beam.LightInfluence = 0
	beam.Brightness = 1
	
	if Settings:WaitForChild("DynamicRays").Value == false then
		beam.Texture = 0
		beam.TextureSpeed = 0 
		beam.Transparency = NumberSequence.new(0,1)
		beam.Texture = 'rbxassetid://2950987178'
		beam.TextureMode = Enum.TextureMode.Stretch
		beam.TextureSpeed = 4
		beam.Width0 = 0.2
		beam.Width1 = 0.1
		Debris:AddItem(beam, .025)
		Debris:AddItem(Attachment1, .1)
		Debris:AddItem(Attachment2, .1)
	else 
		beam.Texture = 'rbxassetid://11226108137'
		beam.TextureSpeed = 4
		beam.Transparency = NumberSequence.new(0,0)
		beam.TextureMode = Enum.TextureMode.Stretch
		beam.TextureLength = .8
		beam.Width0 = 1.3
		beam.Width1 = 1.5
		Debris:AddItem(beam, .04)
		Debris:AddItem(Attachment1, .04)
		Debris:AddItem(Attachment2, .04)
	end

	

end

function ClientServices:CreateDynamicRay(startPos, endPos,PlrShooting, plr)
	local Attachment0 = Instance.new("Attachment")
	local Attachment1 = Instance.new("Attachment")
	local BULLET_SPEED = 100
	
	local Beam = Instance.new("Beam")
	Beam.Attachment0 = Attachment0
	Beam.Attachment1 = Attachment1
	Beam.FaceCamera = true
	Beam.Width0 = 0.2
	Beam.Width1 = 0.2
	Beam.LightEmission = 1
	Beam.Color = ColorSequence.new(Color3.new(1, 0.2, 0.2))
	Beam.Transparency = NumberSequence.new(0, 1)

	local beamPart = Instance.new("Part")
	beamPart.Anchored = true
	beamPart.CanCollide = false
	beamPart.Size = Vector3.new(0.1,0.1,0.1)
	beamPart.Transparency = 1
	beamPart.Parent = workspace

	Attachment0.Parent = beamPart
	Attachment1.Parent = beamPart
	Beam.Parent = beamPart

	-- Start dynamic motion
	local distance = (endPos - startPos).Magnitude
	local direction = (endPos - startPos).Unit
	local travelTime = distance / BULLET_SPEED

	local elapsed = 0
	RunService.Heartbeat:Connect(function(dt)
		elapsed += dt
		local alpha = math.clamp(elapsed / travelTime, 0, 1)
		local currentPos = startPos + direction * (distance * alpha)

		Attachment0.WorldPosition = startPos
		Attachment1.WorldPosition = currentPos

		if alpha >= 1 then
			Debris:AddItem(beamPart, 0.1)
		end
	end)
end

function ClientServices:UpdateCircle(Ammo, MaxAmmo)
	AmmoCircle.Parent.Color = Color3.fromRGB(255, 255, 255)

	if Ammo < MaxAmmo then
		AmmoCircle.Transparency = NumberSequence.new(
			{
				NumberSequenceKeypoint.new(0,0),
				NumberSequenceKeypoint.new(Ammo/MaxAmmo,0),
				NumberSequenceKeypoint.new((Ammo/MaxAmmo)+.001,1),
				NumberSequenceKeypoint.new(1,1),
			}

		)
	elseif Ammo == MaxAmmo then
		AmmoCircle.Transparency = NumberSequence.new(
			{
				NumberSequenceKeypoint.new(0,0),
				NumberSequenceKeypoint.new(1,0),
			}

		)
	elseif Ammo == 0 then
		AmmoCircle.Transparency = NumberSequence.new(
			{
				NumberSequenceKeypoint.new(0,1),
				NumberSequenceKeypoint.new(1,1),
			}

		)
	end
	local Percentage = (Ammo/MaxAmmo)*100

	Main:WaitForChild("Main"):WaitForChild("CanvasGroup"):WaitForChild("AmmoPercentage").Text = math.round(Percentage) .. "%"
end

local function indicate(Part, Damage, Firerate, Charge, ChargeDamage)
	if Settings:WaitForChild("DmgIndicator").Value == true then
		if Settings:WaitForChild("Stack").Value == true then
			local Shadow = CursorFrame:WaitForChild("Damage")

			TweenService:Create(Shadow, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0,false,0), {TextTransparency = 0}):Play()

			-- Update stack amount
			totalDamage = Damage + totalDamage
			print(totalDamage)
			if Charge and ChargeDamage > 0 then
				print("Charge")
				if Charge >= 1 then
					Shadow.Text = tostring(ChargeDamage)
				else
					Shadow.Text = tostring(totalDamage)
				end
			else
				Shadow.Text = tostring(totalDamage)
			end
			
			-- Update shadow (if exists)
			if Shadow then
				if Charge and ChargeDamage > 0 then
					if Charge >= 1 then
						Shadow.Text = tostring(ChargeDamage)
					else
						Shadow.Text = tostring(totalDamage)
					end	
				else
					Shadow.Text = tostring(totalDamage)
				end
						
			else
				-- Optional: fallback — duplicate text for shadow effect
				local newShadow = Shadow:Clone()
				newShadow.Name = "ShadowText"
				newShadow.TextColor3 = Color3.new(0, 0, 0)
				newShadow.TextTransparency = 0.6
				newShadow.TextStrokeTransparency = 1 -- no stroke on shadow
				newShadow.Position = UDim2.new(0, 2, 0, 2) -- offset behind
				newShadow.ZIndex = Shadow.ZIndex - 1
				newShadow.Parent = Shadow
				if Charge then
					if Charge >= 1 then
						Shadow.Text = tostring(ChargeDamage)
					else
						Shadow.Text = tostring(totalDamage)
					end
				else
					Shadow.Text = tostring(totalDamage)
				end
			end

			-- Headshot color logic
			if Part.Name == "Head" then
				Shadow.TextColor3 = Color3.fromRGB(255, 70, 70)
			else
				Shadow.TextColor3 = Color3.fromRGB(255, 255, 255)
			end

			-- Keep TextStroke visible only on main text
			Shadow.TextStrokeTransparency = 0
			if Shadow then
				Shadow.TextStrokeTransparency = 1
			end

			-- Tween visible (main text only, not the shadow)
			if not indicatorVisible then
				indicatorVisible = true
				ClientServices:tweenTransparency(Shadow, 0, SHOW_TIME)
			end

			-- Fade timer logic
			fadeTimerId = Firerate + fadeTimerId
			local thisTimerId = fadeTimerId

			task.delay(FADE_DELAY, function()
				if thisTimerId == fadeTimerId then
					-- Fade out main text only, keep shadow
					
					ClientServices:tweenTransparency(Shadow, 1, FADE_TIME)
					indicatorVisible = false
					totalDamage = 0
					print("Resetting Damage")
					TweenService:Create(Shadow, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0,false,0), {TextTransparency = 1}):Play()

				end
			end)
		else
			local indicator = script:WaitForChild("DmgIndicator"):Clone()
			indicator:WaitForChild("Frame"):WaitForChild("Damage").Text = Damage
			if Charge then
				if Charge >= 1 then
					indicator:WaitForChild("Frame"):WaitForChild("Damage").Text = tostring(ChargeDamage)
				else
					indicator:WaitForChild("Frame"):WaitForChild("Damage").Text = Damage			
				end
			else
				indicator:WaitForChild("Frame"):WaitForChild("Damage").Text = Damage			

			end
			
			indicator.Enabled = true
			if Part.Name == "Head" then
				indicator:WaitForChild("Frame"):WaitForChild("Damage").TextColor3 = Color3.fromRGB(255, 70, 70)
			end
			local Attachment = Instance.new("Part")
			Attachment.Transparency = 1
			Attachment.Anchored = true
			Attachment.CanCollide = false
			Attachment.CanQuery = false
			Attachment.Position = Part.Position
			Attachment.Parent = workspace
			Attachment.Size = Vector3.new(0.001,0.001,0.001)
			indicator.Parent = Attachment
			local Ran1 = math.random(1,2)
			local RandomSide
			if Ran1 == 1 then
				indicator.SizeOffset = Vector2.new(1,0)
				RandomSide = Vector2.new(3,0)
			else
				indicator.SizeOffset = Vector2.new(-1,0)
				RandomSide = Vector2.new(-3,0)
			end
			Debris:AddItem(indicator, 1.1)

			local IndicatorTween = TweenService:Create(indicator, TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0,false,0), {SizeOffset = RandomSide})
			IndicatorTween:Play()
			IndicatorTween.Completed:Connect(function()
				local IndicatorTween = TweenService:Create(indicator, TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0,false,0), {Size = UDim2.new(0,0,0,0)}):Play()
			end)
		end
	end
end

function ClientServices:hitMarker(Part)
	if Settings:WaitForChild("Hitmarker").Value == true then
		if HitmarkerTypeSetting.Value == "Expand" then
			HitmarkerImage.Rotation = 0
			HitmarkerImage.Size = UDim2.new(.4,0,.4,0)
			HitmarkerImage.ImageTransparency = 0
			HitmarkerImage.ImageColor3 = Color3.fromRGB(255, 255, 255)
			local SizeTween = TweenService:Create(HitmarkerImage, TweenInfo.new(.4,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut, 0,false,0), {Size = UDim2.new(1.5,0,1.5,0)})
			TweenService:Create(HitmarkerImage, TweenInfo.new(.4,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut, 0,false,0), {ImageTransparency = 1}):Play()
			SizeTween:Play()
			SizeTween.Completed:Connect(function()
				HitmarkerImage.ImageTransparency = 1
				HitmarkerImage.Size = UDim2.new(.4,0,.4,0)
			end)
		elseif HitmarkerTypeSetting.Value == "Rotate" then

			HitmarkerImage.Size = UDim2.new(1,0,1,0)
			HitmarkerImage.ImageTransparency = 0
			if CurrentRotation >= 180 then
				CurrentRotation = -180
				HitmarkerImage.Rotation = CurrentRotation
			end
			CurrentRotation = CurrentRotation + 20
			HitmarkerImage.ImageColor3 = Color3.fromRGB(255, 255, 255)
			local RotationTween = TweenService:Create(HitmarkerImage, TweenInfo.new(.1,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut, 0,false,0), {Rotation = CurrentRotation})
			RotationTween:Play()

			TweenService:Create(HitmarkerImage, TweenInfo.new(.4,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut, 0,false,0), {ImageTransparency = 1}):Play()
			RotationTween.Completed:Connect(function()
				HitmarkerImage.ImageTransparency = 1

			end)
		elseif HitmarkerTypeSetting.Value == "Fade" then
			HitmarkerImage.Rotation = 0
			HitmarkerImage.Size = UDim2.new(1,0,1,0)
			HitmarkerImage.ImageTransparency = .1


			HitmarkerImage.ImageColor3 = Color3.fromRGB(255, 255, 255)


			local FadeTween = TweenService:Create(HitmarkerImage, TweenInfo.new(.6,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut, 0,false,0), {ImageTransparency = 0})
			FadeTween:Play()

			FadeTween.Completed:Connect(function()
				TweenService:Create(HitmarkerImage, TweenInfo.new(.6,Enum.EasingStyle.Quad,Enum.EasingDirection.InOut, 0,false,0), {ImageTransparency = 1}):Play()
			end)
		end
	end
end

function ClientServices:hitBox(Part)
	if Settings:WaitForChild("Hitboxes").Value == true then
		local hitbox = script:WaitForChild("SelectionBox"):Clone()
		if Part.Name == "Head" then
			hitbox.Color3 = Color3.fromRGB(113, 0, 0)
		else
			hitbox.Color3 = Color3.fromRGB(255, 255, 255)
		end
		hitbox.Parent = Part
		hitbox.Adornee = Part
		Debris:AddItem(hitbox, 1.1)
		local HitboxTween = TweenService:Create(hitbox, TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0,false,0), {Transparency = 0})
		HitboxTween:Play()
		HitboxTween.Completed:Connect(function()
			TweenService:Create(hitbox, TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0,false,0), {Transparency = 1}):Play()
		end)
	end
end

function ClientServices:commitRay(MouseHitPosition, ShellCount, MinDistance, MaxDistance, Spread, Shootpart, ShootSound, HitSound, HeadshotDamage, Damage, Firerate, Charge, ChargeDamage)
	local Hits = {}
	local Misses = {}
	local Origin = Player.Character:WaitForChild("Head").Position
	local Endpoint = MouseHitPosition
	for i=ShellCount, 1, -1 do
		local Params = RaycastParams.new()
		Params.FilterDescendantsInstances = {script.Parent, Player.Character}
		Params.FilterType = Enum.RaycastFilterType.Exclude
		local Axis = (Endpoint - Origin).Unit
		local Direction = RandomCone(Axis, math.rad(Spread)) * MaxDistance
		local AxisLength = (Endpoint-Origin).Magnitude
		if AxisLength <= MinDistance then
			Direction = (Endpoint - Origin).Unit * 10000
		end
		local RaycastResult = workspace:Raycast(Origin,Direction,Params)

		if RaycastResult then
			ShootSound:Play()
			local Hit = RaycastResult.Instance
			local Position = RaycastResult.Position

			ClientServices:Beam(Shootpart.Position, Position, Player)
			if Hit:IsA("BasePart") then
				if Hit.Parent:FindFirstChild("Humanoid") or Hit.Parent.Parent:FindFirstChild("Humanoid") then

					local Humanoid = Hit.Parent:FindFirstChild("Humanoid") or Hit.Parent.Parent:FindFirstChild("Humanoid")
					if Humanoid.Health > 0 then
						if RaycastResult.Instance.Name == "Head" then
							ClientServices:hitBox(RaycastResult.Instance)
							indicate(RaycastResult.Instance,HeadshotDamage,Firerate, Charge, ChargeDamage)
							ClientServices:hitMarker(RaycastResult.Instance)
							HitSound:Play()
							local NewHit = HitSound:Clone()
							NewHit.Parent = HitSound.Parent
							NewHit:Play()
							Debris:AddItem(NewHit, 2)	
						else
							ClientServices:hitBox(RaycastResult.Instance)
							indicate(RaycastResult.Instance,Damage,Firerate, Charge, ChargeDamage)							
							ClientServices:hitMarker(RaycastResult.Instance)
							HitSound:Play()
							local NewHit = HitSound:Clone()
							NewHit.Parent = HitSound.Parent
							NewHit:Play()
							Debris:AddItem(NewHit, 2)
						end
						table.insert(Hits, {Humanoid.Parent, RaycastResult.Instance, RaycastResult.Position})
					else
						table.insert(Misses, RaycastResult.Position)
					end
				else
					table.insert(Misses, RaycastResult.Position)

				end
			end
		else
			ShootSound:Play()
			local Position = Direction+Origin
			table.insert(Misses, Position)
			ClientServices:Beam(Shootpart.Position, Position, Player)

		end
	end

	Event:FireServer(Shootpart.Position, Hits, Misses, Damage, HeadshotDamage, Charge, ChargeDamage)	
end

function ClientServices:UpdateCharge(ChargeAmt, MaxAmt)
	TweenService:Create(CanvasGroup.Parent:WaitForChild("ChargeBG"):WaitForChild("Bar"), TweenInfo.new(.1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0,false,0), {Size = UDim2.new((ChargeAmt/MaxAmt),0,1,0)}):Play()
	CanvasGroup.Parent:WaitForChild("ChargeBG"):WaitForChild("ChargeAmt").Text = math.floor((ChargeAmt/MaxAmt)*100) .. "%"
end

return ClientServices
