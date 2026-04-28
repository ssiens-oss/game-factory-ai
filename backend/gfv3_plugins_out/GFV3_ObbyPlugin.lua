print("GAME FACTORY AI PLUGIN LOADED: Obby Maker")

local toolbar = plugin:CreateToolbar("Game Factory AI")
local buildBtn = toolbar:CreateButton("Obby Maker", "Generate Obby Maker game", "")
local clearBtn = toolbar:CreateButton("Clear Obby Maker", "Clear generated Obby Maker content", "")

local PREFIX = "GF_Obby" .. "_"

local S = {
	Workspace = game:GetService("Workspace"),
	ServerScriptService = game:GetService("ServerScriptService"),
	ReplicatedStorage = game:GetService("ReplicatedStorage"),
	StarterGui = game:GetService("StarterGui"),
	Lighting = game:GetService("Lighting"),
}

local C = {
	blue = Color3.fromRGB(0,190,255),
	pink = Color3.fromRGB(255,60,210),
	yellow = Color3.fromRGB(255,220,0),
	green = Color3.fromRGB(0,255,130),
	red = Color3.fromRGB(255,50,45),
	purple = Color3.fromRGB(150,80,255),
	dark = Color3.fromRGB(8,8,18),
	gray = Color3.fromRGB(38,38,48),
}

local function clearService(service)
	for _, obj in ipairs(service:GetChildren()) do
		if obj.Name:match("^" .. PREFIX) then
			obj:Destroy()
		end
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
	p.Color = color or C.blue
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
	gui.Size = UDim2.fromOffset(230, 52)
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

local function baseplate()
	part("Baseplate", Vector3.new(0,-2,0), Vector3.new(420,1,420), C.gray, Enum.Material.Metal)
	local spawn = part("Spawn", Vector3.new(0,2,0), Vector3.new(24,1,24), C.green)
	label(spawn, "SPAWN")
end

local function coin(pos, value)
	local c = part("Coin", pos, Vector3.new(2,2,.35), C.yellow)
	c.Shape = Enum.PartType.Cylinder
	c.Orientation = Vector3.new(0,0,90)
	glow(c,10,2)
	scriptIn(c,"Coin",[[ 
local busy = false
script.Parent.Touched:Connect(function(hit)
	if busy then return end
	local p = game.Players:GetPlayerFromCharacter(hit.Parent)
	if not p then return end
	busy = true
	local s = p:FindFirstChild("leaderstats")
	if s then
		s.Coins.Value += VALUE_REPLACE
		s.XP.Value += 5
	end
	script.Parent.Transparency = 1
	script.Parent.CanTouch = false
	task.wait(5)
	script.Parent.Transparency = 0
	script.Parent.CanTouch = true
	busy = false
end)
while true do
	script.Parent.CFrame *= CFrame.Angles(0, math.rad(5), 0)
	task.wait()
end
]],false)
	c.GFTemp = nil
	c:FindFirstChild(PREFIX .. "Coin").Source = c:FindFirstChild(PREFIX .. "Coin").Source:gsub("VALUE_REPLACE", tostring(value or 10))
end

local function killBrick(name, pos, size)
	local k = part(name, pos, size, C.red)
	glow(k,16,2)
	scriptIn(k,"Kill",[[ 
script.Parent.Touched:Connect(function(hit)
	local h = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
	if h then h.Health = 0 end
end)
]],false)
end

