#!/usr/bin/env bash
set -e

ROOT="$HOME/game-factory-ai"
BACKEND="$ROOT/backend"
QUEUE="$ROOT/roblox_queue"
PLUGIN_OUT="$BACKEND/GameFactoryAI_V3_Ultimate.lua"
WATCHER="$BACKEND/v3_trigger_watcher.py"

mkdir -p "$BACKEND" "$QUEUE"

cat > "$PLUGIN_OUT" <<'LUA'
print("GAME FACTORY AI V3 ULTIMATE LOADED")

local toolbar = plugin:CreateToolbar("Game Factory AI V3")
local openBtn = toolbar:CreateButton("V3 Maker", "Open Game Factory AI V3", "")
local buildObbyBtn = toolbar:CreateButton("Quick Obby", "Generate quick obby", "")
local clearBtn = toolbar:CreateButton("Clear V3", "Clear generated V3 game", "")

local S = {
	Workspace = game:GetService("Workspace"),
	ServerScriptService = game:GetService("ServerScriptService"),
	ReplicatedStorage = game:GetService("ReplicatedStorage"),
	StarterGui = game:GetService("StarterGui"),
	Lighting = game:GetService("Lighting"),
}

local PREFIX = "GFV3_"

local GENRES = {
	"Obby","Tycoon","Arena","Driving","Racing","Horror","Ragdoll","Simulator",
	"PetCollector","TowerDefense","Survival","FPS","ZombieSurvival","BattleRoyale",
	"Mining","Restaurant","ThemePark","PirateAdventure","SpaceExplorer","FarmLife",
	"PuzzleEscape"
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

local function part(name,pos,size,color,material)
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

local function scriptIn(parent,name,source,isLocal)
	local s = Instance.new(isLocal and "LocalScript" or "Script")
	s.Name = PREFIX .. name
	s.Source = source
	s.Parent = parent
	return s
end

local function glow(obj,range,brightness)
	local l = Instance.new("PointLight")
	l.Name = PREFIX .. "Glow"
	l.Color = obj.Color
	l.Range = range or 16
	l.Brightness = brightness or 1.5
	l.Parent = obj
end

local function label(obj,text)
	local gui = Instance.new("BillboardGui")
	gui.Name = PREFIX .. "Label"
	gui.Size = UDim2.fromOffset(240,54)
	gui.StudsOffset = Vector3.new(0,5,0)
	gui.AlwaysOnTop = true
	gui.Parent = obj

	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1,1)
	t.BackgroundTransparency = 1
	t.Text = text
	t.Font = Enum.Font.GothamBlack
	t.TextScaled = true
	t.TextColor3 = Color3.new(1,1,1)
	t.TextStrokeTransparency = 0
	t.Parent = gui
end

local function setupLighting(genre)
	S.Lighting.ClockTime = genre == "Horror" and 0 or 18
	S.Lighting.Brightness = genre == "Horror" and 1.1 or 3
	S.Lighting.FogEnd = genre == "Horror" and 110 or 900
	S.Lighting.FogColor = genre == "Horror" and Color3.fromRGB(4,4,8) or Color3.fromRGB(10,10,30)

	local bloom = Instance.new("BloomEffect")
	bloom.Name = PREFIX .. "Bloom"
	bloom.Intensity = 1.25
	bloom.Size = 36
	bloom.Parent = S.Lighting

	local cc = Instance.new("ColorCorrectionEffect")
	cc.Name = PREFIX .. "ColorCorrection"
	cc.Contrast = 0.2
	cc.Saturation = genre == "Horror" and -0.3 or 0.25
	cc.Parent = S.Lighting
end

local function remotes()
	local f = Instance.new("Folder")
	f.Name = PREFIX .. "Remotes"
	f.Parent = S.ReplicatedStorage
	for _, n in ipairs({"Buy","Claim","PetRoll","Round","SpawnVehicle"}) do
		local r = Instance.new("RemoteEvent")
		r.Name = n
		r.Parent = f
	end
end

