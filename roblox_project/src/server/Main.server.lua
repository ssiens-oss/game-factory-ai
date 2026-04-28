print("🧠 SELF-OPTIMIZING OBBY FACTORY ONLINE")

local Builder = require(script.Parent.generator.LevelBuilder)
local Stats = require(script.Parent.telemetry.Tracker)

local seed = os.time() % 9999

while true do
	task.wait(60) -- rebuild every minute using live behavior

	Builder.build(seed, Stats)

	print("♻️ Level regenerated from player behavior")
end
