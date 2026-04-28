-- Tycoon Builder Pro
-- Game Factory AI Studio Plugin
-- Bash-safe Roblox Studio plugin file

local toolbar = plugin:CreateToolbar("Game Factory AI")
local button = toolbar:CreateButton(
	"Tycoon Builder Pro",
	"Generate a complete Roblox tycoon game",
	"rbxassetid://4458901886"
)

local Selection = game:GetService("Selection")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")

local CONFIG = {
	TycoonCount = 6,
	PlotSpacing = 180,
	StartingCash = 250,
	EnableObbyBonus = true,
	EnablePets = true,
}

local PRODUCTS = {
	CashPackSmall = 1001,
	CashPackLarge = 1002,
	AutoCollect = 1003,
	TwoXCash = 1004,
	VIPOwner = 1005,
	SkipBuild = 1006,
}

local function clearOld()
	for _, obj in ipairs(workspace:GetChildren()) do
		if obj.Name == "TycoonBuilderPro_World" then
			obj:Destroy()
		end
	end

	for _, obj in ipairs(ServerScriptService:GetChildren()) do
		if obj.Name:match("^TBP_") then
			obj:Destroy()
		end
	end

	for _, obj in ipairs(ReplicatedStorage:GetChildren()) do
		if obj.Name:match("^TBP_") then
			obj:Destroy()
		end
	end

	for _, obj in ipairs(StarterGui:GetChildren()) do
		if obj.Name:match("^TBP_") then
			obj:Destroy()
		end
	end
end

local function part(parent, name, size, pos, color, material)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Position = pos
	p.Anchored = true
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Color = color
	p.Material = material or Enum.Material.SmoothPlastic
	p.Parent = parent
	return p
end

local function label(target, text)
	local gui = Instance.new("BillboardGui")
	gui.Name = "Label"
	gui.Size = UDim2.fromOffset(260, 70)
	gui.StudsOffset = Vector3.new(0, 5, 0)
	gui.AlwaysOnTop = true
	gui.Parent = target

	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.Text = text
	t.TextScaled = true
	t.TextColor3 = Color3.new(1, 1, 1)
	t.Font = Enum.Font.GothamBlack
	t.Parent = gui
end

local function makeRemotes()
	local folder = Instance.new("Folder")
	folder.Name = "TBP_Remotes"
	folder.Parent = ReplicatedStorage

	for _, name in ipairs({
		"BuyButton",
		"CollectCash",
		"Rebirth",
		"Notify"
	}) do
		local r = Instance.new("RemoteEvent")
		r.Name = name
		r.Parent = folder
	end
end

local function makePlayerDataScript()
	local s = Instance.new("Script")
	s.Name = "TBP_PlayerData_Server"
	s.Source = [[
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local store = DataStoreService:GetDataStore("TycoonBuilderPro_v2")
local STARTING_CASH = 250
local session = {}

local function makeStats(player, data)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	stats.Parent = player

	local cash = Instance.new("IntValue")
	cash.Name = "Cash"
	cash.Value = data.Cash or STARTING_CASH
	cash.Parent = stats

	local gems = Instance.new("IntValue")
	gems.Name = "Gems"
	gems.Value = data.Gems or 0
	gems.Parent = stats

	local rebirths = Instance.new("IntValue")
	rebirths.Name = "Rebirths"
	rebirths.Value = data.Rebirths or 0
	rebirths.Parent = stats

	local tycoon = Instance.new("IntValue")
	tycoon.Name = "TycoonPlot"
	tycoon.Value = data.TycoonPlot or 0
	tycoon.Parent = player
end

local function load(player)
	local data = {
		Cash = STARTING_CASH,
		Gems = 0,
		Rebirths = 0,
		TycoonPlot = 0,
	}

	local ok, saved = pcall(function()
		return store:GetAsync("p_" .. player.UserId)
	end)

	if ok and type(saved) == "table" then
		for k, v in pairs(saved) do
			data[k] = v
		end
	end

	session[player] = data
	makeStats(player, data)
end

local function save(player)
	local data = session[player]
	if not data then return end

	local stats = player:FindFirstChild("leaderstats")
	if stats then
		data.Cash = stats.Cash.Value
		data.Gems = stats.Gems.Value
		data.Rebirths = stats.Rebirths.Value
	end

	local plot = player:FindFirstChild("TycoonPlot")
	if plot then
		data.TycoonPlot = plot.Value
	end

	pcall(function()
		store:SetAsync("p_" .. player.UserId, data)
	end)
end

Players.PlayerAdded:Connect(load)

Players.PlayerRemoving:Connect(function(player)
	save(player)
	session[player] = nil
end)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		save(player)
	end
end)
]]
	s.Parent = ServerScriptService
