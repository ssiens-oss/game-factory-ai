local Players = game:GetService("Players")

-- per-session memory
local session = {} -- [userId] = state

-- config knobs (RL output)
local Policy = {
    difficultyBoost = 1.0,
    offerFrequency = 10, -- seconds
    frustrationThreshold = 0.7,
}

-- initialize session
local function init(player)
    session[player.UserId] = {
        deaths = 0,
        time = 0,
        lastOffer = 0,
        frustration = 0,
        completed = false,
    }
end

Players.PlayerAdded:Connect(init)

Players.PlayerRemoving:Connect(function(p)
    session[p.UserId] = nil
end)

-- 📡 hooks from gameplay
_G.RL_Death = function(player)
    local s = session[player.UserId]
    if s then
        s.deaths += 1
        s.frustration += 0.15
    end
end

_G.RL_Progress = function(player, amount)
    local s = session[player.UserId]
    if s then
        s.frustration -= amount
    end
end

-- 🧠 REAL-TIME RL LOOP
task.spawn(function()
    while true do
        for _, player in ipairs(Players:GetPlayers()) do
            local s = session[player.UserId]
            if s then
                s.time += 1

                -- normalize
                s.frustration = math.clamp(s.frustration, 0, 1)

                -- 🎚 difficulty adaptation
                if s.frustration > Policy.frustrationThreshold then
                    Policy.difficultyBoost *= 0.98
                else
                    Policy.difficultyBoost *= 1.01
                end

                Policy.difficultyBoost = math.clamp(Policy.difficultyBoost, 0.6, 2.0)

                -- 💰 offer trigger timing (adaptive)
                local now = os.clock()
                if now - s.lastOffer > Policy.offerFrequency then
                    s.lastOffer = now

                    -- expose trigger for UI
                    _G.TriggerOffer = player
                end
            end
        end

        task.wait(3)
    end
end)

-- 🔌 API
_G.GetSessionPolicy = function()
    return Policy
end

return true
