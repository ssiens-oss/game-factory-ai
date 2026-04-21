import json
import os


class UnityObbyExporter:
    """
    Converts generated obby level → Unity JSON scene format.
    """

    def export(self, level: dict, output_path: str):

        unity_scene = {
            "platforms": [
                {"x": p["x"], "y": p.get("y", 0), "z": p.get("z", 0)}
                for p in level.get("platforms", [])
            ],
            "hazards": level.get("hazards", []),
            "spawn": level.get("spawn", {"x": 0, "y": 1, "z": 0}),
            "goal": level.get("goal", {"x": 10, "y": 1, "z": 0})
        }

        os.makedirs(os.path.dirname(output_path), exist_ok=True)

        with open(output_path, "w") as f:
            json.dump(unity_scene, f, indent=2)

        return output_path