end

local function makeTycoonServerScript()
	local s = Instance.new("Script")
	s.Name = "TBP_Tycoon_Server"
	s.Source = [[
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotes = ReplicatedStorage:WaitForChild("TBP_Remotes")
local buyRemote = remotes:WaitForChild("BuyButton")
local collectRemote = remotes:WaitForChild("CollectCash")
local rebirthRemote = remotes:WaitForChild("Rebirth")

local PRODUCTS = {
	CashPackSmall = 1001,
	CashPackLarge = 1002,
	AutoCollect = 1003,
	TwoXCash = 1004,
	VIPOwner = 1005,
	SkipBuild = 1006,
}

local claimedPlots = {}

local function getCash(player)
	local stats = player:FindFirstChild("leaderstats")
	return stats and stats:FindFirstChild("Cash")
end

local function getGems(player)
	local stats = player:FindFirstChild("leaderstats")
	return stats and stats:FindFirstChild("Gems")
end

local function getRebirths(player)
	local stats = player:FindFirstChild("leaderstats")
	return stats and stats:FindFirstChild("Rebirths")
end

local function getPlotValue(player)
	return player:FindFirstChild("TycoonPlot")
end

local function payout(player, amount)
	local cash = getCash(player)
	local rebirths = getRebirths(player)
	if not cash then return end

	local multiplier = 1
	if rebirths then
		multiplier += rebirths.Value * 0.25
	end

	cash.Value += math.floor(amount * multiplier)
end

local function claimPlot(player, claimPad)
	local plotFolder = claimPad.Parent
	local plotId = plotFolder:GetAttribute("PlotId")
	if not plotId then return end

	local existing = getPlotValue(player)
	if existing and existing.Value ~= 0 then
		return
	end

	if claimedPlots[plotId] then
		return
	end

	claimedPlots[plotId] = player.UserId

	if existing then
		existing.Value = plotId
	end

	claimPad.Color = Color3.fromRGB(255, 210, 0)

	local ownerTag = claimPad:FindFirstChild("OwnerLabel")
	if ownerTag then
		ownerTag.Text = player.Name .. "'s Tycoon"
	end

	for _, obj in ipairs(plotFolder:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj:SetAttribute("OwnerUserId", player.UserId)
		end
	end
end

local function spawnDropperLoop(dropper)
	task.spawn(function()
		while dropper.Parent do
			task.wait(dropper:GetAttribute("Rate") or 2)

			if dropper.Transparency < 1 then
				local ownerId = dropper:GetAttribute("OwnerUserId")
				if ownerId and ownerId > 0 then
					local player = Players:GetPlayerByUserId(ownerId)
					if player then
						payout(player, dropper:GetAttribute("Value") or 10)
					end
				end
			end
		end
	end)
end

for _, obj in ipairs(workspace:GetDescendants()) do
	if obj:IsA("BasePart") and obj.Name == "DropperCore" then
		spawnDropperLoop(obj)
	end

	if obj:IsA("BasePart") and obj.Name == "ClaimPad" then
		obj.Touched:Connect(function(hit)
			local player = Players:GetPlayerFromCharacter(hit.Parent)
			if player then
				claimPlot(player, obj)
			end
		end)
	end
end

buyRemote.OnServerEvent:Connect(function(player, buttonPart)
	if typeof(buttonPart) ~= "Instance" then return end
	if not buttonPart:IsDescendantOf(workspace) then return end
	if buttonPart.Name ~= "BuyButton" then return end
	if buttonPart:GetAttribute("Purchased") then return end

	local ownerId = buttonPart:GetAttribute("OwnerUserId")
	if ownerId ~= player.UserId then
		return
	end

	local price = buttonPart:GetAttribute("Price") or 0
	local unlockName = buttonPart:GetAttribute("UnlockName")
	local cash = getCash(player)

	if not cash or cash.Value < price then
		return
	end

	cash.Value -= price

	buttonPart:SetAttribute("Purchased", true)
	buttonPart.Transparency = 1
	buttonPart.CanCollide = false

	local plotFolder = buttonPart.Parent

	for _, obj in ipairs(plotFolder:GetDescendants()) do
		if obj:GetAttribute("UnlockId") == unlockName then
			if obj:IsA("BasePart") then
				obj.Transparency = 0
				obj.CanCollide = true
				obj:SetAttribute("OwnerUserId", player.UserId)
			end
		end
	end
end)

collectRemote.OnServerEvent:Connect(function(player)
	payout(player, 75)
end)

rebirthRemote.OnServerEvent:Connect(function(player)
	local cash = getCash(player)
	local gems = getGems(player)
	local rebirths = getRebirths(player)
	if not cash or not gems or not rebirths then return end

	local cost = 25000 * math.max(1, rebirths.Value + 1)

	if cash.Value >= cost then
		cash.Value = 250
		rebirths.Value += 1
		gems.Value += 25
	end
end)

MarketplaceService.ProcessReceipt = function(receipt)
	local player = Players:GetPlayerByUserId(receipt.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local cash = getCash(player)
	if not cash then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	if receipt.ProductId == PRODUCTS.CashPackSmall then
		cash.Value += 5000
	elseif receipt.ProductId == PRODUCTS.CashPackLarge then
		cash.Value += 50000
	elseif receipt.ProductId == PRODUCTS.SkipBuild then
		cash.Value += 15000
	end

	return Enum.ProductPurchaseDecision.PurchaseGranted
end
]]
	s.Parent = ServerScriptService
end

local function makeClientGui()
	local gui = Instance.new("ScreenGui")
	gui.Name = "TBP_HUD"
	gui.ResetOnSpawn = false

	local frame = Instance.new("Frame")
	frame.Name = "Main"
	frame.Size = UDim2.fromOffset(300, 200)
	frame.Position = UDim2.fromOffset(20, 120)
	frame.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
	frame.BorderSizePixel = 0
	frame.Parent = gui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 18)
	corner.Parent = frame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, -20, 0, 36)
	title.Position = UDim2.fromOffset(10, 10)
	title.BackgroundTransparency = 1
	title.Text = "TYCOON BUILDER PRO"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBlack
	title.TextScaled = true
	title.Parent = frame

	local subtitle = Instance.new("TextLabel")
	subtitle.Size = UDim2.new(1, -20, 0, 36)
	subtitle.Position = UDim2.fromOffset(10, 50)
	subtitle.BackgroundTransparency = 1
	subtitle.Text = "Claim. Build. Rebirth. Scale."
	subtitle.TextColor3 = Color3.fromRGB(170, 220, 255)
	subtitle.Font = Enum.Font.GothamBold
	subtitle.TextScaled = true
	subtitle.Parent = frame

	local function makeButton(text, y, remoteName)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1, -30, 0, 40)
		b.Position = UDim2.fromOffset(15, y)
		b.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
		b.Text = text
		b.TextColor3 = Color3.new(1, 1, 1)
		b.Font = Enum.Font.GothamBlack
		b.TextScaled = true
		b.Parent = frame

		local bc = Instance.new("UICorner")
		bc.CornerRadius = UDim.new(0, 12)
		bc.Parent = b

		b.MouseButton1Click:Connect(function()
			game.ReplicatedStorage.TBP_Remotes[remoteName]:FireServer()
		end)
	end

	makeButton("Collect Bonus", 100, "CollectCash")
	makeButton("Rebirth", 146, "Rebirth")

	gui.Parent = StarterGui
