import json


class UnityObbyExporter:

    def export(self, level, path="unity_obby.json"):

        with open(path, "w") as f:
            json.dump(level, f, indent=2)

        print("✔ exported:", path)
