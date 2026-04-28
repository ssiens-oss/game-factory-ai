-- GameFactoryObbyUpgrade25.plugin.lua
-- One-click 25 upgrade pass for Roblox obby maps.
-- Creates lobby, checkpoints, hazards, polish, signs, rewards, lighting, shop placeholders, and export notes.

local toolbar = plugin:CreateToolbar("Game Factory")
local button = toolbar:CreateButton(
	"Upgrade Obby 25x",
	"Apply 25 top-tier upgrades to the current obby",
	"rbxassetid://4458901886"
)

local Selection = game:GetService("Selection")
local Lighting = game:GetService("Lighting")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local StarterPack = game:GetService("StarterPack")
local Workspace = game:GetService("Workspace")

local function makeFolder(parent, name)
	local f = parent:FindFirstChild(name)
	if not f then
		f = Instance.new("Folder")
		f.Name = name
		f.Parent = parent
	end
	return f
end

local function part(parent, name, size, pos, color, material, anchored)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Position = pos
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Anchored = anchored ~= false
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent
	return p
end

local function addBillboard(parent, text, y)
	local gui = Instance.new("BillboardGui")
	gui.Name = "GF_Label"
	gui.Size = UDim2.fromOffset(260, 70)
	gui.StudsOffset = Vector3.new(0, y or 5, 0)
	gui.AlwaysOnTop = true
	gui.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextScaled = true
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextStrokeTransparency = 0
	label.Font = Enum.Font.GothamBlack
	label.Parent = gui
end

local function addTouchKill(p)
	p.Name = p.Name .. "_Kill"
	p.Color = Color3.fromRGB(255, 60, 60)
	p.Material = Enum.Material.Neon
	local scriptObj = Instance.new("Script")
	scriptObj.Name = "KillTouchScript"
	scriptObj.Source = [[
script.Parent.Touched:Connect(function(hit)
	local hum = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.Health = 0
	end
end)
]]
	scriptObj.Parent = p
end

local function addCheckpoint(p, stage)
	p.Name = "Checkpoint_" .. stage
	p.Color = Color3.fromRGB(0, 255, 170)
	p.Material = Enum.Material.Neon
	addBillboard(p, "Checkpoint " .. stage, 4)

	local scriptObj = Instance.new("Script")
	scriptObj.Name = "CheckpointScript"
	scriptObj.Source = string.format([[
local stageNumber = %d
script.Parent.Touched:Connect(function(hit)
	local character = hit.Parent
	local player = game.Players:GetPlayerFromCharacter(character)
	if not player then return end

	local stats = player:FindFirstChild("leaderstats")
	if stats and stats:FindFirstChild("Stage") then
		if stats.Stage.Value < stageNumber then
			stats.Stage.Value = stageNumber
		end
	end

	player:SetAttribute("CheckpointPosition", script.Parent.Position)
end)
]], stage)
	scriptObj.Parent = p
end

local function createServerSystems()
	local scriptObj = game.ServerScriptService:FindFirstChild("GF_ObbySystems")
	if scriptObj then scriptObj:Destroy() end

	scriptObj = Instance.new("Script")
	scriptObj.Name = "GF_ObbySystems"
	scriptObj.Source = [[
local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
	local leaderstats = Instance.new("Folder")
	leaderstats.Name = "leaderstats"
	leaderstats.Parent = player

	local stage = Instance.new("IntValue")
	stage.Name = "Stage"
	stage.Value = 1
	stage.Parent = leaderstats

	local coins = Instance.new("IntValue")
	coins.Name = "Coins"
	coins.Value = 0
	coins.Parent = leaderstats

	local wins = Instance.new("IntValue")
	wins.Name = "Wins"
	wins.Value = 0
	wins.Parent = leaderstats

	player.CharacterAdded:Connect(function(character)
		task.wait(0.25)
		local pos = player:GetAttribute("CheckpointPosition")
		if pos and character:FindFirstChild("HumanoidRootPart") then
			character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
		end
	end)
end)
]]
	scriptObj.Parent = game.ServerScriptService
end

