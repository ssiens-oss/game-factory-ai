local Players = game:GetService("Players")

-- 📊 player state memory
local state = {} -- [userId] = metrics

-- 💰 base pricing
local BASE = {
    revive = 10,
    skip = 25
}

-- 🧠 segmentation output
local function segmentPlayer(s)
    local engagement = (s.time or 0) / math.max(1, (s.sessions or 1))
    local deaths = s.deaths or 0
    local purchases = s.purchases or 0

    if purchases >= 5 and engagement > 120 then
        return "WHALE"
    end

    if engagement > 200 and purchases <= 1 then
        return "GRINDER"
    end

    if deaths > 20 and engagement < 60 then
        return "FRUSTRATED"
    end

    return "CASUAL"
end

-- 💸 pricing multiplier per segment
local function pricingMultiplier(segment)
    if segment == "WHALE" then
        return 1.4 -- can tolerate higher prices
    elseif segment == "GRINDER" then
        return 0.85 -- needs lower friction
    elseif segment == "FRUSTRATED" then
        return 0.65 -- heavily discounted
    else
        return 1.0
    end
end

-- 📡 update hooks (call from gameplay)
_G.ECO_TrackDeath = function(player)
    local s = state[player.UserId] or {}
    s.deaths = (s.deaths or 0) + 1
    state[player.UserId] = s
end

_G.ECO_TrackTime = function(player, delta)
    local s = state[player.UserId] or {}
    s.time = (s.time or 0) + delta
    state[player.UserId] = s
end

_G.ECO_TrackPurchase = function(player)
    local s = state[player.UserId] or {}
    s.purchases = (s.purchases or 0) + 1
    state[player.UserId] = s
end

-- 🧠 main RL loop
task.spawn(function()
    while true do
        for _, player in ipairs(Players:GetPlayers()) do
            local s = state[player.UserId] or {}
            s.sessions = (s.sessions or 0) + 1

            local segment = segmentPlayer(s)
            s.segment = segment

            local mult = pricingMultiplier(segment)

            s.pricing = {
                revive = BASE.revive * mult,
                skip = BASE.skip * mult
            }

            state[player.UserId] = s
        end

        task.wait(5)
    end
end)

-- 🔌 API for UI
_G.ECO_GetPricing = function(player)
    local s = state[player.UserId]
    if not s then
        return BASE
    end
    return s.pricing or BASE
end

_G.ECO_GetSegment = function(player)
    local s = state[player.UserId]
    return s and s.segment or "CASUAL"
end

return true
