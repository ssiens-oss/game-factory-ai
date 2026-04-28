local Segmentation = require(script.Parent.Parent.analytics.Segmentation)

local RevenueEngine = {}

function RevenueEngine.evaluate(player, stats)
	local segment = Segmentation.classify(stats)

	local signals = {
		showSkipOffer = false,
		showReviveOffer = false,
		difficultyMultiplier = 1.0
	}

	if segment == "casual_churn_risk" then
		signals.showReviveOffer = true
		signals.difficultyMultiplier = 0.75

	elseif segment == "engaged" then
		signals.difficultyMultiplier = 1.0

	elseif segment == "monetizable_user" then
		signals.showSkipOffer = true
		signals.difficultyMultiplier = 1.2
	end

	return signals
end

return RevenueEngine
