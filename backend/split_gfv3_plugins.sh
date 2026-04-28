#!/usr/bin/env bash
set -e

PLUGDIR="${PLUGDIR:-$PWD/gfv3_plugins_out}"
mkdir -p "$PLUGDIR"

write_plugin () {
  local name="$1"
  local genre="$2"
  local label="$3"

  cat > "$PLUGDIR/$name.lua" <<LUA
print("GAME FACTORY AI PLUGIN LOADED: $label")

local toolbar = plugin:CreateToolbar("Game Factory AI")
local buildBtn = toolbar:CreateButton("$label", "Generate $label game", "")
local clearBtn = toolbar:CreateButton("Clear $label", "Clear generated $label content", "")

local PREFIX = "GF_$genre" .. "_"

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
		text.Text = "⚡ $label" ..
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

	S.Lighting.ClockTime = "$genre" == "Horror" and 0 or 18
	S.Lighting.Brightness = "$genre" == "Horror" and 1.1 or 3
	S.Lighting.FogEnd = "$genre" == "Horror" and 110 or 900

	BUILD_BODY_REPLACE

	warn("Generated $label")
end

buildBtn.Click:Connect(build)
clearBtn.Click:Connect(clear)
LUA
}

make_body () {
  local genre="$1"

  case "$genre" in
    Obby)
      cat <<'BODY'
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
BODY
      ;;
    Tycoon)
      cat <<'BODY'
baseplate()
for i=1,4 do
	local x=(i-2.5)*70
	label(part("TycoonBase_"..i,Vector3.new(x,1,80),Vector3.new(52,1,52),Color3.fromHSV(i/4,1,1)),"TYCOON "..i)
	part("Dropper_"..i,Vector3.new(x,8,80),Vector3.new(8,12,8),C.blue)
	local col=part("Collector_"..i,Vector3.new(x,2,105),Vector3.new(30,2,8),C.yellow)
	coin(col.Position+Vector3.new(0,5,0),25)
end
BODY
      ;;
    Combat)
      cat <<'BODY'
baseplate()
label(part("Arena",Vector3.new(0,2,0),Vector3.new(170,2,170),C.purple),"COMBAT ARENA")
for i=1,18 do
	part("Cover_"..i,Vector3.new(math.random(-80,80),6,math.random(-80,80)),Vector3.new(14,12,6),C.blue)
end
for i=1,12 do
	local a=math.rad(i*30)
	killBrick("Hazard_"..i,Vector3.new(math.cos(a)*65,4,math.sin(a)*65),Vector3.new(8,8,8))
end
BODY
      ;;
    Vehicle)
      cat <<'BODY'
baseplate()
for i=1,55 do
	local z=math.sin(i*.25)*45
	part("Road_"..i,Vector3.new(i*14,1,z),Vector3.new(16,1,32),C.gray,Enum.Material.Asphalt)
	if i%8==0 then coin(Vector3.new(i*14,5,z),20) end
end
label(part("Garage",Vector3.new(0,5,-60),Vector3.new(40,8,28),C.blue),"GARAGE")
label(part("FinishLine",Vector3.new(760,3,0),Vector3.new(60,2,4),C.yellow),"FINISH")
BODY
      ;;
    Horror)
      cat <<'BODY'
baseplate()
for i=1,22 do
	local wall=part("Wall_"..i,Vector3.new(math.random(-140,140),8,math.random(-140,140)),Vector3.new(math.random(12,40),16,4),Color3.fromRGB(20,20,25),Enum.Material.Slate)
	if i==1 then label(wall,"ESCAPE") end
end
for i=1,14 do
	killBrick("MonsterZone_"..i,Vector3.new(math.random(-120,120),2,math.random(-120,120)),Vector3.new(14,2,14))
end
BODY
      ;;
    Simulator)
      cat <<'BODY'
baseplate()
for i=1,30 do
	local node=part("ResourceNode_"..i,Vector3.new(math.random(-150,150),3,math.random(-150,150)),Vector3.new(8,8,8),Color3.fromHSV(i/30,1,1))
	label(node,"+POWER")
	coin(node.Position+Vector3.new(0,7,0),15)
end
BODY
      ;;
    Pets)
      cat <<'BODY'
baseplate()
for i=1,24 do
	local egg=part("Egg_"..i,Vector3.new(math.random(-150,150),5,math.random(-150,150)),Vector3.new(7,9,7),Color3.fromHSV(i/24,1,1))
	egg.Shape=Enum.PartType.Ball
	label(egg,"EGG")
	coin(egg.Position+Vector3.new(0,8,0),20)
end
BODY
      ;;
    World)
      cat <<'BODY'
baseplate()
for i=1,40 do
	local tree=part("Tree_"..i,Vector3.new(math.random(-170,170),8,math.random(-170,170)),Vector3.new(5,16,5),Color3.fromRGB(80,45,20),Enum.Material.Wood)
	local top=part("TreeTop_"..i,tree.Position+Vector3.new(0,11,0),Vector3.new(14,14,14),C.green,Enum.Material.Grass)
	top.Shape=Enum.PartType.Ball
end
for i=1,18 do
	local poi=part("POI_"..i,Vector3.new(math.random(-160,160),6,math.random(-160,160)),Vector3.new(18,12,18),Color3.fromHSV(i/18,1,1))
	label(poi,"POI")
end
BODY
      ;;
  esac
}

