
-- =====================================================
-- AI OBBY GENERATOR PRO - ULTIMATE EDITION
-- Added:
-- Monetization Hooks
-- DataStore Saving
-- Polish Pack
-- Theme Packs
-- Creator Onboarding
-- Free / Pro Gating
-- =====================================================

print("AI OBBY GENERATOR PRO LOADED")

local toolbar = plugin:CreateToolbar("AI Obby Pro")
local buildBtn = toolbar:CreateButton("Quick Build", "Generate premium obby with current defaults", "")
local panelBtn = toolbar:CreateButton("Control Panel", "Open AI Obby Pro control panel", "")
local clearBtn = toolbar:CreateButton("Clear", "Clear generated obby", "")

local PREFIX = "AIOBBY_"

local S = {
	Workspace = game:GetService("Workspace"),
	ServerScriptService = game:GetService("ServerScriptService"),
	ReplicatedStorage = game:GetService("ReplicatedStorage"),
	StarterGui = game:GetService("StarterGui"),
	Lighting = game:GetService("Lighting"),
}

local Theme = {
	Primary = Color3.fromRGB(0, 210, 255),
	Secondary = Color3.fromRGB(255, 70, 210),
	Accent = Color3.fromRGB(255, 220, 0),
	Danger = Color3.fromRGB(255, 45, 35),
	Boost = Color3.fromRGB(0, 255, 130),
	Dark = Color3.fromRGB(8, 8, 20),
	Panel = Color3.fromRGB(10, 10, 28),
}

local Config = {
	Stages = 120,
	Gap = 11,
	CheckpointEvery = 8,
	CoinEvery = 4,
	Difficulty = "Normal",
	HazardDensity = "Medium",
	ThemeName = "Neon",
	Monetization = true,
	MobileUI = true,
}

local Presets = {
	Themes = {"Neon", "Lava", "Ice", "Cyber", "Toxic"},
	Difficulties = {"Easy", "Normal", "Hard", "Insane"},
	HazardDensities = {"Low", "Medium", "High"},
	StageOptions = {40, 80, 120, 160, 200},
}

local function applyTheme(name)
	Config.ThemeName = name or Config.ThemeName

	if Config.ThemeName == "Lava" then
		Theme.Primary = Color3.fromRGB(255, 90, 0)
		Theme.Secondary = Color3.fromRGB(255, 30, 0)
		Theme.Accent = Color3.fromRGB(255, 210, 0)
		Theme.Danger = Color3.fromRGB(255, 0, 0)
		Theme.Boost = Color3.fromRGB(255, 150, 0)
	elseif Config.ThemeName == "Ice" then
		Theme.Primary = Color3.fromRGB(120, 230, 255)
		Theme.Secondary = Color3.fromRGB(180, 240, 255)
		Theme.Accent = Color3.fromRGB(230, 255, 255)
		Theme.Danger = Color3.fromRGB(0, 120, 255)
		Theme.Boost = Color3.fromRGB(180, 255, 255)
	elseif Config.ThemeName == "Cyber" then
		Theme.Primary = Color3.fromRGB(0, 255, 255)
		Theme.Secondary = Color3.fromRGB(255, 0, 255)
		Theme.Accent = Color3.fromRGB(255, 255, 0)
		Theme.Danger = Color3.fromRGB(255, 0, 90)
		Theme.Boost = Color3.fromRGB(0, 255, 120)
	elseif Config.ThemeName == "Toxic" then
		Theme.Primary = Color3.fromRGB(80, 255, 0)
		Theme.Secondary = Color3.fromRGB(180, 255, 0)
		Theme.Accent = Color3.fromRGB(255, 255, 60)
		Theme.Danger = Color3.fromRGB(120, 255, 0)
		Theme.Boost = Color3.fromRGB(0, 255, 80)
	else
		Theme.Primary = Color3.fromRGB(0, 210, 255)
		Theme.Secondary = Color3.fromRGB(255, 70, 210)
		Theme.Accent = Color3.fromRGB(255, 220, 0)
		Theme.Danger = Color3.fromRGB(255, 45, 35)
		Theme.Boost = Color3.fromRGB(0, 255, 130)
	end
end

local function hazardModulo()
	if Config.HazardDensity == "Low" then return 16 end
	if Config.HazardDensity == "High" then return 8 end
	return 12
end

local function difficultyScale()
	if Config.Difficulty == "Easy" then return 0.75 end
	if Config.Difficulty == "Hard" then return 1.35 end
	if Config.Difficulty == "Insane" then return 1.8 end
	return 1
end



-- ===============================
-- ULTIMATE PATCH MODULES
-- ===============================

local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local SaveStore = DataStoreService:GetDataStore("AIObbyPro_Ultimate_v1")

