local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 160)
frame.Position = UDim2.new(0, 20, 0, 200)
frame.Parent = gui

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 0.25, 0)
label.Parent = frame

local revive = Instance.new("TextButton")
revive.Size = UDim2.new(1, 0, 0.35, 0)
revive.Position = UDim2.new(0, 0, 0.25, 0)
revive.Parent = frame

local skip = Instance.new("TextButton")
skip.Size = UDim2.new(1, 0, 0.35, 0)
skip.Position = UDim2.new(0, 0, 0.6, 0)
skip.Parent = frame

local function refresh()
    local pricing = _G.ECO_GetPricing and _G.ECO_GetPricing(player) or {revive=10, skip=25}
    local segment = _G.ECO_GetSegment and _G.ECO_GetSegment(player) or "CASUAL"

    label.Text = "Segment: " .. segment
    revive.Text = "Revive 💀 (" .. math.floor(pricing.revive) .. ")"
    skip.Text = "Skip 🚀 (" .. math.floor(pricing.skip) .. ")"
end

revive.MouseButton1Click:Connect(function()
    MarketplaceService:PromptProductPurchase(player, 1234567890)
end)

skip.MouseButton1Click:Connect(function()
    MarketplaceService:PromptProductPurchase(player, 1234567891)
end)

task.spawn(function()
    while true do
        refresh()
        task.wait(2)
    end
end)
