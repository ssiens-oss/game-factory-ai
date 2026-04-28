local Players = game:GetService("Players")

-- 🔧 Live pricing state
local Pricing = {
    revive = 10,
    skip = 25,
    discountChance = 0.1
}

-- 📊 per-player telemetry buffer
local stats = {} -- [userId] = { deaths, time, retries, skips }

local function init(player)
    stats[player.UserId] = {
        deaths = 0,
        time = 0,
        retries = 0,
        skips = 0
    }
end

Players.PlayerAdded:Connect(init)

Players.PlayerRemoving:Connect(function(p)
    stats[p.UserId] = nil
end)

-- 📡 EVENT HOOKS (call from your systems)
_G.RL_TrackDeath = function(player)
    local s = stats[player.UserId]
    if s then s.deaths += 1 end
end

_G.RL_TrackSkip = function(player)
    local s = stats[player.UserId]
    if s then s.skips += 1 end
end

_G.RL_TrackRetry = function(player)
    local s = stats[player.UserId]
    if s then s.retries += 1 end
end

-- 🧠 REWARD FUNCTION (proxy for monetization value)
local function computeReward(s)
    if not s then return 0 end

    return (
        (s.deaths * 0.2) +
        (s.skips * 1.5) +
        (s.retries * 0.3)
    )
end

-- 🎛 POLICY UPDATE LOOP
task.spawn(function()
    while true do
        local totalReward = 0
        local count = 0

        for _, s in pairs(stats) do
            totalReward += computeReward(s)
            count += 1
        end

        local avg = count > 0 and (totalReward / count) or 0

        -- 📈 HIGH ENGAGEMENT → raise prices slightly
        if avg > 3 then
            Pricing.revive *= 1.05
            Pricing.skip *= 1.03

        -- 📉 LOW ENGAGEMENT → reduce friction
        elseif avg < 1.5 then
            Pricing.revive *= 0.92
            Pricing.skip *= 0.90
        end

        -- clamp
        Pricing.revive = math.clamp(Pricing.revive, 5, 50)
        Pricing.skip = math.clamp(Pricing.skip, 10, 100)

        print("💰 RL Pricing Update:", Pricing)

        task.wait(10)
    end
end)

-- 🔌 expose for shop UI
_G.GetPricing = function()
    return Pricing
end

return true