local Ultimate = {
	IsPro = true, -- set false for free mode
	Gamepasses = {
		SkipStage = 100001,
		Revive = 100002,
		DoubleCoins = 100003,
		VIPTrail = 100004,
		SpeedBoost = 100005,
	}
}

local function proMaxStages()
	return Ultimate.IsPro and 200 or 40
end

local function clampConfigForLicense()
	if Config.Stages > proMaxStages() then
		Config.Stages = proMaxStages()
	end

	if not Ultimate.IsPro then
		Config.ThemeName = "Neon"
		Config.Monetization = false
	end
end

local function safeGetAsync(key)
	local ok, result = pcall(function()
		return SaveStore:GetAsync(key)
	end)
	if ok then return result end
	return nil
end

local function safeSetAsync(key, value)
	pcall(function()
		SaveStore:SetAsync(key, value)
	end)
end

local function savePlayer(player)
	local s = player:FindFirstChild("leaderstats")
	if not s then return end

	local payload = {
		Coins = s:FindFirstChild("Coins") and s.Coins.Value or 0,
		Gems = s:FindFirstChild("Gems") and s.Gems.Value or 0,
		Wins = s:FindFirstChild("Wins") and s.Wins.Value or 0,
		Level = s:FindFirstChild("Level") and s.Level.Value or 1,
		BestTime = s:FindFirstChild("BestTime") and s.BestTime.Value or 999999,
		Purchases = {
			DoubleCoins = player:GetAttribute("AIO_DoubleCoins") == true,
			VIPTrail = player:GetAttribute("AIO_VIPTrail") == true,
		}
	}

	safeSetAsync("u_" .. player.UserId, payload)
end

local function loadPlayer(player)
	local data = safeGetAsync("u_" .. player.UserId)
	if not data then return end

	local s = player:FindFirstChild("leaderstats")
	if not s then return end

	if s:FindFirstChild("Coins") then s.Coins.Value = data.Coins or 0 end
	if s:FindFirstChild("Gems") then s.Gems.Value = data.Gems or 0 end
	if s:FindFirstChild("Wins") then s.Wins.Value = data.Wins or 0 end
	if s:FindFirstChild("Level") then s.Level.Value = data.Level or 1 end
	if s:FindFirstChild("BestTime") then s.BestTime.Value = data.BestTime or 999999 end

	if data.Purchases then
		player:SetAttribute("AIO_DoubleCoins", data.Purchases.DoubleCoins == true)
		player:SetAttribute("AIO_VIPTrail", data.Purchases.VIPTrail == true)
	end
end

Players.PlayerRemoving:Connect(savePlayer)
game:BindToClose(function()
	for _, p in ipairs(Players:GetPlayers()) do
		savePlayer(p)
	end
end)

Players.PlayerAdded:Connect(function(player)
	task.delay(2, function()
		loadPlayer(player)
	end)
end)

local function addTrail(player)
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	if root:FindFirstChild("AIO_Trail") then return end

	local a0 = Instance.new("Attachment", root)
	local a1 = Instance.new("Attachment", root)
	a0.Position = Vector3.new(0,1,0)
	a1.Position = Vector3.new(0,-1,0)

	local tr = Instance.new("Trail")
	tr.Name = "AIO_Trail"
	tr.Attachment0 = a0
	tr.Attachment1 = a1
	tr.Lifetime = 0.4
	tr.Parent = root
end

local function fireworks(pos)
	for i = 1, 6 do
		local p = Instance.new("Part")
		p.Name = PREFIX .. "Firework"
		p.Anchored = true
		p.CanCollide = false
		p.Transparency = 1
		p.Position = pos + Vector3.new(math.random(-8,8), math.random(0,8), math.random(-8,8))
		p.Parent = S.Workspace

		local emitter = Instance.new("ParticleEmitter")
		emitter.Rate = 0
		emitter.Speed = NumberRange.new(18, 28)
		emitter.Lifetime = NumberRange.new(1, 2)
		emitter.SpreadAngle = Vector2.new(360,360)
		emitter.Parent = p
		emitter:Emit(40)

		game:GetService("Debris"):AddItem(p, 3)
	end
end

local function playChime(parent)
	local s = Instance.new("Sound")
	s.Name = PREFIX .. "Chime"
	s.SoundId = "rbxassetid://6026984224"
	s.Volume = 0.5
	s.Parent = parent
	s:Play()
	game:GetService("Debris"):AddItem(s, 4)
end

local function animatedSign(obj, text)
	label(obj, text)
	local gui = obj:FindFirstChild(PREFIX .. "Label")
	if not gui then return end
	local t = gui:FindFirstChildOfClass("TextLabel")
	if not t then return end

	task.spawn(function()
		local hue = 0
		while t.Parent do
			hue += 0.01
			t.TextColor3 = Color3.fromHSV(hue % 1, 1, 1)
			task.wait()
		end
	end)
