import os

ROOT = os.path.expanduser("~/game-factory-ai/roblox_project/src")

def write(path, content):
    full = os.path.join(ROOT, path)
    os.makedirs(os.path.dirname(full), exist_ok=True)
    with open(full, "w") as f:
        f.write(content)

def world():
    return """
local Workspace = game:GetService("Workspace")

Workspace:ClearAllChildren()

for i = 1, 30 do
    local p = Instance.new("Part")
    p.Size = Vector3.new(10,1,10)
    p.Position = Vector3.new(i*10, 5, 0)
    p.Anchored = true
    p.Parent = Workspace
end
"""

def game_logic():
    return """
game.Players.PlayerAdded:Connect(function(p)
    print("Player joined:", p.Name)
end)
"""

def run():
    print("🚀 Generating Roblox game...")

    write("worlds/main.lua", world())
    write("server/Game.lua", game_logic())

    print("✅ Done. Rojo will auto-sync to Studio.")

if __name__ == "__main__":
    run()
