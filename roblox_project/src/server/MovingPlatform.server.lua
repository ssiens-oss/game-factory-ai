local TweenService = game:GetService("TweenService")

local function move(part)
	local start = part.Position
	local goal = start + Vector3.new(0, 0, 20)

	while true do
		local t1 = TweenService:Create(part, TweenInfo.new(2), {Position = goal})
		t1:Play()
		t1.Completed:Wait()

		local t2 = TweenService:Create(part, TweenInfo.new(2), {Position = start})
		t2:Play()
		t2.Completed:Wait()
	end
end

for _, v in pairs(workspace:GetDescendants()) do
	if v.Name == "MovingPlatform" then
		task.spawn(move, v)
	end
end
