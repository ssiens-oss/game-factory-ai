local GameRegistry = require(game:GetService("ReplicatedStorage").GameRegistry)

local function applyGenreModifiers(policy, gameType)
    local g = GameRegistry[gameType]

    if not g then return policy end

    -- 🎮 horror = panic monetization (higher urgency pricing)
    if gameType == "HORROR" then
        policy.reviveMult *= 1.3
        policy.skipMult *= 1.2

    -- 🧠 tycoon = long-term monetization
    elseif gameType == "TYCOON" then
        policy.reviveMult *= 0.8
        policy.skipMult *= 0.9

    -- ⚙️ physics sandbox = low pressure monetization
    elseif gameType == "PHYSICS" then
        policy.reviveMult *= 0.6

    -- 🚗 gta style = cosmetic-driven economy
    elseif gameType == "GTA_STYLE" then
        policy.skipMult *= 0.7
    end

    return policy
end

_G.ApplyGenreEconomy = applyGenreModifiers
