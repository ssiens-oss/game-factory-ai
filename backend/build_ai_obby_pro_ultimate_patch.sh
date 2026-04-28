#!/usr/bin/env bash
set -e

PLUGIN="$PWD/sellable_plugins/AIObbyGeneratorPro.lua"
PATCHED="$PWD/sellable_plugins/AIObbyGeneratorPro_Ultimate.lua"

if [ ! -f "$PLUGIN" ]; then
  echo "ERROR: Missing $PLUGIN"
  exit 1
fi

python3 - "$PLUGIN" "$PATCHED" <<'PY'
from pathlib import Path
import sys

src = Path(sys.argv[1])
dst = Path(sys.argv[2])

code = src.read_text(encoding="utf-8", errors="ignore")

banner = '''
-- =====================================================
-- AI OBBY GENERATOR PRO - ULTIMATE EDITION
-- Added:
-- Monetization Hooks
-- DataStore Saving
-- Polish Pack
-- Theme Packs
-- Creator Onboarding
-- Free / Pro Gating
-- =====================================================

'''

if "ULTIMATE EDITION" not in code:
    code = banner + code

inject = r'''

-- ===============================
-- ULTIMATE PATCH MODULES
-- ===============================

local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local SaveStore = DataStoreService:GetDataStore("AIObbyPro_Ultimate_v1")

local Ultimate = {
	IsPro = true, -- set false for free mode
	Gamepasses = {
		SkipStage = 100001,
		Revive = 100002,
		DoubleCoins = 100003,
		VIPTrail = 100004,
		SpeedBoost = 100005,
	}
}

local function proMaxStages()
	return Ultimate.IsPro and 200 or 40
end

local function clampConfigForLicense()
	if Config.Stages > proMaxStages() then
		Config.Stages = proMaxStages()
	end

	if not Ultimate.IsPro then
		Config.ThemeName = "Neon"
		Config.Monetization = false
	end
end

local function safeGetAsync(key)
	local ok, result = pcall(function()
		return SaveStore:GetAsync(key)
	end)
	if ok then return result end
	return nil
end

local function safeSetAsync(key, value)
	pcall(function()
		SaveStore:SetAsync(key, value)
	end)
end

local function savePlayer(player)
	local s = player:FindFirstChild("leaderstats")
	if not s then return end

	local payload = {
		Coins = s:FindFirstChild("Coins") and s.Coins.Value or 0,
		Gems = s:FindFirstChild("Gems") and s.Gems.Value or 0,
		Wins = s:FindFirstChild("Wins") and s.Wins.Value or 0,
		Level = s:FindFirstChild("Level") and s.Level.Value or 1,
		BestTime = s:FindFirstChild("BestTime") and s.BestTime.Value or 999999,
		Purchases = {
			DoubleCoins = player:GetAttribute("AIO_DoubleCoins") == true,
			VIPTrail = player:GetAttribute("AIO_VIPTrail") == true,
		}
	}

	safeSetAsync("u_" .. player.UserId, payload)
end

local function loadPlayer(player)
	local data = safeGetAsync("u_" .. player.UserId)
	if not data then return end

	local s = player:FindFirstChild("leaderstats")
	if not s then return end

	if s:FindFirstChild("Coins") then s.Coins.Value = data.Coins or 0 end
	if s:FindFirstChild("Gems") then s.Gems.Value = data.Gems or 0 end
	if s:FindFirstChild("Wins") then s.Wins.Value = data.Wins or 0 end
	if s:FindFirstChild("Level") then s.Level.Value = data.Level or 1 end
	if s:FindFirstChild("BestTime") then s.BestTime.Value = data.BestTime or 999999 end

	if data.Purchases then
		player:SetAttribute("AIO_DoubleCoins", data.Purchases.DoubleCoins == true)
		player:SetAttribute("AIO_VIPTrail", data.Purchases.VIPTrail == true)
	end
end

Players.PlayerRemoving:Connect(savePlayer)
game:BindToClose(function()
	for _, p in ipairs(Players:GetPlayers()) do
		savePlayer(p)
	end
end)

Players.PlayerAdded:Connect(function(player)
	task.delay(2, function()
		loadPlayer(player)
	end)
end)

local function addTrail(player)
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	if root:FindFirstChild("AIO_Trail") then return end

	local a0 = Instance.new("Attachment", root)
	local a1 = Instance.new("Attachment", root)
	a0.Position = Vector3.new(0,1,0)
	a1.Position = Vector3.new(0,-1,0)

	local tr = Instance.new("Trail")
	tr.Name = "AIO_Trail"
	tr.Attachment0 = a0
	tr.Attachment1 = a1
	tr.Lifetime = 0.4
	tr.Parent = root
end

local function fireworks(pos)
	for i = 1, 6 do
		local p = Instance.new("Part")
		p.Name = PREFIX .. "Firework"
		p.Anchored = true
		p.CanCollide = false
		p.Transparency = 1
		p.Position = pos + Vector3.new(math.random(-8,8), math.random(0,8), math.random(-8,8))
		p.Parent = S.Workspace

		local emitter = Instance.new("ParticleEmitter")
		emitter.Rate = 0
		emitter.Speed = NumberRange.new(18, 28)
		emitter.Lifetime = NumberRange.new(1, 2)
		emitter.SpreadAngle = Vector2.new(360,360)
		emitter.Parent = p
		emitter:Emit(40)

		game:GetService("Debris"):AddItem(p, 3)
	end
end

local function playChime(parent)
	local s = Instance.new("Sound")
	s.Name = PREFIX .. "Chime"
	s.SoundId = "rbxassetid://6026984224"
	s.Volume = 0.5
	s.Parent = parent
	s:Play()
	game:GetService("Debris"):AddItem(s, 4)
end

local function animatedSign(obj, text)
	label(obj, text)
	local gui = obj:FindFirstChild(PREFIX .. "Label")
	if not gui then return end
	local t = gui:FindFirstChildOfClass("TextLabel")
	if not t then return end

	task.spawn(function()
		local hue = 0
		while t.Parent do
			hue += 0.01
			t.TextColor3 = Color3.fromHSV(hue % 1, 1, 1)
			task.wait()
		end
	end)
end

local function showOnboarding()
	local lines = {
		"AI OBBY PRO - QUICK START",
		"",
		"1. Choose preset or custom settings.",
		"2. Click GENERATE.",
		"3. Press Play to test.",
		"4. Create gamepasses in Creator Dashboard.",
		"5. Tune rewards after first playtest.",
		"6. Publish with icon + thumbnail.",
		"",
		"Suggested Products:",
		"- Skip Stage",
		"- Revive",
		"- 2x Coins",
		"- VIP Trail",
		"- Speed Boost",
	}

	local existing = S.ReplicatedStorage:FindFirstChild(PREFIX .. "Onboarding")
	if existing then existing:Destroy() end

	local v = Instance.new("StringValue")
	v.Name = PREFIX .. "Onboarding"
	v.Value = table.concat(lines, "\\n")
	v.Parent = S.ReplicatedStorage
end
'''

if "ULTIMATE PATCH MODULES" not in code:
    # inject after Config block if possible
    marker = "local function clearService(service)"
    code = code.replace(marker, inject + "\n" + marker)

# Hook build start
code = code.replace(
"""local function build()
\tclear()
\tapplyTheme(Config.ThemeName)""",
"""local function build()
\tclampConfigForLicense()
\tclear()
\tapplyTheme(Config.ThemeName)"""
)

# Add onboarding hook after setupUI
code = code.replace(
"""setupUI()""",
"""setupUI()
\tshowOnboarding()""",
1
)

# Enhance finish reward block if present
code = code.replace(
"""label(finish, "FINISH")""",
"""animatedSign(finish, "FINISH")"""
)

# Add fireworks near end warning
code = code.replace(
"""warn("AI Obby Generator Pro built premium obby.")""",
"""fireworks(finish.Position)
\tplayChime(finish)
\twarn("AI Obby Generator Pro Ultimate built premium obby.")"""
)

dst.write_text(code, encoding="utf-8")
print("Wrote:", dst)
PY

echo "✅ Built Ultimate plugin:"
echo "$PATCHED"