end

local function makeClientButtonScript()
	local s = Instance.new("LocalScript")
	s.Name = "TBP_Button_Client"
	s.Source = [[
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remote = ReplicatedStorage:WaitForChild("TBP_Remotes"):WaitForChild("BuyButton")
local cooldown = {}

local function hook(part)
	if not part:IsA("BasePart") then return end
	if part.Name ~= "BuyButton" then return end

	part.Touched:Connect(function(hit)
		local character = player.Character
		if not character then return end
		if not hit:IsDescendantOf(character) then return end

		if cooldown[part] then return end
		cooldown[part] = true

		remote:FireServer(part)

		task.delay(0.75, function()
			cooldown[part] = nil
		end)
	end)
end

for _, obj in ipairs(workspace:GetDescendants()) do
	hook(obj)
end

workspace.DescendantAdded:Connect(hook)
]]
	s.Parent = StarterGui:WaitForChild("TBP_HUD")
end

local function makePlot(world, index)
	local angle = (index / CONFIG.TycoonCount) * math.pi * 2
	local x = math.cos(angle) * CONFIG.PlotSpacing
	local z = math.sin(angle) * CONFIG.PlotSpacing
	local origin = Vector3.new(x, 2, z)

	local plot = Instance.new("Folder")
	plot.Name = "TycoonPlot_" .. index
	plot:SetAttribute("PlotId", index)
	plot.Parent = world

	local base = part(
		plot,
		"PlotBase",
		Vector3.new(120, 2, 120),
		origin,
		Color3.fromRGB(45, 50, 65),
		Enum.Material.Metal
	)
	label(base, "TYCOON " .. index)

	local claim = part(
		plot,
		"ClaimPad",
		Vector3.new(22, 1, 22),
		origin + Vector3.new(0, 2, -42),
		Color3.fromRGB(0, 255, 140),
		Enum.Material.Neon
	)
	label(claim, "CLAIM TYCOON")

	local ownerText = Instance.new("StringValue")
	ownerText.Name = "OwnerLabel"
	ownerText.Value = "Unclaimed"
	ownerText.Parent = claim

	part(
		plot,
		"Conveyor",
		Vector3.new(75, 1, 8),
		origin + Vector3.new(0, 3, 0),
		Color3.fromRGB(30, 30, 35),
		Enum.Material.SmoothPlastic
	)

	local collector = part(
		plot,
		"Collector",
		Vector3.new(16, 10, 16),
		origin + Vector3.new(45, 8, 0),
		Color3.fromRGB(255, 220, 0),
		Enum.Material.Neon
	)
	label(collector, "COLLECTOR")

	for i = 1, 8 do
		local unlockId = "Dropper_" .. index .. "_" .. i
		local price = 100 * i * i

		local b = part(
			plot,
			"BuyButton",
			Vector3.new(10, 1, 10),
			origin + Vector3.new(-45, 3, -36 + i * 8),
			Color3.fromRGB(0, 170, 255),
			Enum.Material.Neon
		)
		b:SetAttribute("Price", price)
		b:SetAttribute("UnlockName", unlockId)
		b:SetAttribute("OwnerUserId", 0)
		label(b, "$" .. price .. " Dropper " .. i)

		local d = part(
			plot,
			"DropperCore",
			Vector3.new(8, 12, 8),
			origin + Vector3.new(-32 + i * 8, 11, -18),
			Color3.fromRGB(160, 90, 255),
			Enum.Material.Neon
		)
		d:SetAttribute("UnlockId", unlockId)
		d:SetAttribute("OwnerUserId", 0)
		d:SetAttribute("Rate", math.max(0.5, 2.2 - i * 0.15))
		d:SetAttribute("Value", 10 * i)
		d.Transparency = 1
		d.CanCollide = false
	end

	for i = 1, 5 do
		local unlockId = "Wall_" .. index .. "_" .. i
		local price = 500 * i

		local b = part(
			plot,
			"BuyButton",
			Vector3.new(10, 1, 10),
			origin + Vector3.new(45, 3, -34 + i * 10),
			Color3.fromRGB(255, 120, 0),
			Enum.Material.Neon
		)
		b:SetAttribute("Price", price)
		b:SetAttribute("UnlockName", unlockId)
		b:SetAttribute("OwnerUserId", 0)
		label(b, "$" .. price .. " Wall " .. i)

		local wall = part(
			plot,
			"FactoryWall",
			Vector3.new(95, 18, 2),
			origin + Vector3.new(0, 12, -58 + i * 6),
			Color3.fromRGB(70, 80, 100),
			Enum.Material.Metal
		)
		wall:SetAttribute("UnlockId", unlockId)
		wall.Transparency = 1
		wall.CanCollide = false
	end

	local roofButton = part(
		plot,
		"BuyButton",
		Vector3.new(12, 1, 12),
		origin + Vector3.new(0, 3, 45),
		Color3.fromRGB(255, 0, 180),
		Enum.Material.Neon
	)
	roofButton:SetAttribute("Price", 10000)
	roofButton:SetAttribute("UnlockName", "Roof_" .. index)
	roofButton:SetAttribute("OwnerUserId", 0)
	label(roofButton, "$10000 MEGA ROOF")

	local roof = part(
		plot,
		"FactoryRoof",
		Vector3.new(105, 3, 105),
		origin + Vector3.new(0, 26, 0),
		Color3.fromRGB(30, 25, 45),
		Enum.Material.Metal
	)
	roof:SetAttribute("UnlockId", "Roof_" .. index)
	roof.Transparency = 1
	roof.CanCollide = false
