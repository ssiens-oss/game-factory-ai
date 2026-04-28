import random

class Agent:
    STYLES = {"casual": -0.1, "speedrunner": 0.2, "explorer": 0.0, "exploiter": 0.3}

    def __init__(self, i, style):
        self.style = style
        self.skill = random.uniform(0.3, 1.0)

    def simulate(self, build):
        diff = build["spec"].get("difficulty", 1.0)
        base = 0.5 + diff * 0.1
        bias = self.STYLES[self.style]
        p = self.skill - base + bias
        return {
            "completed": random.random() < max(0.05, min(0.95, p + 0.5)),
            "exploited":  self.style == "exploiter" and random.random() < 0.2,
            "time":       random.uniform(30, 600)
        }
