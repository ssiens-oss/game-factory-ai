print("Game Factory AI: Neon Obby loaded")

local Workspace = game:GetService("Workspace")

local function part(name, pos, size, color)
	local p = Instance.new("Part")
	p.Name = name
	p.Anchored = true
	p.Position = pos
	p.Size = size
	p.Color = color
	p.Parent = Workspace
	return p
end

part("SpawnPlatform", Vector3.new(0, 2, 0), Vector3.new(20, 1, 20), Color3.fromRGB(20, 20, 30))

for i = 1, 18 do
	local x = i * 14
	local y = 2 + math.sin(i) * 2
	local z = math.random(-8, 8)

	local platform = part(
		"NeonPlatform_" .. i,
		Vector3.new(x, y, z),
		Vector3.new(10, 1, 10),
		Color3.fromRGB(0, 255, 255)
	)

	if i % 4 == 0 then
		local kill = part(
			"KillBrick_" .. i,
			Vector3.new(x, y + 1, z),
			Vector3.new(8, 1, 8),
			Color3.fromRGB(255, 0, 80)
		)
		kill.Touched:Connect(function(hit)
			local hum = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
			if hum then hum.Health = 0 end
		end)
	end
end

part("Finish", Vector3.new(280, 5, 0), Vector3.new(16, 2, 16), Color3.fromRGB(0, 255, 80))
