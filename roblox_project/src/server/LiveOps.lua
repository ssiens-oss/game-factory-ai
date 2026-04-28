local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local STATE = {
    revive_price = 1,
    difficulty = 1
}

-- simulate polling your local RL server
task.spawn(function()
    while true do
        -- in production, replace with real endpoint
        print("🧠 current state:", STATE)

        workspace.Gravity = 196.2 * STATE.difficulty

        task.wait(3)
    end
end)

-- expose hook
_G.APPLY_PATCH = function(patch)
    for k, v in pairs(patch) do
        STATE[k] = v
    end
end
