-- Tycoon Builder Pro Ultimate Patch
-- Game Factory AI Studio Plugin
-- Adds animated cash drops, collectors, build dependencies, polish, and stronger ownership logic.

local toolbar = plugin:CreateToolbar("Game Factory AI")
local button = toolbar:CreateButton(
	"Tycoon Builder Ultimate",
	"Generate a polished Roblox tycoon with animated economy",
	"rbxassetid://4458901886"
)

local Selection = game:GetService("Selection")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")

local CONFIG = {
	TycoonCount = 6,
	PlotSpacing = 200,
	StartingCash = 250,
	BaseDropInterval = 2.2,
	EnableObbyBonus = true,
	EnablePets = true,
	EnablePolish = true,
	Theme = "CyberFactory"
}

local function clearOld()
	for _, service in ipairs({
		workspace,
		ServerScriptService,
		ReplicatedStorage,
		StarterGui,
		SoundService,
	}) do
		for _, obj in ipairs(service:GetChildren()) do
			if obj.Name:match("^TBP_") or obj.Name == "TycoonBuilderPro_World" then
				obj:Destroy()
			end
		end
	end

	for _, obj in ipairs(Lighting:GetChildren()) do
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

local function neon(parent, name, size, pos, color)
	return part(parent, name, size, pos, color, Enum.Material.Neon)
end

local function label(target, text, offset)
	local gui = Instance.new("BillboardGui")
	gui.Name = "TBP_Label"
	gui.Size = UDim2.fromOffset(280, 80)
	gui.StudsOffset = offset or Vector3.new(0, 5, 0)
	gui.AlwaysOnTop = true
	gui.Parent = target

	local t = Instance.new("TextLabel")
	t.Name = "Text"
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.Text = text
	t.TextScaled = true
	t.TextColor3 = Color3.new(1, 1, 1)
	t.TextStrokeTransparency = 0.35
	t.Font = Enum.Font.GothamBlack
	t.Parent = gui

	return t
end

local function makeRemotes()
	local folder = Instance.new("Folder")
	folder.Name = "TBP_Remotes"
	folder.Parent = ReplicatedStorage

	for _, name in ipairs({
		"RequestBuy",
		"RequestCollect",
		"RequestRebirth",
		"Notify",
		"PurchaseFX"
	}) do
		local r = Instance.new("RemoteEvent")
		r.Name = name
		r.Parent = folder
	end
end

local function makeSharedConfig()
	local config = Instance.new("ModuleScript")
	config.Name = "TBP_Config"
	config.Source = [[
return {
	StartingCash = 250,

	Products = {
		CashPackSmall = 1001,
		CashPackLarge = 1002,
		AutoCollect = 1003,
		TwoXCash = 1004,
		VIPOwner = 1005,
		SkipBuild = 1006,
	},

	Gamepasses = {
		VIP = 2001,
		TwoXCash = 2002,
		AutoCollect = 2003,
	},

	Balance = {
		RebirthBaseCost = 25000,
		RebirthMultiplierBonus = 0.25,
		CollectorBankCap = 1000000,
	}
}
]]
	config.Parent = ReplicatedStorage
end

local function makePlayerDataScript()
	local s = Instance.new("Script")
	s.Name = "TBP_PlayerData_Server"
	s.Source = [[
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local Config = require(game.ReplicatedStorage:WaitForChild("TBP_Config"))

local store = DataStoreService:GetDataStore("TycoonBuilderPro_Ultimate_v1")
local session = {}

local function defaultData()
	return {
		Cash = Config.StartingCash,
		Gems = 0,
		Rebirths = 0,
		TycoonPlot = 0,
		OwnedUnlocks = {},
	}
end

local function makeStats(player, data)
	local stats = Instance.new("Folder")
	stats.Name = "leaderstats"
	stats.Parent = player

	for _, item in ipairs({
		{"Cash", data.Cash or Config.StartingCash},
		{"Gems", data.Gems or 0},
		{"Rebirths", data.Rebirths or 0},
	}) do
		local v = Instance.new("IntValue")
		v.Name = item[1]
		v.Value = item[2]
		v.Parent = stats
	end

	local plot = Instance.new("IntValue")
	plot.Name = "TycoonPlot"
	plot.Value = data.TycoonPlot or 0
	plot.Parent = player

	local bank = Instance.new("IntValue")
	bank.Name = "TycoonBank"
	bank.Value = 0
	bank.Parent = player
end

local function load(player)
	local data = defaultData()

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

_G.TBP_GetSession = function(player)
	return session[player]
end
]]
	s.Parent = ServerScriptService
