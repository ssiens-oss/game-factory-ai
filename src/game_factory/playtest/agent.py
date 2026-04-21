import random

class PlaytestAgent:
    """
    Simple autonomous agent for obby-style navigation.
    """

    def __init__(self):
        self.position = {"x": 0, "y": 1, "z": 0}
        self.alive = True
        self.progress = 0

    def decide_move(self, scene):
        """
        Chooses next action based on local heuristics.
        """

        platforms = scene.get("platforms", [])

        # simple forward bias + occasional jump
        move = {
            "dx": random.choice([1, 2]),
            "dy": random.choice([0, 1]) if random.random() > 0.7 else 0
        }

        return move

    def apply_move(self, move):
        if not self.alive:
            return

        self.position["x"] += move["dx"]
        self.position["y"] += move["dy"]

        # simulate fall risk
        if self.position["y"] < 0:
            self.alive = False
