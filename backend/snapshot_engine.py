#!/usr/bin/env python3

import os, json, time, shutil

ROOT = os.path.expanduser("~/game-factory-ai/roblox_project/src")
SNAP = os.path.expanduser("~/game-factory-ai/snapshots")

def write_file(path, content):
    full = os.path.join(ROOT, path)
    os.makedirs(os.path.dirname(full), exist_ok=True)
    with open(full, "w") as f:
        f.write(content)

def load_snapshot(path):
    with open(path, "r") as f:
        return json.load(f)

def apply_snapshot(snapshot):
    for path, content in snapshot["files"].items():
        write_file(path, content)

def save_snapshot(snapshot):
    os.makedirs(SNAP, exist_ok=True)
    version = snapshot["version"]
    path = os.path.join(SNAP, f"snapshot_{version}.json")
    with open(path, "w") as f:
        json.dump(snapshot, f, indent=2)

def rollback(version):
    path = os.path.join(SNAP, f"snapshot_{version}.json")
    snap = load_snapshot(path)
    apply_snapshot(snap)
    print(f"🔁 Rolled back to v{version}")

def commit(files, rl_meta):
    version = int(time.time())

    snapshot = {
        "version": version,
        "timestamp": version,
        "files": files,
        "rl_meta": rl_meta
    }

    save_snapshot(snapshot)
    apply_snapshot(snapshot)

    print(f"✅ committed snapshot v{version}")

if __name__ == "__main__":
    print("Snapshot engine ready")
