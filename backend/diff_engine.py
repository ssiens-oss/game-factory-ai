#!/usr/bin/env python3

import os, time, json

ROOT = os.path.expanduser("~/game-factory-ai/roblox_project/src")

def write(path, content):
    full = os.path.join(ROOT, path)
    os.makedirs(os.path.dirname(full), exist_ok=True)
    with open(full, "w") as f:
        f.write(content)

def apply_add(item):
    if item["type"] == "platform":
        return f"""
local p = Instance.new("Part")
p.Size = Vector3.new(10,1,10)
p.Position = Vector3.new({item.get('pos',[0,5,0])[0]},5,0)
p.Anchored = true
p.Parent = workspace
"""
    return ""

def apply_patch(meta):
    return f"-- updated meta: {json.dumps(meta)}\n"

def apply_diff(diff):
    print("⚙️ applying diff")

    if "patch" in diff:
        write("meta/state.lua", apply_patch(diff["patch"]))

    if "add" in diff:
        existing = ""
        for item in diff["add"]:
            existing += apply_add(item)

        write("worlds/delta.lua", existing)

    print("✅ diff applied")

if __name__ == "__main__":
    demo = {
        "add": [{"type": "platform", "pos": [10,5,0]}],
        "patch": {"difficulty": 1.2}
    }

    apply_diff(demo)
