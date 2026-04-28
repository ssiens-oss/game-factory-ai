#!/usr/bin/env python3

from snapshot_engine import commit

def generate_world(difficulty):
    return f"""
local Workspace = game:GetService("Workspace")

Workspace:ClearAllChildren()

for i = 1, {int(20 + difficulty * 20)} do
    local p = Instance.new("Part")
    p.Size = Vector3.new(10,1,10)
    p.Position = Vector3.new(i*10, 5, 0)
    p.Anchored = true
    p.Parent = Workspace
end
"""

def generate_logic():
    return """
game.Players.PlayerAdded:Connect(function(p)
    print("Player:", p.Name)
end)
"""

def step(difficulty):
    files = {
        "worlds/main.lua": generate_world(difficulty),
        "server/Game.lua": generate_logic()
    }

    rl_meta = {
        "difficulty": difficulty,
        "economy": 0.5 + difficulty * 0.1
    }

    commit(files, rl_meta)

if __name__ == "__main__":
    step(1.2)
