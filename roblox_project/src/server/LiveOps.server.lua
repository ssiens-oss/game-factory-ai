local HttpService = game:GetService("HttpService")

local PATCH_URL = "http://127.0.0.1:8010/state"

local STATE = {
    difficulty = 1,
    revive_price = 1
}

local function applyPatch(patch)
    if patch.difficulty then
        STATE.difficulty = patch.difficulty
        workspace.Gravity = 196.2 * patch.difficulty
    end

    if patch.revive_price then
        STATE.revive_price = patch.revive_price
    end

    print("🧠 Applied Patch:", HttpService:JSONEncode(STATE))
end

task.spawn(function()
    while true do
        local success, result = pcall(function()
            return HttpService:GetAsync(PATCH_URL)
        end)

        if success then
            local data = HttpService:JSONDecode(result)
            applyPatch(data)
        else
            warn("⚠️ Patch fetch failed:", result)
        end

        task.wait(2)
    end
end)
