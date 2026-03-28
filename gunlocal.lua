local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local Settings = require(script:WaitForChild("settings"))
local clientServices = ReplicatedStorage:WaitForChild("ClientServices")
local action = require(clientServices:WaitForChild("actions"))

local beamEvent = ReplicatedStorage:FindFirstChild("beamEvent")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local Animator = hum:WaitForChild("Animator")
local mouse = player:GetMouse()
local mainSettings = player:WaitForChild("Settings")
local AmmoCursor = mainSettings:WaitForChild("AmmoCursor")

local tool = script.Parent
local barrel = tool:WaitForChild("Barrel")

local hasSpread = Settings.hasSpread
local MaxDistance = Settings.maxDistance
local MinDistance = Settings.minDistance
local Spread = Settings.Spread
local maxReconCharge = Settings.MaxReconCharge

local SoundsFolder = tool:WaitForChild("Sounds")
local ShootSound = SoundsFolder:WaitForChild("Shoot")
local ReloadSound = SoundsFolder:WaitForChild("Reload")
local ConsistentReload = SoundsFolder:WaitForChild("ConsistentReload")
local DamageSound = SoundsFolder:WaitForChild("Damage")
local KillSound = SoundsFolder:WaitForChild("Kill")
local EquipSound = SoundsFolder:WaitForChild("GunEquip")

local AnimsFolder = tool:WaitForChild("Animations")
local IdlePre = AnimsFolder:WaitForChild("Idle")
local ShootingPre = AnimsFolder:WaitForChild("Shoot")
local SprintingPre = AnimsFolder:WaitForChild("Sprint")
local IdleAnim = Animator:LoadAnimation(IdlePre)
local ShootingAnim = Animator:LoadAnimation(ShootingPre)
local SprintingAnim = Animator:LoadAnimation(SprintingPre)
SprintingAnim.Priority = Enum.AnimationPriority.Action3

local PlayerGui = player.PlayerGui
local template = script:FindFirstChild("Template") or script:WaitForChild("Template")
local WeaponBarHolder = template:WaitForChild("Ammo")
local BarBG = WeaponBarHolder:WaitForChild("Bar")
local ammo = template:WaitForChild("AmmoTxT")
template:WaitForChild("ImageLabel").Image = Settings.ToolIcon

local parentFrame = PlayerGui:WaitForChild("Main"):WaitForChild("WeaponBar")
local CursorUi = PlayerGui:WaitForChild("CursorUI")
local CursorFrame = CursorUi:WaitForChild("CursorFrame")
local AmmoBarHolder = CursorFrame:WaitForChild("AmmoBar")
local AmmoBar = AmmoBarHolder:WaitForChild("Bar")
local StickyIndicatorUI = CursorFrame:WaitForChild("StickyIndicator")

local NameLabel = template:WaitForChild("Name")

local equipped = false
local reloading = false
local shooting = false
local ShootingDebounce = false
local ReconCharge = Settings.ReconCharge

action.getGui(template, parentFrame, tool.Name)


