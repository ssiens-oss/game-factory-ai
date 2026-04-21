import random


class ObbyGenerator:

    def generate(self, rules=None):
        rules = rules or {}

        platforms = []
        x = 0

        for i in range(10):
            platforms.append({"x": x, "y": 0, "z": 0})
            x += random.randint(3, 6)

        return {
            "platforms": platforms,
            "hazards": [],
            "spawn": {"x": 0, "y": 1, "z": 0},
            "goal": {"x": x, "y": 1, "z": 0}
        }
