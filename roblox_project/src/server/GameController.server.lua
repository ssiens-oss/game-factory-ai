local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local BACKEND = "http://127.0.0.1:8000"
local sessions = {}

Players.PlayerAdded:Connect(function(player)
    sessions[player.UserId] = { deaths = 0, start = os.clock() }
    player.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid")
        hum.Died:Connect(function()
            sessions[player.UserId].deaths += 1
            pcall(function()
                HttpService:PostAsync(BACKEND .. "/telemetry",
                    HttpService:JSONEncode({ type="death", userId=player.UserId }),
                    Enum.HttpContentType.ApplicationJson)
            end)
        end)
    end)
end)

Players.PlayerRemoving:Connect(function(player)
    local s = sessions[player.UserId]
    if not s then return end
    local playtime = os.clock() - s.start
    pcall(function()
        HttpService:PostAsync(BACKEND .. "/telemetry",
            HttpService:JSONEncode({
                type    = "session_end",
                userId  = player.UserId,
                playtime = playtime,
                deaths  = s.deaths
            }), Enum.HttpContentType.ApplicationJson)
    end)
    sessions[player.UserId] = nil
end)