end

local function makeLobby(world)
	local lobby = Instance.new("Folder")
	lobby.Name = "CentralLobby"
	lobby.Parent = world

	part(
		lobby,
		"LobbyBase",
		Vector3.new(120, 2, 120),
		Vector3.new(0, 1, 0),
		Color3.fromRGB(25, 25, 35),
		Enum.Material.Slate
	)

	local sign = part(
		lobby,
		"MainSign",
		Vector3.new(55, 18, 4),
		Vector3.new(0, 18, -55),
		Color3.fromRGB(0, 120, 255),
		Enum.Material.Neon
	)
	label(sign, "TYCOON BUILDER PRO")

	local vip = part(
		lobby,
		"VIPPortal",
		Vector3.new(18, 22, 3),
		Vector3.new(-38, 12, 38),
		Color3.fromRGB(255, 210, 0),
		Enum.Material.Neon
	)
	label(vip, "VIP AREA")

	local rebirth = part(
		lobby,
		"RebirthPortal",
		Vector3.new(18, 22, 3),
		Vector3.new(38, 12, 38),
		Color3.fromRGB(255, 0, 140),
		Enum.Material.Neon
	)
	label(rebirth, "REBIRTH SHOP")
end

local function makeObby(world)
	local obby = Instance.new("Folder")
	obby.Name = "BonusObby"
	obby.Parent = world

	for i = 1, 18 do
		local p = part(
			obby,
			"BonusObbyStage_" .. i,
			Vector3.new(14, 1, 14),
			Vector3.new(-220, 5 + i * 1.5, -80 + i * 16),
			Color3.fromHSV(i / 18, 0.9, 1),
			Enum.Material.Neon
		)
		label(p, "+" .. i * 25 .. " CASH")
	end

	local finish = part(
		obby,
		"BonusObbyFinish",
		Vector3.new(24, 2, 24),
		Vector3.new(-220, 38, 230),
		Color3.fromRGB(0, 255, 140),
		Enum.Material.Neon
	)
	label(finish, "FINISH BONUS")