end

local function showOnboarding()
	local lines = {
		"AI OBBY PRO - QUICK START",
		"",
		"1. Choose preset or custom settings.",
		"2. Click GENERATE.",
		"3. Press Play to test.",
		"4. Create gamepasses in Creator Dashboard.",
		"5. Tune rewards after first playtest.",
		"6. Publish with icon + thumbnail.",
		"",
		"Suggested Products:",
		"- Skip Stage",
		"- Revive",
		"- 2x Coins",
		"- VIP Trail",
		"- Speed Boost",
	}

	local existing = S.ReplicatedStorage:FindFirstChild(PREFIX .. "Onboarding")
	if existing then existing:Destroy() end

	local v = Instance.new("StringValue")
	v.Name = PREFIX .. "Onboarding"
	v.Value = table.concat(lines, "\\n")
	v.Parent = S.ReplicatedStorage
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
	p.Color = color
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
	l.Brightness = brightness or 1.5
	l.Parent = obj
end

local function label(obj, text)
	local gui = Instance.new("BillboardGui")
	gui.Name = PREFIX .. "Label"
	gui.Size = UDim2.fromOffset(250, 56)
	gui.StudsOffset = Vector3.new(0, 5, 0)
	gui.AlwaysOnTop = true
	gui.Parent = obj

	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.Text = text
	t.Font = Enum.Font.GothamBlack
	t.TextScaled = true
	t.TextColor3 = Color3.new(1, 1, 1)
	t.TextStrokeTransparency = 0
	t.Parent = gui
end

local function setupLighting()
	S.Lighting.ClockTime = 20
	S.Lighting.Brightness = 3.2
	S.Lighting.FogEnd = 1000
	S.Lighting.FogColor = Color3.fromRGB(8, 8, 28)
	S.Lighting.Ambient = Color3.fromRGB(70, 40, 140)

	local bloom = Instance.new("BloomEffect")
	bloom.Name = PREFIX .. "Bloom"
	bloom.Intensity = 1.5
	bloom.Size = 42
	bloom.Threshold = 0.72
	bloom.Parent = S.Lighting

	local cc = Instance.new("ColorCorrectionEffect")
	cc.Name = PREFIX .. "ColorCorrection"
	cc.Contrast = 0.25
	cc.Saturation = 0.35
	cc.TintColor = Color3.fromRGB(220, 230, 255)
	cc.Parent = S.Lighting
end

local function setupRuntime()
	local remotes = Instance.new("Folder")
	remotes.Name = PREFIX .. "Remotes"
	remotes.Parent = S.ReplicatedStorage

	for _, name in ipairs({"ClaimDaily", "BuyUpgrade"}) do
		local r = Instance.new("RemoteEvent")
		r.Name = name
		r.Parent = remotes
	end

	scriptIn(S.ServerScriptService, "Runtime", [[
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("AIOBBY_Remotes")

local function stat(parent, className, name, value)
	local v = Instance.new(className)
	v.Name = name
	v.Value = value
	v.Parent = parent
	return v
end

local function setupPlayer(player)
	local s = Instance.new("Folder")
	s.Name = "leaderstats"
	s.Parent = player

	stat(s, "IntValue", "Coins", 0)
	stat(s, "IntValue", "Gems", 0)
	stat(s, "IntValue", "Stage", 0)
	stat(s, "IntValue", "Wins", 0)
	stat(s, "IntValue", "Deaths", 0)
	stat(s, "IntValue", "Level", 1)
	stat(s, "IntValue", "XP", 0)
	stat(s, "NumberValue", "BestTime", 999999)
	stat(s, "NumberValue", "Multiplier", 1)

	stat(player, "Vector3Value", "AIOBBY_Checkpoint", Vector3.new(0, 10, 0))
	stat(player, "NumberValue", "AIOBBY_StartTime", os.clock())
	stat(player, "BoolValue", "AIOBBY_Shield", false)
end

local function reward(player, coins, xp, gems)
	local s = player:FindFirstChild("leaderstats")
	if not s then return end

	s.Coins.Value += math.floor((coins or 0) * s.Multiplier.Value)
	s.XP.Value += xp or 0
	s.Gems.Value += gems or 0

	while s.XP.Value >= s.Level.Value * 100 do
		s.XP.Value -= s.Level.Value * 100
		s.Level.Value += 1
		s.Coins.Value += 50
		s.Gems.Value += 1
	end
end

Players.PlayerAdded:Connect(function(player)
	setupPlayer(player)

	player.CharacterAdded:Connect(function(char)
		task.wait(0.15)
		local root = char:FindFirstChild("HumanoidRootPart")
		local cp = player:FindFirstChild("AIOBBY_Checkpoint")
		if root and cp then root.CFrame = CFrame.new(cp.Value) end

		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.Died:Connect(function()
				local s = player:FindFirstChild("leaderstats")
				if s then s.Deaths.Value += 1 end
			end)
		end
	end)
end)

Remotes.ClaimDaily.OnServerEvent:Connect(function(player)
	reward(player, 250, 100, 5)
end)

Remotes.BuyUpgrade.OnServerEvent:Connect(function(player, upgrade)
	local s = player:FindFirstChild("leaderstats")
	if not s then return end

	if upgrade == "Multiplier" and s.Coins.Value >= 250 then
		s.Coins.Value -= 250
		s.Multiplier.Value += 0.25
	elseif upgrade == "Shield" and s.Coins.Value >= 100 then
		s.Coins.Value -= 100
		player.AIOBBY_Shield.Value = true
	end
end)

_G.AIOBBY_Reward = reward
]], false)
end

