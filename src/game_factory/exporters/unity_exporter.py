import json
import os


def export_to_unity(scene, output_dir="unity_project/Assets/Generated"):

    os.makedirs(output_dir, exist_ok=True)

    unity_scene = {
        "spawn": scene["spawn"],
        "finish": scene["finish"],
        "platforms": scene["platforms"],
        "coins": scene["coins"],
        "obstacles": scene["obstacles"],
        "checkpoints": scene["checkpoints"]
    }

    path = os.path.join(output_dir, "scene.json")

    with open(path, "w") as f:
        json.dump(unity_scene, f, indent=2)

    return {
        "status": "exported",
        "path": path
    }
