print("Loaded Vehicle Maker")

local toolbar = plugin:CreateToolbar("Game Factory AI")
local buildBtn = toolbar:CreateButton("Vehicle Maker", "Build Vehicle Maker", "")
local clearBtn = toolbar:CreateButton("Clear Vehicle Maker", "Clear generated Vehicle Maker", "")

local PREFIX = "GF_VehiclePlugin_"
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
	
for i = 1, 55 do
	local z = math.sin(i * 0.25) * 45
	part("Road_" .. i, Vector3.new(i*14,1,z), Vector3.new(16,1,32), Color3.fromRGB(45,45,55))
end
label(part("Garage", Vector3.new(0,5,-60), Vector3.new(40,8,28), Color3.fromRGB(0,190,255)), "GARAGE")
label(part("FinishLine", Vector3.new(760,3,0), Vector3.new(60,2,4), Color3.fromRGB(255,220,0)), "FINISH")

	warn("Built Vehicle Maker")
end

buildBtn.Click:Connect(build)
clearBtn.Click:Connect(clear)
