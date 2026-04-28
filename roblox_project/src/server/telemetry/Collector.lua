local Stats = {
	deaths = 0,
	runs = 0,
}

_G.TrackDeath = function()
	Stats.deaths += 1
end

function Stats.snapshot()
	return {
		deaths = Stats.deaths,
		runs = Stats.runs,
	}
end

return Stats