local function createShopGui()
	local gui = StarterGui:FindFirstChild("GF_ObbyShopGui")
	if gui then gui:Destroy() end

	gui = Instance.new("ScreenGui")
	gui.Name = "GF_ObbyShopGui"
	gui.ResetOnSpawn = false
	gui.Parent = StarterGui

	local frame = Instance.new("Frame")
	frame.Name = "ShopBar"
	frame.Size = UDim2.fromOffset(190, 260)
	frame.Position = UDim2.new(1, -210, 0.5, -130)
	frame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	frame.BackgroundTransparency = 0.1
	frame.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = frame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 40)
	title.BackgroundTransparency = 1
	title.Text = "OBBY SHOP"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextScaled = true
	title.Font = Enum.Font.GothamBlack
	title.Parent = frame

	local items = {
		"Skip Stage",
		"Revive",
		"2x Coins",
		"VIP Trail",
		"Speed Boost"
	}

	for i, txt in ipairs(items) do
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1, -20, 0, 34)
		b.Position = UDim2.fromOffset(10, 45 + ((i - 1) * 40))
		b.BackgroundColor3 = Color3.fromRGB(60, 120, 255)
		b.Text = txt
		b.TextColor3 = Color3.fromRGB(255, 255, 255)
		b.TextScaled = true
		b.Font = Enum.Font.GothamBold
		b.Parent = frame

		local c = Instance.new("UICorner")
		c.CornerRadius = UDim.new(0, 10)
		c.Parent = b
	end
end

local function applyLighting()
	Lighting.ClockTime = 14
	Lighting.Brightness = 3
	Lighting.EnvironmentDiffuseScale = 0.6
	Lighting.EnvironmentSpecularScale = 0.9
	Lighting.GlobalShadows = true

	local bloom = Lighting:FindFirstChild("GF_Bloom") or Instance.new("BloomEffect")
	bloom.Name = "GF_Bloom"
	bloom.Intensity = 0.35
	bloom.Size = 32
	bloom.Threshold = 1.2
	bloom.Parent = Lighting

	local cc = Lighting:FindFirstChild("GF_ColorCorrection") or Instance.new("ColorCorrectionEffect")
	cc.Name = "GF_ColorCorrection"
	cc.Contrast = 0.08
	cc.Saturation = 0.18
	cc.Brightness = 0.02
	cc.Parent = Lighting

	local sky = Lighting:FindFirstChild("GF_Sky") or Instance.new("Sky")
	sky.Name = "GF_Sky"
	sky.Parent = Lighting
end

local function createUpgradeNotes()
	local notes = ReplicatedStorage:FindFirstChild("GF_Upgrade25_Notes")
	if notes then notes:Destroy() end

	notes = Instance.new("StringValue")
	notes.Name = "GF_Upgrade25_Notes"
	notes.Value = [[
GAME FACTORY OBBY 25x UPGRADE NOTES

Applied:
1. Polished lobby
2. Spawn platform
3. Stage path
4. Neon theme pass
5. Lava kill hazards
6. Moving platform placeholders
7. Spinner hazards
8. Disappearing tile placeholders
9. Checkpoints
10. Leaderstats
11. Coins stat
12. Wins stat
13. Shop UI
14. Monetization placeholders
15. Better lighting
16. Bloom
17. Color correction
18. Signs
19. Difficulty ramp
20. Finish zone
21. Win fireworks
22. Reward scaffolding
23. Folder organization
24. Export notes
25. Creator-ready structure

Next:
- Replace placeholder product IDs.
- Add real gamepass/dev product IDs.
- Publish and test multiplayer.
- Add DataStore saving.
]]
	notes.Parent = ReplicatedStorage
end

local function createFireworks(parent, pos)
	local base = part(parent, "Finish_Fireworks_Base", Vector3.new(8, 1, 8), pos, Color3.fromRGB(255, 255, 255), Enum.Material.Neon, true)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "WinFireworks"
	emitter.Rate = 20
	emitter.Lifetime = NumberRange.new(1, 2)
	emitter.Speed = NumberRange.new(20, 35)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Parent = base
	return base
end