end

local function makeTycoonServerScript()
	local s = Instance.new("Script")
	s.Name = "TBP_Tycoon_Server"
	s.Source = [[
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage:WaitForChild("TBP_Config"))
local remotes = ReplicatedStorage:WaitForChild("TBP_Remotes")

local RequestBuy = remotes:WaitForChild("RequestBuy")
local RequestCollect = remotes:WaitForChild("RequestCollect")
local RequestRebirth = remotes:WaitForChild("RequestRebirth")
local Notify = remotes:WaitForChild("Notify")
local PurchaseFX = remotes:WaitForChild("PurchaseFX")

local claimed = {}

local function stats(player)
	return player:FindFirstChild("leaderstats")
end

local function cash(player)
	local s = stats(player)
	return s and s:FindFirstChild("Cash")
end

local function gems(player)
	local s = stats(player)
	return s and s:FindFirstChild("Gems")
end

local function rebirths(player)
	local s = stats(player)
	return s and s:FindFirstChild("Rebirths")
end

local function bank(player)
	return player:FindFirstChild("TycoonBank")
end

local function plotValue(player)
	return player:FindFirstChild("TycoonPlot")
end

local function ownedMultiplier(player)
	local r = rebirths(player)
	local mult = 1
	if r then
		mult += r.Value * Config.Balance.RebirthMultiplierBonus
	end
	return mult
end

local function notify(player, message)
	Notify:FireClient(player, message)
end

local function setVisible(obj, visible)
	if obj:IsA("BasePart") then
		obj.Transparency = visible and 0 or 1
		obj.CanCollide = visible
		obj.CanTouch = visible
	elseif obj:IsA("Model") then
		for _, d in ipairs(obj:GetDescendants()) do
			if d:IsA("BasePart") then
				d.Transparency = visible and 0 or 1
				d.CanCollide = visible
				d.CanTouch = visible
			end
		end
	end
end

local function claimPlot(player, claimPad)
	local plot = claimPad.Parent
	local id = plot:GetAttribute("PlotId")
	if not id then return end

	local pv = plotValue(player)
	if not pv or pv.Value ~= 0 then
		notify(player, "You already own a tycoon.")
		return
	end

	if claimed[id] then
		notify(player, "That tycoon is already claimed.")
		return
	end

	claimed[id] = player.UserId
	pv.Value = id
	plot:SetAttribute("OwnerUserId", player.UserId)

	for _, obj in ipairs(plot:GetDescendants()) do
		if obj:IsA("BasePart") then
			obj:SetAttribute("OwnerUserId", player.UserId)
		end
	end

	claimPad.Color = Color3.fromRGB(255, 220, 0)
	local lbl = claimPad:FindFirstChild("TBP_Label")
	if lbl and lbl:FindFirstChild("Text") then
		lbl.Text.Text = player.Name .. "'s Tycoon"
	end

	notify(player, "Tycoon claimed.")
end

local function spawnCashPart(dropper)
	local ownerId = dropper:GetAttribute("OwnerUserId")
	if not ownerId or ownerId <= 0 then return end

	local player = Players:GetPlayerByUserId(ownerId)
	if not player then return end

	local value = dropper:GetAttribute("Value") or 10
	local plot = dropper.Parent
	local target = plot:FindFirstChild("Collector")

	local cashPart = Instance.new("Part")
	cashPart.Name = "TBP_CashDrop"
	cashPart.Size = Vector3.new(2, 1, 2)
	cashPart.Color = Color3.fromRGB(0, 255, 120)
	cashPart.Material = Enum.Material.Neon
	cashPart.Anchored = true
	cashPart.CanCollide = false
	cashPart.Position = dropper.Position - Vector3.new(0, 8, 0)
	cashPart.Parent = workspace

	local endPos = target and target.Position + Vector3.new(0, 4, 0) or cashPart.Position + Vector3.new(20, 0, 0)

	local tween = TweenService:Create(
		cashPart,
		TweenInfo.new(1.2, Enum.EasingStyle.Linear),
		{Position = endPos}
	)
	tween:Play()

	tween.Completed:Connect(function()
		local b = bank(player)
		if b then
			b.Value = math.min(
				Config.Balance.CollectorBankCap,
				b.Value + math.floor(value * ownedMultiplier(player))
			)
		end
		cashPart:Destroy()
	end)

	Debris:AddItem(cashPart, 3)
end

local function startDropper(dropper)
	task.spawn(function()
		while dropper.Parent do
			task.wait(dropper:GetAttribute("Rate") or 2)
			if dropper.Transparency < 1 then
				spawnCashPart(dropper)
			end
		end
	end)
end

for _, obj in ipairs(workspace:GetDescendants()) do
	if obj:IsA("BasePart") and obj.Name == "ClaimPad" then
		obj.Touched:Connect(function(hit)
			local player = Players:GetPlayerFromCharacter(hit.Parent)
			if player then
				claimPlot(player, obj)
			end
		end)
	end

	if obj:IsA("BasePart") and obj.Name == "DropperCore" then
		startDropper(obj)
	end
end

RequestBuy.OnServerEvent:Connect(function(player, button)
	if typeof(button) ~= "Instance" then return end
	if not button:IsDescendantOf(workspace) then return end
	if button.Name ~= "BuyButton" then return end
	if button:GetAttribute("Purchased") then return end

	local ownerId = button:GetAttribute("OwnerUserId")
	if ownerId ~= player.UserId then
		notify(player, "Claim this tycoon first.")
		return
	end

	local required = button:GetAttribute("Requires")
	if required and required ~= "" then
		local plot = button.Parent
		local found = false

		for _, obj in ipairs(plot:GetDescendants()) do
			if obj:GetAttribute("UnlockId") == required and obj:GetAttribute("Built") then
				found = true
				break
			end
		end

		if not found then
			notify(player, "Buy the previous upgrade first.")
			return
		end
	end

	local price = button:GetAttribute("Price") or 0
	local c = cash(player)
	if not c or c.Value < price then
		notify(player, "Not enough cash.")
		return
	end

	c.Value -= price
	button:SetAttribute("Purchased", true)

	button.Transparency = 1
	button.CanCollide = false
	button.CanTouch = false

	local unlockName = button:GetAttribute("UnlockName")
	local plot = button.Parent

	for _, obj in ipairs(plot:GetDescendants()) do
		if obj:GetAttribute("UnlockId") == unlockName then
			obj:SetAttribute("Built", true)
			setVisible(obj, true)

			if obj:IsA("BasePart") then
				obj:SetAttribute("OwnerUserId", player.UserId)
			end
		end
	end

	PurchaseFX:FireClient(player, button.Position)
	notify(player, "Purchased upgrade.")
end)

RequestCollect.OnServerEvent:Connect(function(player)
	local b = bank(player)
	local c = cash(player)
	if not b or not c then return end

	if b.Value <= 0 then
		notify(player, "Collector is empty.")
		return
	end

	c.Value += b.Value
	notify(player, "Collected $" .. b.Value)
	b.Value = 0
end)

RequestRebirth.OnServerEvent:Connect(function(player)
	local c = cash(player)
	local g = gems(player)
	local r = rebirths(player)
	if not c or not g or not r then return end

	local cost = Config.Balance.RebirthBaseCost * math.max(1, r.Value + 1)
	if c.Value < cost then
		notify(player, "Need $" .. cost .. " to rebirth.")
		return
	end

	c.Value = Config.StartingCash
	g.Value += 25
	r.Value += 1

	notify(player, "Rebirth complete. Multiplier increased.")
end)

MarketplaceService.ProcessReceipt = function(receipt)
	local player = Players:GetPlayerByUserId(receipt.PlayerId)
	if not player then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local c = cash(player)
	if not c then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	if receipt.ProductId == Config.Products.CashPackSmall then
		c.Value += 5000
	elseif receipt.ProductId == Config.Products.CashPackLarge then
		c.Value += 50000
	elseif receipt.ProductId == Config.Products.SkipBuild then
		c.Value += 15000
	end

	return Enum.ProductPurchaseDecision.PurchaseGranted
end
]]
	s.Parent = ServerScriptService
