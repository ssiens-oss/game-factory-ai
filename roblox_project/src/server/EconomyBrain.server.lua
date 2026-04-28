local Players = game:GetService("Players")

local state = {}

local function score(s)
    local ltv = (s.time or 1)*0.04 + (s.purchases or 0)*12
                + (s.progress or 1)*1.8 - (s.deaths or 0)*0.25
    local churn = math.clamp(
        (s.time or 60) < 60 and 0.4 or 0 +
        (s.deaths or 0) > 10 and 0.3 or 0 +
        (s.progress or 5) < 3 and 0.3 or 0, 0, 1)
    return ltv, churn
end

local function decide(ltv, churn)
    if ltv > 25 and churn > 0.6 then
        return {mode="SAVE",      revive=0.5, skip=0.6, diff=0.85}
    elseif ltv > 10 then
        return {mode="OPTIMIZE",  revive=1.0, skip=1.1, diff=1.05}
    elseif churn > 0.7 then
        return {mode="RETENTION", revive=0.7, skip=0.7, diff=0.80, disableMono=true}
    end
    return     {mode="STANDARD",  revive=1.0, skip=1.0, diff=1.0}
end

Players.PlayerAdded:Connect(function(p)
    state[p.UserId] = {time=0, deaths=0, progress=0, purchases=0}
    task.spawn(function()
        while p.Parent do
            state[p.UserId].time += 1
            task.wait(1)
        end
    end)
end)

_G.BRAIN_TrackDeath = function(p) if state[p.UserId] then state[p.UserId].deaths += 1 end end
_G.BRAIN_TrackProgress = function(p,a) if state[p.UserId] then state[p.UserId].progress += a end end
_G.BRAIN_TrackPurchase = function(p) if state[p.UserId] then state[p.UserId].purchases += 1 end end

_G.GetBrainPolicy = function(player)
    local s = state[player.UserId]
    if not s then return {mode="STANDARD",revive=1,skip=1,diff=1} end
    local ltv, churn = score(s)
    return decide(ltv, churn)
end

task.spawn(function()
    while true do
        for _, p in ipairs(Players:GetPlayers()) do
            local s = state[p.UserId]
            if s then
                local ltv, churn = score(s)
                local pol = decide(ltv, churn)
                print(string.format("💰 %s | mode=%s ltv=%.1f churn=%.2f", p.Name, pol.mode, ltv, churn))
            end
        end
        task.wait(10)
    end
end)