local function setupUI()
	showOnboarding()
	local gui = Instance.new("ScreenGui")
	gui.Name = PREFIX .. "UI"
	gui.ResetOnSpawn = false
	gui.Parent = S.StarterGui

	local hud = Instance.new("Frame")
	hud.Name = "HUD"
	hud.Size = UDim2.fromOffset(250, 96)
	hud.Position = UDim2.fromOffset(12, 12)
	hud.BackgroundColor3 = Theme.Panel
	hud.BackgroundTransparency = 0.12
	hud.BorderSizePixel = 0
	hud.Parent = gui
	Instance.new("UICorner", hud).CornerRadius = UDim.new(0, 12)

	local text = Instance.new("TextLabel")
	text.Name = "Stats"
	text.Size = UDim2.new(1, -16, 1, -12)
	text.Position = UDim2.fromOffset(8, 6)
	text.BackgroundTransparency = 1
	text.Font = Enum.Font.GothamBold
	text.TextSize = 15
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.TextYAlignment = Enum.TextYAlignment.Top
	text.TextColor3 = Color3.new(1, 1, 1)
	text.Parent = hud

	local daily = Instance.new("TextButton")
	daily.Name = "Daily"
	daily.Size = UDim2.fromOffset(168, 32)
	daily.Position = UDim2.new(0.5, -84, 0, 14)
	daily.BackgroundColor3 = Theme.Accent
	daily.BorderSizePixel = 0
	daily.Text = "CLAIM +250"
	daily.Font = Enum.Font.GothamBold
	daily.TextSize = 15
	daily.TextColor3 = Color3.new(1,1,1)
	daily.Parent = gui
	Instance.new("UICorner", daily).CornerRadius = UDim.new(0, 10)

	local shop = Instance.new("Frame")
	shop.Name = "Shop"
	shop.Size = UDim2.fromOffset(210, 132)
	shop.Position = UDim2.new(1, -228, 0, 14)
	shop.BackgroundColor3 = Theme.Panel
	shop.BackgroundTransparency = 0.12
	shop.BorderSizePixel = 0
	shop.Parent = gui
	Instance.new("UICorner", shop).CornerRadius = UDim.new(0, 12)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 28)
	title.BackgroundTransparency = 1
	title.Text = "PRO SHOP"
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 17
	title.TextColor3 = Color3.new(1,1,1)
	title.Parent = shop

	for i, data in ipairs({
		{"Multiplier", "x+0.25 - 250"},
		{"Shield", "Shield - 100"},
	}) do
		local b = Instance.new("TextButton")
		b.Name = data[1]
		b.Size = UDim2.new(1, -20, 0, 30)
		b.Position = UDim2.fromOffset(10, 34 + (i - 1) * 36)
		b.BackgroundColor3 = Theme.Primary
		b.BorderSizePixel = 0
		b.Text = data[2]
		b.Font = Enum.Font.GothamBold
		b.TextSize = 14
		b.TextColor3 = Color3.new(1,1,1)
		b.Parent = shop
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
	end

	scriptIn(gui, "UIClient", [[
local player = game.Players.LocalPlayer
local remotes = game.ReplicatedStorage:WaitForChild("AIOBBY_Remotes")
local text = script.Parent.HUD.Stats

script.Parent.Daily.MouseButton1Click:Connect(function()
	remotes.ClaimDaily:FireServer()
	script.Parent.Daily.Text = "CLAIMED"
end)

for _, b in ipairs(script.Parent.Shop:GetChildren()) do
	if b:IsA("TextButton") then
		b.MouseButton1Click:Connect(function()
			remotes.BuyUpgrade:FireServer(b.Name)
		end)
	end
end

while true do
	local s = player:FindFirstChild("leaderstats")
	if s then
		text.Text =
			"⚡ AI Obby Pro" ..
			"\nStage " .. s.Stage.Value .. "  💰 " .. s.Coins.Value .. "  💎 " .. s.Gems.Value ..
			"\n⭐ " .. s.Level.Value .. "  🏆 " .. s.Wins.Value .. "  x" .. s.Multiplier.Value
	end
	task.wait(0.25)
end
]], true)
end

