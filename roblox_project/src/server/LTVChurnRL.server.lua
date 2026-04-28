local Players = game:GetService("Players")

-- 📊 per-player memory
local state = {} -- [userId] = metrics

-- 🧠 LTV MODEL (heuristic proxy, replaceable with ML later)
local function estimateLTV(s)
    local engagement = (s.time or 1)
    local deaths = s.deaths or 0
    local purchases = s.purchases or 0
    local progression = s.progress or 1

    return (
        (engagement * 0.05) +
        (purchases * 15) +
        (progression * 2) -
        (deaths * 0.3)
    )
end

-- ⚠️ churn risk model
local function churnRisk(s)
    local shortSession = (s.time or 0) < 60
    local highDeaths = (s.deaths or 0) > 10
    local noProgress = (s.progress or 0) < 3

    local risk = 0

    if shortSession then risk += 0.4 end
    if highDeaths then risk += 0.3 end
    if noProgress then risk += 0.3 end

    return math.clamp(risk, 0, 1)
end

-- 🎯 intervention policy
local function intervention(player, s)
    local risk = churnRisk(s)
    local ltv = estimateLTV(s)

    -- high-value + high-risk → save aggressively
    if ltv > 25 and risk > 0.6 then
        return {
            type = "SAVE_HIGH_VALUE",
            discount = 0.5,
            trigger = "REVIVE_BUNDLE"
        }
    end

    -- medium value + rising churn → soft intervention
    if ltv > 10 and risk > 0.5 then
        return {
            type = "SAVE_MEDIUM",
            discount = 0.75,
            trigger = "SKIP_DISCOUNT"
        }
    end

    -- low value churn → ignore monetization pressure
    if risk > 0.7 then
        return {
            type = "RETENTION_ONLY",
            disable_offers = true
        }
    end

    return {
        type = "NORMAL"
    }
end

-- 📡 hooks from gameplay
_G.LTV_TrackDeath = function(player)
    local s = state[player.UserId] or {}
    s.deaths = (s.deaths or 0) + 1
    state[player.UserId] = s
end

_G.LTV_TrackProgress = function(player, amount)
    local s = state[player.UserId] or {}
    s.progress = (s.progress or 0) + amount
    state[player.UserId] = s
end

_G.LTV_TrackPurchase = function(player)
    local s = state[player.UserId] or {}
    s.purchases = (s.purchases or 0) + 1
    state[player.UserId] = s
end

-- ⏱ session tracking
Players.PlayerAdded:Connect(function(p)
    state[p.UserId] = {
        time = 0,
        deaths = 0,
        progress = 0,
        purchases = 0
    }

    task.spawn(function()
        while p.Parent do
            state[p.UserId].time += 1
            task.wait(1)
        end
    end)
end)

-- 🔁 MAIN RL LOOP
task.spawn(function()
    while true do
        for _, player in ipairs(Players:GetPlayers()) do
            local s = state[player.UserId]
            if s then
                local policy = intervention(player, s)

                -- expose to UI / monetization system
                _G.LTV_Policy = _G.LTV_Policy or {}
                _G.LTV_Policy[player.UserId] = policy
            end
        end

        task.wait(5)
    end
end)

-- 🔌 API
_G.GetLTVPolicy = function(player)
    return (_G.LTV_Policy and _G.LTV_Policy[player.UserId]) or { type = "NORMAL" }
end

return true
