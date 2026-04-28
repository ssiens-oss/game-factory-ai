local Players = game:GetService("Players")

local Data = {}

Players.PlayerAdded:Connect(function(player)
	Data[player.UserId] = {
		deaths = 0,
		timeStart = os.clock(),
		skips = 0
	}
end)

_G.TrackDeath = function(player)
	local d = Data[player.UserId]
	if d then d.deaths += 1 end
end

_G.TrackSkip = function(player)
	local d = Data[player.UserId]
	if d then d.skips += 1 end
end

_G.GetStats = function(player)
	local d = Data[player.UserId]
	if not d then return {} end

	d.time = os.clock() - d.timeStart
	d.player = player

	return d
end

return Data
