import random

class BaseAgent:
    def __init__(self, name):
        self.name = name
        self.position = {"x": 0, "y": 1}
        self.alive = True
        self.steps = 0

    def act(self, scene):
        raise NotImplementedError


class Speedrunner(BaseAgent):
    def act(self, scene):
        return {"dx": 3, "dy": 0}


class Explorer(BaseAgent):
    def act(self, scene):
        return {
            "dx": random.choice([1, 2]),
            "dy": random.choice([0, 1])
        }


class RiskTaker(BaseAgent):
    def act(self, scene):
        return {
            "dx": random.choice([2, 4]),
            "dy": random.choice([0, 2])  # aggressive jumps
        }


class CasualPlayer(BaseAgent):
    def act(self, scene):
        return {
            "dx": 1,
            "dy": 0
        }


def create_population():
    return [
        Speedrunner("speedrunner"),
        Explorer("explorer"),
        RiskTaker("risk_taker"),
        CasualPlayer("casual")
    ]
