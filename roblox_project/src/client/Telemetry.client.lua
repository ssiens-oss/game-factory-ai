local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local URL = "http://127.0.0.1:8001/event"
local player = Players.LocalPlayer

local function send(event, value)
    local payload = {
        player = player.Name,
        event = event,
        value = value or 0
    }
    pcall(function()
        HttpService:PostAsync(URL, HttpService:JSONEncode(payload), Enum.HttpContentType.ApplicationJson)
    end)
end

-- basic signals
player.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    hum.Died:Connect(function()
        send("death", 1)
    end)
end)

-- heartbeat session time
task.spawn(function()
    while true do
        send("session_time", 1)
        task.wait(5)
    end
end)