local function manager(genre)
	scriptIn(S.ServerScriptService,"GameManager",[[
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("GFV3_Remotes")

local function stat(parent, className, name, value)
	local v = Instance.new(className)
	v.Name = name
	v.Value = value
	v.Parent = parent
	return v
end

local function setup(player)
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
	stat(player,"Vector3Value","GFV3_Checkpoint",Vector3.new(0,10,0))
end

local function reward(player, coins, xp, gems)
	local s = player:FindFirstChild("leaderstats")
	if not s then return end
	s.Coins.Value += coins or 0
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
	setup(player)
	player.CharacterAdded:Connect(function(char)
		task.wait(.15)
		local root = char:FindFirstChild("HumanoidRootPart")
		local cp = player:FindFirstChild("GFV3_Checkpoint")
		if root and cp then root.CFrame = CFrame.new(cp.Value) end
	end)
end)

Remotes.Claim.OnServerEvent:Connect(function(player)
	reward(player,250,100,5)
end)

Remotes.Buy.OnServerEvent:Connect(function(player)
	local s = player:FindFirstChild("leaderstats")
	if s and s.Coins.Value >= 100 then
		s.Coins.Value -= 100
		s.Gems.Value += 1
	end
end)

Remotes.PetRoll.OnServerEvent:Connect(function(player)
	local s = player:FindFirstChild("leaderstats")
	if s and s.Coins.Value >= 50 then
		s.Coins.Value -= 50
		s.Pets.Value += 1
	end
end)

_G.GFV3_Reward = reward
]],false)
end

local function hud(genre)
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

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0,12)
	corner.Parent = frame

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

	scriptIn(gui,"HUDClient",[[
local player = game.Players.LocalPlayer
local text = script.Parent.Panel.Stats
local genre = "]] .. genre .. [["
while true do
	local s = player:FindFirstChild("leaderstats")
	if s then
		text.Text = "⚡ " .. genre ..
		"\n💰 " .. s.Coins.Value .. "  💎 " .. s.Gems.Value .. "  ⭐ " .. s.Level.Value ..
		"\n🏆 " .. s.Wins.Value .. "  ⚔ " .. s.Kills.Value .. "  🐾 " .. s.Pets.Value
	end
	task.wait(.25)
end
]],true)
end

local function shopUI()
	local gui = Instance.new("ScreenGui")
	gui.Name = PREFIX .. "Shop"
	gui.ResetOnSpawn = false
	gui.Parent = S.StarterGui

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
	Instance.new("UICorner",daily).CornerRadius = UDim.new(0,10)

	local panel = Instance.new("Frame")
	panel.Name = "Panel"
	panel.Size = UDim2.fromOffset(220,188)
	panel.Position = UDim2.new(1,-238,0,14)
	panel.BackgroundColor3 = C.dark
	panel.BackgroundTransparency = .12
	panel.BorderSizePixel = 0
	panel.Parent = gui
	Instance.new("UICorner",panel).CornerRadius = UDim.new(0,12)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1,0,0,28)
	title.BackgroundTransparency = 1
	title.Text = "SHOP"
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 18
	title.TextColor3 = Color3.new(1,1,1)
	title.Parent = panel

	for i, row in ipairs({"Upgrade - 100","Pet Roll - 50","Boost - 100","Cosmetic - 100"}) do
		local b = Instance.new("TextButton")
		b.Name = row:split(" ")[1]
		b.Size = UDim2.new(1,-20,0,28)
		b.Position = UDim2.fromOffset(10,34+(i-1)*34)
		b.BackgroundColor3 = C.blue
		b.Text = row
		b.Font = Enum.Font.GothamBold
		b.TextSize = 14
		b.TextColor3 = Color3.new(1,1,1)
		b.BorderSizePixel = 0
		b.Parent = panel
		Instance.new("UICorner",b).CornerRadius = UDim.new(0,8)
	end

	scriptIn(gui,"ShopClient",[[
local remotes = game.ReplicatedStorage:WaitForChild("GFV3_Remotes")
script.Parent.Daily.MouseButton1Click:Connect(function()
	remotes.Claim:FireServer()
	script.Parent.Daily.Text = "CLAIMED"
end)
for _, b in ipairs(script.Parent.Panel:GetChildren()) do
	if b:IsA("TextButton") then
		b.MouseButton1Click:Connect(function()
			if b.Text:find("Pet") then remotes.PetRoll:FireServer() else remotes.Buy:FireServer(b.Name) end
		end)
	end
end
]],true)
end

