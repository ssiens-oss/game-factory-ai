local Players = game:GetService("Players")

local function bind(part)
	part.Touched:Connect(function(hit)
		local player = Players:GetPlayerFromCharacter(hit.Parent)
		if player then
			print("WIN:", player.Name)
			player:LoadCharacter()
		end
	end)
end

for _, v in pairs(workspace:GetDescendants()) do
	if v.Name == "WinZone" then
		bind(v)
	end
end
