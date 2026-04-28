local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")

local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 120)
frame.Position = UDim2.new(0.5, -110, 0.7, 0)
frame.Visible = false
frame.Parent = gui

local text = Instance.new("TextLabel")
text.Size = UDim2.new(1, 0, 0.5, 0)
text.Parent = frame

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(1, 0, 0.5, 0)
btn.Position = UDim2.new(0, 0, 0.5, 0)
btn.Text = "Buy"
btn.Parent = frame

local function showOffer()
    local offer = _G.GetOfferPack and _G.GetOfferPack(player)
    if not offer then return end

    frame.Visible = true
    text.Text = "Special Offer!"
    btn.Text = "Revive Boost (" .. tostring(offer.revive * 10) .. ")"
end

btn.MouseButton1Click:Connect(function()
    MarketplaceService:PromptProductPurchase(player, 1234567890)
end)

-- reactive trigger from server
task.spawn(function()
    while true do
        if _G.TriggerOffer == player then
            _G.TriggerOffer = nil
            showOffer()
        end
        task.wait(1)
    end
end)
