local DataStoreService = game:GetService("DataStoreService");
local ReplicatedStorage = game:GetService("ReplicatedStorage");
local Players = game:GetService("Players");

local updateSettingEvent = ReplicatedStorage:WaitForChild("RemoteEvents"):WaitForChild("SettingsToggle"); 

local DataStore = DataStoreService:GetDataStore("Settings"); 


function updateSetting(plr, settingName, settingValue)
	local plrSetting = plr.Settings;
	plrSetting[settingName].Value = settingValue; 
end
updateSettingEvent.OnServerEvent:Connect(updateSetting);

--Save/Load Functions--
function saveSettings(plr)
	local settingsFolder = plr.Settings;
	local settings = {}; 

	for _, setting in next, settingsFolder:GetChildren() do 
		settings[setting.Name] = setting.Value;
	end

	return settings;
end

function loadSettings(plr, settings)
	local settingsFolder = plr.Settings;
	for _, setting in next, settingsFolder:GetChildren() do
		setting.Value = settings[setting.Name];
	end
end

--Join/Leave Functions--
function onJoin(plr)
	local plrSettings = script.Settings:Clone(); 
	plrSettings.Parent = plr; 

	local data;
	local success, errorMessage = pcall(function()
		data = DataStore:GetAsync(plr.UserId); 
	end)

	if success and data then
		local settings = data.settings; 
		loadSettings(plr, settings);
	else
		warn(errorMessage); 
	end
end
Players.PlayerAdded:Connect(onJoin);

function onLeave(plr)
	local data = {};
	data.settings = saveSettings(plr);

	local success, message = pcall(function()
		DataStore:SetAsync(plr.UserId, data);
	end)

	if success then
		print(plr.Name .. "'s data was saved successfully!");
	else
		warn(message); 
	end
end
Players.PlayerRemoving:Connect(onLeave);







