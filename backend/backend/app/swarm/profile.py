import random

class Agent:
    def __init__(self, i, style):
        self.style = style
        self.skill = random.uniform(0.3, 1.0)

    def simulate(self, build):
        base = 0.6
        bias = {"casual": -0.1, "speedrunner": 0.2, "explorer": 0.0, "exploiter": 0.3}[self.style]

        success = self.skill - base + bias
        completed = random.random() < (success + 0.5)

        return {
            "completed": completed,
            "exploited": self.style == "exploiter" and random.random() < 0.2,
            "time": random.uniform(30, 600)
        }
