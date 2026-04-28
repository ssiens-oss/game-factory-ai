local HttpService = game:GetService("HttpService")

local currentConfig = {
    reviveMult = 1,
    skipMult = 1,
    difficultyMult = 1,
    version = 0
}

-- 📡 pull latest config from datastore (or cached replication)
local function fetchConfig()
    local success, result = pcall(function()
        -- In real Open Cloud setup, you'd use DataStore:GetAsync or MemoryStore
        local response = HttpService:GetAsync("https://example.com/live-economy")
        return HttpService:JSONDecode(response)
    end)

    if success and result then
        currentConfig = result
    end
end

-- 🧠 expose unified economy API
_G.GetRemoteEconomy = function()
    return currentConfig
end

-- 🔁 polling loop (live patching system)
task.spawn(function()
    while true do
        fetchConfig()
        print("📡 Live Economy Updated:", currentConfig.version)
        task.wait(10)
    end
end)
