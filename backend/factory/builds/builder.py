import os, json

ROOT = os.path.expanduser("~/game-factory-ai/roblox_project/generated")

def build_game(idea):

    name = idea["name"].replace(" ", "_")

    path = os.path.join(ROOT, name)
    os.makedirs(path + "/server", exist_ok=True)

    # basic world
    with open(path + "/world.lua", "w") as f:
        f.write("""
local Workspace = game:GetService("Workspace")

for i = 1, 20 do
    local p = Instance.new("Part")
    p.Size = Vector3.new(10,1,10)
    p.Position = Vector3.new(i*10, 5, 0)
    p.Anchored = true
    p.Parent = Workspace
end
""")

    # metadata
    with open(path + "/meta.json", "w") as f:
        json.dump(idea, f)

    return path
