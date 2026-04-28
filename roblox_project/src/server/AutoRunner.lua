local Players = game:GetService("Players")

print("🚀 AutoRunner started")

-- simulate fake players
for i = 1, 10 do
    print("Simulating player", i)
end

-- simple metric
local retention = math.random()

-- write to file via HttpService (to your Python backend)
local HttpService = game:GetService("HttpService")

local success, err = pcall(function()
    HttpService:PostAsync(
        "http://127.0.0.1:8000/metrics",
        HttpService:JSONEncode({
            retention = retention,
            timestamp = os.time()
        }),
        Enum.HttpContentType.ApplicationJson
    )
end)

print("Metrics sent:", success, err)

wait(5)

print("🛑 Shutting down test run")
game:Shutdown()
