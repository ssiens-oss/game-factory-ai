local Players = game:GetService("Players")

-- Attach this script to checkpoint parts OR call logic when touched
local function onTouched(part, hit)
    local char = hit.Parent
    local player = Players:GetPlayerFromCharacter(char)
    if not player then return end

    if _G.SetCheckpoint then
        _G.SetCheckpoint(player, part.Position)
    end
end

-- If this script is under a Part:
local part = script.Parent
if part and part:IsA("BasePart") then
    part.Touched:Connect(function(hit)
        onTouched(part, hit)
    end)
end
