local Players = game:GetService("Players")

local Bandit = {}

-- 🎯 arms (economic strategies)
local arms = {
    A = { pulls = 1, reward = 1 }, -- conservative
    B = { pulls = 1, reward = 1 }, -- aggressive
    C = { pulls = 1, reward = 1 }, -- retention-first
    D = { pulls = 1, reward = 1 }, -- balanced (default brain)
}

-- 🧠 player → assigned arm
local assignment = {}

-- 📊 reward function (real proxy signal)
local function computeReward(s)
    return (
        (s.time or 0) * 0.02 +
        (s.purchases or 0) * 5 +
        (s.progress or 0) * 1.5 -
        (s.deaths or 0) * 0.2
    )
end

-- 🎯 UCB1 selection
local function selectArm()
    local total = 0
    for _, a in pairs(arms) do
        total += a.pulls
    end

    local bestArm = "D"
    local bestScore = -math.huge

    for name, a in pairs(arms) do
        local avg = a.reward / math.max(1, a.pulls)
        local confidence = math.sqrt(2 * math.log(total + 1) / a.pulls)

        local score = avg + confidence

        if score > bestScore then
            bestScore = score
            bestArm = name
        end
    end

    return bestArm
end

-- 📡 assign arm per player session
Players.PlayerAdded:Connect(function(p)
    assignment[p.UserId] = selectArm()
end)

-- 🔌 API
_G.GetBanditArm = function(player)
    return assignment[player.UserId] or "D"
end

-- 🎯 update rewards periodically
task.spawn(function()
    while true do
        for _, p in ipairs(Players:GetPlayers()) do
            local s = _G.BRAIN_STATE and _G.BRAIN_STATE[p.UserId]
            if s then
                local arm = assignment[p.UserId]
                if arm then
                    arms[arm].reward += computeReward(s)
                    arms[arm].pulls += 1
                end
            end
        end
        task.wait(10)
    end
end)

return Bandit