end

local function makePetArea(world)
	local pets = Instance.new("Folder")
	pets.Name = "PetEggs"
	pets.Parent = world

	local names = {"Dog", "Cat", "Robot", "Dragon", "Galaxy Beast"}

	for i, name in ipairs(names) do
		local egg = part(
			pets,
			"Egg_" .. name,
			Vector3.new(12, 16, 12),
			Vector3.new(190, 9, -50 + i * 24),
			Color3.fromHSV(i / #names, 0.8, 1),
			Enum.Material.Neon
		)
		label(egg, name .. " Egg")
	end
end

local function makeLighting()
	Lighting.ClockTime = 20
	Lighting.Brightness = 3
	Lighting.Ambient = Color3.fromRGB(80, 90, 130)
	Lighting.OutdoorAmbient = Color3.fromRGB(40, 50, 90)

	local bloom = Instance.new("BloomEffect")
	bloom.Name = "TBP_Bloom"
	bloom.Intensity = 0.45
	bloom.Size = 32
	bloom.Threshold = 0.8
	bloom.Parent = Lighting

	local cc = Instance.new("ColorCorrectionEffect")
	cc.Name = "TBP_Color"
	cc.Contrast = 0.15
	cc.Saturation = 0.2
	cc.Parent = Lighting
end

local function makeExportNotes()
	local notes = Instance.new("ModuleScript")
	notes.Name = "TBP_EXPORT_NOTES"
	notes.Source = [[
return {
	Name = "Tycoon Builder Pro",
	Version = "2.0.0",

	Setup = {
		"Replace placeholder developer product IDs.",
		"Enable Studio API Services before testing DataStores.",
		"Publish the experience before testing purchases.",
		"Create gamepasses for VIP, Auto Collect, and 2x Cash.",
		"Tune BuyButton price attributes inside each plot.",
	},

	Monetization = {
		"Cash packs",
		"VIP area",
		"Skip build",
		"2x cash",
		"Auto collect",
		"Premium pet eggs",
	},

	ExpansionIdeas = {
		"Add raid/PvP tycoon attacks.",
		"Add seasonal leaderboard rewards.",
		"Add prestige islands.",
		"Add trading for pets.",
		"Add factory machine skins.",
	}
}
]]
	notes.Parent = ReplicatedStorage
end

local function generate()
	clearOld()

	local world = Instance.new("Folder")
	world.Name = "TycoonBuilderPro_World"
	world.Parent = workspace

	makeRemotes()
	makeLobby(world)

	for i = 1, CONFIG.TycoonCount do
		makePlot(world, i)
	end

	if CONFIG.EnableObbyBonus then
		makeObby(world)
	end

	if CONFIG.EnablePets then
		makePetArea(world)
	end

	makeLighting()
	makePlayerDataScript()
	makeTycoonServerScript()
	makeClientGui()
	makeClientButtonScript()
	makeExportNotes()

	Selection:Set({world})

	print("✅ Tycoon Builder Pro generated successfully.")
	print("Next: replace product IDs, publish, enable API services, then test in Play mode.")
end

button.Click:Connect(generate)