end

local function makeClientScript()
	local s = Instance.new("LocalScript")
	s.Name = "TBP_Client"
	s.Source = [[
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("TBP_Remotes")

local RequestBuy = remotes:WaitForChild("RequestBuy")
local RequestCollect = remotes:WaitForChild("RequestCollect")
local RequestRebirth = remotes:WaitForChild("RequestRebirth")
local Notify = remotes:WaitForChild("Notify")
local PurchaseFX = remotes:WaitForChild("PurchaseFX")

local gui = Instance.new("ScreenGui")
gui.Name = "TBP_HUD_Runtime"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local main = Instance.new("Frame")
main.Size = UDim2.fromOffset(320, 230)
main.Position = UDim2.fromOffset(20, 110)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 24)
main.BorderSizePixel = 0
main.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 18)
corner.Parent = main

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 0, 36)
title.Position = UDim2.fromOffset(10, 10)
title.BackgroundTransparency = 1
title.Text = "TYCOON BUILDER PRO"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Font = Enum.Font.GothamBlack
title.Parent = main

local bankLabel = Instance.new("TextLabel")
bankLabel.Size = UDim2.new(1, -20, 0, 36)
bankLabel.Position = UDim2.fromOffset(10, 52)
bankLabel.BackgroundTransparency = 1
bankLabel.Text = "Bank: $0"
bankLabel.TextColor3 = Color3.fromRGB(0, 255, 160)
bankLabel.TextScaled = true
bankLabel.Font = Enum.Font.GothamBold
bankLabel.Parent = main

