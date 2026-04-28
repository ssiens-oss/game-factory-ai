#!/usr/bin/env bash
set -e

OUT="$PWD/gfv3_plugins_out"
mkdir -p "$OUT"

make_plugin () {
  FILE="$1"
  LABEL="$2"
  COLOR="$3"
  BODY="$4"

cat > "$OUT/$FILE.lua" <<LUA
print("Loaded $LABEL")

local toolbar = plugin:CreateToolbar("Game Factory AI")
local buildBtn = toolbar:CreateButton("$LABEL", "Build $LABEL", "")
local clearBtn = toolbar:CreateButton("Clear $LABEL", "Clear generated $LABEL", "")

local PREFIX = "GF_${FILE}_"
local Workspace = game:GetService("Workspace")

local function clear()
	for _, obj in ipairs(Workspace:GetChildren()) do
		if obj.Name:match("^" .. PREFIX) then
			obj:Destroy()
		end
	end
end

local function part(name, pos, size, color)
	local p = Instance.new("Part")
	p.Name = PREFIX .. name
	p.Anchored = true
	p.Position = pos
	p.Size = size
	p.Color = color
	p.Material = Enum.Material.Neon
	p.Parent = Workspace
	return p
end

local function label(obj, text)
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.fromOffset(220, 50)
	gui.StudsOffset = Vector3.new(0, 5, 0)
	gui.AlwaysOnTop = true
	gui.Parent = obj

	local t = Instance.new("TextLabel")
	t.Size = UDim2.fromScale(1, 1)
	t.BackgroundTransparency = 1
	t.Text = text
	t.TextScaled = true
	t.Font = Enum.Font.GothamBlack
	t.TextColor3 = Color3.new(1,1,1)
	t.TextStrokeTransparency = 0
	t.Parent = gui
end

local function baseplate()
	part("Baseplate", Vector3.new(0, -2, 0), Vector3.new(420, 1, 420), Color3.fromRGB(35,35,45))
	label(part("Spawn", Vector3.new(0, 2, 0), Vector3.new(24, 1, 24), Color3.fromRGB(0,255,120)), "SPAWN")
end

local function build()
	clear()
	baseplate()
	$BODY
	warn("Built $LABEL")
end

buildBtn.Click:Connect(build)
clearBtn.Click:Connect(clear)
LUA
}

make_plugin "ObbyPlugin" "Obby Maker" "blue" '
for i = 1, 80 do
	local x = i * 10
	local y = 4 + math.sin(i * 0.4) * 3
	local z = math.sin(i * 0.8) * 18
	part("Platform_" .. i, Vector3.new(x,y,z), Vector3.new(9,1,9), Color3.fromHSV((i%24)/24,1,1))
	if i % 7 == 0 then
		part("Lava_" .. i, Vector3.new(x,y-2,z), Vector3.new(14,1,14), Color3.fromRGB(255,40,30))
	end
end
label(part("Finish", Vector3.new(850, 10, 0), Vector3.new(30,3,30), Color3.fromRGB(255,220,0)), "FINISH")
'

make_plugin "TycoonPlugin" "Tycoon Maker" "green" '
for i = 1, 4 do
	local x = (i - 2.5) * 70
	label(part("TycoonBase_" .. i, Vector3.new(x,1,80), Vector3.new(52,1,52), Color3.fromHSV(i/4,1,1)), "TYCOON " .. i)
	part("Dropper_" .. i, Vector3.new(x,8,80), Vector3.new(8,12,8), Color3.fromRGB(0,190,255))
	part("Collector_" .. i, Vector3.new(x,2,105), Vector3.new(30,2,8), Color3.fromRGB(255,220,0))
end
'

make_plugin "CombatPlugin" "Combat Maker" "red" '
label(part("Arena", Vector3.new(0,2,0), Vector3.new(170,2,170), Color3.fromRGB(150,80,255)), "COMBAT ARENA")
for i = 1, 18 do
	part("Cover_" .. i, Vector3.new(math.random(-80,80),6,math.random(-80,80)), Vector3.new(14,12,6), Color3.fromRGB(0,190,255))
end
'

make_plugin "VehiclePlugin" "Vehicle Maker" "gray" '
for i = 1, 55 do
	local z = math.sin(i * 0.25) * 45
	part("Road_" .. i, Vector3.new(i*14,1,z), Vector3.new(16,1,32), Color3.fromRGB(45,45,55))
end
label(part("Garage", Vector3.new(0,5,-60), Vector3.new(40,8,28), Color3.fromRGB(0,190,255)), "GARAGE")
label(part("FinishLine", Vector3.new(760,3,0), Vector3.new(60,2,4), Color3.fromRGB(255,220,0)), "FINISH")
'

make_plugin "HorrorPlugin" "Horror Maker" "dark" '
game:GetService("Lighting").ClockTime = 0
game:GetService("Lighting").FogEnd = 110
for i = 1, 22 do
	local wall = part("Wall_" .. i, Vector3.new(math.random(-140,140),8,math.random(-140,140)), Vector3.new(math.random(12,40),16,4), Color3.fromRGB(20,20,25))
	if i == 1 then label(wall, "ESCAPE") end
end
'

make_plugin "SimulatorPlugin" "Simulator Maker" "purple" '
for i = 1, 30 do
	local node = part("ResourceNode_" .. i, Vector3.new(math.random(-150,150),3,math.random(-150,150)), Vector3.new(8,8,8), Color3.fromHSV(i/30,1,1))
	label(node, "+POWER")
end
'

make_plugin "PetsPlugin" "Pet Maker" "yellow" '
for i = 1, 24 do
	local egg = part("Egg_" .. i, Vector3.new(math.random(-150,150),5,math.random(-150,150)), Vector3.new(7,9,7), Color3.fromHSV(i/24,1,1))
	egg.Shape = Enum.PartType.Ball
	label(egg, "EGG")
end
'

make_plugin "WorldPlugin" "World Maker" "green" '
for i = 1, 40 do
	local trunk = part("Tree_" .. i, Vector3.new(math.random(-170,170),8,math.random(-170,170)), Vector3.new(5,16,5), Color3.fromRGB(90,55,25))
	local top = part("TreeTop_" .. i, trunk.Position + Vector3.new(0,11,0), Vector3.new(14,14,14), Color3.fromRGB(0,180,80))
	top.Shape = Enum.PartType.Ball
end
'

echo "✅ Built discrete plugins in:"
echo "$OUT"
ls -lah "$OUT"
