local Hazards = require(script.Parent.Parent.hazards.HazardLibrary)

local LevelGenerator = {}

local function rand(seed, i)
	return math.abs(math.sin(seed + i) * 10000) % 1
end

function LevelGenerator.generate(seed, length)
	local segments = {}

	for i = 1, length do
		local difficulty = i / length

		table.insert(segments, {
			type = Hazards.getRandom(seed, i),
			difficulty = difficulty
		})
	end

	return segments
end

return LevelGenerator
