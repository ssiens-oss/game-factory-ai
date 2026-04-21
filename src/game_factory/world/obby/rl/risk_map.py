import math


class RiskMap:
    """
    Converts obby layout into a hazard-aware cost field.
    """

    def build(self, level):

        grid = {}

        for p in level["platforms"]:
            grid[(p["x"], p["y"])] = 0.1  # safe base

        for h in level["hazards"]:

            key = (h["x"], h["y"])

            if h["type"] == "KillBlock":
                grid[key] = 1.0

            elif h["type"] == "MovingPlatform":
                grid[key] = 0.6

            elif h["type"] == "RotatingHazard":
                grid[key] = 0.8

        return grid
