local Currency = require(script.Parent.CurrencyService)

local Monetization = {}

function Monetization.rewardPlayer(player, difficulty)
	local reward = math.floor(10 * difficulty)
	_G.AddCoins(player, reward)
end

function Monetization.skipSegment(player)
	local w = _G.GetWallet(player)
	if w and w.premiumSkips > 0 then
		w.premiumSkips -= 1
		return true
	end
	return false
end

function Monetization.buyRevive(player)
	local w = _G.GetWallet(player)
	if w and w.coins >= 50 then
		w.coins -= 50
		w.revives += 1
		return true
	end
	return false
end

return Monetization
