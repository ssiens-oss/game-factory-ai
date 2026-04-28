local Players = game:GetService("Players")

local LiveOps = {}

-- 📦 versioned economy configs
local Versions = {
    v1 = {
        reviveMult = 1.0,
        skipMult = 1.0,
        difficultyMult = 1.0
    }
}

local activeVersion = "v1"

-- 📊 rollout state
local rollout = {
    v1 = 1.0 -- 100% traffic initially
}

-- 📈 metrics tracking per version
local metrics = {
    v1 = { revenue = 0, retention = 0, churn = 0, samples = 0 }
}

-- 🎯 assign version per player (A/B logic)
local function assignVersion(player)
    local r = (player.UserId % 100) / 100

    local cumulative = 0
    for v, pct in pairs(rollout) do
        cumulative += pct
        if r <= cumulative then
            return v
        end
    end

    return activeVersion
end

-- 🔌 API: get active economy policy for player
_G.GetLiveOpsPolicy = function(player)
    local version = assignVersion(player)
    return Versions[version], version
end

-- 📡 report metrics (from gameplay)
_G.LiveOps_Report = function(version, revenue, retention, churn)
    local m = metrics[version]
    if not m then return end

    m.revenue += revenue
    m.retention += retention
    m.churn += churn
    m.samples += 1
end

-- 🧠 evaluate versions
local function evaluate()
    local bestVersion = activeVersion
    local bestScore = -math.huge

    for v, m in pairs(metrics) do
        if m.samples > 0 then
            local avgRevenue = m.revenue / m.samples
            local avgRetention = m.retention / m.samples
            local avgChurn = m.churn / m.samples

            local score = avgRevenue + (avgRetention * 2) - (avgChurn * 3)

            if score > bestScore then
                bestScore = score
                bestVersion = v
            end
        end
    end

    return bestVersion
end

-- 🚀 rollout controller loop
task.spawn(function()
    while true do
        local best = evaluate()

        -- 🧠 promote best version
        activeVersion = best

        -- 🎯 soft rollout (exploration still exists)
        for v, _ in pairs(Versions) do
            if v == best then
                rollout[v] = math.min(0.7, (rollout[v] or 0.3) + 0.05)
            else
                rollout[v] = math.max(0.1, (rollout[v] or 0.3) - 0.05)
            end
        end

        print("🚀 LiveOps Active Version:", activeVersion)
        task.wait(15)
    end
end)

return LiveOps