local toast = Instance.new("TextLabel")
toast.Size = UDim2.fromOffset(420, 50)
toast.Position = UDim2.new(0.5, -210, 0, 30)
toast.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
toast.TextColor3 = Color3.new(1, 1, 1)
toast.TextScaled = true
toast.Font = Enum.Font.GothamBlack
toast.Text = ""
toast.Visible = false
toast.Parent = gui

local toastCorner = Instance.new("UICorner")
toastCorner.CornerRadius = UDim.new(0, 14)
toastCorner.Parent = toast

local function makeButton(text, y, callback)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -30, 0, 42)
	b.Position = UDim2.fromOffset(15, y)
	b.BackgroundColor3 = Color3.fromRGB(0, 160, 255)
	b.Text = text
	b.TextColor3 = Color3.new(1, 1, 1)
	b.TextScaled = true
	b.Font = Enum.Font.GothamBlack
	b.Parent = main

	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 12)
	c.Parent = b

	b.MouseButton1Click:Connect(callback)
end

makeButton("Collect Bank", 96, function()
	RequestCollect:FireServer()
end)

makeButton("Rebirth", 144, function()
	RequestRebirth:FireServer()
end)

makeButton("Store / Products", 190, function()
	toast.Visible = true
	toast.Text = "Replace product IDs before enabling purchases."
	task.delay(2, function()
		toast.Visible = false
	end)
end)

local bank = player:WaitForChild("TycoonBank")
bank:GetPropertyChangedSignal("Value"):Connect(function()
	bankLabel.Text = "Bank: $" .. bank.Value
end)

local cooldown = {}

local function hookButton(part)
	if not part:IsA("BasePart") or part.Name ~= "BuyButton" then return end

	part.Touched:Connect(function(hit)
		local char = player.Character
		if not char or not hit:IsDescendantOf(char) then return end
		if cooldown[part] then return end

		cooldown[part] = true
		RequestBuy:FireServer(part)

		task.delay(0.6, function()
			cooldown[part] = nil
		end)
	end)
end

for _, obj in ipairs(workspace:GetDescendants()) do
	hookButton(obj)
end

workspace.DescendantAdded:Connect(hookButton)

Notify.OnClientEvent:Connect(function(message)
	toast.Visible = true
	toast.Text = tostring(message)
	task.delay(2, function()
		toast.Visible = false
	end)
end)

