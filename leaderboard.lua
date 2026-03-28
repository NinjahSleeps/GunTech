-- Client Script for leaderboard --

-- Services --
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Teams = game:GetService("Teams")
local UserInputService = game:GetService("UserInputService")

local StarterGui = game:GetService("StarterGui")

task.spawn(function()
	local success = false
	repeat
		success = pcall(function()
			StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, false)		
		end)
		task.wait(0.1)
	until success
end)

-- Remote Events --
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local StatChangeEvent:RemoteEvent = RemoteEvents:WaitForChild("StatsUpdate")
local LeaderboardUpdateEvent:RemoteEvent = RemoteEvents:WaitForChild("LeaderboardUpdate")


-- UI Variables --
local Banners = script:WaitForChild("Banners")
local Main = script.Parent
local HostTop = Main:WaitForChild("HostTop")
local HostBottom = Main:WaitForChild("HostBottom")
local HostPlayerList = HostBottom:WaitForChild("ScrollingFrame")
local HostPlayerCount = HostTop:WaitForChild("PlayerCount")
local HostKills = HostTop:WaitForChild("Kills")
local HostDamage = HostTop:WaitForChild("Dmg")
local HostHeals = HostTop:WaitForChild("Heals")
local HostCaps = HostTop:WaitForChild("Caps")

local KronTop = Main:WaitForChild("KronTop")
local KronBottom = Main:WaitForChild("KronBottom")
local KronPlayerList = KronBottom:WaitForChild("ScrollingFrame")
local KronPlayerCount = KronTop:WaitForChild("PlayerCount")
local KronKills = KronTop:WaitForChild("Kills")
local KronDamage = KronTop:WaitForChild("Dmg")
local KronHeals = KronTop:WaitForChild("Heals")
local KronCaps = KronTop:WaitForChild("Caps")

-- Playerframe Variables --
local Gradients = script:WaitForChild("Gradients")

local PlayersList = {}


-- Functions --



local function newFrame(Player:Player)
	local Frame = script:WaitForChild("PlayerFrame"):Clone()
	Frame.Name = Player.Name
	local leaderstats = Player:WaitForChild("leaderstats")

	-- UI Text--
	local KillsText = Frame:WaitForChild("Kills")
	local DamageText = Frame:WaitForChild("Damage")
	local HealsText = Frame:WaitForChild("Heals")
	local CapsText = Frame:WaitForChild("Caps")
	local UsernameText = Frame:WaitForChild("Username")
	local PlayerIcon = Frame:WaitForChild("PlayerIcon")
	local BannerImage = Frame:WaitForChild("Banner")

	-- Players Leaderstats --
	local Kills = leaderstats:WaitForChild("Kills")
	local Damage = leaderstats:WaitForChild("Damage")
	local Heals = leaderstats:WaitForChild("Heals")
	local Caps = leaderstats:WaitForChild("Caps")

	-- Player Settings --
	local PlayerSettings = Player:WaitForChild("Settings")
	local Banner = PlayerSettings:WaitForChild("Banner")
	
	UsernameText.Text = Player.Name
	KillsText.Text = Kills.Value
	DamageText.Text = Damage.Value
	HealsText.Text = Heals.Value
	CapsText.Text = CapsText.Text
	
	local PlayerImage = Players:GetUserThumbnailAsync(Player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size420x420)
	PlayerIcon.Image = PlayerImage

	-- Get the Correct Gradient --

	-- Kronian Gradient
	if Player.Team == Teams:WaitForChild("Kronians") then
		if Frame:FindFirstChild("HostileGradient") then
			Frame:WaitForChild("HostileGradient"):Destroy()
			local DefenderGradient = Gradients:WaitForChild("DefenderGradient"):Clone()
			DefenderGradient.Parent = Frame
			Frame.Parent = KronPlayerList
		elseif Frame:FindFirstChild("DefenderGradient") then
		else
			local DefenderGradient = Gradients:WaitForChild("DefenderGradient"):Clone()
			DefenderGradient.Parent = Frame
			Frame.Parent = KronPlayerList
		end
	else
		-- Hostile/Spec Gradient
		if Frame:FindFirstChild("DefenderGradient") then
			Frame:WaitForChild("DefenderGradient"):Destroy()
			local HostileGradient = Gradients:WaitForChild("HostileGradient"):Clone()
			HostileGradient.Parent = Frame
			Frame.Parent = HostPlayerList
		elseif Frame:FindFirstChild("HostileGradient") then
		else
			local HostileGradient = Gradients:WaitForChild("HostileGradient"):Clone()
			HostileGradient.Parent = Frame
			Frame.Parent = HostPlayerList

		end	
	end

	if Banner.Value ~= "Default" and Banner.Value ~= "" and Banner.Value ~= " " then
		BannerImage.Image = Banners:FindFirstChild(Banner.Value).Image
		Frame:WaitForChild("Banner").Visible = true
	else
		Frame:WaitForChild("Banner").Visible = false
	end	
	
	Kills:GetPropertyChangedSignal("Value"):Connect(function()
		KillsText.Text = Kills.Value
	end)

	Damage:GetPropertyChangedSignal("Value"):Connect(function()
		DamageText.Text = Damage.Value
	end)

	Heals:GetPropertyChangedSignal("Value"):Connect(function()
		HealsText.Text = Heals.Value
	end)

	Caps:GetPropertyChangedSignal("Value"):Connect(function()
		CapsText.Text = Caps.Value
	end)
	
	Player:GetPropertyChangedSignal("Team"):Connect(function()
		if Player.Team == Teams:WaitForChild("Kronians") then
			if Frame:FindFirstChild("HostileGradient") then
				Frame:WaitForChild("HostileGradient"):Destroy()
				local DefenderGradient = Gradients:WaitForChild("DefenderGradient"):Clone()
				DefenderGradient.Parent = Frame
				Frame.Parent = KronPlayerList
			elseif Frame:FindFirstChild("DefenderGradient") then
			else
				local DefenderGradient = Gradients:WaitForChild("DefenderGradient"):Clone()
				DefenderGradient.Parent = Frame
				Frame.Parent = KronPlayerList
			end
		else
			-- Hostile/Spec Gradient
			if Frame:FindFirstChild("DefenderGradient") then
				Frame:WaitForChild("DefenderGradient"):Destroy()
				local HostileGradient = Gradients:WaitForChild("HostileGradient"):Clone()
				HostileGradient.Parent = Frame
				Frame.Parent = HostPlayerList
			elseif Frame:FindFirstChild("HostileGradient") then
			else
				local HostileGradient = Gradients:WaitForChild("HostileGradient"):Clone()
				HostileGradient.Parent = Frame
				Frame.Parent = HostPlayerList
			end
		end
	end)
	
	Banner:GetPropertyChangedSignal("Value"):Connect(function()
		if Banner.Value ~= "Default" and Banner.Value ~= "" and Banner.Value ~= " " then
			BannerImage.Image = Banners:FindFirstChild(Banner.Value).Image
			Frame:WaitForChild("Banner").Visible = true
		else
			Frame:WaitForChild("Banner").Visible = false
		end	
	end)
