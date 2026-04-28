#!/usr/bin/env bash
set -e

PLUGIN="$PWD/sellable_plugins/AIObbyGeneratorPro.lua"

if [ ! -f "$PLUGIN" ]; then
  echo "ERROR: Missing $PLUGIN"
  exit 1
fi

cp "$PLUGIN" "$PLUGIN.bak_panel"

python3 - "$PLUGIN" <<'PY'
from pathlib import Path
import sys

p = Path(sys.argv[1])
code = p.read_text(encoding="utf-8", errors="ignore")

# Rename old button text
code = code.replace(
'''local buildBtn = toolbar:CreateButton("Build Pro Obby", "Generate premium obby", "")''',
'''local buildBtn = toolbar:CreateButton("Quick Build", "Generate premium obby with current defaults", "")
local panelBtn = toolbar:CreateButton("Control Panel", "Open AI Obby Pro control panel", "")'''
)

# Add pro config globals after Config table
code = code.replace(
'''local Config = {
	Stages = 120,
	Gap = 11,
	CheckpointEvery = 8,
	CoinEvery = 4,
}''',
'''local Config = {
	Stages = 120,
	Gap = 11,
	CheckpointEvery = 8,
	CoinEvery = 4,
	Difficulty = "Normal",
	HazardDensity = "Medium",
	ThemeName = "Neon",
	Monetization = true,
	MobileUI = true,
}

local Presets = {
	Themes = {"Neon", "Lava", "Ice", "Cyber", "Toxic"},
	Difficulties = {"Easy", "Normal", "Hard", "Insane"},
	HazardDensities = {"Low", "Medium", "High"},
	StageOptions = {40, 80, 120, 160, 200},
}

local function applyTheme(name)
	Config.ThemeName = name or Config.ThemeName

	if Config.ThemeName == "Lava" then
		Theme.Primary = Color3.fromRGB(255, 90, 0)
		Theme.Secondary = Color3.fromRGB(255, 30, 0)
		Theme.Accent = Color3.fromRGB(255, 210, 0)
		Theme.Danger = Color3.fromRGB(255, 0, 0)
		Theme.Boost = Color3.fromRGB(255, 150, 0)
	elseif Config.ThemeName == "Ice" then
		Theme.Primary = Color3.fromRGB(120, 230, 255)
		Theme.Secondary = Color3.fromRGB(180, 240, 255)
		Theme.Accent = Color3.fromRGB(230, 255, 255)
		Theme.Danger = Color3.fromRGB(0, 120, 255)
		Theme.Boost = Color3.fromRGB(180, 255, 255)
	elseif Config.ThemeName == "Cyber" then
		Theme.Primary = Color3.fromRGB(0, 255, 255)
		Theme.Secondary = Color3.fromRGB(255, 0, 255)
		Theme.Accent = Color3.fromRGB(255, 255, 0)
		Theme.Danger = Color3.fromRGB(255, 0, 90)
		Theme.Boost = Color3.fromRGB(0, 255, 120)
	elseif Config.ThemeName == "Toxic" then
		Theme.Primary = Color3.fromRGB(80, 255, 0)
		Theme.Secondary = Color3.fromRGB(180, 255, 0)
		Theme.Accent = Color3.fromRGB(255, 255, 60)
		Theme.Danger = Color3.fromRGB(120, 255, 0)
		Theme.Boost = Color3.fromRGB(0, 255, 80)
	else
		Theme.Primary = Color3.fromRGB(0, 210, 255)
		Theme.Secondary = Color3.fromRGB(255, 70, 210)
		Theme.Accent = Color3.fromRGB(255, 220, 0)
		Theme.Danger = Color3.fromRGB(255, 45, 35)
		Theme.Boost = Color3.fromRGB(0, 255, 130)
	end
end

local function hazardModulo()
	if Config.HazardDensity == "Low" then return 16 end
	if Config.HazardDensity == "High" then return 8 end
	return 12
end

local function difficultyScale()
	if Config.Difficulty == "Easy" then return 0.75 end
	if Config.Difficulty == "Hard" then return 1.35 end
	if Config.Difficulty == "Insane" then return 1.8 end
	return 1
end'''
)

# Replace build start to apply theme and scale
code = code.replace(
'''local function build()
	clear()
	setupLighting()
	setupRuntime()
	setupUI()''',
'''local function build()
	clear()
	applyTheme(Config.ThemeName)
	setupLighting()
	setupRuntime()
	setupUI()'''
)

# Stage loop uses Config.Stages already; patch h modulo
code = code.replace(
'''local h = i % 12''',
'''local h = i % hazardModulo()'''
)

# Patch platform gap/difficulty scaling lightly
code = code.replace(
'''local y = 5 + math.sin(i * .5) * 3 + math.floor(i / 25) * 5''',
'''local y = 5 + math.sin(i * .5) * (3 * difficultyScale()) + math.floor(i / 25) * (5 * difficultyScale())'''
)