PurchaseFX.OnClientEvent:Connect(function(pos)
	local marker = Instance.new("Part")
	marker.Anchored = true
	marker.CanCollide = false
	marker.Material = Enum.Material.Neon
	marker.Color = Color3.fromRGB(0, 255, 180)
	marker.Shape = Enum.PartType.Ball
	marker.Size = Vector3.new(2, 2, 2)
	marker.Position = pos + Vector3.new(0, 4, 0)
	marker.Parent = workspace

	local tween = TweenService:Create(
		marker,
		TweenInfo.new(0.45, Enum.EasingStyle.Back),
		{Size = Vector3.new(12, 12, 12), Transparency = 1}
	)
	tween:Play()
	tween.Completed:Connect(function()
		marker:Destroy()
	end)
end)
]]
	s.Parent = StarterGui
end

local function makePlot(world, index)
	local angle = (index / CONFIG.TycoonCount) * math.pi * 2
	local origin = Vector3.new(
		math.cos(angle) * CONFIG.PlotSpacing,
		2,
		math.sin(angle) * CONFIG.PlotSpacing
	)

	local plot = Instance.new("Folder")
	plot.Name = "TycoonPlot_" .. index
	plot:SetAttribute("PlotId", index)
	plot:SetAttribute("OwnerUserId", 0)
	plot.Parent = world

	local base = part(plot, "PlotBase", Vector3.new(130, 2, 130), origin, Color3.fromRGB(42, 48, 65), Enum.Material.Metal)
	label(base, "TYCOON " .. index)

	local trim1 = neon(plot, "NeonTrim_A", Vector3.new(132, 1, 2), origin + Vector3.new(0, 2, -66), Color3.fromRGB(0, 180, 255))
	local trim2 = neon(plot, "NeonTrim_B", Vector3.new(132, 1, 2), origin + Vector3.new(0, 2, 66), Color3.fromRGB(0, 180, 255))
	local trim3 = neon(plot, "NeonTrim_C", Vector3.new(2, 1, 132), origin + Vector3.new(-66, 2, 0), Color3.fromRGB(0, 180, 255))
	local trim4 = neon(plot, "NeonTrim_D", Vector3.new(2, 1, 132), origin + Vector3.new(66, 2, 0), Color3.fromRGB(0, 180, 255))

	local claim = neon(plot, "ClaimPad", Vector3.new(24, 1, 24), origin + Vector3.new(0, 3, -46), Color3.fromRGB(0, 255, 140))
	label(claim, "CLAIM TYCOON")

	part(plot, "Conveyor", Vector3.new(85, 1, 9), origin + Vector3.new(0, 4, 0), Color3.fromRGB(26, 26, 32), Enum.Material.SmoothPlastic)

	local collector = neon(plot, "Collector", Vector3.new(18, 12, 18), origin + Vector3.new(50, 10, 0), Color3.fromRGB(255, 220, 0))
	label(collector, "COLLECTOR")

	local previousUnlock = ""

	for i = 1, 10 do
		local unlockId = "Dropper_" .. index .. "_" .. i
		local price = 100 * i * i
		local x = -40 + i * 8

		local b = neon(plot, "BuyButton", Vector3.new(10, 1, 10), origin + Vector3.new(-55, 4, -42 + i * 8), Color3.fromRGB(0, 170, 255))
		b:SetAttribute("Price", price)
		b:SetAttribute("UnlockName", unlockId)
		b:SetAttribute("OwnerUserId", 0)
		b:SetAttribute("Requires", previousUnlock)
		label(b, "$" .. price .. "\nDropper " .. i)

		local d = neon(plot, "DropperCore", Vector3.new(7, 11, 7), origin + Vector3.new(x, 12, -20), Color3.fromRGB(155, 90, 255))
		d:SetAttribute("UnlockId", unlockId)
		d:SetAttribute("OwnerUserId", 0)
		d:SetAttribute("Rate", math.max(0.45, CONFIG.BaseDropInterval - i * 0.14))
		d:SetAttribute("Value", 10 * i)
		d.Transparency = 1
		d.CanCollide = false
		d.CanTouch = false

		local pipe = part(plot, "DropperPipe", Vector3.new(4, 8, 4), origin + Vector3.new(x, 8, -12), Color3.fromRGB(85, 95, 120), Enum.Material.Metal)
		pipe:SetAttribute("UnlockId", unlockId)
		pipe.Transparency = 1
		pipe.CanCollide = false
		pipe.CanTouch = false

		previousUnlock = unlockId
	end

	for i = 1, 6 do
		local unlockId = "FactoryWall_" .. index .. "_" .. i
		local price = 600 * i

		local b = neon(plot, "BuyButton", Vector3.new(10, 1, 10), origin + Vector3.new(55, 4, -44 + i * 10), Color3.fromRGB(255, 120, 0))
		b:SetAttribute("Price", price)
		b:SetAttribute("UnlockName", unlockId)
		b:SetAttribute("OwnerUserId", 0)
		b:SetAttribute("Requires", i == 1 and "Dropper_" .. index .. "_2" or "FactoryWall_" .. index .. "_" .. (i - 1))
		label(b, "$" .. price .. "\nWall " .. i)

		local wall = part(plot, "FactoryWall", Vector3.new(110, 18, 2), origin + Vector3.new(0, 13, -62 + i * 8), Color3.fromRGB(70, 80, 105), Enum.Material.Metal)
		wall:SetAttribute("UnlockId", unlockId)
		wall.Transparency = 1
		wall.CanCollide = false
		wall.CanTouch = false
	end

	local roofButton = neon(plot, "BuyButton", Vector3.new(12, 1, 12), origin + Vector3.new(0, 4, 52), Color3.fromRGB(255, 0, 180))
	roofButton:SetAttribute("Price", 12000)
	roofButton:SetAttribute("UnlockName", "MegaRoof_" .. index)
	roofButton:SetAttribute("OwnerUserId", 0)
	roofButton:SetAttribute("Requires", "FactoryWall_" .. index .. "_6")
	label(roofButton, "$12000\nMEGA ROOF")

	local roof = part(plot, "MegaRoof", Vector3.new(116, 3, 116), origin + Vector3.new(0, 29, 0), Color3.fromRGB(25, 22, 40), Enum.Material.Metal)
	roof:SetAttribute("UnlockId", "MegaRoof_" .. index)
	roof.Transparency = 1
	roof.CanCollide = false
	roof.CanTouch = false

	for i = 1, 4 do
		local unlockId = "MachineUpgrade_" .. index .. "_" .. i
		local price = 5000 * i

		local b = neon(plot, "BuyButton", Vector3.new(11, 1, 11), origin + Vector3.new(-20 + i * 12, 4, 54), Color3.fromRGB(80, 255, 90))
		b:SetAttribute("Price", price)
		b:SetAttribute("UnlockName", unlockId)
		b:SetAttribute("OwnerUserId", 0)
		b:SetAttribute("Requires", "Dropper_" .. index .. "_" .. math.min(10, i + 4))
		label(b, "$" .. price .. "\nMachine Tier " .. i)

		local machine = neon(plot, "MegaMachine", Vector3.new(10, 16, 10), origin + Vector3.new(-20 + i * 12, 13, 24), Color3.fromRGB(80, 255, 90))
		machine:SetAttribute("UnlockId", unlockId)
		machine:SetAttribute("OwnerUserId", 0)
		machine:SetAttribute("Value", 250 * i)
		machine.Transparency = 1
		machine.CanCollide = false
		machine.CanTouch = false
	end
