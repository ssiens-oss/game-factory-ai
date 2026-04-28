local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Builder = require(script.Parent.generator.LevelBuilder)
local Bots = require(script.Parent.sim.BotRunner)
local Telemetry = require(script.Parent.telemetry.Collector)

local CONTROL_PATH = "control/control.json"
local TELEMETRY_PATH = "control/telemetry.json"

local function readControl()
	local ok, content = pcall(readfile, CONTROL_PATH)
	if not ok or not content then return nil end
	local ok2, data = pcall(HttpService.JSONDecode, HttpService, content)
	if not ok2 then return nil end
	return data
end

local function writeControl(data)
	local json = HttpService:JSONEncode(data)
	writefile(CONTROL_PATH, json)
end

local function writeTelemetry(data)
	local json = HttpService:JSONEncode(data)
	writefile(TELEMETRY_PATH, json)
end

local function clearMap()
	for _, v in ipairs(workspace:GetChildren()) do
		if v.Name == "AI_OBBY" then
			v:Destroy()
		end
	end
end

local function runSimulation(ctrl)
	ctrl.status = "running"
	writeControl(ctrl)

	-- Build level
	clearMap()
	local spec = ctrl.spec or {}
	local seed = spec.seed or os.time()
	local difficulty = spec.difficulty or 1.0

	Builder.build(seed, {difficulty = difficulty})

	-- Run bots
	local agents = spec.agents or 50
	local duration = spec.duration or 60

	Bots.run({agents = agents, duration = duration})

	task.wait(duration + 2)

	-- Collect telemetry
	local stats = Telemetry.snapshot and Telemetry.snapshot() or {
		deaths = Telemetry.deaths or 0
	}

	local out = {
		run_id = ctrl.run_id,
		stats = stats,
		timestamp = os.time()
	}

	writeTelemetry(out)

	ctrl.status = "done"
	writeControl(ctrl)

	print("✅ Simulation done:", ctrl.run_id)
end

-- Poll loop
task.spawn(function()
	while true do
		local ctrl = readControl()

		if ctrl and ctrl.status == "pending" then
			print("🚀 Starting run:", ctrl.run_id)
			runSimulation(ctrl)
		end

		task.wait(2)
	end
end)
