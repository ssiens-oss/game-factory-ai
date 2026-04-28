print("Loaded Tycoon Maker")

local toolbar = plugin:CreateToolbar("Game Factory AI")
local buildBtn = toolbar:CreateButton("Tycoon Maker", "Build Tycoon Maker", "")
local clearBtn = toolbar:CreateButton("Clear Tycoon Maker", "Clear generated Tycoon Maker", "")

local PREFIX = "GF_TycoonPlugin_"
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
	
for i = 1, 4 do
	local x = (i - 2.5) * 70
	label(part("TycoonBase_" .. i, Vector3.new(x,1,80), Vector3.new(52,1,52), Color3.fromHSV(i/4,1,1)), "TYCOON " .. i)
	part("Dropper_" .. i, Vector3.new(x,8,80), Vector3.new(8,12,8), Color3.fromRGB(0,190,255))
	part("Collector_" .. i, Vector3.new(x,2,105), Vector3.new(30,2,8), Color3.fromRGB(255,220,0))
end

	warn("Built Tycoon Maker")
end

buildBtn.Click:Connect(build)
clearBtn.Click:Connect(clear)