local function checkpoint(obj, stage)
	obj.Name = PREFIX .. "Checkpoint_" .. stage
	label(obj, "STAGE " .. stage)

	scriptIn(obj, "Checkpoint", [[
local stage = ]] .. stage .. [[
script.Parent.Touched:Connect(function(hit)
	local player = game.Players:GetPlayerFromCharacter(hit.Parent)
	if not player then return end

	local s = player:FindFirstChild("leaderstats")
	if s and stage > s.Stage.Value then
		s.Stage.Value = stage
	end

	local cp = player:FindFirstChild("AIOBBY_Checkpoint")
	if cp then
		cp.Value = script.Parent.Position + Vector3.new(0, 8, 0)
	end
end)
]], false)
end

local function coin(pos, value)
	local c = part("Coin", pos, Vector3.new(2,2,0.35), Theme.Accent)
	c.Shape = Enum.PartType.Cylinder
	c.Orientation = Vector3.new(0,0,90)
	glow(c, 10, 2)

	scriptIn(c, "Coin", [[
local busy = false
script.Parent.Touched:Connect(function(hit)
	if busy then return end
	local p = game.Players:GetPlayerFromCharacter(hit.Parent)
	if not p then return end

	busy = true
	if _G.AIOBBY_Reward then _G.AIOBBY_Reward(p, ]] .. tostring(value or 10) .. [[, 5, 0) end

	script.Parent.Transparency = 1
	script.Parent.CanTouch = false
	task.wait(6)
	script.Parent.Transparency = 0
	script.Parent.CanTouch = true
	busy = false
end)

while true do
	script.Parent.CFrame *= CFrame.Angles(0, math.rad(5), 0)
	task.wait()
end
]], false)
end

local function kill(obj)
	scriptIn(obj, "Kill", [[
script.Parent.Touched:Connect(function(hit)
	local player = game.Players:GetPlayerFromCharacter(hit.Parent)
	local hum = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")

	if player and player:FindFirstChild("AIOBBY_Shield") and player.AIOBBY_Shield.Value then
		player.AIOBBY_Shield.Value = false
		return
	end

	if hum then hum.Health = 0 end
end)
]], false)
end

local function booster(name, pos, kind)
	local color = kind == "Jump" and Theme.Boost or kind == "Speed" and Theme.Primary or Theme.Secondary
	local p = part(name, pos, Vector3.new(9, 0.7, 9), color)
	glow(p, 18, 2)
	label(p, kind)

	if kind == "Jump" then
		scriptIn(p, "Jump", [[
script.Parent.Touched:Connect(function(hit)
	local root = hit.Parent and hit.Parent:FindFirstChild("HumanoidRootPart")
	if root then root.AssemblyLinearVelocity = Vector3.new(root.AssemblyLinearVelocity.X, 115, root.AssemblyLinearVelocity.Z) end
end)
]], false)
	elseif kind == "Speed" then
		scriptIn(p, "Speed", [[
script.Parent.Touched:Connect(function(hit)
	local hum = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
	if hum then
	hum.WalkSpeed = 34
	task.delay(5, function() if hum then hum.WalkSpeed = 16 end end)
	end
end)
]], false)
	else
		scriptIn(p, "Shield", [[
script.Parent.Touched:Connect(function(hit)
	local p = game.Players:GetPlayerFromCharacter(hit.Parent)
	if p and p:FindFirstChild("AIOBBY_Shield") then p.AIOBBY_Shield.Value = true end
end)
]], false)
	end
end

local function hazard(pos, index, kind)
	if kind == "Lava" then
		local h = part("Lava_" .. index, pos, Vector3.new(18, 1, 22), Theme.Danger)
		glow(h, 20, 2)
		kill(h)

	elseif kind == "Spinner" then
		local h = part("Spinner_" .. index, pos, Vector3.new(22, 1, 1), Theme.Accent)
		glow(h, 18, 2)
		kill(h)
		scriptIn(h, "Spin", [[
while true do script.Parent.CFrame *= CFrame.Angles(0, math.rad(5), 0) task.wait() end
]], false)

	elseif kind == "Laser" then
		local h = part("Laser_" .. index, pos, Vector3.new(2, 2, 26), Theme.Secondary)
		glow(h, 18, 2)
		kill(h)
		scriptIn(h, "Move", [[
local start = script.Parent.Position
local t = 0
while true do
	t += .04
	script.Parent.Position = start + Vector3.new(0,0,math.sin(t*2)*16)
	task.wait()
end
]], false)

	elseif kind == "Crusher" then
		local h = part("Crusher_" .. index, pos, Vector3.new(12, 12, 12), Theme.Danger)
		glow(h, 20, 2)
		kill(h)
		scriptIn(h, "Crush", [[
local start = script.Parent.Position
while true do
	script.Parent.Position = start + Vector3.new(0, 10, 0)
	task.wait(1)
	script.Parent.Position = start
	task.wait(.35)
end
]], false)
	end
