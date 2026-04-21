import random

class ExploitAgent:
    def __init__(self, name):
        self.name = name
        self.position = {"x": 0, "y": 1}
        self.alive = True

    def act(self, scene):
        raise NotImplementedError


class SkipPathFinder(ExploitAgent):
    """
    Tries to jump directly to finish (sequence break).
    """

    def act(self, scene):
        finish = scene.get("finish", {"x": 50})

        return {
            "dx": min(10, finish["x"] - self.position["x"]),
            "dy": 2  # aggressive vertical skipping
        }


class BoundaryBreaker(ExploitAgent):
    """
    Attempts to fall, clip, or escape bounds.
    """

    def act(self, scene):
        return {
            "dx": random.choice([5, 7, 10]),
            "dy": random.choice([-2, 3])  # fall/climb abuse
        }


class EconomyAbuser(ExploitAgent):
    """
    Tries to farm coins infinitely or cluster them.
    """

    def act(self, scene):
        return {
            "dx": random.randint(1, 5),
            "dy": 0
        }


def create_adversaries():
    return [
        SkipPathFinder("skip"),
        BoundaryBreaker("break"),
        EconomyAbuser("farm")
    ]