create () {
  local file="$1"
  local genre="$2"
  local label="$3"
  write_plugin "$file" "$genre" "$label"
  body=$(make_body "$genre" | sed 's/[&/\]/\\&/g')
  python3 - "$PLUGDIR/$file.lua" "$genre" <<'PY'
from pathlib import Path
import sys

p = Path(sys.argv[1])
genre = sys.argv[2]
code = p.read_text()

bodies = {
"Obby": r'''baseplate()
for i=1,90 do
	local x=i*10
	local y=4+math.sin(i*.4)*3
	local z=math.sin(i*.8)*18
	local p=part("Platform_"..i,Vector3.new(x,y,z),Vector3.new(9,1,9),Color3.fromHSV((i%24)/24,1,1))
	glow(p,10,1)
	if i%5==0 then coin(Vector3.new(x,y+3,z),10) end
	if i%7==0 then killBrick("Lava_"..i,Vector3.new(x,y-2,z),Vector3.new(14,1,14)) end
end
label(part("Finish",Vector3.new(950,12,0),Vector3.new(30,3,30),C.yellow),"FINISH")''',

"Tycoon": r'''baseplate()
for i=1,4 do
	local x=(i-2.5)*70
	label(part("TycoonBase_"..i,Vector3.new(x,1,80),Vector3.new(52,1,52),Color3.fromHSV(i/4,1,1)),"TYCOON "..i)
	part("Dropper_"..i,Vector3.new(x,8,80),Vector3.new(8,12,8),C.blue)
	local col=part("Collector_"..i,Vector3.new(x,2,105),Vector3.new(30,2,8),C.yellow)
	coin(col.Position+Vector3.new(0,5,0),25)
end''',

"Combat": r'''baseplate()
label(part("Arena",Vector3.new(0,2,0),Vector3.new(170,2,170),C.purple),"COMBAT ARENA")
for i=1,18 do
	part("Cover_"..i,Vector3.new(math.random(-80,80),6,math.random(-80,80)),Vector3.new(14,12,6),C.blue)
end
for i=1,12 do
	local a=math.rad(i*30)
	killBrick("Hazard_"..i,Vector3.new(math.cos(a)*65,4,math.sin(a)*65),Vector3.new(8,8,8))
end''',

"Vehicle": r'''baseplate()
for i=1,55 do
	local z=math.sin(i*.25)*45
	part("Road_"..i,Vector3.new(i*14,1,z),Vector3.new(16,1,32),C.gray,Enum.Material.Asphalt)
	if i%8==0 then coin(Vector3.new(i*14,5,z),20) end
end
label(part("Garage",Vector3.new(0,5,-60),Vector3.new(40,8,28),C.blue),"GARAGE")
label(part("FinishLine",Vector3.new(760,3,0),Vector3.new(60,2,4),C.yellow),"FINISH")''',

"Horror": r'''baseplate()
for i=1,22 do
	local wall=part("Wall_"..i,Vector3.new(math.random(-140,140),8,math.random(-140,140)),Vector3.new(math.random(12,40),16,4),Color3.fromRGB(20,20,25),Enum.Material.Slate)
	if i==1 then label(wall,"ESCAPE") end
end
for i=1,14 do
	killBrick("MonsterZone_"..i,Vector3.new(math.random(-120,120),2,math.random(-120,120)),Vector3.new(14,2,14))
end''',

"Simulator": r'''baseplate()
for i=1,30 do
	local node=part("ResourceNode_"..i,Vector3.new(math.random(-150,150),3,math.random(-150,150)),Vector3.new(8,8,8),Color3.fromHSV(i/30,1,1))
	label(node,"+POWER")
	coin(node.Position+Vector3.new(0,7,0),15)
end''',

"Pets": r'''baseplate()
for i=1,24 do
	local egg=part("Egg_"..i,Vector3.new(math.random(-150,150),5,math.random(-150,150)),Vector3.new(7,9,7),Color3.fromHSV(i/24,1,1))
	egg.Shape=Enum.PartType.Ball
	label(egg,"EGG")
	coin(egg.Position+Vector3.new(0,8,0),20)
end''',

"World": r'''baseplate()
for i=1,40 do
	local tree=part("Tree_"..i,Vector3.new(math.random(-170,170),8,math.random(-170,170)),Vector3.new(5,16,5),Color3.fromRGB(80,45,20),Enum.Material.Wood)
	local top=part("TreeTop_"..i,tree.Position+Vector3.new(0,11,0),Vector3.new(14,14,14),C.green,Enum.Material.Grass)
	top.Shape=Enum.PartType.Ball
end
for i=1,18 do
	local poi=part("POI_"..i,Vector3.new(math.random(-160,160),6,math.random(-160,160)),Vector3.new(18,12,18),Color3.fromHSV(i/18,1,1))
	label(poi,"POI")
end'''
}

code = code.replace("BUILD_BODY_REPLACE", bodies[genre])
p.write_text(code)
PY
}

create "GFV3_ObbyPlugin" "Obby" "Obby Maker"
create "GFV3_TycoonPlugin" "Tycoon" "Tycoon Maker"
create "GFV3_CombatPlugin" "Combat" "Combat Maker"
create "GFV3_VehiclePlugin" "Vehicle" "Vehicle Maker"
create "GFV3_HorrorPlugin" "Horror" "Horror Maker"
create "GFV3_SimulatorPlugin" "Simulator" "Simulator Maker"
create "GFV3_PetsPlugin" "Pets" "Pet Maker"
create "GFV3_WorldPlugin" "World" "World Maker"

echo "✅ Installed discrete Game Factory AI plugins:"
ls -1 "$PLUGDIR"/GFV3_*Plugin.lua

echo
echo "Next:"
echo "1. Restart Roblox Studio"
echo "2. Plugins tab will show separate Game Factory AI buttons"
echo "3. Use one maker at a time, or combine outputs manually"