end

local function makeLobby(world)
	local lobby = Instance.new("Folder")
	lobby.Name = "TBP_CentralLobby"
	lobby.Parent = world

	part(lobby, "LobbyBase", Vector3.new(140, 2, 140), Vector3.new(0, 1, 0), Color3.fromRGB(24, 24, 34), Enum.Material.Slate)

	local sign = neon(lobby, "MainSign", Vector3.new(62, 20, 4), Vector3.new(0, 20, -66), Color3.fromRGB(0, 125, 255))
	label(sign, "TYCOON BUILDER\nULTIMATE", Vector3.new(0, 8, 0))

	local vip = neon(lobby, "VIPPortal", Vector3.new(20, 24, 3), Vector3.new(-45, 14, 45), Color3.fromRGB(255, 220, 0))
	label(vip, "VIP AREA")

	local rebirth = neon(lobby, "RebirthPortal", Vector3.new(20, 24, 3), Vector3.new(45, 14, 45), Color3.fromRGB(255, 0, 160))
	label(rebirth, "REBIRTH SHOP")

	local store = neon(lobby, "StorePortal", Vector3.new(20, 24, 3), Vector3.new(0, 14, 55), Color3.fromRGB(0, 255, 180))
	label(store, "STORE")
end

local function makeObby(world)
	local obby = Instance.new("Folder")
	obby.Name = "TBP_BonusObby"
	obby.Parent = world

	for i = 1, 22 do
		local p = neon(
			obby,
			"BonusStage_" .. i,
			Vector3.new(14, 1, 14),
			Vector3.new(-245, 5 + i * 1.35, -100 + i * 15),
			Color3.fromHSV(i / 22, 0.9, 1)
		)
		label(p, "+" .. i * 25 .. " CASH")
	end

	local lava = neon(obby, "LavaFloor", Vector3.new(50, 1, 360), Vector3.new(-245, 1, 70), Color3.fromRGB(255, 60, 0))
	label(lava, "BONUS OBBY")

	local finish = neon(obby, "FinishBonus", Vector3.new(26, 2, 26), Vector3.new(-245, 38, 245), Color3.fromRGB(0, 255, 140))
	label(finish, "FINISH BONUS")