NameLabel.Text = tool.Name
local function chargeTween(recon, maxRecon)
    local percent = math.clamp(recon / maxRecon, 0, 1)
    local tweenInfo = TweenInfo.new(0.5, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
    TweenService:Create(BarBG, tweenInfo, {Size = UDim2.new(percent, 0, 1, 0)}):Play()
    ammo.Text = string.format("%d%%", math.floor(percent * 100))
end

local function updateAmmoBar()
    local percent = math.clamp(Settings.bullets / Settings.clipSize, 0, 1)
    local tweenInfo = TweenInfo.new(0.05, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
    TweenService:Create(BarBG, tweenInfo, {Size = UDim2.new(percent, 0, 1, 0)}):Play()
    ammo.Text = string.format("%d%%", math.floor(percent * 100))
    if AmmoCursor.Value then
        TweenService:Create(AmmoBar, tweenInfo, {Size = UDim2.new(percent, 0, 1, 0)}):Play()
    end
end

local function chargeGun()
    while char:GetAttribute("Zooming") and equipped and ReconCharge < maxReconCharge do
        ReconCharge = math.min(ReconCharge + 0.1, maxReconCharge)
        chargeTween(ReconCharge, maxReconCharge)
        task.wait(Settings.ChargeDelay)
    end
end

local function Reload()
    reloading = true
    ReloadSound:Play()
    task.wait(Settings.reloadDelay)
    for i = Settings.bullets + 1, Settings.clipSize do
        Settings.bullets = i
        ConsistentReload:Play()
        updateAmmoBar()
        task.wait(Settings.reloadRate)
    end
    reloading = false
end

tool.Equipped:Connect(function()
	equipped = true
    updateAmmoBar()
    IdleAnim:Play()
    EquipSound:Play()
	TweenService:Create(template, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0,false,0), {Size = UDim2.new(1, 0,0.675, 0)}):Play()
	AmmoBarHolder.Visible = AmmoCursor.Value
	NameLabel.Text = tool.Name
    if player:GetAttribute("Sprinting") then
        SprintingAnim:Play()
    end
    template:WaitForChild("Class").Text = tostring(player:GetAttribute("Class"))
end)

tool.Unequipped:Connect(function()
    equipped = false
    IdleAnim:Stop()
	updateAmmoBar()

	SprintingAnim:Stop()
	TweenService:Create(template, TweenInfo.new(.3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut, 0,false,0), {Size = UDim2.new(.85, 0,0.675, 0)}):Play()

	NameLabel.Text = tool.Name
    AmmoBarHolder.Visible = false
    ReconCharge = 0
end)

tool.Activated:Connect(function()
    shooting = true
    if reloading or Settings.bullets <= 0 then return end
    if Settings.gunMode == 1 then
        while shooting and hum.Health > 0 and not ShootingDebounce and not reloading and Settings.bullets > 0 do
            ShootingDebounce = true
            player:SetAttribute("Sprinting", false)
            ShootSound:Play()
            ShootingAnim:Play()
            Settings.bullets -= 1
            action.shoot(mouse, barrel, char, hasSpread, MaxDistance, MinDistance, Spread, Settings.bodyDamage, Settings.isRecon, Settings.ShellCount, Settings.headshotDamage)
            if Settings.bullets == 0 then
                shooting = false
                Reload()
            end
            updateAmmoBar()
            task.wait(Settings.firerate)
            ShootingDebounce = false
        end
    elseif Settings.gunMode == 2 then
        if Settings.isRecon then
            if not ShootingDebounce and Settings.bullets > 0 then
                ShootingDebounce = true
                player:SetAttribute("Sprinting", false)
                if ReconCharge >= maxReconCharge then
                    ShootSound:Play()
                    ShootingAnim:Play()
                    Settings.bullets -= 1
                    action.shoot(mouse, barrel, char, hasSpread, MaxDistance, MinDistance, Spread, Settings.bodyDamage*Settings.ChargeMultiplier, true, Settings.ShellCount, Settings.headshotDamage*Settings.ChargeMultiplier)
                else
                    ShootSound:Play()
                    ShootingAnim:Play()
                    Settings.bullets -= 1
                    action.shoot(mouse, barrel, char, hasSpread, MaxDistance, MinDistance, Spread, Settings.bodyDamage, true, Settings.ShellCount, Settings.headshotDamage)
                end
                if Settings.bullets == 0 then
                    shooting = false
                    Reload()
                end
                updateAmmoBar()
                ReconCharge = 0
                chargeTween(ReconCharge, maxReconCharge)
                char:SetAttribute("Zooming", false)
                task.wait(Settings.firerate)
                ShootingDebounce = false
            end
        else
            if not ShootingDebounce and Settings.bullets > 0 then
                ShootingDebounce = true
                player:SetAttribute("Sprinting", false)
                ShootSound:Play()
                ShootingAnim:Play()
                Settings.bullets -= 1
                action.shoot(mouse, barrel, char, hasSpread, MaxDistance, MinDistance, Spread, Settings.bodyDamage, false, Settings.ShellCount, Settings.headshotDamage)
                if Settings.bullets == 0 then
                    shooting = false
                    Reload()
                end
                updateAmmoBar()
                task.wait(Settings.firerate)
                ShootingDebounce = false
            end
        end
    elseif Settings.gunMode == 3 then
        if not ShootingDebounce and Settings.bullets > 0 then
            ShootingDebounce = true
            player:SetAttribute("Sprinting", false)
            ShootSound:Play()
            Settings.bullets -= 1
            action.shoot(mouse, barrel, char, hasSpread, MaxDistance, MinDistance, Spread, Settings.bodyDamage, Settings.isRecon, Settings.ShellCount, Settings.headshotDamage)
            ShootingAnim:Play()
            updateAmmoBar()
            task.wait(Settings.firerate)
            ShootingDebounce = false
        end
    end
end)

tool.Deactivated:Connect(function()
    shooting = false
end)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.KeyCode == Enum.KeyCode.R and not gameProcessed and equipped and not reloading and Settings.bullets < Settings.clipSize then
        Reload()
    end
end)

hum.Died:Connect(function()
    tool:Destroy()
end)

char:GetAttributeChangedSignal("Zooming"):Connect(function()
    if Settings.isRecon and equipped then
        if char:GetAttribute("Zooming") then
            if Settings.bullets > 0 then
                chargeGun()
            end
        else
            ReconCharge = 0
            chargeTween(ReconCharge, maxReconCharge)
        end
    end
end)

player:GetAttributeChangedSignal("Sprinting"):Connect(function()
    if player:GetAttribute("Sprinting") and equipped then
        SprintingAnim:Play()
    else
        SprintingAnim:Stop()
    end
end)