local function baseplate()
	part("Baseplate",Vector3.new(0,-2,0),Vector3.new(420,1,420),C.gray,Enum.Material.Metal)
	local spawn = part("Spawn",Vector3.new(0,2,0),Vector3.new(24,1,24),C.green)
	label(spawn,"SPAWN")
	scriptIn(spawn,"Checkpoint",[[
script.Parent.Touched:Connect(function(hit)
	local p = game.Players:GetPlayerFromCharacter(hit.Parent)
	if p and p:FindFirstChild("GFV3_Checkpoint") then
		p.GFV3_Checkpoint.Value = script.Parent.Position + Vector3.new(0,8,0)
	end
end)
]],false)
end

local function coin(pos,value)
	local c = part("Coin",pos,Vector3.new(2,2,.35),C.yellow)
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
	if _G.GFV3_Reward then _G.GFV3_Reward(p,]] .. tostring(value or 10) .. [[,4,0) end
	script.Parent.Transparency = 1
	script.Parent.CanTouch = false
	task.wait(5)
	script.Parent.Transparency = 0
	script.Parent.CanTouch = true
	busy = false
end)
while true do
	script.Parent.CFrame *= CFrame.Angles(0,math.rad(5),0)
	task.wait()
end
]],false)
end

local function killBrick(name,pos,size)
	local k = part(name,pos,size,C.red)
	glow(k,16,2)
	scriptIn(k,"Kill",[[
script.Parent.Touched:Connect(function(hit)
	local h = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
	if h then h.Health = 0 end
end)
]],false)
end

local Builders = {}

function Builders.Obby()
	baseplate()
	for i=1,90 do
		local x=i*10
		local y=4+math.sin(i*.4)*3
		local z=math.sin(i*.8)*18
		local p=part("ObbyPlatform_"..i,Vector3.new(x,y,z),Vector3.new(9,1,9),Color3.fromHSV((i%24)/24,1,1))
		glow(p,10,1)
		if i%5==0 then coin(Vector3.new(x,y+3,z),10) end
		if i%7==0 then killBrick("Lava_"..i,Vector3.new(x,y-2,z),Vector3.new(14,1,14)) end
	end
	label(part("Finish",Vector3.new(950,12,0),Vector3.new(30,3,30),C.yellow),"FINISH")
end

function Builders.Tycoon()
	baseplate()
	for i=1,4 do
		local x=(i-2.5)*70
		label(part("TycoonBase_"..i,Vector3.new(x,1,80),Vector3.new(52,1,52),Color3.fromHSV(i/4,1,1)),"TYCOON "..i)
		part("Dropper_"..i,Vector3.new(x,8,80),Vector3.new(8,12,8),C.blue)
		local col=part("Collector_"..i,Vector3.new(x,2,105),Vector3.new(30,2,8),C.yellow)
		coin(col.Position+Vector3.new(0,5,0),25)
	end
end

function Builders.Arena()
	baseplate()
	label(part("Arena",Vector3.new(0,2,0),Vector3.new(160,2,160),C.purple),"BATTLE ARENA")
	for i=1,12 do
		local a=math.rad(i*30)
		killBrick("ArenaHazard_"..i,Vector3.new(math.cos(a)*65,4,math.sin(a)*65),Vector3.new(8,8,8))
	end
end

function Builders.Driving()
	baseplate()
	for i=1,45 do
		local z=math.sin(i*.25)*45
		part("Road_"..i,Vector3.new(i*14,1,z),Vector3.new(16,1,32),C.gray,Enum.Material.Asphalt)
		if i%8==0 then coin(Vector3.new(i*14,5,z),20) end
	end
	label(part("Garage",Vector3.new(0,5,-60),Vector3.new(40,8,28),C.blue),"GARAGE")
end

function Builders.Racing()
	Builders.Driving()
	label(part("StartLine",Vector3.new(0,3,20),Vector3.new(60,2,4),C.green),"START")
	label(part("FinishLine",Vector3.new(640,3,0),Vector3.new(60,2,4),C.yellow),"FINISH")
end

function Builders.Horror()
	baseplate()
	for i=1,18 do
		local wall=part("Wall_"..i,Vector3.new(math.random(-140,140),8,math.random(-140,140)),Vector3.new(math.random(12,40),16,4),Color3.fromRGB(20,20,25),Enum.Material.Slate)
		if i==1 then label(wall,"ESCAPE") end
	end
	for i=1,10 do killBrick("MonsterZone_"..i,Vector3.new(math.random(-120,120),2,math.random(-120,120)),Vector3.new(14,2,14)) end
end