# Add panel before button connections
panel = r'''

local panelWidget

local function cycleValue(list, current)
	local idx = 1
	for i, v in ipairs(list) do
		if v == current then idx = i break end
	end
	idx += 1
	if idx > #list then idx = 1 end
	return list[idx]
end

local function makePanel()
	local info = DockWidgetPluginGuiInfo.new(
		Enum.InitialDockState.Float,
		true,
		false,
		330,
		430,
		300,
		360
	)

	local widget = plugin:CreateDockWidgetPluginGui("AIObbyGeneratorProPanel", info)
	widget.Title = "AI Obby Generator Pro"

	local root = Instance.new("Frame")
	root.Size = UDim2.fromScale(1,1)
	root.BackgroundColor3 = Theme.Panel
	root.BorderSizePixel = 0
	root.Parent = widget

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1,-20,0,38)
	title.Position = UDim2.fromOffset(10,8)
	title.BackgroundTransparency = 1
	title.Text = "AI Obby Generator Pro"
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 20
	title.TextColor3 = Color3.new(1,1,1)
	title.Parent = root

	local subtitle = Instance.new("TextLabel")
	subtitle.Size = UDim2.new(1,-20,0,24)
	subtitle.Position = UDim2.fromOffset(10,44)
	subtitle.BackgroundTransparency = 1
	subtitle.Text = "Configure. Generate. Sell-ready obby."
	subtitle.Font = Enum.Font.Gotham
	subtitle.TextSize = 13
	subtitle.TextColor3 = Color3.fromRGB(200,210,230)
	subtitle.Parent = root

	local function makeButton(y, labelText, getText, onClick)
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(1,-20,0,18)
		label.Position = UDim2.fromOffset(10,y)
		label.BackgroundTransparency = 1
		label.Text = labelText
		label.Font = Enum.Font.GothamBold
		label.TextSize = 12
		label.TextColor3 = Color3.fromRGB(210,220,240)
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = root

		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1,-20,0,32)
		b.Position = UDim2.fromOffset(10,y+20)
		b.BackgroundColor3 = Theme.Primary
		b.BorderSizePixel = 0
		b.Text = getText()
		b.Font = Enum.Font.GothamBold
		b.TextSize = 14
		b.TextColor3 = Color3.new(1,1,1)
		b.Parent = root

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0,8)
		corner.Parent = b

		b.MouseButton1Click:Connect(function()
			onClick()
			b.Text = getText()
		end)

		return b
	end

	makeButton(82, "Theme", function()
		return Config.ThemeName
	end, function()
		Config.ThemeName = cycleValue(Presets.Themes, Config.ThemeName)
		applyTheme(Config.ThemeName)
	end)

	makeButton(140, "Difficulty", function()
		return Config.Difficulty
	end, function()
		Config.Difficulty = cycleValue(Presets.Difficulties, Config.Difficulty)
	end)

	makeButton(198, "Stage Count", function()
		return tostring(Config.Stages) .. " stages"
	end, function()
		local current = Config.Stages
		local idx = 1
		for i, v in ipairs(Presets.StageOptions) do
			if v == current then idx = i break end
		end
		idx += 1
		if idx > #Presets.StageOptions then idx = 1 end
		Config.Stages = Presets.StageOptions[idx]
	end)

	makeButton(256, "Hazard Density", function()
		return Config.HazardDensity
	end, function()
		Config.HazardDensity = cycleValue(Presets.HazardDensities, Config.HazardDensity)
	end)

	local monetization = makeButton(314, "Monetization Hooks", function()
		return Config.Monetization and "Enabled" or "Disabled"
	end, function()
		Config.Monetization = not Config.Monetization
	end)

	local generate = Instance.new("TextButton")
	generate.Size = UDim2.new(.5,-15,0,38)
	generate.Position = UDim2.new(0,10,1,-48)
	generate.BackgroundColor3 = Theme.Boost
	generate.BorderSizePixel = 0
	generate.Text = "GENERATE"
	generate.Font = Enum.Font.GothamBlack
	generate.TextSize = 15
	generate.TextColor3 = Color3.new(1,1,1)
	generate.Parent = root
	Instance.new("UICorner", generate).CornerRadius = UDim.new(0,10)
	generate.MouseButton1Click:Connect(build)

	local clearButton = Instance.new("TextButton")
	clearButton.Size = UDim2.new(.5,-15,0,38)
	clearButton.Position = UDim2.new(.5,5,1,-48)
	clearButton.BackgroundColor3 = Theme.Danger
	clearButton.BorderSizePixel = 0
	clearButton.Text = "CLEAR"
	clearButton.Font = Enum.Font.GothamBlack
	clearButton.TextSize = 15
	clearButton.TextColor3 = Color3.new(1,1,1)
	clearButton.Parent = root
	Instance.new("UICorner", clearButton).CornerRadius = UDim.new(0,10)
	clearButton.MouseButton1Click:Connect(clear)

	return widget
end

local function togglePanel()
	if not panelWidget then
		panelWidget = makePanel()
	else
		panelWidget.Enabled = not panelWidget.Enabled
	end
end
'''

code = code.replace(
'''buildBtn.Click:Connect(build)
clearBtn.Click:Connect(clear)''',
panel + '''
panelBtn.Click:Connect(togglePanel)
buildBtn.Click:Connect(build)
clearBtn.Click:Connect(clear)'''
)

p.write_text(code, encoding="utf-8")
print("✅ Patched control panel:", p)
PY

echo "✅ AI Obby Pro control panel patched"
echo "Backup: $PLUGIN.bak_panel"
