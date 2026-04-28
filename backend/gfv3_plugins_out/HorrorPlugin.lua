print("Loaded Horror Maker")

local toolbar = plugin:CreateToolbar("Game Factory AI")
local buildBtn = toolbar:CreateButton("Horror Maker", "Build Horror Maker", "")
local clearBtn = toolbar:CreateButton("Clear Horror Maker", "Clear generated Horror Maker", "")

local PREFIX = "GF_HorrorPlugin_"
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
	
game:GetService("Lighting").ClockTime = 0
game:GetService("Lighting").FogEnd = 110
for i = 1, 22 do
	local wall = part("Wall_" .. i, Vector3.new(math.random(-140,140),8,math.random(-140,140)), Vector3.new(math.random(12,40),16,4), Color3.fromRGB(20,20,25))
	if i == 1 then label(wall, "ESCAPE") end
end

	warn("Built Horror Maker")
end

buildBtn.Click:Connect(build)
clearBtn.Click:Connect(clear)
