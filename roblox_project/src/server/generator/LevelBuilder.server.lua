local Workspace = game:GetService("Workspace")

local LevelGenerator = require(script.Parent.LevelGenerator)
local Difficulty = require(script.Parent.Parent.ai.DynamicDifficulty)
local RevenueEngine = require(script.Parent.Parent.economy.RevenueEngine)

local Builder = {}

function Builder.build(seed, playerStats)

	local difficulty, signals = Difficulty.compute(playerStats.player, playerStats)

	local level = LevelGenerator.generate(seed, 30)

	local pos = Vector3.new(0, 5, 0)

	for _, seg in ipairs(level) do

		pos += Vector3.new(0, seg.difficulty * 4 * difficulty, 12)

		local part = Instance.new("Part")
		part.Size = Vector3.new(10,1,10)
		part.Position = pos
		part.Anchored = true
		part.Parent = Workspace

		-- economic signal encoding
		if signals.showSkipOffer then
			part.Color = Color3.fromRGB(255, 200, 0) -- "monetization zone"
		else
			part.Color = Color3.fromHSV(seg.difficulty, 1, 1)
		end
	end
end

return Builder
