-- Backpack GUI --

-- Services
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
game.StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
--
local keys = {
	Enum.KeyCode.One;
	Enum.KeyCode.Two;
	Enum.KeyCode.Three;
	Enum.KeyCode.Four;
	Enum.KeyCode.Five;
	Enum.KeyCode.Six;
	Enum.KeyCode.Seven;
	Enum.KeyCode.Eight;
	Enum.KeyCode.Nine;
	Enum.KeyCode.Zero;
}

local customKeyNames = {
	[Enum.KeyCode.One]   = "1";
	[Enum.KeyCode.Two]   = "2";
	[Enum.KeyCode.Three] = "3";
	[Enum.KeyCode.Four]  = "4";
	[Enum.KeyCode.Five]  = "5";
	[Enum.KeyCode.Six]   = "6";
	[Enum.KeyCode.Seven] = "7";
	[Enum.KeyCode.Eight] = "8";
	[Enum.KeyCode.Nine]  = "9";
	[Enum.KeyCode.Zero]  = "0";
}

local toolBinds = {}
local toolGuis = {}

local master = script.Parent

local player = Players.LocalPlayer
local backpack
local character
local humanoid
local equippedTool

-- Finds the earliest key that is not already bound to a tool
function GetNextAvailableKey()
	for _, key in pairs(keys) do
		if not toolBinds[key] then
			return key
		end
	end

	return nil
end

-- Checks if tool is bound to a key
function IsToolBound(tool)
	for key, boundTool in pairs(toolBinds) do
		if tool == boundTool then
			return true
		end
	end

	return false
end

-- Binds a tool if it is not bound already
function CheckTool(tool)
	if not IsToolBound(tool) then
		-- Bind tool
		local key = GetNextAvailableKey()
		toolBinds[key] = tool
		-- Create GUI
		local gui = script.Template:Clone()
		gui.Number.Text = customKeyNames[key] or key.Name
		gui.Parent = master
		gui.ToolName.Text = tool.Name


		toolGuis[tool] = gui
		local UiGradient = gui:WaitForChild("UIGradient")

		tool.Equipped:Connect(function()
			if gui then
				UiGradient.Transparency = NumberSequence.new(
					{
						NumberSequenceKeypoint.new(0,0),
						NumberSequenceKeypoint.new(1,0.363),
					}

				)

			end
		end)

		tool.Unequipped:Connect(function()
			if gui then
				UiGradient.Transparency = NumberSequence.new(
					{
						NumberSequenceKeypoint.new(0,0.3),
						NumberSequenceKeypoint.new(1,0.606),
					}

				)

			end
		end)

		-- Tool destroyed
		tool.AncestryChanged:Connect(function()
			if tool.Parent ~= character and tool.Parent ~= backpack then
				gui:Destroy()
				toolGuis[tool] = nil
				for key, oTool in pairs(toolBinds) do
					if tool == oTool then
						toolBinds[key] = nil
					end
				end
			end
		end)

		--print("Bound", tool, "to", key)
	end
end

-- When the player picks up a tool, set it up
function BackpackChildAdded(tool)
	if tool:IsA("Tool") then
		CheckTool(tool)
		if tool == equippedTool then
			equippedTool = nil
		end
	end
end

-- When the player respawns, clear the backpack
function CharacterAdded(char)
	-- Unbind tools
	toolBinds = {}

	-- Remove GUIs
	for _, gui in pairs(toolGuis) do
		gui:Destroy()
	end

	toolGuis = {}

	character = char

	-- Handle character tool added
	character.ChildAdded:Connect(function(tool)
		if tool:IsA("Tool") then
			CheckTool(tool)
			equippedTool = tool
		end
	end)

	-- Handle backpack
	backpack = player.Backpack
	backpack.ChildAdded:Connect(BackpackChildAdded)
	for _, child in pairs(backpack:GetChildren()) do
		BackpackChildAdded(child)
	end

	-- Handle death
	humanoid = character:WaitForChild("Humanoid")
	humanoid.Died:Connect(function()

	end)
end

player.CharacterAdded:Connect(CharacterAdded)

if player.Character then
	CharacterAdded(player.Character)
end

-- Handle inputs
UserInputService.InputBegan:Connect(function(input, gameProcesed)
	if not gameProcesed then
		if input.UserInputState == Enum.UserInputState.Begin then
			local tool = toolBinds[input.KeyCode]
			if tool and humanoid and humanoid.Health > 0 and master.Visible then

				if tool == equippedTool then
					humanoid:UnequipTools()

					
				else
					humanoid:EquipTool(tool)

				end
			end
		end
	end
end)

master:GetPropertyChangedSignal("Visible"):Connect(function()
	if not master.Visible and humanoid then
		humanoid:UnequipTools()
	end
end)