end

local function build()
	clampConfigForLicense()
	clear()
	applyTheme(Config.ThemeName)
	setupLighting()
	setupRuntime()
	setupUI()

	part("VoidGrid", Vector3.new(660,-10,0), Vector3.new(1500,1,260), Theme.Dark, Enum.Material.Metal)

	local start = part("Start", Vector3.new(0,4,0), Vector3.new(38,2,38), Theme.Boost)
	glow(start, 30, 2.5)
	label(start, "START")
	checkpoint(start, 0)

	for i = 1, Config.Stages do
		local zone = math.floor((i - 1) / 20) + 1
		local x = i * Config.Gap
		local y = 5 + math.sin(i * .5) * (3 * difficultyScale()) + math.floor(i / 25) * (5 * difficultyScale())
		local z = math.sin(i * .82) * (14 + zone * 2)

		if i > 75 then y += (i - 75) * .85 end

		local width = math.max(6, 15 - zone)
		local platform = part("Platform_" .. i, Vector3.new(x,y,z), Vector3.new(width,1.2,10), Color3.fromHSV((zone % 8) / 8, 1, 1))
		glow(platform, 12, 1)

		if i % Config.CheckpointEvery == 0 then checkpoint(platform, math.floor(i / Config.CheckpointEvery)) end
		if i % Config.CoinEvery == 0 then coin(Vector3.new(x, y + 3, z), 10 + zone * 2) end
		if i % 20 == 0 then label(platform, "ZONE " .. zone) end

		local h = i % hazardModulo()

		if h == 0 then hazard(Vector3.new(x+8,y-3,z), i, "Lava")
		elseif h == 1 then hazard(Vector3.new(x,y+3,z), i, "Spinner")
		elseif h == 2 then hazard(Vector3.new(x,y+3,z), i, "Laser")
		elseif h == 3 then hazard(Vector3.new(x,y+8,z-15), i, "Crusher")
		elseif h == 4 then booster("JumpPad_"..i, Vector3.new(x,y+1.2,z), "Jump")
		elseif h == 5 then booster("SpeedPad_"..i, Vector3.new(x,y+1.2,z), "Speed")
		elseif h == 6 then booster("ShieldPad_"..i, Vector3.new(x,y+1.2,z), "Shield")
		elseif h == 7 then
			scriptIn(platform, "Moving", [[
local start = script.Parent.Position
local t = 0
while true do
	t += .04
	script.Parent.Position = start + Vector3.new(0,0,math.sin(t)*12)
	task.wait()
end
]], false)
		elseif h == 8 then
			scriptIn(platform, "Disappear", [[
while true do
	script.Parent.Transparency = 0
	script.Parent.CanCollide = true
	task.wait(2)
	script.Parent.Transparency = .75
	script.Parent.CanCollide = false
	task.wait(1)
end
]], false)
		end
	end

	local boss = part("BossStage", Vector3.new(1380, 110, 0), Vector3.new(60,3,60), Theme.Secondary)
	glow(boss, 40, 4)
	label(boss, "BOSS STAGE")

	for j = 1, 10 do
		hazard(Vector3.new(1380, 114 + j, 0), 900 + j, "Spinner")
	end

	local finish = part("Finish", Vector3.new(1460,118,0), Vector3.new(46,5,46), Theme.Accent)
	glow(finish, 42, 4)
	animatedSign(finish, "FINISH")

	scriptIn(finish, "Win", [[
local busy = {}

script.Parent.Touched:Connect(function(hit)
	local p = game.Players:GetPlayerFromCharacter(hit.Parent)
	if not p or busy[p] then return end
	busy[p] = true

	local s = p:FindFirstChild("leaderstats")
	if s then
		s.Wins.Value += 1
		s.Coins.Value += 250
		s.Gems.Value += 10

		local start = p:FindFirstChild("AIOBBY_StartTime")
		if start then
			local t = os.clock() - start.Value
			if t < s.BestTime.Value then s.BestTime.Value = t end
			start.Value = os.clock()
		end
	end

	if _G.AIOBBY_Reward then _G.AIOBBY_Reward(p, 250, 250, 10) end

	task.wait(4)
	busy[p] = nil
end)
]], false)

	fireworks(finish.Position)
	playChime(finish)
	warn("AI Obby Generator Pro Ultimate built premium obby.")
end





