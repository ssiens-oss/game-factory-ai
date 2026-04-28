local RevenueEngine = require(script.Parent.Parent.economy.RevenueEngine)

local Difficulty = {}
local base = 1.0

function Difficulty.compute(player, stats)
	local signals = RevenueEngine.evaluate(player, stats)

	local adjusted = base * (signals.difficultyMultiplier or 1.0)

	-- clamp system (prevents impossible levels)
	if adjusted < 0.6 then adjusted = 0.6 end
	if adjusted > 2.2 then adjusted = 2.2 end

	return adjusted, signals
end

return Difficulty
