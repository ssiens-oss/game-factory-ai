
-- Auto prompt revive on death
local function hookCharacter(char)
    local hum = char:WaitForChild("Humanoid")

    hum.Died:Connect(function()
        task.wait(1) -- small delay feels better
        MarketplaceService:PromptProductPurchase(player, PRODUCTS.REVIVE)
    end)
end

if player.Character then
    hookCharacter(player.Character)
end

player.CharacterAdded:Connect(hookCharacter)