function Builders.Ragdoll()
	baseplate()
	for i=1,30 do
		local ramp=part("RagdollRamp_"..i,Vector3.new(i*12,i*2,0),Vector3.new(16,1,18),C.pink)
		ramp.Orientation=Vector3.new(0,0,math.random(-18,18))
	end
	label(part("RagdollDrop",Vector3.new(390,75,0),Vector3.new(36,2,36),C.yellow),"RAGDOLL DROP")
end

function Builders.Simulator()
	baseplate()
	for i=1,24 do
		local node=part("ResourceNode_"..i,Vector3.new(math.random(-150,150),3,math.random(-150,150)),Vector3.new(8,8,8),Color3.fromHSV(i/24,1,1))
		label(node,"+POWER")
		coin(node.Position+Vector3.new(0,7,0),15)
	end
end

function Builders.PetCollector()
	baseplate()
	for i=1,18 do
		local egg=part("Egg_"..i,Vector3.new(math.random(-150,150),5,math.random(-150,150)),Vector3.new(7,9,7),Color3.fromHSV(i/18,1,1))
		egg.Shape=Enum.PartType.Ball
		label(egg,"EGG")
		coin(egg.Position+Vector3.new(0,8,0),20)
	end
end

function Builders.TowerDefense()
	baseplate()
	for i=1,35 do part("EnemyPath_"..i,Vector3.new(i*8-140,1,math.sin(i*.5)*35),Vector3.new(9,1,9),C.red) end
	for i=1,8 do label(part("TowerPad_"..i,Vector3.new(i*28-120,2,50),Vector3.new(14,1,14),C.blue),"TOWER") end
end

function Builders.Survival()
	baseplate()
	for i=1,30 do
		local tree=part("Tree_"..i,Vector3.new(math.random(-170,170),8,math.random(-170,170)),Vector3.new(5,16,5),Color3.fromRGB(80,45,20),Enum.Material.Wood)
		local top=part("TreeTop_"..i,tree.Position+Vector3.new(0,11,0),Vector3.new(14,14,14),C.green,Enum.Material.Grass)
		top.Shape=Enum.PartType.Ball
	end
	for i=1,12 do killBrick("DangerZone_"..i,Vector3.new(math.random(-160,160),2,math.random(-160,160)),Vector3.new(16,2,16)) end
end

Builders.FPS = Builders.Arena
Builders.ZombieSurvival = Builders.Survival
Builders.BattleRoyale = Builders.Survival
Builders.Mining = Builders.Simulator
Builders.Restaurant = Builders.Tycoon
Builders.ThemePark = Builders.Simulator
Builders.PirateAdventure = Builders.Survival
Builders.SpaceExplorer = Builders.Simulator
Builders.FarmLife = Builders.Simulator
Builders.PuzzleEscape = Builders.Obby

local function logicPack(genre)
	scriptIn(S.ServerScriptService,"LogicPack_"..genre,[[
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local GENRE = "]] .. genre .. [["
local function reward(p,c,x,g) if _G.GFV3_Reward then _G.GFV3_Reward(p,c,x,g) end end
local function bind(part,c,x,g,cd)
	local busy={}
	part.Touched:Connect(function(hit)
		local p=Players:GetPlayerFromCharacter(hit.Parent)
		if not p or busy[p] then return end
		busy[p]=true
		reward(p,c,x,g)
		task.delay(cd or 1,function() busy[p]=nil end)
	end)
end
task.wait(1)
for _,o in ipairs(Workspace:GetChildren()) do
	if o.Name:find("GFV3_Collector") then bind(o,25,5,0,1) end
	if o.Name:find("GFV3_ResourceNode") then bind(o,20,20,1,1) end
	if o.Name:find("GFV3_Egg") then bind(o,5,5,1,2) end
	if o.Name:find("GFV3_FinishLine") then
		bind(o,75,50,2,3)
	end
	if o.Name:find("GFV3_Finish") then
		o.Touched:Connect(function(hit)
			local p=Players:GetPlayerFromCharacter(hit.Parent)
			local s=p and p:FindFirstChild("leaderstats")
			if s then s.Wins.Value += 1; reward(p,150,100,5) end
		end)
	end
end
task.spawn(function()
	while true do
		for _,p in ipairs(Players:GetPlayers()) do
			local h=p.Character and p.Character:FindFirstChildOfClass("Humanoid")
			if h and h.Health>0 then reward(p,10,10,0) end
		end
		task.wait(20)
	end
end)
warn("GFV3 Logic active:",GENRE)
]],false)
end

