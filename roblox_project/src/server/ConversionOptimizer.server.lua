local Players = game:GetService("Players")

local Offers = {
    LOW = { revive = 0.8, skip = 1.0 },
    MID = { revive = 1.0, skip = 1.2 },
    HIGH = { revive = 1.3, skip = 1.6 },
}

local state = {}

local function getSegment(s)
    if s.deaths > 15 then return "HIGH" end
    if s.time < 60 then return "LOW" end
    return "MID"
end

_G.GetOfferPack = function(player)
    local s = state[player.UserId]
    if not s then return Offers.LOW end

    local seg = getSegment(s)
    return Offers[seg]
end

_G.TrackDeath = function(player)
    local s = state[player.UserId] or { deaths = 0, time = 0 }
    s.deaths += 1
    state[player.UserId] = s
end

task.spawn(function()
    while true do
        for _, p in ipairs(Players:GetPlayers()) do
            state[p.UserId] = state[p.UserId] or { deaths = 0, time = 0 }
            state[p.UserId].time += 1
        end
        task.wait(1)
    end
end)

return true