local PresetConfigs = {
	Easy = {
		ThemeName = "Neon",
		Difficulty = "Easy",
		Stages = 40,
		HazardDensity = "Low",
		Monetization = false,
	},
	Viral = {
		ThemeName = "Cyber",
		Difficulty = "Normal",
		Stages = 120,
		HazardDensity = "Medium",
		Monetization = true,
	},
	Hardcore = {
		ThemeName = "Lava",
		Difficulty = "Insane",
		Stages = 160,
		HazardDensity = "High",
		Monetization = true,
	},
	Monetized = {
		ThemeName = "Toxic",
		Difficulty = "Hard",
		Stages = 120,
		HazardDensity = "High",
		Monetization = true,
	},
}

local function applyPreset(name)
	local preset = PresetConfigs[name]
	if not preset then return end

	Config.ThemeName = preset.ThemeName
	Config.Difficulty = preset.Difficulty
	Config.Stages = preset.Stages
	Config.HazardDensity = preset.HazardDensity
	Config.Monetization = preset.Monetization

	applyTheme(Config.ThemeName)
end

local function exportBuildReport()
	local report = table.concat({
		"AI OBBY GENERATOR PRO - BUILD REPORT",
		"",
		"Theme: " .. tostring(Config.ThemeName),
		"Difficulty: " .. tostring(Config.Difficulty),
		"Stages: " .. tostring(Config.Stages),
		"Hazard Density: " .. tostring(Config.HazardDensity),
		"Monetization Hooks: " .. tostring(Config.Monetization),
		"",
		"Generated Systems:",
		"- Checkpoints",
		"- Coins",
		"- XP / levels",
		"- Daily reward",
		"- Upgrade shop",
		"- Shield protection",
		"- Jump / speed / shield boosters",
		"- Lava, spinners, lasers, crushers",
		"- Boss stage",
		"- Finish rewards",
		"",
		"Creator Polish Checklist:",
		"1. Test full course in Play mode.",
		"2. Replace placeholder colors/materials with branded art.",
		"3. Add thumbnails and icons.",
		"4. Configure gamepasses/dev products manually in Roblox Creator Dashboard.",
		"5. Add sound effects/music.",
		"6. Publish private test, then invite testers.",
		"7. Tune rewards after first playtest.",
		"",
		"Recommended Monetization:",
		"- 2x Coins gamepass",
		"- VIP trail/aura",
		"- Skip stage developer product",
		"- Revive developer product",
		"- Daily reward streak booster",
		"",
		"Generated by AI Obby Generator Pro."
	}, "\n")

	local existing = S.ReplicatedStorage:FindFirstChild(PREFIX .. "BuildReport")
	if existing then existing:Destroy() end

	local value = Instance.new("StringValue")
	value.Name = PREFIX .. "BuildReport"
	value.Value = report
	value.Parent = S.ReplicatedStorage

	warn("AI Obby Pro build report exported to ReplicatedStorage > " .. value.Name)
end

local panelWidget

local function cycleValue(list, current)
	local idx = 1
	for i, v in ipairs(list) do
		if v == current then idx = i break end
	end
	idx += 1
	if idx > #list then idx = 1 end
	return list[idx]
end

