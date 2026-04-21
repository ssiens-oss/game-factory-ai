import random

class GenerationRules:

    def __init__(self):
        self.max_gap_size = 3
        self.coin_density = 0.5
        self.allow_vertical_skips = False

    def apply(self, scene: dict):

        # enforce anti-skip constraint
        if not self.allow_vertical_skips:
            for obj in scene.get("obstacles", []):
                obj["y"] = min(obj.get("y", 1), 1)

        # control density
        if len(scene.get("coins", [])) > 20:
            scene["coins"] = scene["coins"][:20]

        return scene

    def mutate_from_failure(self, failure_type: str):

        # rule evolution logic
        if failure_type == "skip_exploit":
            self.allow_vertical_skips = False

        if failure_type == "economy_abuse":
            self.coin_density *= 0.9

        if failure_type == "boundary_skip":
            self.max_gap_size = max(1, self.max_gap_size - 1)
