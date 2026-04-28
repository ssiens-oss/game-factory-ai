local Difficulty = {}

local globalDifficulty = 1.0

function Difficulty.update(stats)
	local avgDeaths = stats.deaths / math.max(1, stats.sessions or 1)

	if avgDeaths > 5 then
		globalDifficulty *= 0.85
	elseif avgDeaths < 2 then
		globalDifficulty *= 1.1
	end

	globalDifficulty = math.clamp(globalDifficulty, 0.6, 2.0)

	return globalDifficulty
end

function Difficulty.get()
	return globalDifficulty
end

return Difficulty
