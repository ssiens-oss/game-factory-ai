print("Loaded Obby Maker")

local toolbar = plugin:CreateToolbar("Game Factory AI")
local buildBtn = toolbar:CreateButton("Obby Maker", "Build Obby Maker", "")
local clearBtn = toolbar:CreateButton("Clear Obby Maker", "Clear generated Obby Maker", "")

local PREFIX = "GF_ObbyPlugin_"
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

	warn("Built Obby Maker")
end

buildBtn.Click:Connect(build)
clearBtn.Click:Connect(clear)
