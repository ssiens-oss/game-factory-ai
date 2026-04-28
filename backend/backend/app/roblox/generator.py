import json
import os

OUTPUT_DIR = "roblox_project/src"

def generate_lua_game(spec):
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    # main server script
    with open(f"{OUTPUT_DIR}/Main.server.lua", "w") as f:
        f.write(build_main_script(spec))

    # obby generator
    with open(f"{OUTPUT_DIR}/ObbyGenerator.lua", "w") as f:
        f.write(build_obby(spec))

    return {"status": "lua_generated", "path": OUTPUT_DIR}


def build_main_script(spec):
    return f"""
print("Starting Game: {spec['name']}")

local generator = require(script.Parent.ObbyGenerator)
generator.build()
"""


def build_obby(spec):
    return """
local module = {}

function module.build()
    local Workspace = game:GetService("Workspace")

    for i = 1, 20 do
        local part = Instance.new("Part")
        part.Size = Vector3.new(10,1,10)
        part.Position = Vector3.new(0, i * 5, 0)
        part.Anchored = true
        part.Parent = Workspace
    end
end

return module
"""