local function buildUpgradedObby()
	local root = makeFolder(Workspace, "GF_Upgraded_Obby")
	root:ClearAllChildren()

	local platforms = makeFolder(root, "01_Platforms")
	local hazards = makeFolder(root, "02_Hazards")
	local checkpoints = makeFolder(root, "03_Checkpoints")
	local decor = makeFolder(root, "04_Decor")
	local lobby = makeFolder(root, "05_Lobby")
	local finish = makeFolder(root, "06_Finish")

	-- 1. Lobby
	local lobbyBase = part(lobby, "Polished_Lobby_Base", Vector3.new(80, 2, 80), Vector3.new(0, 1, 0), Color3.fromRGB(35, 35, 55), Enum.Material.Slate, true)
	addBillboard(lobbyBase, "GAME FACTORY OBBY", 8)

	-- 2. Spawn
	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "GF_Spawn"
	spawn.Size = Vector3.new(12, 1, 12)
	spawn.Position = Vector3.new(0, 4, 0)
	spawn.Color = Color3.fromRGB(0, 255, 170)
	spawn.Material = Enum.Material.Neon
	spawn.Anchored = true
	spawn.Parent = lobby

	-- 3. Update board
	local board = part(lobby, "Update_Board", Vector3.new(18, 10, 1), Vector3.new(-25, 8, -30), Color3.fromRGB(20, 20, 30), Enum.Material.SmoothPlastic, true)
	addBillboard(board, "UPDATE BOARD\n25x Upgrade Applied", 4)

	-- 4. Shop stand
	local shop = part(lobby, "Shop_Stand", Vector3.new(16, 4, 8), Vector3.new(25, 3, -25), Color3.fromRGB(80, 120, 255), Enum.Material.Neon, true)
	addBillboard(shop, "SHOP\nSkips • Revives • VIP", 5)

	-- 5. Stage generation
	local colors = {
		Color3.fromRGB(0, 170, 255),
		Color3.fromRGB(170, 0, 255),
		Color3.fromRGB(255, 170, 0),
		Color3.fromRGB(0, 255, 170),
		Color3.fromRGB(255, 60, 120),
	}

	local x = 0
	local z = 60
	for i = 1, 50 do
		local difficulty = math.ceil(i / 10)
		local y = 4 + math.floor(i / 6) * 1.5
		local p = part(
			platforms,
			"Stage_" .. i,
			Vector3.new(math.max(8, 18 - difficulty), 1, math.max(8, 18 - difficulty)),
			Vector3.new(x, y, z),
			colors[((i - 1) % #colors) + 1],
			i % 5 == 0 and Enum.Material.Neon or Enum.Material.SmoothPlastic,
			true
		)

		addBillboard(p, "Stage " .. i, 4)

		-- 6. Checkpoints every 5
		if i % 5 == 0 then
			local cp = part(checkpoints, "CheckpointPad_" .. i, Vector3.new(12, 1, 12), Vector3.new(x, y + 1.2, z + 11), Color3.fromRGB(0, 255, 170), Enum.Material.Neon, true)
			addCheckpoint(cp, i)
		end

		-- 7. Lava hazards
		if i % 3 == 0 then
			local lava = part(hazards, "Lava_Bar_" .. i, Vector3.new(18, 1, 3), Vector3.new(x, y + 1.2, z - 9), Color3.fromRGB(255, 60, 0), Enum.Material.Neon, true)
			addTouchKill(lava)
		end

		-- 8. Spinner hazards
		if i % 4 == 0 then
			local spinner = part(hazards, "Spinner_" .. i, Vector3.new(24, 1, 1), Vector3.new(x, y + 3, z), Color3.fromRGB(255, 0, 90), Enum.Material.Neon, true)
			addTouchKill(spinner)

			local s = Instance.new("Script")
			s.Name = "SpinScript"
			s.Source = [[
while true do
	script.Parent.CFrame = script.Parent.CFrame * CFrame.Angles(0, math.rad(4), 0)
	task.wait()
end
]]
			s.Parent = spinner
		end

		-- 9. Moving platform placeholders
		if i % 6 == 0 then
			local mover = part(platforms, "Moving_Platform_" .. i, Vector3.new(10, 1, 10), Vector3.new(x + 20, y, z), Color3.fromRGB(255, 255, 0), Enum.Material.Neon, true)

			local s = Instance.new("Script")
			s.Name = "MoveScript"
			s.Source = [[
local TweenService = game:GetService("TweenService")
local p = script.Parent
local start = p.Position
local goal = start + Vector3.new(0, 0, 22)
while true do
	TweenService:Create(p, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = goal}):Play()
	task.wait(2)
	TweenService:Create(p, TweenInfo.new(2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Position = start}):Play()
	task.wait(2)
end
]]
			s.Parent = mover
		end

		-- 10. Disappearing tiles
		if i % 7 == 0 then
			local tile = part(platforms, "Disappearing_Tile_" .. i, Vector3.new(10, 1, 10), Vector3.new(x - 20, y, z), Color3.fromRGB(255, 255, 255), Enum.Material.Glass, true)

			local s = Instance.new("Script")
			s.Name = "DisappearScript"
			s.Source = [[
local p = script.Parent
while true do
	p.Transparency = 0
	p.CanCollide = true
	task.wait(2)
	p.Transparency = 0.75
	p.CanCollide = false
	task.wait(1.2)
end
]]
			s.Parent = tile
		end

		-- 11. Decorative rings
		if i % 2 == 0 then
			local ring = part(decor, "Neon_Ring_" .. i, Vector3.new(2, 18, 18), Vector3.new(x, y + 8, z + 8), Color3.fromRGB(0, 255, 255), Enum.Material.Neon, true)
			ring.Shape = Enum.PartType.Cylinder
			ring.Rotation = Vector3.new(0, 0, 90)
			ring.CanCollide = false
		end

		x += ((i % 2 == 0) and 18 or -18)
		z += 32
	end

	-- 12. Finish platform
	local finishPad = part(finish, "Finish_Zone", Vector3.new(40, 2, 40), Vector3.new(x, 18, z + 35), Color3.fromRGB(255, 215, 0), Enum.Material.Neon, true)
	addBillboard(finishPad, "FINISH!\nClaim Win + Coins", 8)

	local finishScript = Instance.new("Script")
	finishScript.Name = "FinishRewardScript"
	finishScript.Source = [[
local debounce = {}

script.Parent.Touched:Connect(function(hit)
	local player = game.Players:GetPlayerFromCharacter(hit.Parent)
	if not player or debounce[player] then return end
	debounce[player] = true

	local stats = player:FindFirstChild("leaderstats")
	if stats then
		if stats:FindFirstChild("Wins") then stats.Wins.Value += 1 end
		if stats:FindFirstChild("Coins") then stats.Coins.Value += 500 end
	end

	task.wait(3)
	debounce[player] = nil
end)
]]
	finishScript.Parent = finishPad

	-- 13. Fireworks
	createFireworks(finish, Vector3.new(x, 25, z + 35))

	-- 14. Clouds / floating decor
	for i = 1, 20 do
		local cloud = part(
			decor,
			"Floating_Cloud_" .. i,
			Vector3.new(math.random(16, 35), 3, math.random(8, 20)),
			Vector3.new(math.random(-120, 120), math.random(35, 80), math.random(20, 1700)),
			Color3.fromRGB(240, 245, 255),
			Enum.Material.SmoothPlastic,
			true
		)
		cloud.Transparency = 0.25
		cloud.CanCollide = false
	end

	-- 15. Theme portals
	local themes = {"Candy", "Lava", "Cyber", "Space", "Jungle"}
	for i, name in ipairs(themes) do
		local portal = part(decor, "Theme_Portal_" .. name, Vector3.new(3, 22, 14), Vector3.new(-55 + i * 20, 12, 35), colors[((i - 1) % #colors) + 1], Enum.Material.Neon, true)
		addBillboard(portal, name .. " Theme", 6)
	end

	-- 16. World border rails
	for i = 1, 12 do
		part(decor, "Safety_Rail_L_" .. i, Vector3.new(2, 4, 70), Vector3.new(-65, 8, i * 140), Color3.fromRGB(50, 50, 80), Enum.Material.Metal, true)
		part(decor, "Safety_Rail_R_" .. i, Vector3.new(2, 4, 70), Vector3.new(65, 8, i * 140), Color3.fromRGB(50, 50, 80), Enum.Material.Metal, true)
	end

	-- 17-25. Systems
	createServerSystems()
	createShopGui()
	applyLighting()
	createUpgradeNotes()

	Selection:Set({root})
end

button.Click:Connect(function()
	buildUpgradedObby()
	print("✅ Game Factory: 25x Obby Upgrade applied.")
end)


