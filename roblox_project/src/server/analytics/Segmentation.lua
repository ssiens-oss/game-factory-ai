local Segmentation = {}

function Segmentation.classify(stats)
	local deaths = stats.deaths or 0
	local time = stats.time or 0
	local skips = stats.skips or 0

	-- simple heuristic model (upgradeable later to ML)
	if deaths > 10 and time < 120 then
		return "casual_churn_risk"
	elseif deaths < 5 and time > 300 then
		return "engaged"
	elseif skips > 2 then
		return "monetizable_user"
	else
		return "standard"
	end
end

return Segmentation
