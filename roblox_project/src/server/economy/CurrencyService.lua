local Players = game:GetService("Players")

local Wallets = {}

Players.PlayerAdded:Connect(function(player)
	Wallets[player.UserId] = {
		coins = 0,
		premiumSkips = 0,
		revives = 1
	}
end)

function _G.AddCoins(player, amount)
	local w = Wallets[player.UserId]
	if w then
		w.coins += amount
	end
end

function _G.SpendCoins(player, amount)
	local w = Wallets[player.UserId]
	if w and w.coins >= amount then
		w.coins -= amount
		return true
	end
	return false
end

function _G.GetWallet(player)
	return Wallets[player.UserId]
end

return Wallets
