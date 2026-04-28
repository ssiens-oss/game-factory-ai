local Players = game:GetService("Players")

local function bind(part)
	part.Touched:Connect(function(hit)
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.Health = 0
		end
	end)
end

for _, v in pairs(workspace:GetDescendants()) do
	if v.Name == "KillBrick" then
		bind(v)
	end
end