end

local function AddFrame(Player:Player)
	if Player.Team == Teams:WaitForChild("Kronians") then
		print("Running Checks for Kronian Team")
		if KronPlayerList:FindFirstChild(Player.Name) then
			print(Player.Name .. " Already Found inside of Kronian Playerlist")
		elseif HostPlayerList:FindFirstChild(Player.Name) then
			print(Player.Name .. " Already Found inside of Hostile Playerlist, Switching to Kronian Playerlist")
			local Frame = HostPlayerList:FindFirstChild(Player.Name)
			if Frame:FindFirstChild("HostileGradient") then
				Frame:WaitForChild("HostileGradient"):Destroy()
				local DefenderGradient = Gradients:WaitForChild("DefenderGradient"):Clone()
				DefenderGradient.Parent = Frame
			elseif Frame:FindFirstChild("DefenderGradient") then
			else
				local DefenderGradient = Gradients:WaitForChild("DefenderGradient"):Clone()
				DefenderGradient.Parent = Frame
			end
			Frame.Parent = KronPlayerList
		else
			print(Player.Name .. " Frame doesnt exist, intializing new Frame")
			newFrame(Player)
		end
	else
		print("Running Checks for Hostile Team")

		if HostPlayerList:FindFirstChild(Player.Name) then
			print(Player.Name .. " Already Found inside of Hostile Playerlist")

		elseif KronPlayerList:FindFirstChild(Player.Name) then
			print(Player.Name .. " Already Found inside of Kronian Playerlist, switching to Hostile Playerlist")

			local Frame = KronPlayerList:FindFirstChild(Player.Name)
			Frame.Name = Player.Name
			if Frame:FindFirstChild("DefenderGradient") then
				Frame:WaitForChild("DefenderGradient"):Destroy()
				local HostileGradient = Gradients:WaitForChild("HostileGradient"):Clone()
				HostileGradient.Parent = Frame
			elseif Frame:FindFirstChild("HostileGradient") then
			else
				local HostileGradient = Gradients:WaitForChild("HostileGradient"):Clone()
				HostileGradient.Parent = Frame
			end
			Frame.Parent = HostPlayerList
		else
			print(Player.Name .. " Frame doesnt exist, intializing new Frame")
			newFrame(Player)
		end
	end
end

local function removeFrame(Player)
	
	local Frame = HostPlayerList:FindFirstChild(Player.Name) or KronPlayerList:FindFirstChild(Player.Name)
	if Frame then	
		Frame:Destroy()
	end
end

local function UpdatePlayerList(Player, Type)
	if Type == "Add" then
		if not table.find(PlayersList, Player) then
			table.insert(PlayersList, Player)
			newFrame(Player)
		end
	elseif Type == "Remove" then
		local PlayerIndex = table.find(PlayersList, Player)
		if PlayerIndex then
			removeFrame(Player)
			table.remove(PlayersList, PlayerIndex)
		end
	end
end



-- Updates --


LeaderboardUpdateEvent.OnClientEvent:Connect(function(Type, Player)
	UpdatePlayerList(Player, Type)
	AddFrame(Player)
end)


-- Initialize --
task.wait(5)
for i,v in pairs(Players:GetPlayers()) do
	UpdatePlayerList(v, "Add")
	AddFrame(v)
end

UserInputService.InputBegan:Connect(function(Input, IsTyping)
	if IsTyping == false then
		if Input.KeyCode == Enum.KeyCode.Tab then
			Main.Enabled = not Main.Enabled
		end
	end
end)
