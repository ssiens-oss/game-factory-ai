local HttpService = game:GetService("HttpService")
local toolbar = plugin:CreateToolbar("Game Factory SaaS")

local verifyButton = toolbar:CreateButton(
    "Verify License",
    "Verify your Game Factory SaaS license",
    "rbxassetid://4458901886"
)

local generateButton = toolbar:CreateButton(
    "Cloud Obby",
    "Generate an obby from the SaaS backend",
    "rbxassetid://4458901886"
)

local API_BASE = "http://127.0.0.1:8111"
local LICENSE_KEY = "FOUNDER-PRO"

local function post(path, body)
    local json = HttpService:JSONEncode(body)

    local ok, result = pcall(function()
        return HttpService:PostAsync(
            API_BASE .. path,
            json,
            Enum.HttpContentType.ApplicationJson
        )
    end)

    if not ok then
        warn("Game Factory API error:", result)
        return nil
    end

    return HttpService:JSONDecode(result)
end

verifyButton.Click:Connect(function()
    local res = post("/api/license/verify", {
        license_key = LICENSE_KEY,
        plugin_version = "0.1.0",
    })

    if not res then return end

    print("License valid:", res.valid)
    print("Plan:", res.plan)
end)

generateButton.Click:Connect(function()
    local res = post("/api/generate/obby", {
        license_key = LICENSE_KEY,
        theme = "Cyber",
        stages = 50,
        difficulty = "medium",
    })

    if not res or not res.lua then
        warn("No generated Lua returned.")
        return
    end

    local scriptObj = Instance.new("Script")
    scriptObj.Name = "GF_CloudGeneratedObby"
    scriptObj.Source = res.lua
    scriptObj.Parent = game.ServerScriptService

    print("Cloud obby inserted.")
end)