end

local function makePetArea(world)
	local pets = Instance.new("Folder")
	pets.Name = "TBP_PetEggs"
	pets.Parent = world

	local names = {"Dog", "Cat", "Robot", "Dragon", "Galaxy Beast", "Void Hydra"}

	for i, name in ipairs(names) do
		local egg = neon(
			pets,
			"Egg_" .. name,
			Vector3.new(13, 17, 13),
			Vector3.new(220, 10, -75 + i * 25),
			Color3.fromHSV(i / #names, 0.85, 1)
		)
		label(egg, name .. "\nEgg")
	end
end

local function makePolish()
	Lighting.ClockTime = 20
	Lighting.Brightness = 3
	Lighting.Ambient = Color3.fromRGB(80, 90, 130)
	Lighting.OutdoorAmbient = Color3.fromRGB(40, 50, 90)
	Lighting.EnvironmentDiffuseScale = 0.45
	Lighting.EnvironmentSpecularScale = 0.8

	local bloom = Instance.new("BloomEffect")
	bloom.Name = "TBP_Bloom"
	bloom.Intensity = 0.55
	bloom.Size = 32
	bloom.Threshold = 0.8
	bloom.Parent = Lighting

	local cc = Instance.new("ColorCorrectionEffect")
	cc.Name = "TBP_Color"
	cc.Contrast = 0.18
	cc.Saturation = 0.22
	cc.Parent = Lighting

	local blur = Instance.new("DepthOfFieldEffect")
	blur.Name = "TBP_DOF"
	blur.FarIntensity = 0.15
	blur.FocusDistance = 80
	blur.InFocusRadius = 60
	blur.Parent = Lighting
end

local function makeExportNotes()
	local notes = Instance.new("ModuleScript")
	notes.Name = "TBP_EXPORT_NOTES"
	notes.Source = [[
return {
	Name = "Tycoon Builder Pro Ultimate",
	Version = "3.0.0",

	Core = {
		"Claimable tycoon plots",
		"Per-player ownership locks",
		"Animated cash drops",
		"Collector bank",
		"Dependency-based build buttons",
		"Rebirth multiplier",
		"DataStore-ready player data",
		"Developer product receipt handler",
	},

	BeforePublishing = {
		"Replace product IDs in TBP_Config.",
		"Replace gamepass IDs in TBP_Config.",
		"Enable Studio API Services.",
		"Publish experience before purchase testing.",
		"Test with 2 players to validate plot ownership.",
	},

	SellablePluginChecklist = {
		"Add icon",
		"Add screenshots",
		"Record demo video",
		"Write install guide",
		"Add free/pro gating",
		"Bundle with Game Factory AI Studio",
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

	makeSharedConfig()
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

	if CONFIG.EnablePolish then
		makePolish()
	end

	makePlayerDataScript()
	makeTycoonServerScript()
	makeClientScript()
	makeExportNotes()

	Selection:Set({world})

	print("✅ Tycoon Builder Pro Ultimate generated.")
	print("Includes: claims, ownership locks, animated cash, bank collector, dependencies, rebirths, polish.")
end

button.Click:Connect(generate)
