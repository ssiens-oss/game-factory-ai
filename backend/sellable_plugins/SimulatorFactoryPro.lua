print("SIMULATOR FACTORY PRO LOADED")

local toolbar = plugin:CreateToolbar("Simulator Factory Pro")
local panelBtn = toolbar:CreateButton("Control Panel", "Open Simulator Factory Pro", "")
local quickBtn = toolbar:CreateButton("Quick Build", "Build simulator with defaults", "")
local clearBtn = toolbar:CreateButton("Clear", "Clear generated simulator", "")

local PREFIX = "SIMPRO_"

local S = {
	Workspace = game:GetService("Workspace"),
	ServerScriptService = game:GetService("ServerScriptService"),
	ReplicatedStorage = game:GetService("ReplicatedStorage"),
	StarterGui = game:GetService("StarterGui"),
	Lighting = game:GetService("Lighting"),
}

local Theme = {
	Primary = Color3.fromRGB(0, 210, 255),
	Secondary = Color3.fromRGB(255, 80, 210),
	Accent = Color3.fromRGB(255, 220, 0),
	Green = Color3.fromRGB(0, 255, 130),
	Red = Color3.fromRGB(255, 55, 45),
	Dark = Color3.fromRGB(8, 8, 20),
	Panel = Color3.fromRGB(10, 10, 28),
}

local Config = {
	ThemeName = "Cyber",
	Zones = 5,
	Eggs = 4,
	ResourceNodes = 50,
	Rebirths = true,
	DataStore = true,
	Monetization = true,
	IsPro = true,
}

local Presets = {
	Starter = {ThemeName="Candy", Zones=3, Eggs=2, ResourceNodes=25, Rebirths=true, Monetization=false},
	Viral = {ThemeName="Cyber", Zones=5, Eggs=4, ResourceNodes=50, Rebirths=true, Monetization=true},
	Grind = {ThemeName="Toxic", Zones=7, Eggs=5, ResourceNodes=80, Rebirths=true, Monetization=true},
	Premium = {ThemeName="Space", Zones=8, Eggs=6, ResourceNodes=100, Rebirths=true, Monetization=true},
}

local function applyTheme(name)
	Config.ThemeName = name or Config.ThemeName

	if Config.ThemeName == "Candy" then
		Theme.Primary = Color3.fromRGB(255, 120, 220)
		Theme.Secondary = Color3.fromRGB(120, 220, 255)
		Theme.Accent = Color3.fromRGB(255, 245, 120)
		Theme.Green = Color3.fromRGB(120, 255, 170)
	elseif Config.ThemeName == "Toxic" then
		Theme.Primary = Color3.fromRGB(80, 255, 0)
		Theme.Secondary = Color3.fromRGB(180, 255, 0)
		Theme.Accent = Color3.fromRGB(255, 255, 80)
		Theme.Green = Color3.fromRGB(0, 255, 90)
	elseif Config.ThemeName == "Space" then
		Theme.Primary = Color3.fromRGB(100, 120, 255)
		Theme.Secondary = Color3.fromRGB(180, 80, 255)
		Theme.Accent = Color3.fromRGB(255, 230, 120)
		Theme.Green = Color3.fromRGB(0, 255, 220)
	else
		Theme.Primary = Color3.fromRGB(0, 210, 255)
		Theme.Secondary = Color3.fromRGB(255, 80, 210)
		Theme.Accent = Color3.fromRGB(255, 220, 0)
		Theme.Green = Color3.fromRGB(0, 255, 130)
	end
end

local function clearService(service)
	for _, obj in ipairs(service:GetChildren()) do
		if obj.Name:match("^" .. PREFIX) then obj:Destroy() end
	end
end

local function clear()
	clearService(S.Workspace)
	clearService(S.ServerScriptService)
	clearService(S.ReplicatedStorage)
	clearService(S.StarterGui)

	for _, obj in ipairs(S.Lighting:GetChildren()) do
		if obj.Name:match("^" .. PREFIX) then obj:Destroy() end
	end
end

