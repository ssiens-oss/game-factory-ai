local Players = game:GetService("Players")
local player = Players.LocalPlayer

local coins = Instance.new("IntValue")
coins.Name = "Coins"
coins.Value = 0
coins.Parent = player

local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 200, 0, 40)
label.Position = UDim2.new(0, 20, 0, 20)
label.Text = "Coins: 0"
label.Parent = gui

coins:GetPropertyChangedSignal("Value"):Connect(function()
    label.Text = "Coins: " .. coins.Value
end)
