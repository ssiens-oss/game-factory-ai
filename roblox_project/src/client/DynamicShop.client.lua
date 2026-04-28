local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 140)
frame.Position = UDim2.new(0, 20, 0, 200)
frame.Parent = gui

local reviveBtn = Instance.new("TextButton")
reviveBtn.Size = UDim2.new(1, 0, 0.5, 0)
reviveBtn.Parent = frame

local skipBtn = Instance.new("TextButton")
skipBtn.Size = UDim2.new(1, 0, 0.5, 0)
skipBtn.Position = UDim2.new(0, 0, 0.5, 0)
skipBtn.Parent = frame

local function refresh()
    local pricing = _G.GetPricing and _G.GetPricing() or { revive = 10, skip = 25 }

    reviveBtn.Text = "Revive 💀 (" .. math.floor(pricing.revive) .. ")"
    skipBtn.Text = "Skip 🚀 (" .. math.floor(pricing.skip) .. ")"
end

reviveBtn.MouseButton1Click:Connect(function()
    local pricing = _G.GetPricing()
    MarketplaceService:PromptProductPurchase(player, 1234567890)
end)

skipBtn.MouseButton1Click:Connect(function()
    local pricing = _G.GetPricing()
    MarketplaceService:PromptProductPurchase(player, 1234567891)
end)

task.spawn(function()
    while true do
        refresh()
        task.wait(2)
    end
end)