local function part(name, pos, size, color, material)
	local p = Instance.new("Part")
	p.Name = PREFIX .. name
	p.Anchored = true
	p.Position = pos
	p.Size = size
	p.Color = color or Theme.Primary
	p.Material = material or Enum.Material.Neon
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = S.Workspace
	return p
end

local function scriptIn(parent, name, source, isLocal)
	local s = Instance.new(isLocal and "LocalScript" or "Script")
	s.Name = PREFIX .. name
	s.Source = source
	s.Parent = parent
	return s
end

local function glow(obj, range, brightness)
	local l = Instance.new("PointLight")
	l.Name = PREFIX .. "Glow"
	l.Color = obj.Color
	l.Range = range or 16
	l.Brightness = brightness or 1.4
	l.Parent = obj
end

local function label(obj, text)
	local gui = Instance.new("BillboardGui")
	gui.Name = PREFIX .. "Label"
	gui.Size = UDim2.fromOffset(260, 58)
	gui.StudsOffset = Vector3.new(0, 5, 0)
	gui.AlwaysOnTop = true
	gui.Parent = obj

	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.Text = text
	t.Font = Enum.Font.GothamBlack
	t.TextScaled = true
	t.TextColor3 = Color3.new(1,1,1)
	t.TextStrokeTransparency = 0
	t.Parent = gui
end

local function setupLighting()
	S.Lighting.ClockTime = 18
	S.Lighting.Brightness = 3.4
	S.Lighting.FogEnd = 1200
	S.Lighting.FogColor = Color3.fromRGB(10, 10, 32)
	S.Lighting.Ambient = Color3.fromRGB(65, 45, 130)

	local bloom = Instance.new("BloomEffect")
	bloom.Name = PREFIX .. "Bloom"
	bloom.Intensity = 1.35
	bloom.Size = 38
	bloom.Threshold = 0.75
	bloom.Parent = S.Lighting

	local cc = Instance.new("ColorCorrectionEffect")
	cc.Name = PREFIX .. "ColorCorrection"
	cc.Contrast = 0.18
	cc.Saturation = 0.35
	cc.Parent = S.Lighting
end

