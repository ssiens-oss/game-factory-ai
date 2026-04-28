local BotRunner = {}

local function createBot(i)
	local model = Instance.new("Model")
	model.Name = "Bot_" .. i

	local root = Instance.new("Part")
	root.Name = "HumanoidRootPart"
	root.Size = Vector3.new(2,2,1)
	root.Position = Vector3.new(0,5,0)
	root.Parent = model

	local humanoid = Instance.new("Humanoid")
	humanoid.Parent = model

	model.Parent = workspace
	return model
end

local function simulate(bot, duration)
	local root = bot:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local t0 = os.clock()
	while os.clock() - t0 < duration do
		root.Position += Vector3.new(0, 0, 5)
		task.wait(0.1)

		if math.random() < 0.1 then
			_G.TrackDeath and _G.TrackDeath(bot)
		end
	end
end

function BotRunner.run(config)
	for i = 1, config.agents do
		local bot = createBot(i)
		task.spawn(simulate, bot, config.duration or 60)
	end
end

return BotRunner