local function generate(genre)
	clear()
	setupLighting(genre)
	remotes()
	manager(genre)
	hud(genre)
	shopUI()
	local builder = Builders[genre] or Builders.Obby
	builder()
	logicPack(genre)
	warn("GFV3 generated:", genre)
end

local widget
local function makeUI()
	local info=DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float,true,false,320,560,280,420)
	local w=plugin:CreateDockWidgetPluginGui("GFV3_Maker",info)
	w.Title="Game Factory AI V3"

	local root=Instance.new("Frame")
	root.Size=UDim2.fromScale(1,1)
	root.BackgroundColor3=C.dark
	root.BorderSizePixel=0
	root.Parent=w

	local title=Instance.new("TextLabel")
	title.Size=UDim2.new(1,-20,0,38)
	title.Position=UDim2.fromOffset(10,8)
	title.BackgroundTransparency=1
	title.Text="Game Factory AI V3"
	title.Font=Enum.Font.GothamBlack
	title.TextSize=20
	title.TextColor3=Color3.new(1,1,1)
	title.Parent=root

	local y=56
	for _,genre in ipairs(GENRES) do
		local b=Instance.new("TextButton")
		b.Size=UDim2.new(1,-24,0,28)
		b.Position=UDim2.fromOffset(12,y)
		b.BackgroundColor3=C.blue
		b.BorderSizePixel=0
		b.Text="Generate "..genre
		b.Font=Enum.Font.GothamBold
		b.TextSize=13
		b.TextColor3=Color3.new(1,1,1)
		b.Parent=root
		Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
		b.MouseButton1Click:Connect(function() generate(genre) end)
		y += 32
	end

	local cb=Instance.new("TextButton")
	cb.Size=UDim2.new(1,-24,0,32)
	cb.Position=UDim2.fromOffset(12,y+8)
	cb.BackgroundColor3=C.red
	cb.BorderSizePixel=0
	cb.Text="Clear Generated"
	cb.Font=Enum.Font.GothamBlack
	cb.TextSize=14
	cb.TextColor3=Color3.new(1,1,1)
	cb.Parent=root
	Instance.new("UICorner",cb).CornerRadius=UDim.new(0,8)
	cb.MouseButton1Click:Connect(clear)

	return w
end

openBtn.Click:Connect(function()
	if not widget then widget=makeUI() else widget.Enabled = not widget.Enabled end
end)

buildObbyBtn.Click:Connect(function() generate("Obby") end)
clearBtn.Click:Connect(clear)
LUA

cat > "$WATCHER" <<'PY'
import json, socket, time, pathlib

HOST = "192.168.122.77"
PORT = 5050
WATCH = pathlib.Path.home() / "game-factory-ai" / "backend" / "trigger.txt"

print("GF V3 watcher")
print("watching:", WATCH)

last = None

while True:
    try:
        if WATCH.exists():
            m = WATCH.stat().st_mtime
            if last is None:
                last = m
            elif m != last:
                last = m
                payload = {
                    "type": "trigger",
                    "path": str(WATCH),
                    "action": "install_plugin",
                    "plugin_file": str(pathlib.Path.home() / "game-factory-ai" / "backend" / "GameFactoryAI_V3_Ultimate.lua"),
                    "ts": time.time(),
                }
                s = socket.socket()
                s.settimeout(5)
                s.connect((HOST, PORT))
                s.send(json.dumps(payload).encode("utf-8"))
                print("sent:", s.recv(2048))
                s.close()
        time.sleep(0.5)
    except Exception as e:
        print("send failed:", e)
        time.sleep(2)
PY

echo "✅ Built V3 files:"
echo "$PLUGIN_OUT"
echo "$WATCHER"
echo
echo "Next:"
echo "1. Copy plugin into Windows Roblox Plugins folder:"
echo "   cp '$PLUGIN_OUT' /mnt/c/Users/<WINDOWS_USER>/AppData/Local/Roblox/Plugins/GameFactoryAI_V3_Ultimate.lua"
echo
echo "2. Or find folder automatically:"
echo "   PLUGDIR=\$(find /mnt/c/Users -type d -path '*/AppData/Local/Roblox/Plugins' 2>/dev/null | head -n 1)"
echo "   cp '$PLUGIN_OUT' \"\$PLUGDIR/GameFactoryAI_V3_Ultimate.lua\""
echo
echo "3. Restart Roblox Studio → Plugins → V3 Maker"
