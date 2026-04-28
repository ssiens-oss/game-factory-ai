local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 240, 0, 140)
frame.Position = UDim2.new(0.5, -120, 0.7, 0)
frame.Visible = false
frame.Parent = gui

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 0.5, 0)
label.Parent = frame

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, 0, 0.5, 0)
btn.Position = UDim2.new(0, 0, 0.5, 0)
btn.Parent = frame

local function refresh()
    local policy = _G.GetLTVPolicy and _G.GetLTVPolicy(player)
    if not policy then return end

    if policy.type == "SAVE_HIGH_VALUE" then
        frame.Visible = true
        label.Text = "🔥 Special Save Offer"
        btn.Text = "Revive Bundle (-50%)"

    elseif policy.type == "SAVE_MEDIUM" then
        frame.Visible = true
        label.Text = "⚡ Limited Discount"
        btn.Text = "Skip Boost (-25%)"

    else
        frame.Visible = false
    end
end

btn.MouseButton1Click:Connect(function()
    MarketplaceService:PromptProductPurchase(player, 1234567890)
end)

task.spawn(function()
    while true do
        refresh()
        task.wait(2)
    end
end)
