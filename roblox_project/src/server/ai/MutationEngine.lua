local Generator = require(script.Parent.Parent.generator.LevelGenerator)
local Difficulty = require(script.Parent.DifficultyController)

local Mutation = {}

function Mutation.generate(seed, stats)
	local diff = Difficulty.update(stats)

	local level = Generator.generate(seed, 30)

	for _, seg in ipairs(level) do
		-- mutate based on difficulty
		seg.difficulty *= diff
	end

	return level
end

return Mutation
