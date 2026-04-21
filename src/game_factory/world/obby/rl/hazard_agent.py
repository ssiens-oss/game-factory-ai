from game_factory.world.obby.rl.risk_map import RiskMap
from game_factory.world.obby.rl.pathfinder import HazardAwarePathfinder


class HazardAwareAgent:
    """
    Evaluates obby risk exposure via pathfinding.
    """

    def __init__(self):
        self.risk_map = RiskMap()

    def evaluate_level(self, level):

        risk = self.risk_map.build(level)

        nodes = [
            (p["x"], p["y"])
            for p in level["platforms"]
        ]

        start = nodes[0]
        goal = nodes[-1]

        pathfinder = HazardAwarePathfinder(risk)

        path = pathfinder.find_path(
            start,
            goal,
            nodes
        )

        risk_score = sum(
            risk.get(n, 0.1) for n in path
        ) / max(len(path), 1)

        return {
            "path": path,
            "risk_exposure": risk_score
        }