local function setupRuntime()
	local remotes = Instance.new("Folder")
	remotes.Name = PREFIX .. "Remotes"
	remotes.Parent = S.ReplicatedStorage

	for _, name in ipairs({"Collect", "Sell", "BuyEgg", "Rebirth", "BuyUpgrade", "ClaimDaily"}) do
		local r = Instance.new("RemoteEvent")
		r.Name = name
		r.Parent = remotes
	end

	scriptIn(S.ServerScriptService, "Runtime", [[
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DataStoreService = game:GetService("DataStoreService")

local Remotes = ReplicatedStorage:WaitForChild("SIMPRO_Remotes")
local Store = DataStoreService:GetDataStore("SimulatorFactoryPro_v1")

local PETS = {
	{ name="Dog", mult=1.10 },
	{ name="Cat", mult=1.15 },
	{ name="Fox", mult=1.35 },
	{ name="Dragon", mult=2.00 },
	{ name="Galaxy Beast", mult=3.00 },
}

local function stat(parent, className, name, value)
	local v = Instance.new(className)
	v.Name = name
	v.Value = value
	v.Parent = parent
	return v
end

local function getMult(player)
	local s = player:FindFirstChild("leaderstats")
	if not s then return 1 end
	return s.Multiplier.Value
end

local function reward(player, power, coins, gems)
	local s = player:FindFirstChild("leaderstats")
	if not s then return end

	local mult = getMult(player)
	s.Power.Value += math.floor((power or 0) * mult)
	s.Coins.Value += math.floor((coins or 0) * mult)
	s.Gems.Value += gems or 0
	s.XP.Value += math.floor((power or 0) / 2)

	while s.XP.Value >= s.Level.Value * 100 do
		s.XP.Value -= s.Level.Value * 100
		s.Level.Value += 1
		s.Gems.Value += 1
	end
end

local function save(player)
	local s = player:FindFirstChild("leaderstats")
	if not s then return end

	local data = {
		Coins=s.Coins.Value,
		Gems=s.Gems.Value,
		Power=s.Power.Value,
		Level=s.Level.Value,
		XP=s.XP.Value,
		Rebirths=s.Rebirths.Value,
		Pets=s.Pets.Value,
		Multiplier=s.Multiplier.Value,
		BestPet=player:GetAttribute("SIMPRO_BestPet") or "None",
	}

	pcall(function()
		Store:SetAsync("u_" .. player.UserId, data)
	end)
end

local function load(player)
	local data
	pcall(function()
		data = Store:GetAsync("u_" .. player.UserId)
	end)
	if not data then return end

	local s = player:FindFirstChild("leaderstats")
	if not s then return end

	s.Coins.Value = data.Coins or 0
	s.Gems.Value = data.Gems or 0
	s.Power.Value = data.Power or 0
	s.Level.Value = data.Level or 1
	s.XP.Value = data.XP or 0
	s.Rebirths.Value = data.Rebirths or 0
	s.Pets.Value = data.Pets or 0
	s.Multiplier.Value = data.Multiplier or 1
	player:SetAttribute("SIMPRO_BestPet", data.BestPet or "None")
end

Players.PlayerAdded:Connect(function(player)
	local s = Instance.new("Folder")
	s.Name = "leaderstats"
	s.Parent = player

	stat(s, "IntValue", "Coins", 0)
	stat(s, "IntValue", "Gems", 0)
	stat(s, "IntValue", "Power", 0)
	stat(s, "IntValue", "Level", 1)
	stat(s, "IntValue", "XP", 0)
	stat(s, "IntValue", "Rebirths", 0)
	stat(s, "IntValue", "Pets", 0)
	stat(s, "NumberValue", "Multiplier", 1)

	player:SetAttribute("SIMPRO_BestPet", "None")

	task.delay(1, function()
		load(player)
	end)
end)

Players.PlayerRemoving:Connect(save)

game:BindToClose(function()
	for _, p in ipairs(Players:GetPlayers()) do
		save(p)
	end
end)

Remotes.Collect.OnServerEvent:Connect(function(player, amount)
	reward(player, amount or 5, 0, 0)
end)

Remotes.Sell.OnServerEvent:Connect(function(player)
	local s = player:FindFirstChild("leaderstats")
	if not s then return end
	local payout = math.floor(s.Power.Value * s.Multiplier.Value)
	s.Power.Value = 0
	s.Coins.Value += payout
end)

Remotes.BuyEgg.OnServerEvent:Connect(function(player, cost)
	local s = player:FindFirstChild("leaderstats")
	if not s then return end
	cost = cost or 100
	if s.Coins.Value < cost then return end

	s.Coins.Value -= cost
	local pet = PETS[math.random(1, #PETS)]
	s.Pets.Value += 1
	if pet.mult > s.Multiplier.Value then
		s.Multiplier.Value = pet.mult
		player:SetAttribute("SIMPRO_BestPet", pet.name)
	end
end)

Remotes.Rebirth.OnServerEvent:Connect(function(player)
	local s = player:FindFirstChild("leaderstats")
	if not s then return end
	local required = 1000 * (s.Rebirths.Value + 1)
	if s.Coins.Value < required then return end

	s.Coins.Value = 0
	s.Power.Value = 0
	s.Rebirths.Value += 1
	s.Gems.Value += 25
	s.Multiplier.Value += 0.25
end)

Remotes.ClaimDaily.OnServerEvent:Connect(function(player)
	reward(player, 100, 250, 10)
end)

_G.SIMPRO_Reward = reward
]], false)
end

local function setupUI()
	local gui = Instance.new("ScreenGui")
	gui.Name = PREFIX .. "UI"
	gui.ResetOnSpawn = false
	gui.Parent = S.StarterGui

	local hud = Instance.new("Frame")
	hud.Name = "HUD"
	hud.Size = UDim2.fromOffset(270, 112)
	hud.Position = UDim2.fromOffset(12, 12)
	hud.BackgroundColor3 = Theme.Panel
	hud.BackgroundTransparency = 0.12
	hud.BorderSizePixel = 0
	hud.Parent = gui
	Instance.new("UICorner", hud).CornerRadius = UDim.new(0,12)

	local text = Instance.new("TextLabel")
	text.Name = "Stats"
	text.Size = UDim2.new(1,-16,1,-12)
	text.Position = UDim2.fromOffset(8,6)
	text.BackgroundTransparency = 1
	text.TextColor3 = Color3.new(1,1,1)
	text.Font = Enum.Font.GothamBold
	text.TextSize = 15
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.TextYAlignment = Enum.TextYAlignment.Top
	text.Parent = hud

	local daily = Instance.new("TextButton")
	daily.Name = "Daily"
	daily.Size = UDim2.fromOffset(168, 32)
	daily.Position = UDim2.new(0.5, -84, 0, 14)
	daily.BackgroundColor3 = Theme.Accent
	daily.BorderSizePixel = 0
	daily.Text = "CLAIM DAILY"
	daily.Font = Enum.Font.GothamBold
	daily.TextSize = 15
	daily.TextColor3 = Color3.new(1,1,1)
	daily.Parent = gui
	Instance.new("UICorner", daily).CornerRadius = UDim.new(0,10)

	local actions = Instance.new("Frame")
	actions.Name = "Actions"
	actions.Size = UDim2.fromOffset(220, 150)
	actions.Position = UDim2.new(1, -238, 0, 14)
	actions.BackgroundColor3 = Theme.Panel
	actions.BackgroundTransparency = 0.12
	actions.BorderSizePixel = 0
	actions.Parent = gui
	Instance.new("UICorner", actions).CornerRadius = UDim.new(0,12)

	local function actionButton(name, textValue, y)
		local b = Instance.new("TextButton")
		b.Name = name
		b.Size = UDim2.new(1,-20,0,30)
		b.Position = UDim2.fromOffset(10,y)
		b.BackgroundColor3 = Theme.Primary
		b.BorderSizePixel = 0
		b.Text = textValue
		b.Font = Enum.Font.GothamBold
		b.TextSize = 14
		b.TextColor3 = Color3.new(1,1,1)
		b.Parent = actions
		Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
	end

	actionButton("Sell", "SELL POWER", 12)
	actionButton("Egg", "BUY EGG", 48)
	actionButton("Rebirth", "REBIRTH", 84)

	scriptIn(gui, "UIClient", [[
local player = game.Players.LocalPlayer
local remotes = game.ReplicatedStorage:WaitForChild("SIMPRO_Remotes")
local statsText = script.Parent.HUD.Stats

script.Parent.Daily.MouseButton1Click:Connect(function()
	remotes.ClaimDaily:FireServer()
	script.Parent.Daily.Text = "CLAIMED"
end)

script.Parent.Actions.Sell.MouseButton1Click:Connect(function()
	remotes.Sell:FireServer()
end)

script.Parent.Actions.Egg.MouseButton1Click:Connect(function()
	remotes.BuyEgg:FireServer(100)
end)

script.Parent.Actions.Rebirth.MouseButton1Click:Connect(function()
	remotes.Rebirth:FireServer()
end)

while true do
	local s = player:FindFirstChild("leaderstats")
	if s then
		statsText.Text =
			"⚡ Simulator Factory Pro" ..
			"\n💪 Power: " .. s.Power.Value .. "  💰 " .. s.Coins.Value ..
			"\n💎 " .. s.Gems.Value .. "  ⭐ " .. s.Level.Value .. "  🔁 " .. s.Rebirths.Value ..
			"\n🐾 " .. s.Pets.Value .. "  x" .. s.Multiplier.Value
	end
	task.wait(0.25)
end
]], true)
end

local function exportReport()
	local lines = {
		"SIMULATOR FACTORY PRO - BUILD REPORT",
		"",
		"Theme: " .. tostring(Config.ThemeName),
		"Zones: " .. tostring(Config.Zones),
		"Eggs: " .. tostring(Config.Eggs),
		"Resource Nodes: " .. tostring(Config.ResourceNodes),
		"Rebirths: " .. tostring(Config.Rebirths),
		"Monetization Hooks: " .. tostring(Config.Monetization),
		"",
		"Generated Systems:",
		"- Power collection",
		"- Sell zone",
		"- Coins / gems",
		"- Eggs",
		"- Pets",
		"- Best pet multiplier",
		"- Rebirth loop",
		"- DataStore scaffold",
		"- Daily rewards",
		"- Zone unlock layout",
		"",
		"Creator Checklist:",
		"1. Test power collection.",
		"2. Tune egg prices.",
		"3. Configure gamepasses/dev products.",
		"4. Add icons/thumbnails.",
		"5. Test DataStore after publishing.",
		"6. Balance rebirth requirements.",
		"",
		"Suggested Products:",
		"- 2x Power",
		"- 2x Coins",
		"- Auto Sell",
		"- Lucky Eggs",
		"- VIP Zone",
	}

	local old = S.ReplicatedStorage:FindFirstChild(PREFIX .. "BuildReport")
	if old then old:Destroy() end

	local v = Instance.new("StringValue")
	v.Name = PREFIX .. "BuildReport"
	v.Value = table.concat(lines, "\n")
	v.Parent = S.ReplicatedStorage

	warn("Simulator Factory Pro report exported to ReplicatedStorage > " .. v.Name)
end

local function resourceNode(pos, i, zone)
	local node = part("ResourceNode_" .. i, pos, Vector3.new(8,8,8), Color3.fromHSV((i % 30) / 30, 1, 1))
	node.Shape = Enum.PartType.Ball
	glow(node, 12, 1.5)
	label(node, "+" .. tostring(zone * 5) .. " POWER")

	scriptIn(node, "Collect", [[
local busy = {}
local amount = ]] .. tostring(zone * 5) .. [[

script.Parent.Touched:Connect(function(hit)
	local player = game.Players:GetPlayerFromCharacter(hit.Parent)
	if not player or busy[player] then return end
	busy[player] = true

	local remotes = game.ReplicatedStorage:WaitForChild("SIMPRO_Remotes")
	remotes.Collect:FireServer(amount)

	task.wait(0.35)
	busy[player] = nil
end)
]], true)
end

local function sellZone(pos)
	local z = part("SellZone", pos, Vector3.new(34,1,34), Theme.Green)
	glow(z, 24, 2)
	label(z, "SELL POWER")

	scriptIn(z, "Sell", [[
local busy = {}
script.Parent.Touched:Connect(function(hit)
	local player = game.Players:GetPlayerFromCharacter(hit.Parent)
	if not player or busy[player] then return end
	busy[player] = true
	game.ReplicatedStorage.SIMPRO_Remotes.Sell:FireServer()
	task.wait(1)
	busy[player] = nil
end)
]], true)
end

local function eggStand(pos, i, cost)
	local base = part("EggStand_" .. i, pos, Vector3.new(18,2,18), Theme.Secondary)
	glow(base, 16, 1.8)
	label(base, "EGG " .. cost)

	local egg = part("Egg_" .. i, pos + Vector3.new(0,7,0), Vector3.new(8,10,8), Color3.fromHSV(i / math.max(Config.Eggs, 1), 1, 1))
	egg.Shape = Enum.PartType.Ball
	glow(egg, 15, 2)

	scriptIn(base, "BuyEgg", [[
local busy = {}
local cost = ]] .. tostring(cost) .. [[

script.Parent.Touched:Connect(function(hit)
	local player = game.Players:GetPlayerFromCharacter(hit.Parent)
	if not player or busy[player] then return end
	busy[player] = true
	game.ReplicatedStorage.SIMPRO_Remotes.BuyEgg:FireServer(cost)
	task.wait(1)
	busy[player] = nil
end)
]], true)
end

local function zone(index)
	local radius = 70 + index * 35
	local angle = math.rad(index * 55)
	local center = Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)

	local floor = part("Zone_" .. index, center + Vector3.new(0, -1, 0), Vector3.new(80,1,80), Color3.fromHSV(index / math.max(Config.Zones, 1), 0.8, 1), Enum.Material.Metal)
	label(floor, "ZONE " .. index)
	glow(floor, 24, 1.2)

	local count = math.floor(Config.ResourceNodes / Config.Zones)
	for i = 1, count do
		local x = math.random(-30, 30)
		local z = math.random(-30, 30)
		resourceNode(center + Vector3.new(x, 5, z), (index * 100) + i, index)
	end

	if index <= Config.Eggs then
		eggStand(center + Vector3.new(0, 2, -34), index, 100 * index)
	end
end

local function baseWorld()
	part("Baseplate", Vector3.new(0,-2,0), Vector3.new(700,1,700), Theme.Dark, Enum.Material.Metal)

	local spawn = part("Spawn", Vector3.new(0,2,0), Vector3.new(30,1,30), Theme.Green)
	label(spawn, "SPAWN")
	glow(spawn, 20, 2)

	sellZone(Vector3.new(40,2,0))

	local rebirth = part("RebirthZone", Vector3.new(-40,2,0), Vector3.new(30,1,30), Theme.Accent)
	label(rebirth, "REBIRTH")
	glow(rebirth, 20, 2)

	scriptIn(rebirth, "Rebirth", [[
local busy = {}
script.Parent.Touched:Connect(function(hit)
	local player = game.Players:GetPlayerFromCharacter(hit.Parent)
	if not player or busy[player] then return end
	busy[player] = true
	game.ReplicatedStorage.SIMPRO_Remotes.Rebirth:FireServer()
	task.wait(1.5)
	busy[player] = nil
end)
]], true)
end

local function build()
	clear()
	applyTheme(Config.ThemeName)
	setupLighting()
	setupRuntime()
	setupUI()
	baseWorld()

	for i = 1, Config.Zones do
		zone(i)
	end

	exportReport()
	warn("Simulator Factory Pro generated simulator.")
end

local panelWidget

local function applyPreset(name)
	local p = Presets[name]
	if not p then return end
	Config.ThemeName = p.ThemeName
	Config.Zones = p.Zones
	Config.Eggs = p.Eggs
	Config.ResourceNodes = p.ResourceNodes
	Config.Rebirths = p.Rebirths
	Config.Monetization = p.Monetization
	applyTheme(Config.ThemeName)
end

local function cycleTheme()
	local themes = {"Cyber", "Candy", "Toxic", "Space"}
	local idx = 1
	for i,v in ipairs(themes) do
		if v == Config.ThemeName then idx = i break end
	end
	idx += 1
	if idx > #themes then idx = 1 end
	Config.ThemeName = themes[idx]
	applyTheme(Config.ThemeName)
end

local function makePanel()
	local info = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, true, false, 360, 540, 320, 460)
	local widget = plugin:CreateDockWidgetPluginGui("SimulatorFactoryProPanel", info)
	widget.Title = "Simulator Factory Pro"

	local root = Instance.new("Frame")
	root.Size = UDim2.fromScale(1,1)
	root.BackgroundColor3 = Theme.Panel
	root.BorderSizePixel = 0
	root.Parent = widget

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1,-20,0,38)
	title.Position = UDim2.fromOffset(10,8)
	title.BackgroundTransparency = 1
	title.Text = "Simulator Factory Pro"
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 20
	title.TextColor3 = Color3.new(1,1,1)
	title.Parent = root

	local subtitle = Instance.new("TextLabel")
	subtitle.Size = UDim2.new(1,-20,0,26)
	subtitle.Position = UDim2.fromOffset(10,44)
	subtitle.BackgroundTransparency = 1
	subtitle.Text = "Pets, eggs, zones, rebirths, multipliers."
	subtitle.Font = Enum.Font.Gotham
	subtitle.TextSize = 13
	subtitle.TextColor3 = Color3.fromRGB(210,220,235)
	subtitle.Parent = root

	local function button(y, labelText, valueText, cb)
		local lab = Instance.new("TextLabel")
		lab.Size = UDim2.new(1,-20,0,18)
		lab.Position = UDim2.fromOffset(10,y)
		lab.BackgroundTransparency = 1
		lab.Text = labelText
		lab.Font = Enum.Font.GothamBold
		lab.TextSize = 12
		lab.TextColor3 = Color3.fromRGB(210,220,240)
		lab.TextXAlignment = Enum.TextXAlignment.Left
		lab.Parent = root

		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1,-20,0,32)
		b.Position = UDim2.fromOffset(10,y+20)
		b.BackgroundColor3 = Theme.Primary
		b.BorderSizePixel = 0
		b.Text = valueText()
		b.Font = Enum.Font.GothamBold
		b.TextSize = 14
		b.TextColor3 = Color3.new(1,1,1)
		b.Parent = root
		Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)

		b.MouseButton1Click:Connect(function()
			cb()
			b.Text = valueText()
		end)
	end

	button(82, "Theme", function() return Config.ThemeName end, cycleTheme)

	button(140, "Zones", function() return tostring(Config.Zones) end, function()
		Config.Zones += 1
		if Config.Zones > 8 then Config.Zones = 3 end
	end)

	button(198, "Eggs", function() return tostring(Config.Eggs) end, function()
		Config.Eggs += 1
		if Config.Eggs > 6 then Config.Eggs = 2 end
	end)

	button(256, "Resource Nodes", function() return tostring(Config.ResourceNodes) end, function()
		Config.ResourceNodes += 25
		if Config.ResourceNodes > 100 then Config.ResourceNodes = 25 end
	end)

	local presets = {"Starter", "Viral", "Grind", "Premium"}
	for i,name in ipairs(presets) do
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(0.5,-15,0,30)
		b.Position = UDim2.fromOffset(i % 2 == 1 and 10 or 185, 328 + math.floor((i-1)/2) * 36)
		b.BackgroundColor3 = Theme.Secondary
		b.BorderSizePixel = 0
		b.Text = name
		b.Font = Enum.Font.GothamBold
		b.TextSize = 13
		b.TextColor3 = Color3.new(1,1,1)
		b.Parent = root
		Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)
		b.MouseButton1Click:Connect(function() applyPreset(name) end)
	end

	local export = Instance.new("TextButton")
	export.Size = UDim2.new(1,-20,0,34)
	export.Position = UDim2.fromOffset(10,410)
	export.BackgroundColor3 = Theme.Accent
	export.BorderSizePixel = 0
	export.Text = "EXPORT REPORT"
	export.Font = Enum.Font.GothamBlack
	export.TextSize = 14
	export.TextColor3 = Color3.new(1,1,1)
	export.Parent = root
	Instance.new("UICorner", export).CornerRadius = UDim.new(0,10)
	export.MouseButton1Click:Connect(exportReport)

	local gen = Instance.new("TextButton")
	gen.Size = UDim2.new(0.5,-15,0,40)
	gen.Position = UDim2.new(0,10,1,-50)
	gen.BackgroundColor3 = Theme.Green
	gen.BorderSizePixel = 0
	gen.Text = "GENERATE"
	gen.Font = Enum.Font.GothamBlack
	gen.TextSize = 15
	gen.TextColor3 = Color3.new(1,1,1)
	gen.Parent = root
	Instance.new("UICorner", gen).CornerRadius = UDim.new(0,10)
	gen.MouseButton1Click:Connect(build)

	local clr = Instance.new("TextButton")
	clr.Size = UDim2.new(0.5,-15,0,40)
	clr.Position = UDim2.new(0.5,5,1,-50)
	clr.BackgroundColor3 = Theme.Red
	clr.BorderSizePixel = 0
	clr.Text = "CLEAR"
	clr.Font = Enum.Font.GothamBlack
	clr.TextSize = 15
	clr.TextColor3 = Color3.new(1,1,1)
	clr.Parent = root
	Instance.new("UICorner", clr).CornerRadius = UDim.new(0,10)
	clr.MouseButton1Click:Connect(clear)

	return widget
end

local function togglePanel()
	if not panelWidget then
		panelWidget = makePanel()
	else
		panelWidget.Enabled = not panelWidget.Enabled
	end
end

panelBtn.Click:Connect(togglePanel)
quickBtn.Click:Connect(build)
clearBtn.Click:Connect(clear)