local function makePanel()
	local info = DockWidgetPluginGuiInfo.new(
		Enum.InitialDockState.Float,
		true,
		false,
		360,
		560,
		320,
		480
	)

	local widget = plugin:CreateDockWidgetPluginGui("AIObbyGeneratorProPanel", info)
	widget.Title = "AI Obby Generator Pro"

	local root = Instance.new("Frame")
	root.Size = UDim2.fromScale(1,1)
	root.BackgroundColor3 = Theme.Panel
	root.BorderSizePixel = 0
	root.Parent = widget

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1,-20,0,38)
	title.Position = UDim2.fromOffset(10,8)
	title.BackgroundTransparency = 1
	title.Text = "AI Obby Generator Pro"
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 20
	title.TextColor3 = Color3.new(1,1,1)
	title.Parent = root

	local subtitle = Instance.new("TextLabel")
	subtitle.Size = UDim2.new(1,-20,0,24)
	subtitle.Position = UDim2.fromOffset(10,44)
	subtitle.BackgroundTransparency = 1
	subtitle.Text = "Configure. Generate. Sell-ready obby."
	subtitle.Font = Enum.Font.Gotham
	subtitle.TextSize = 13
	subtitle.TextColor3 = Color3.fromRGB(200,210,230)
	subtitle.Parent = root

	local function makeButton(y, labelText, getText, onClick)
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1,-20,0,18)
		label.Position = UDim2.fromOffset(10,y)
		label.BackgroundTransparency = 1
		label.Text = labelText
		label.Font = Enum.Font.GothamBold
		label.TextSize = 12
		label.TextColor3 = Color3.fromRGB(210,220,240)
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = root

		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1,-20,0,32)
		b.Position = UDim2.fromOffset(10,y+20)
		b.BackgroundColor3 = Theme.Primary
		b.BorderSizePixel = 0
		b.Text = getText()
		b.Font = Enum.Font.GothamBold
		b.TextSize = 14
		b.TextColor3 = Color3.new(1,1,1)
		b.Parent = root

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0,8)
		corner.Parent = b

		b.MouseButton1Click:Connect(function()
			onClick()
			b.Text = getText()
		end)

		return b
	end

	makeButton(82, "Theme", function()
		return Config.ThemeName
	end, function()
		Config.ThemeName = cycleValue(Presets.Themes, Config.ThemeName)
		applyTheme(Config.ThemeName)
	end)

	makeButton(140, "Difficulty", function()
		return Config.Difficulty
	end, function()
		Config.Difficulty = cycleValue(Presets.Difficulties, Config.Difficulty)
	end)

	makeButton(198, "Stage Count", function()
		return tostring(Config.Stages) .. " stages"
	end, function()
		local current = Config.Stages
		local idx = 1
		for i, v in ipairs(Presets.StageOptions) do
			if v == current then idx = i break end
		end
		idx += 1
		if idx > #Presets.StageOptions then idx = 1 end
		Config.Stages = Presets.StageOptions[idx]
	end)

	makeButton(256, "Hazard Density", function()
		return Config.HazardDensity
	end, function()
		Config.HazardDensity = cycleValue(Presets.HazardDensities, Config.HazardDensity)
	end)

	local monetization = makeButton(314, "Monetization Hooks", function()
		return Config.Monetization and "Enabled" or "Disabled"
	end, function()
		Config.Monetization = not Config.Monetization
	end)

	local presetLabel = Instance.new("TextLabel")
	presetLabel.Size = UDim2.new(1,-20,0,18)
	presetLabel.Position = UDim2.fromOffset(10,372)
	presetLabel.BackgroundTransparency = 1
	presetLabel.Text = "Presets"
	presetLabel.Font = Enum.Font.GothamBold
	presetLabel.TextSize = 12
	presetLabel.TextColor3 = Color3.fromRGB(210,220,240)
	presetLabel.TextXAlignment = Enum.TextXAlignment.Left
	presetLabel.Parent = root

	local presetNames = {"Easy", "Viral", "Hardcore", "Monetized"}
	for i, presetName in ipairs(presetNames) do
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(0.5,-15,0,28)
		b.Position = UDim2.fromOffset(i % 2 == 1 and 10 or 180, 394 + math.floor((i-1)/2) * 34)
		b.BackgroundColor3 = Theme.Secondary
		b.BorderSizePixel = 0
		b.Text = presetName
		b.Font = Enum.Font.GothamBold
		b.TextSize = 13
		b.TextColor3 = Color3.new(1,1,1)
		b.Parent = root
		Instance.new("UICorner", b).CornerRadius = UDim.new(0,8)

		b.MouseButton1Click:Connect(function()
			applyPreset(presetName)
		end)
	end

	local export = Instance.new("TextButton")
	export.Size = UDim2.new(1,-20,0,32)
	export.Position = UDim2.fromOffset(10,466)
	export.BackgroundColor3 = Theme.Accent
	export.BorderSizePixel = 0
	export.Text = "EXPORT BUILD REPORT"
	export.Font = Enum.Font.GothamBlack
	export.TextSize = 14
	export.TextColor3 = Color3.new(1,1,1)
	export.Parent = root
	Instance.new("UICorner", export).CornerRadius = UDim.new(0,10)
	export.MouseButton1Click:Connect(exportBuildReport)

	local generate = Instance.new("TextButton")
	generate.Size = UDim2.new(.5,-15,0,38)
	generate.Position = UDim2.new(0,10,1,-48)
	generate.BackgroundColor3 = Theme.Boost
	generate.BorderSizePixel = 0
	generate.Text = "GENERATE"
	generate.Font = Enum.Font.GothamBlack
	generate.TextSize = 15
	generate.TextColor3 = Color3.new(1,1,1)
	generate.Parent = root
	Instance.new("UICorner", generate).CornerRadius = UDim.new(0,10)
	generate.MouseButton1Click:Connect(build)

	local clearButton = Instance.new("TextButton")
	clearButton.Size = UDim2.new(.5,-15,0,38)
	clearButton.Position = UDim2.new(.5,5,1,-48)
	clearButton.BackgroundColor3 = Theme.Danger
	clearButton.BorderSizePixel = 0
	clearButton.Text = "CLEAR"
	clearButton.Font = Enum.Font.GothamBlack
	clearButton.TextSize = 15
	clearButton.TextColor3 = Color3.new(1,1,1)
	clearButton.Parent = root
	Instance.new("UICorner", clearButton).CornerRadius = UDim.new(0,10)
	clearButton.MouseButton1Click:Connect(clear)

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
buildBtn.Click:Connect(build)
clearBtn.Click:Connect(clear)
