local Players = game:GetService("Players")
local checkpoints = {}

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(char)
        task.wait(1)
        local cp = checkpoints[player.UserId]
        if cp and char:FindFirstChild("HumanoidRootPart") then
            char:MoveTo(cp + Vector3.new(0, 5, 0))
        end
    end)
end)

_G.SetCheckpoint = function(player, pos)
    checkpoints[player.UserId] = pos
end