local function setupRuntime()
	local remotes = Instance.new("Folder")
	remotes.Name = PREFIX .. "Remotes"
	remotes.Parent = S.ReplicatedStorage

	local claim = Instance.new("RemoteEvent")
	claim.Name = "Claim"
	claim.Parent = remotes

	local buy = Instance.new("RemoteEvent")
	buy.Name = "Buy"
	buy.Parent = remotes

	scriptIn(S.ServerScriptService, "Runtime", [[
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PREFIX = "]] .. PREFIX .. [["
local Remotes = ReplicatedStorage:WaitForChild(PREFIX .. "Remotes")

local function stat(parent, className, name, value)
	local v = Instance.new(className)
	v.Name = name
	v.Value = value
	v.Parent = parent
	return v
end

Players.PlayerAdded:Connect(function(player)
	local s = Instance.new("Folder")
	s.Name = "leaderstats"
	s.Parent = player

	stat(s,"IntValue","Coins",0)
	stat(s,"IntValue","Gems",0)
	stat(s,"IntValue","Cash",0)
	stat(s,"IntValue","Level",1)
	stat(s,"IntValue","XP",0)
	stat(s,"IntValue","Wins",0)
	stat(s,"IntValue","Kills",0)
	stat(s,"IntValue","Pets",0)
end)

Remotes.Claim.OnServerEvent:Connect(function(player)
	local s = player:FindFirstChild("leaderstats")
	if s then
		s.Coins.Value += 250
		s.Gems.Value += 5
		s.XP.Value += 100
	end
end)

Remotes.Buy.OnServerEvent:Connect(function(player)
	local s = player:FindFirstChild("leaderstats")
	if s and s.Coins.Value >= 100 then
		s.Coins.Value -= 100
		s.Gems.Value += 1
	end
end)
]], false)
end

local function setupUI()
	local gui = Instance.new("ScreenGui")
	gui.Name = PREFIX .. "HUD"
	gui.ResetOnSpawn = false
	gui.Parent = S.StarterGui

	local frame = Instance.new("Frame")
	frame.Name = "Panel"
	frame.Size = UDim2.fromOffset(250,94)
	frame.Position = UDim2.fromOffset(12,12)
	frame.BackgroundColor3 = C.dark
	frame.BackgroundTransparency = .12
	frame.BorderSizePixel = 0
	frame.Parent = gui
	Instance.new("UICorner", frame).CornerRadius = UDim.new(0,12)

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
	text.Parent = frame

	local daily = Instance.new("TextButton")
	daily.Name = "Daily"
	daily.Size = UDim2.fromOffset(168,32)
	daily.Position = UDim2.new(.5,-84,0,14)
	daily.BackgroundColor3 = C.yellow
	daily.Text = "CLAIM +250"
	daily.Font = Enum.Font.GothamBold
	daily.TextSize = 15
	daily.TextColor3 = Color3.new(1,1,1)
	daily.BorderSizePixel = 0
	daily.Parent = gui
	Instance.new("UICorner", daily).CornerRadius = UDim.new(0,10)

	scriptIn(gui, "UIClient", [[
local player = game.Players.LocalPlayer
local text = script.Parent.Panel.Stats
local daily = script.Parent.Daily
local remotes = game.ReplicatedStorage:WaitForChild("]] .. PREFIX .. [[Remotes")

daily.MouseButton1Click:Connect(function()
	remotes.Claim:FireServer()
	daily.Text = "CLAIMED"
end)

while true do
	local s = player:FindFirstChild("leaderstats")
	if s then
		text.Text = "⚡ Obby Maker" ..
		"\n💰 " .. s.Coins.Value .. "  💎 " .. s.Gems.Value .. "  ⭐ " .. s.Level.Value ..
		"\n🏆 " .. s.Wins.Value .. "  ⚔ " .. s.Kills.Value .. "  🐾 " .. s.Pets.Value
	end
	task.wait(.25)
end
]], true)
end

local function build()
	clear()
	setupRuntime()
	setupUI()

	S.Lighting.ClockTime = "Obby" == "Horror" and 0 or 18
	S.Lighting.Brightness = "Obby" == "Horror" and 1.1 or 3
	S.Lighting.FogEnd = "Obby" == "Horror" and 110 or 900

	baseplate()
for i=1,90 do
	local x=i*10
	local y=4+math.sin(i*.4)*3
	local z=math.sin(i*.8)*18
	local p=part("Platform_"..i,Vector3.new(x,y,z),Vector3.new(9,1,9),Color3.fromHSV((i%24)/24,1,1))
	glow(p,10,1)
	if i%5==0 then coin(Vector3.new(x,y+3,z),10) end
	if i%7==0 then killBrick("Lava_"..i,Vector3.new(x,y-2,z),Vector3.new(14,1,14)) end
end
label(part("Finish",Vector3.new(950,12,0),Vector3.new(30,3,30),C.yellow),"FINISH")

	warn("Generated Obby Maker")
end

buildBtn.Click:Connect(build)
clearBtn.Click:Connect(clear)
