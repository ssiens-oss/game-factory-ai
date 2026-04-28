local Players            = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local PRODUCTS = { REVIVE = 0000000001, SKIP = 0000000002 }
local player   = Players.LocalPlayer

local gui   = Instance.new("ScreenGui")
gui.Parent  = player:WaitForChild("PlayerGui")
gui.ResetOnSpawn = false

local frame = Instance.new("Frame")
frame.Size     = UDim2.new(0, 230, 0, 140)
frame.Position = UDim2.new(0, 15, 0, 200)
frame.BackgroundTransparency = 0.15
frame.Parent   = gui

local status = Instance.new("TextLabel")
status.Size   = UDim2.new(1,0,0.25,0)
status.Text   = "💰 Shop"
status.Parent = frame

local reviveBtn = Instance.new("TextButton")
reviveBtn.Size     = UDim2.new(1,0,0.35,0)
reviveBtn.Position = UDim2.new(0,0,0.25,0)
reviveBtn.Text     = "Revive 💀"
reviveBtn.Parent   = frame

local skipBtn = Instance.new("TextButton")
skipBtn.Size     = UDim2.new(1,0,0.35,0)
skipBtn.Position = UDim2.new(0,0,0.60,0)
skipBtn.Text     = "Skip Level 🚀"
skipBtn.Parent   = frame

-- Dynamic pricing from EconomyBrain
task.spawn(function()
    while true do
        local pol = _G.GetBrainPolicy and _G.GetBrainPolicy(player)
        if pol then
            reviveBtn.Text = string.format("Revive 💀 (x%.1f)", pol.revive or 1)
            skipBtn.Text   = string.format("Skip 🚀 (x%.1f)",   pol.skip   or 1)
            status.Text    = "Mode: " .. (pol.mode or "STANDARD")
        end
        task.wait(3)
    end
end)

reviveBtn.MouseButton1Click:Connect(function()
    MarketplaceService:PromptProductPurchase(player, PRODUCTS.REVIVE)
end)
skipBtn.MouseButton1Click:Connect(function()
    MarketplaceService:PromptProductPurchase(player, PRODUCTS.SKIP)
end)

-- Auto-prompt on death
local function hookChar(char)
    char:WaitForChild("Humanoid").Died:Connect(function()
        task.wait(1.5)
        MarketplaceService:PromptProductPurchase(player, PRODUCTS.REVIVE)
    end)
end

if player.Character then hookChar(player.Character) end
player.CharacterAdded:Connect(hookChar)
